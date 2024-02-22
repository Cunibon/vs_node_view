import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_node_view/common.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/special_nodes/vs_widget_node.dart';
import 'package:vs_node_view/widgets/gradiant_line_drawer.dart';

class VSNodeOutput extends StatefulWidget {
  ///Base node output widget
  ///
  ///Used in [VSNode]
  ///
  ///Uses [Draggable] to make a connection with [VSInputData]
  const VSNodeOutput({
    required this.data,
    super.key,
  });

  final VSOutputData data;

  @override
  State<VSNodeOutput> createState() => _VSNodeOutputState();
}

class _VSNodeOutputState extends State<VSNodeOutput> {
  Offset? dragPos;
  late RenderBox renderBox;
  final GlobalKey _anchor = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      renderBox = findAndUpdateWidgetPosition(
        widgetAnchor: _anchor,
        context: context,
        data: widget.data,
      );
    });
  }

  void updateLinePosition(Offset newPosition) {
    setState(() => dragPos = renderBox.globalToLocal(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.data.nodeData is VSWidgetNode
        ? (widget.data.nodeData as VSWidgetNode).child
        : Text(widget.data.title);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        firstItem,
        CustomPaint(
          foregroundPainter: GradientLinePainter(
            startPoint: interfaceCenterOffset,
            endPoint: dragPos,
            startColor: widget.data.interfaceColor,
            endColor: widget.data.interfaceColor,
          ),
          child: Draggable<VSOutputData>(
            data: widget.data,
            onDragUpdate: (details) =>
                updateLinePosition(details.localPosition),
            onDragEnd: (details) => setState(() {
              dragPos = null;
            }),
            onDraggableCanceled: (velocity, offset) {
              context.read<VSNodeDataProvider>().openContextMenu(
                    position: offset,
                    outputData: widget.data,
                  );
            },
            feedback: Icon(
              Icons.circle,
              color: widget.data.interfaceColor,
              size: 15,
            ),
            child: wrapWithToolTip(
              toolTip: widget.data.toolTip,
              child: Icon(
                Icons.circle,
                key: _anchor,
                color: widget.data.interfaceColor,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
