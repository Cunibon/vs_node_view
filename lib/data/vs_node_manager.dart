import 'package:vs_node_view/common.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_serialization_manager.dart';
import 'package:vs_node_view/special_nodes/vs_output_node.dart';

class VSNodeManager {
  ///Holds all relevant node data
  ///
  ///Handles interactions with the data
  ///
  ///Creates an instance of VSNodeSerializationManager to handle serializations
  VSNodeManager({
    required List<dynamic> nodeBuilders,
    String? serializedNodes,
    Function(Map nodeJSON)? onBuilderMissing,

    ///These nodes will not be part of [contextNodeBuilders]
    ///
    ///They will only be used for deserialization
    List<VSNodeDataBuilder>? additionalNodes,
  }) {
    serializationManager = VSNodeSerializationManager(
      nodeBuilders: nodeBuilders,
      onBuilderMissing: onBuilderMissing,
      additionalNodes: additionalNodes,
    );

    if (serializedNodes != null) {
      _nodes = serializationManager.deserializeNodes(serializedNodes);
    }
  }

  late VSNodeSerializationManager serializationManager;
  Map<String, dynamic> get nodeBuildersMap =>
      serializationManager.contextNodeBuilders;

  ///Returns all output nodes in the current node data
  Iterable<VSOutputNode> get getOutputNodes =>
      _nodes.values.whereType<VSOutputNode>();

  Map<String, VSNodeData> _nodes = {};

  ///Returns a copy of the current node data
  Map<String, VSNodeData> get nodes => Map.from(_nodes);

  ///Calls serializationManager.serializeNodes with the current node data and returns a String
  String serializeNodes() {
    return serializationManager.serializeNodes(_nodes);
  }

  ///Loades nodes from string and replaces current nodes
  void loadSerializedNodes(String serializedNodes) {
    final deserializedNodes =
        serializationManager.deserializeNodes(serializedNodes);

    removeNodes(
      nodes.keys
          .toSet()
          .difference(deserializedNodes.keys.toSet())
          .map((e) => nodes[e]!)
          .toList(),
    );

    updateOrCreateNodes(
      deserializedNodes.values.toList(),
    );
  }

  ///Updates or Creates a nodes
  void updateOrCreateNodes(List<VSNodeData> nodeDatas) async {
    for (final node in nodeDatas) {
      _nodes[node.id] = node;
    }
    _nodes = Map.from(_nodes);
  }

  ///Removes multiple nodes and clears all references
  void removeNodes(List<VSNodeData> nodeDatas) async {
    for (final node in nodeDatas) {
      _nodes.remove(node.id);
    }
    _nodes = Map.from(_nodes);
    for (final node in _nodes.values) {
      for (final input in node.inputData) {
        if (nodeDatas.contains(input.connectedInterface?.nodeData)) {
          input.connectedInterface = null;
        }
      }
    }
  }

  ///Cleares all nodes
  void clearNodes() async {
    _nodes = {};
  }
}
