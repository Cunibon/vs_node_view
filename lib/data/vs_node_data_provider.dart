import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_manager.dart';

typedef VSNodeDataBuilder = VSNodeData Function(Offset, VSOutputData?);

///Small data class to keep track of where the context menu is in 2D space
///
///Also knows if it was opend through a reference
class ContextMenuContext {
  ContextMenuContext({
    required this.offset,
    this.reference,
  });

  Offset offset;
  VSOutputData? reference;
}

class VSNodeDataProvider extends ChangeNotifier {
  ///Wraps VSNodeManager to allow UI interaction and updates
  VSNodeDataProvider({
    required List<dynamic> nodeBuilders,
    String? serializedNodes,
  }) {
    nodeManger = VSNodeManager(
      nodeBuilders: nodeBuilders,
      serializedNodes: serializedNodes,
    );
  }

  ///Instance of [VSNodeManager] created on initialization
  ///
  ///Holds all the data and is used as an "API" to modify data
  late VSNodeManager nodeManger;

  ///A map of all nodeBuilders can be used to build a context menu.
  ///
  ///Is in this format:
  ///
  ///{
  /// Subgroup:{
  ///   nodeName: NodeBuilder
  /// },
  /// nodeName: NodeBuilder
  ///}
  Map<String, dynamic> get nodeBuildersMap => nodeManger.nodeBuildersMap;

  ///Node data map in this format: {NodeData.id: NodeData}
  Map<String, VSNodeData> get nodes => nodeManger.nodes;

  ///Updates existing nodes or creates them
  ///
  ///Notifies listeners to this provider
  void updateOrCreateNodes(List<VSNodeData> nodeDatas) async {
    nodeManger.updateOrCreateNodes(nodeDatas);
    notifyListeners();
  }

  ///Used to move one or mulitple nodes
  ///
  ///Offset will be applied to all nodes based on the offset from the moved nodes original position
  void moveNode(VSNodeData nodeData, Offset offset) {
    final movedOffset = applyViewPortTransfrom(offset) - nodeData.widgetOffset;

    final List<VSNodeData> modifiedNodes = [];

    if (selectedNodes.contains(nodeData.id)) {
      for (final nodeId in selectedNodes) {
        final currentNode = nodes[nodeId]!;
        modifiedNodes.add(
          currentNode..widgetOffset = currentNode.widgetOffset + movedOffset,
        );
      }
    } else {
      modifiedNodes.add(
        nodeData..widgetOffset = nodeData.widgetOffset + movedOffset,
      );
    }

    updateOrCreateNodes(modifiedNodes);
  }

  ///Removes a node
  ///
  ///Notifies listeners to this provider
  void removeNode(VSNodeData nodeData) async {
    nodeManger.removeNode(nodeData);
    notifyListeners();
  }

  ///Creates a node based on the builder and the current [_contextMenuContext]
  ///
  ///Notifies listeners to this provider
  void createNodeFromContext(VSNodeDataBuilder builder) {
    updateOrCreateNodes(
      [
        builder(
          _contextMenuContext!.offset,
          _contextMenuContext!.reference,
        )
      ],
    );
  }

  ///Set of currently selected node ids
  Set<String> get selectedNodes => _selectedNodes;
  Set<String> _selectedNodes = {};

  set selectedNodes(Set<String> data) {
    _selectedNodes = Set.from(data);
    notifyListeners();
  }

  ///Adds an [Iterable] of type [String] to the currently selected nodes
  void addSelectedNodes(Iterable<String> data) {
    selectedNodes = selectedNodes..addAll(data);
  }

  ///Removes an [Iterable] of type [String] from the currently selected nodes
  void removeSelectedNodes(Iterable<String> data) {
    selectedNodes = selectedNodes
        .where(
          (element) => !data.contains(element),
        )
        .toSet();
  }

  ///Returns a set of all nodes that fall into the are between the supplied start and end
  Set<VSNodeData> findNodesInsideSelectionArea(Offset start, Offset end) {
    final Set<VSNodeData> inside = {};
    for (final node in nodeManger.nodes.values) {
      final pos = node.widgetOffset;
      if (pos.dy > start.dy &&
          pos.dx > start.dx &&
          pos.dy < end.dy &&
          pos.dx < end.dx) {
        inside.add(node);
      }
    }
    return inside;
  }

  ContextMenuContext? _contextMenuContext;
  ContextMenuContext? get contextMenuContext => _contextMenuContext;

  ///Used to offset the UI by a given value
  ///
  ///Usefull if you want to wrap [VSNodeView] in an [InteractiveViewer] or the sorts,
  ///to assure context menu and node interactions work as planned
  Offset viewportOffset = Offset.zero;

  ///Used to offset the UI by a given value
  ///
  ///Usefull if you want to wrap [VSNodeView] in an [InteractiveViewer] or the sorts,
  ///to assure context menu and node interactions work as planned
  double viewportScale = 1;

  ///Helper function to apply [viewportOffset] and [viewportScale] to a Offset
  Offset applyViewPortTransfrom(Offset inital) =>
      (inital - viewportOffset) * viewportScale;

  ///Opens the context menu at a given postion
  ///
  ///If the context menu was opened through a reference it will also be passed
  void openContextMenu({
    required Offset position,
    VSOutputData? outputData,
  }) {
    _contextMenuContext = ContextMenuContext(
      offset: applyViewPortTransfrom(position),
      reference: outputData,
    );
    notifyListeners();
  }

  ///Closes the context menu
  void closeContextMenu() {
    _contextMenuContext = null;
    notifyListeners();
  }
}
