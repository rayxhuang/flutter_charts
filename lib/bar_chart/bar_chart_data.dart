import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bar_chart_style.dart';

enum BarChartDataType {Number, Double, DoubleWithUnitLength}

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
  const BarChartDataNumber.double({
    List<BarData> data = const [BarData()],
    BarChartBarStyle style = const BarChartBarStyle(),
  }) : super._(
    data: data,
    type: BarChartDataType.Double,
    style: style,
  );
}

class BarChartDataDoubleWithUnitLength {
  final List<double> data;
  final double unitLength;
  final BarChartBarStyle style;

  const BarChartDataDoubleWithUnitLength({
    @required this.data,
    this.unitLength = 1,
    this.style = const BarChartBarStyle(),
  });
}

class BarChartBarDataDouble {
  final String group;
  final double data;
  final BarChartBarStyle style;

  const BarChartBarDataDouble({
    @required this.group,
    @required this.data,
    this.style,
  });
}

class BarChartBarDataDoubleGrouped {
  final String mainGroup;
  final List<BarChartBarDataDouble> dataList;
  final BarChartBarStyle sectionStyle;

  const BarChartBarDataDoubleGrouped({
    @required this.mainGroup,
    @required this.dataList,
    this.sectionStyle = const BarChartBarStyle(),
  });
}

class BarData {
  final double x1;
  final double x2;
  final double y1;
  final double y2;
  final BarChartBarStyle style;

  const BarData({
    this.x1 = 0,
    this.x2 = 0,
    this.y1 = 0,
    this.y2 = 0,
    this.style = const BarChartBarStyle(),
  });
}

class BarDataUnitLength extends BarData{
  final double x;
  final double y;
  final BarChartBarStyle style;

  const BarDataUnitLength({
    this.x = 0,
    this.y = 0,
    this.style,
  });
}