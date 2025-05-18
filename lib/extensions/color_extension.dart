import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color withValues({
    int? red,
    int? green,
    int? blue,
    double? alpha,
  }) {
    return Color.fromRGBO(
      red ?? r.toInt(),
      green ?? g.toInt(),
      blue ?? b.toInt(),
      alpha ?? a,
    );
  }
}
