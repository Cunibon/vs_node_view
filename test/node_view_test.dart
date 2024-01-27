import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vs_node_view/widgets/vs_context_menu.dart';
import 'package:vs_node_view/widgets/vs_node.dart';

import 'helper/helper_functions.dart';
import 'helper/test_data.dart';

void main() {
  testWidgets('Create new node', (tester) async {
    await pumpVSNodeView(
      tester,
    );

    await tester.tapAt(
      Offset.zero,
      buttons: kSecondaryButton,
    );
    await tester.pumpAndSettle();

    expect(find.byType(VSContextMenu), findsOneWidget);

    await tester.tap(find.text("Input"));
    await tester.pumpAndSettle();

    expect(find.byType(VSNode), findsOneWidget);
  });

  testWidgets('Create new node from subgroup', (tester) async {
    await pumpVSNodeView(
      tester,
    );

    await tester.tapAt(
      Offset.zero,
      buttons: kSecondaryButton,
    );

    await tester.pumpAndSettle();

    expect(find.byType(VSContextMenu), findsOneWidget);

    await tester.tap(find.text("Number"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Parse int"));
    await tester.pumpAndSettle();

    expect(find.byType(VSNode), findsOneWidget);
  });

  testWidgets('Create new node with reference', (tester) async {
    final nodeDataProvider = await pumpVSNodeView(
      tester,
    );

    final input = textInputNode(
      Offset.zero,
      null,
      TextEditingController()..text = "10",
    );

    nodeDataProvider.updateOrCreateNodes([
      input,
    ]);
    await tester.pumpAndSettle();

    final inputOffset =
        input.outputData.first.widgetOffset! + input.widgetOffset;

    await dragAndDropFromTo(
      from: inputOffset,
      to: inputOffset + const Offset(130, 0),
      tester: tester,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Output"));
    await tester.pumpAndSettle();

    expect(find.byType(VSNode), findsNWidgets(2));

    expect(
      nodeDataProvider.nodeManger.getOutputNodes.first.inputData.first
          .connectedNode!.nodeData,
      input,
    );
  });

  testWidgets('Move node', (tester) async {
    final nodeDataProvider = await pumpVSNodeView(
      tester,
    );

    final output = outputNode(Offset.zero, null);

    nodeDataProvider.updateOrCreateNodes([
      output,
    ]);
    await tester.pumpAndSettle();

    final Finder targetFinder = find.byType(VSNode);
    final Offset titleLocation = tester.getCenter(targetFinder);

    await dragAndDropFromTo(
      from: titleLocation,
      to: titleLocation + const Offset(130, 0),
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(output.widgetOffset, const Offset(130, 0));
  });

  testWidgets('Connect node', (tester) async {
    final nodeDataProvider = await pumpVSNodeView(
      tester,
    );

    final input = textInputNode(
      Offset.zero,
      null,
      TextEditingController()..text = "10",
    );
    final output = outputNode(const Offset(130, 0), null);

    nodeDataProvider.updateOrCreateNodes([
      input,
      output,
    ]);
    await tester.pumpAndSettle();

    await dragAndDropFromTo(
      from: input.outputData.first.widgetOffset! + input.widgetOffset,
      to: output.inputData.first.widgetOffset! + output.widgetOffset,
      tester: tester,
    );
    await tester.pumpAndSettle();

    expect(output.inputData.first.connectedNode!.nodeData, input);
  });
}
