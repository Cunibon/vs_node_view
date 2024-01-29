import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/special_nodes/vs_widget_node.dart';
import 'package:vs_node_view/widgets/gradiant_line_drawer.dart';
import 'package:vs_node_view/widgets/vs_node_input.dart';

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

  void findWidgetPosition() {
    renderBox = _anchor.currentContext?.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    final provider = context.read<VSNodeDataProvider>();

    widget.data.widgetOffset = provider.applyViewPortTransfrom(position) -
        widget.data.nodeData.widgetOffset;

    provider.updateOrCreateNodes([widget.data.nodeData]);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      findWidgetPosition();
    });
  }

  void updateLinePosition(Offset newPosition) {
    setState(() => dragPos = renderBox.globalToLocal(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.data.nodeData is VSWidgetNode
        ? (widget.data.nodeData as VSWidgetNode).child
        : Tooltip(
            message: widget.data.toolTip,
            child: Text(widget.data.name),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        firstItem,
        CustomPaint(
          foregroundPainter: GradientLinePainter(
            startPoint: centerOffset,
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
            child: Icon(
              Icons.circle,
              key: _anchor,
              color: widget.data.interfaceColor,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}
