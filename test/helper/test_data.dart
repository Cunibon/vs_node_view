import 'package:flutter/material.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_bool_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_double_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_int_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_num_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_string_interface.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_subgroup.dart';
import 'package:vs_node_view/special_nodes/vs_list_node.dart';
import 'package:vs_node_view/special_nodes/vs_output_node.dart';
import 'package:vs_node_view/special_nodes/vs_widget_node.dart';

final List<dynamic> nodeBuilders = [
  textInputNode,
  concatNode,
  VSSubgroup(
    name: "Number",
    subgroup: [
      parseIntNode,
      parseDoubleNode,
      sumNode,
    ],
  ),
  VSSubgroup(
    name: "Logik",
    subgroup: [
      biggerNode,
      ifNode,
    ],
  ),
  outputNode,
];

VSWidgetNode textInputNode(
  Offset offset,
  VSOutputData? ref, [
  TextEditingController? controller,
]) {
  controller ??= TextEditingController();
  final input = TextField(
    controller: controller,
    decoration: const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    ),
  );

  return VSWidgetNode(
    type: "Input",
    widgetOffset: offset,
    outputData: VSStringOutputData(
      type: "Output",
      outputFunction: (data) => controller!.text,
    ),
    child: Expanded(child: input),
    setValue: (value) => controller!.text = value,
    getValue: () => controller!.text,
  );
}

VSListNode concatNode(
  Offset offset,
  VSOutputData? ref,
) {
  return VSListNode(
    type: "Concat",
    toolTip: "Concatinates all inputs",
    widgetOffset: offset,
    outputData: VSStringOutputData(
      type: "Output",
      toolTip: "All inputs concatinated",
      outputFunction: (data) => data.values.join(),
    ),
    inputBuilder: (index, ref) => VSDynamicInputData(
      type: "$index",
      title: "$index input",
      initialConnection: ref,
    ),
  );
}

VSOutputNode outputNode(Offset offset, VSOutputData? ref) {
  return VSOutputNode(
    type: "Output",
    widgetOffset: offset,
    ref: ref,
  );
}

VSNodeData parseIntNode(Offset offset, VSOutputData? ref) {
  return VSNodeData(
    type: "Parse int",
    widgetOffset: offset,
    inputData: [
      VSStringInputData(
        type: "Input",
        initialConnection: ref,
      )
    ],
    outputData: [
      VSIntOutputData(
        type: "Output",
        outputFunction: (data) {
          return int.parse(data["Input"]);
        },
      ),
    ],
  );
}

VSNodeData parseDoubleNode(Offset offset, VSOutputData? ref) {
  return VSNodeData(
    type: "Parse double",
    widgetOffset: offset,
    inputData: [
      VSStringInputData(
        type: "Input",
        initialConnection: ref,
      )
    ],
    outputData: [
      VSDoubleOutputData(
        type: "Output",
        outputFunction: (data) {
          return double.parse(data["Input"]);
        },
      ),
    ],
  );
}

VSNodeData sumNode(Offset offset, VSOutputData? ref) {
  return VSNodeData(
    type: "Sum",
    widgetOffset: offset,
    inputData: [
      VSNumInputData(
        type: "Input 1",
        initialConnection: ref,
      ),
      VSNumInputData(
        type: "Input 2",
        initialConnection: ref,
      )
    ],
    outputData: [
      VSNumOutputData(
        type: "Output",
        outputFunction: (data) {
          return (data["Input 1"] ?? 0) + (data["Input 2"] ?? 0);
        },
      ),
    ],
  );
}

VSNodeData biggerNode(Offset offset, VSOutputData? ref) {
  return VSNodeData(
    type: "Bigger then",
    widgetOffset: offset,
    inputData: [
      VSNumInputData(
        type: "First",
        initialConnection: ref,
      ),
      VSNumInputData(
        type: "Second",
        initialConnection: ref,
      ),
    ],
    outputData: [
      VSBoolOutputData(
        type: "Output",
        outputFunction: (data) {
          return data["First"] > data["Second"];
        },
      ),
    ],
  );
}

VSNodeData ifNode(Offset offset, VSOutputData? ref) {
  return VSNodeData(
    type: "If",
    widgetOffset: offset,
    inputData: [
      VSBoolInputData(
        type: "Input",
        initialConnection: ref,
      ),
      VSDynamicInputData(
        type: "True",
        initialConnection: ref,
      ),
      VSDynamicInputData(
        type: "False",
        initialConnection: ref,
      ),
    ],
    outputData: [
      VSDynamicOutputData(
        type: "Output",
        outputFunction: (data) {
          return data["Input"] ? data["True"] : data["False"];
        },
      ),
    ],
  );
}
