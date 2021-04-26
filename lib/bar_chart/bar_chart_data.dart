import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum BarChartDataType {Number, Double}
enum BarChartBarShape {Rectangle, Rounded}

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

class BarChartBarStyle {
  final Color color;
  final BarChartBarShape shape;

  const BarChartBarStyle({
    this.color = Colors.red,
    this.shape = BarChartBarShape.Rectangle,
  });
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

class BarChartAnimation {
  final bool animateAxis;
  final bool animateData;
  final Duration axisAnimationDuration;
  final Duration dataAnimationDuration;
  final bool animateDataAfterAxis;

  const BarChartAnimation({
    this.animateAxis = false,
    this.animateData = false,
    this.axisAnimationDuration = const Duration(milliseconds: 1500),
    this.dataAnimationDuration = const Duration(milliseconds: 1500),
    this.animateDataAfterAxis = true,
  });
}