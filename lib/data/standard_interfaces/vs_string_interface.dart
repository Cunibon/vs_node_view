import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_interface.dart';

const Color _interfaceColor = Colors.green;

class VSStringInputData extends VSInputData {
  ///Basic String input interface
  VSStringInputData({
    required super.name,
    super.initialConnection,
  });

  @override
  List<Type> get acceptedTypes => [VSStringOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSStringOutputData extends VSOutputData<String> {
  ///Basic String output interface
  VSStringOutputData({
    required super.name,
    super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
