import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';

class VSListNode extends VSNodeData {
  ///List Node
  ///
  ///Can be used to add a node that bundles multiple inputs into one output
  VSListNode({
    String? id,
    required String type,
    required Offset widgetOffset,
    required VSOutputData outputData,
    required this.inputBuilder,
    String? title,
    String? toolTip,
    Function(VSInputData interfaceData)? onUpdatedConnection,
  }) : super(
          id: id,
          type: type,
          widgetOffset: widgetOffset,
          inputData: [inputBuilder(0, null)],
          outputData: [outputData],
          title: title,
          toolTip: toolTip,
          onUpdatedConnection: onUpdatedConnection,
        );

  ///Used to build the nodes inputs dynamically
  ///
  ///[index] is the current index of this input in the [inputData] of this node
  ///
  ///Make sure to pass [connection] to [initialConnection] of your input interface
  VSInputData Function(int index, VSOutputData? connection) inputBuilder;

  @override
  Function(VSInputData interfaceData)? get onUpdatedConnection => _updateInputs;

  List<VSInputData> getCleanInputs() {
    return inputData
        .where(
          (element) => element.connectedInterface != null,
        )
        .toList();
  }

  void _updateInputs(VSInputData interfaceData) {
    final cleanInputData = getCleanInputs();
    _setInputs(cleanInputData.map((e) => e.connectedInterface));

    super.onUpdatedConnection?.call(interfaceData);
  }

  void _setInputs(Iterable<VSOutputData?> connectedInterface) {
    final List<VSInputData> newInputData = [];
    connectedInterface = [...connectedInterface, null];

    for (int i = 0; i < connectedInterface.length; i++) {
      final currentInput = inputBuilder(
        i,
        connectedInterface.elementAtOrNull(i),
      );
      currentInput.nodeData = this;
      newInputData.add(currentInput);
    }

    inputData = newInputData;
  }

  ///Used for deserializing
  ///
  ///Reconstructs list connections based on index
  @override
  void setRefData(Map<String, VSOutputData?> inputRefs) {
    _setInputs(inputRefs.values);
  }
}
