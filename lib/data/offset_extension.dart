import 'package:flutter/material.dart';

extension ToJson on Offset {
  Map<String, dynamic> toJson() {
    return {
      "dx": dx,
      "dy": dy,
    };
  }
}

Offset offsetFromJson(Map<String, dynamic> data) {
  return Offset(
    data["dx"],
    data["dy"],
  );
}
