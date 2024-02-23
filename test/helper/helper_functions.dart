import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vs_node_view/vs_node_view.dart';

import 'test_data.dart';

Future<VSNodeDataProvider> pumpInteractiveVSNodeView(
  WidgetTester tester,
) async {
  final nodeDataProvider = VSNodeDataProvider(
    nodeBuilders: nodeBuilders,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: InteractiveVSNodeView(
        nodeDataProvider: nodeDataProvider,
        width: 1000,
      ),
    ),
  );

  return nodeDataProvider;
}

Future<VSNodeDataProvider> pumpVSNodeView(
  WidgetTester tester,
) async {
  final nodeDataProvider = VSNodeDataProvider(
    nodeBuilders: nodeBuilders,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: VSNodeView(
        nodeDataProvider: nodeDataProvider,
      ),
    ),
  );

  return nodeDataProvider;
}

Future<void> dragAndDropFromTo({
  required Offset from,
  required Offset to,
  required WidgetTester tester,
}) async {
  final TestGesture gesture = await tester.startGesture(
    from,
  );
  await tester.pump();
  await gesture.moveTo(to);
  await gesture.up();
  await tester.pump();
}

Future<void> panFromTo({
  required Offset from,
  required Offset to,
  required WidgetTester tester,
}) async {
  final TestGesture gesture = await tester.startGesture(
    from,
    kind: PointerDeviceKind.trackpad,
  );
  await tester.pump();
  await gesture.panZoomUpdate(to);
  await tester.pump();
  await gesture.panZoomEnd();
}
