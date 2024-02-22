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
  RenderBox? renderBox;
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

  Offset? updateLinePosition(VSOutputData? outputData) {
    if (outputData?.widgetOffset == null || widget.data.widgetOffset == null) {
      return null;
    }

    return outputData!.widgetOffset! +
        outputData.nodeData.widgetOffset -
        widget.data.nodeData.widgetOffset -
        widget.data.widgetOffset! +
        getWidgetCenter(renderBox);
  }

  void updateConnectedNode(VSOutputData? data) {
    widget.data.connectedNode = data;
    context.read<VSNodeDataProvider>().updateOrCreateNodes(
      [widget.data.nodeData],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomPaint(
          foregroundPainter: GradientLinePainter(
            startPoint: getWidgetCenter(renderBox),
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
                  child: widget.data.getInterfaceIcon(
                    context: context,
                    anchor: _anchor,
                  ),
                ),
              );
            },
            onWillAcceptWithDetails: (details) {
              return widget.data.acceptInput(details.data);
            },
            onAcceptWithDetails: (details) {
              updateConnectedNode(details.data);
            },
          ),
        ),
        Text(widget.data.title),
      ],
    );
  }
}
