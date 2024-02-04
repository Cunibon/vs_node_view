import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';

typedef VSNodeDataBuilder = VSNodeData Function(Offset, VSOutputData?);

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

const interfaceCenterOffset = Offset(7.5, 7.5);
