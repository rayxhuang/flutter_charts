import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/bar_chart/bar_chart_bar.dart';

enum BarChartDataType {Number, Double}

abstract class BarChartData{
  final Map data;
  final BarChartDataType type;
  final BarChartBarStyle style;

  const BarChartData._({
    @required this.data,
    @required this.type,
    @required this.style,
  });
}

class BarChartDataNumber extends BarChartData {
  const BarChartDataNumber.Double({
    Map<double, double> data = const {},
    BarChartBarStyle style = const BarChartBarStyle(),
  }) : super._(
    data: data,
    type: BarChartDataType.Double,
    style: style,
  );
}