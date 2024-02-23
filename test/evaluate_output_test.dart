import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vs_node_view/data/vs_node_manager.dart';

import 'helper/test_data.dart';

void main() {
  final controller = TextEditingController();

  final input1 = textInputNode(
    Offset.zero,
    null,
    controller..text = "10",
  );
  final input2 = textInputNode(
    Offset.zero,
    null,
    TextEditingController()..text = "5",
  );

  final parseInt1 = parseIntNode(Offset.zero, input1.outputData.first);
  final parseInt2 = parseIntNode(Offset.zero, input2.outputData.first);

  final sum = sumNode(Offset.zero, null);

  sum.inputData.first.connectedInterface = parseInt1.outputData.first;
  sum.inputData.last.connectedInterface = parseInt2.outputData.first;

  final input3 = textInputNode(
    Offset.zero,
    null,
    TextEditingController()..text = "20",
  );
  final parseInt3 = parseIntNode(Offset.zero, input3.outputData.first);

  final bigger = biggerNode(Offset.zero, null);

  bigger.inputData.first.connectedInterface = sum.outputData.first;
  bigger.inputData.last.connectedInterface = parseInt3.outputData.first;

  final ifN = ifNode(Offset.zero, null);
  final ifInputs = ifN.inputData.toList();

  ifInputs[0].connectedInterface = bigger.outputData.first;
  ifInputs[1].connectedInterface = sum.outputData.first;
  ifInputs[2].connectedInterface = parseInt3.outputData.first;

  final output = outputNode(Offset.zero, ifN.outputData.first);

  test('Evaluate complex tree', () {
    expect(output.evaluate().value, 20);
    controller.text = "20";
    expect(output.evaluate().value, 25);
  });

  test('Serialize and Deserialize data', () {
    final manager1 = VSNodeManager(
      nodeBuilders: nodeBuilders,
    );

    manager1.updateOrCreateNodes([
      input1,
      input2,
      input3,
      parseInt1,
      parseInt2,
      parseInt3,
      sum,
      bigger,
      ifN,
      output,
    ]);

    final serializedNodes = manager1.serializeNodes();

    final manager2 = VSNodeManager(
      nodeBuilders: nodeBuilders,
      serializedNodes: serializedNodes,
    );

    expect(manager1.nodes.keys, manager2.nodes.keys);

    final outputs1 = manager1.getOutputNodes.map((e) => e.evaluate());
    final outputs2 = manager2.getOutputNodes.map((e) => e.evaluate());

    expect(
      mapEquals(
        Map.fromEntries(outputs1),
        Map.fromEntries(outputs2),
      ),
      true,
    );
  });
}
