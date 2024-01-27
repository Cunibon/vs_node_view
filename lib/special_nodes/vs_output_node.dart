import 'package:flutter/material.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';

class VSOutputNode extends VSNodeData {
  ///Output Node
  ///
  ///Used to traverse the node tree and evalutate them to a result
  VSOutputNode({
    required String type,
    required Offset widgetOffset,
    VSOutputData? ref,
  }) : super(
          type: type,
          widgetOffset: widgetOffset,
          inputData: [
            VSDynamicInputData(
              name: type,
              initialConnection: ref,
            )
          ],
          outputData: const [],
        );

  ///Evalutes the tree from this node and returns the result
  ///
  ///Supply an onError function to be called when an error occures inside the evaluation
  MapEntry<String, dynamic> evaluate({
    Function(Object e, StackTrace s)? onError,
  }) {
    try {
      Map<String, Map<String, dynamic>> nodeInputValues = {};
      _traverseInputNodes(nodeInputValues, this);

      return MapEntry(title, nodeInputValues[id]!.values.first);
    } catch (e, s) {
      onError?.call(e, s);
    }
    return MapEntry(title, null);
  }

  ///Traverses input nodes
  ///
  ///Used by evalTree to recursivly move through the nodes
  void _traverseInputNodes(
    Map<String, Map<String, dynamic>> nodeInputValues,
    VSNodeData data,
  ) {
    Map<String, dynamic> inputValues = {};
    for (final input in data.inputData) {
      final connectedNode = input.connectedNode;
      if (connectedNode != null) {
        if (!nodeInputValues.containsKey(connectedNode.nodeData.id)) {
          _traverseInputNodes(
            nodeInputValues,
            connectedNode.nodeData,
          );
        }

        inputValues[input.name] = connectedNode.outputFunction?.call(
          nodeInputValues[connectedNode.nodeData.id]!,
        );
      } else {
        inputValues[input.name] = null;
      }
    }
    nodeInputValues[data.id] = inputValues;
  }
}
