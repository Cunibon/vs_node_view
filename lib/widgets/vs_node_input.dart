import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_node_view/common.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/widgets/gradiant_line_drawer.dart';

class VSNodeInput extends StatefulWidget {
  ///Base node input widget
  ///
  ///Used in [VSNode]
  ///
  ///Uses [DragTarget] to accept [VSOutputData]
  const VSNodeInput({
    required this.data,
    super.key,
  });

  final VSInputData data;

  @override
  State<VSNodeInput> createState() => _VSNodeInputState();
}

class _VSNodeInputState extends State<VSNodeInput> {
  late RenderBox renderBox;
  final GlobalKey _anchor = GlobalKey();

  void findWidgetPosition() {
    renderBox = _anchor.currentContext?.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    final provider = context.read<VSNodeDataProvider>();

    widget.data.widgetOffset = provider.applyViewPortTransfrom(position) -
        widget.data.nodeData.widgetOffset;

    context
        .read<VSNodeDataProvider>()
        .updateOrCreateNodes([widget.data.nodeData]);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      findWidgetPosition();
    });
  }

  Offset? updateLinePosition(VSOutputData? outputData) {
    if (outputData?.widgetOffset == null || widget.data.widgetOffset == null) {
      return null;
    }

    return outputData!.widgetOffset! +
        outputData.nodeData.widgetOffset -
        widget.data.nodeData.widgetOffset -
        widget.data.widgetOffset! +
        interfaceCenterOffset;
  }

  void updateConnectedNode(VSOutputData? data) {
    widget.data.connectedNode = data;
    context.read<VSNodeDataProvider>().updateOrCreateNodes(
      [widget.data.nodeData],
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.data.connectedNode == null
        ? Icons.radio_button_unchecked
        : Icons.radio_button_checked;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomPaint(
          foregroundPainter: GradientLinePainter(
            startPoint: interfaceCenterOffset,
            endPoint: updateLinePosition(
              widget.data.connectedNode,
            ),
            startColor: widget.data.interfaceColor,
            endColor: widget.data.connectedNode?.interfaceColor,
          ),
          child: DragTarget<VSOutputData>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return GestureDetector(
                onTap: () {
                  updateConnectedNode(null);
                },
                child: wrapWithToolTip(
                  toolTip: widget.data.toolTip,
                  child: Icon(
                    icon,
                    key: _anchor,
                    color: widget.data.interfaceColor,
                    size: 15,
                  ),
                ),
              );
            },
            onWillAccept: (data) {
              if (data != null) {
                return widget.data.acceptInput(data);
              } else {
                return false;
              }
            },
            onAccept: (data) {
              updateConnectedNode(data);
            },
          ),
        ),
        Text(widget.data.title),
      ],
    );
  }
}
