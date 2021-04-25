import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

enum BarChartBarShape {Rectangle, Rounded}

// class BarChartBar {
//   final BarChartData data;
//   final BarChartBarStyle style;
//
//   const BarChartBar({
//     @required this.data,
//     @required this.style,
//   });
// }

class BarChartBarStyle {
  final Color color;
  final BarChartBarShape shape;

  const BarChartBarStyle({
    this.color = Colors.red,
    this.shape = BarChartBarShape.Rectangle,
  });
}