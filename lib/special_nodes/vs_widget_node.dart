import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';

class VSWidgetNode extends VSNodeData {
  ///Widget Node
  ///
  ///Can be used to add a custom UI component to a node
  VSWidgetNode({
    String? id,
    required String type,
    required Offset widgetOffset,
    required VSOutputData<dynamic> outputData,
    required this.setValue,
    required this.getValue,
    required this.child,
    String? title,
    String? toolTip,
  }) : super(
          id: id,
          type: type,
          widgetOffset: widgetOffset,
          inputData: const [],
          outputData: [outputData],
          title: title,
          toolTip: toolTip,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    return json..["value"] = getValue();
  }

  final Widget child;

  ///Used to set the value of the supplied widget during deserialization
  final Function(dynamic) setValue;

  ///Used to get the value of the supplied widget during serialization
  final dynamic Function() getValue;
}
