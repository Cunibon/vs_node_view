import 'package:flutter/gestures.dart';
import 'package:vs_node_view/common.dart';
import 'package:vs_node_view/data/offset_extension.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_manager.dart';

class VSNodeData {
  ///Holds all relevant node data
  VSNodeData({
    String? id,
    required this.type,
    required this.widgetOffset,
    required this.inputData,
    required this.outputData,
    this.nodeWidth,
    this.onUpdatedConnection,
    this.toolTip,
    String? title,
  })  : _id = id ?? getRandomString(10),
        _title = title ?? "" {
    for (var value in inputData) {
      value.nodeData = this;
    }
    for (var value in outputData) {
      value.nodeData = this;
    }
  }

  ///The nodes ID
  ///
  ///Used inside [VSNodeManager] as a key for nodes
  String get id => _id;
  String _id;

  ///The type of this node
  ///
  ///Important for deserialization
  final String type;

  ///The current offset of the widget from the origin (Top-Left corner)
  Offset widgetOffset;

  ///The width this node will have in the UI
  final double? nodeWidth;

  ///The input interfaces of this node
  Iterable<VSInputData> inputData;

  ///The output interfaces of this node
  Iterable<VSOutputData> outputData;

  ///The title displayed on the node
  ///
  ///Usefull for localization
  String get title => _title.isNotEmpty ? _title : type;
  set title(String data) => _title = data;
  String _title = "";

  ///A tooltip displayed on the widget
  final String? toolTip;

  ///This function gets called when any input interface updates its connected node
  ///
  ///The interface in question is passed to the function call
  final Function(VSInputData interfaceData)? onUpdatedConnection;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': _title,
      'widgetOffset': widgetOffset.toJson(),
      'inputData': inputData,
      'outputData': outputData,
    };
  }

  ///Used for deserializing
  ///
  ///Sets base node data id and offset
  void setBaseData(
    String id,
    String title,
    Offset widgetOffset,
  ) {
    _id = id;
    _title = title;
    this.widgetOffset = widgetOffset;
  }

  ///Used for deserializing
  ///
  ///Reconstructs connections
  ///
  ///Maps inputRefs to the corresponding connection inside this node
  void setRefData(Map<String, VSOutputData?> inputRefs) {
    Map<String, VSInputData> inputMap = {
      for (final element in inputData) element.type: element
    };

    for (final ref in inputRefs.entries) {
      inputMap[ref.key]?.connectedInterface = ref.value;
    }
  }
}
