import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum BarChartBarShape {Rectangle, Rounded}

class BarChartBarStyle {
  final Color color;
  final BarChartBarShape shape;

  const BarChartBarStyle({
    this.color = Colors.red,
    this.shape = BarChartBarShape.Rectangle,
  });
}