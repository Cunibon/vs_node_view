import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/widgets/line_drawer/multi_gradiant_line_drawer.dart';
import 'package:vs_node_view/widgets/vs_context_menu.dart';
import 'package:vs_node_view/widgets/vs_node.dart';
import 'package:vs_node_view/widgets/vs_node_title.dart';
import 'package:vs_node_view/widgets/vs_selection_area.dart';

class VSNodeView extends StatelessWidget {
  ///The base node widget
  ///
  ///Display and interact with nodes to build node trees
  const VSNodeView({
    required this.nodeDataProvider,
    this.contextMenuBuilder,
    this.nodeBuilder,
    this.nodeTitleBuilder,
    this.enableSelectionArea = true,
    this.selectionAreaBuilder,
    this.gestureDetectorBuilder,
    super.key,
  });

  ///The provider that will be used to controll the UI
  final VSNodeDataProvider nodeDataProvider;

  ///Can be used to take control over the building of the nodes
  ///
  ///See [VSNode] for reference
  final Widget Function(
    BuildContext context,
    VSNodeData data,
  )? nodeBuilder;

  ///Can be used to take control over the building of the context menu
  ///
  ///See [VSContextMenu] for reference
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> nodeBuildersMap,
  )? contextMenuBuilder;

  ///Can be used to take control over the building of the nodes titles
  ///
  ///See [VSNodeTitle] for reference
  final Widget Function(
    BuildContext context,
    VSNodeData nodeData,
  )? nodeTitleBuilder;

  ///If [VSSelectionArea] or [selectionAreaBuilder] will be inserted to the widget tree
  final bool enableSelectionArea;

  ///Can be used to take control over the building of the selection area
  ///
  ///See [VSSelectionArea] for reference
  final Widget Function(
    BuildContext context,
    Widget view,
  )? selectionAreaBuilder;

  ///Can be used to override the GestureDetector
  ///
  ///See [VSNodeDataProvider.closeContextMenu], [VSNodeDataProvider.openContextMenu] and [VSNodeDataProvider.selectedNodes]
  final GestureDetector Function(
    BuildContext context,
    VSNodeDataProvider nodeDataProvider,
  )? gestureDetectorBuilder;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: nodeDataProvider),
      ],
      child: Builder(
        builder: (context) {
          final nodeDataProvider = context.watch<VSNodeDataProvider>();

          final nodes = nodeDataProvider.nodes.values.map((value) {
            return Positioned(
              left: value.widgetOffset.dx,
              top: value.widgetOffset.dy,
              child: nodeBuilder?.call(
                    context,
                    value,
                  ) ??
                  VSNode(
                    key: ValueKey(value.id),
                    data: value,
                    nodeTitleBuilder: nodeTitleBuilder,
                  ),
            );
          });

          final view = CustomPaint(
            foregroundPainter: MultiGradientLinePainter(
              data: nodeDataProvider.nodes.values
                  .expand<VSInputData>((element) => element.inputData)
                  .toList(),
            ),
            child: Stack(
              children: [
                gestureDetectorBuilder?.call(context, nodeDataProvider) ??
                    GestureDetector(
                      onTapDown: (details) {
                        nodeDataProvider.closeContextMenu();
                        nodeDataProvider.selectedNodes = {};
                      },
                      onSecondaryTapUp: (details) =>
                          nodeDataProvider.openContextMenu(
                        position: details.globalPosition,
                      ),
                      onLongPressStart: (details) =>
                          nodeDataProvider.openContextMenu(
                        position: details.globalPosition,
                      ),
                    ),
                ...nodes,
                if (nodeDataProvider.contextMenuContext != null)
                  Positioned(
                    left: nodeDataProvider.contextMenuContext!.offset.dx,
                    top: nodeDataProvider.contextMenuContext!.offset.dy,
                    child: contextMenuBuilder?.call(
                          context,
                          nodeDataProvider.nodeBuildersMap,
                        ) ??
                        VSContextMenu(
                          nodeBuilders: nodeDataProvider.nodeBuildersMap,
                        ),
                  ),
              ],
            ),
          );

          if (enableSelectionArea) {
            return selectionAreaBuilder?.call(
                  context,
                  view,
                ) ??
                VSSelectionArea(
                  child: view,
                );
          } else {
            return view;
          }
        },
      ),
    );
  }
}
