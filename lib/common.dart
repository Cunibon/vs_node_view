import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vs_node_view/data/offset_extension.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';

typedef VSNodeDataBuilder = VSNodeData Function(Offset, VSOutputData?);

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );

RenderBox findAndUpdateWidgetPosition({
  required GlobalKey widgetAnchor,
  required BuildContext context,
  required VSInterfaceData data,
}) {
  final renderBox =
      widgetAnchor.currentContext?.findRenderObject() as RenderBox;
  Offset position = renderBox.localToGlobal(Offset.zero);

  final provider = context.read<VSNodeDataProvider>();

  data.widgetOffset =
      provider.applyViewPortTransfrom(position) - data.nodeData!.widgetOffset;

  provider.updateOrCreateNodes([data.nodeData!]);

  return renderBox;
}

Widget wrapWithToolTip({
  String? toolTip,
  required Widget child,
}) {
  return toolTip == null
      ? child
      : Tooltip(
          message: toolTip,
          waitDuration: const Duration(seconds: 1),
          child: child,
        );
}

Offset getWidgetCenter(RenderBox? renderBox) =>
    renderBox != null ? (renderBox.size.toOffset() / 2) : Offset.zero;
