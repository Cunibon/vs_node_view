import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';

class InheritedNodeDataProvider extends InheritedWidget {
  const InheritedNodeDataProvider({
    super.key,
    required this.provider,
    required super.child,
  });

  final VSNodeDataProvider provider;

  @override
  bool updateShouldNotify(InheritedNodeDataProvider oldWidget) =>
      provider.nodeManager.nodes != provider.nodeManager.nodes;
}
