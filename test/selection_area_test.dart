import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vs_node_view/vs_node_view.dart';

import 'helper/helper_functions.dart';
import 'helper/test_data.dart';

void main() {
  final nodeDataProvider = VSNodeDataProvider(
    nodeBuilders: nodeBuilders,
  );

  Future<void> setupSelectionAreaTest(WidgetTester tester) async {
    await pumpVSNodeView(
      tester,
    );

    final input = textInputNode(
      const Offset(10, 10),
      null,
      TextEditingController()..text = "10",
    );
    final output = outputNode(
      const Offset(130, 10),
      input.outputData.first,
    );

    nodeDataProvider.updateOrCreateNodes([
      input,
      output,
    ]);
  }

  testWidgets('Select nodes', (tester) async {
    await setupSelectionAreaTest(tester);
    await tester.pumpAndSettle();

    await simulateKeyDownEvent(LogicalKeyboardKey.control);
    await tester.pumpAndSettle();

    await panFromTo(
      from: const Offset(0, 0),
      to: const Offset(150, 100),
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(nodeDataProvider.selectedNodes.length, 2);
  });

  testWidgets('Unselect nodes', (tester) async {
    await setupSelectionAreaTest(tester);
    nodeDataProvider.selectedNodes.addAll(
      nodeDataProvider.nodes.keys,
    );
    await tester.pumpAndSettle();

    expect(nodeDataProvider.selectedNodes.length, 2);

    await simulateKeyDownEvent(LogicalKeyboardKey.control);
    await tester.pumpAndSettle();

    await panFromTo(
      from: const Offset(120, 0),
      to: const Offset(150, 100),
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(nodeDataProvider.selectedNodes.length, 1);
  });

  testWidgets('Move nodes', (tester) async {
    await setupSelectionAreaTest(tester);
    nodeDataProvider.selectedNodes.addAll(
      nodeDataProvider.nodes.keys,
    );
    await tester.pumpAndSettle();

    final Finder targetFinder = find.byType(VSNode).first;
    final Offset titleLocation = tester.getCenter(targetFinder);

    await dragAndDropFromTo(
      from: titleLocation,
      to: titleLocation + const Offset(130, 0),
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(
      nodeDataProvider.nodes.values.first.widgetOffset,
      const Offset(140, 10),
    );
    expect(
      nodeDataProvider.nodes.values.last.widgetOffset,
      const Offset(260, 10),
    );
  });
}
