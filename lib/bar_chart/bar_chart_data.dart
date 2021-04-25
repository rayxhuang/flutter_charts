import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/bar_chart/bar_chart_bar.dart';

enum BarChartDataType {Number, Double}

abstract class BarChartData{
  final List<BarData> data;
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
    List<BarData> data = const [BarData()],
    BarChartBarStyle style = const BarChartBarStyle(),
  }) : super._(
    data: data,
    type: BarChartDataType.Double,
    style: style,
  );
}

class BarData {
  final double x1;
  final double x2;
  final double y;

  const BarData({
    this.x1 = 0,
    this.x2 = 0,
    this.y = 0,
  });
}