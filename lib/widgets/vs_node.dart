import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/widgets/vs_node_input.dart';
import 'package:vs_node_view/widgets/vs_node_output.dart';
import 'package:vs_node_view/widgets/vs_node_title.dart';

class VSNode extends StatefulWidget {
  ///The base node widget
  ///
  ///Used inside [VSNodeView] to display nodes
  const VSNode({
    required this.data,
    this.width = 125,
    this.nodeTitleBuilder,
    super.key,
  });

  ///The data the widget will use to build the UI
  final VSNodeData data;

  ///Default width of the node
  ///
  ///Will be used unless width is specified inside [VSNodeData]
  final double width;

  ///Can be used to take control over the building of the nodes titles
  ///
  ///See [VSNodeTitle] for reference
  final Widget Function(
    BuildContext context,
    VSNodeData nodeData,
  )? nodeTitleBuilder;

  @override
  State<VSNode> createState() => _VSNodeState();
}

class _VSNodeState extends State<VSNode> {
  final GlobalKey _anchor = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final List<Widget> interfaceWidgets = [];

    for (final value in widget.data.inputData) {
      interfaceWidgets.add(
        VSNodeInput(
          data: value,
        ),
      );
    }

    for (final value in widget.data.outputData) {
      interfaceWidgets.add(
        VSNodeOutput(
          data: value,
        ),
      );
    }

    final nodeProvider = VSNodeDataProvider.of(context);

    return Draggable(
      onDragEnd: (_) {
        final renderBox =
            _anchor.currentContext?.findRenderObject() as RenderBox;
        Offset position = renderBox.localToGlobal(Offset.zero);

        nodeProvider.moveNode(
          widget.data,
          position,
        );
      },
      feedback: Transform.scale(
        scale: 1 / nodeProvider.viewportScale,
        child: Card(
          key: _anchor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.data.title,
                ),
                SizedBox(
                  width: widget.data.nodeWidth ?? widget.width,
                )
              ],
            ),
          ),
        ),
      ),
      child: Card(
        color: nodeProvider.selectedNodes.contains(widget.data.id)
            ? Colors.lightBlue
            : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: widget.data.nodeWidth ?? widget.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.nodeTitleBuilder?.call(context, widget.data) ??
                    VSNodeTitle(data: widget.data),
                ...interfaceWidgets,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
