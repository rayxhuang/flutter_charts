import 'package:flutter/material.dart';

enum AxisType {XWithNum, YWithNum, XWithTextLabel, YWithTextLabel, X, Y}

abstract class BaseAxis {
  final AxisType type;
  final String labelText;
  final double startValue;
  final double endValue;
  final AxisStyle style;

  const BaseAxis._({
    @required this.type,
    @required this.labelText,
    @required this.startValue,
    @required this.endValue,
    @required this.style,
  });

  double get valueRange => (this.endValue - this.startValue).abs();
}

class AxisWithNum extends BaseAxis {
  const AxisWithNum.X({
    String labelText = 'X Axis',
    double startValue = 0,
    double endValue = 10,
    AxisStyle style = const AxisStyle(),
  }) : super._(
    type: AxisType.XWithNum,
    labelText: labelText,
    startValue: startValue,
    endValue: endValue,
    style: style,
  );

  const AxisWithNum.Y({
    String labelText = 'Y Axis',
    double startValue = 0,
    double endValue = 10,
    AxisStyle style = const AxisStyle(),
  }) : super._(
    type: AxisType.YWithNum,
    labelText: labelText,
    startValue: startValue,
    endValue: endValue,
    style: style,
  );
}

class AxisStyle {
  final double shift;
  final bool visible;
  final int numTicks;
  final Tick tick;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final double preferredStart;
  final double preferredEnd;

  const AxisStyle({
    this.shift = 0,
    this.visible = true,
    this.numTicks = 10,
    this.tick = const Tick(),
    this.color = Colors.teal,
    this.strokeWidth = 3,
    this.strokeCap = StrokeCap.round,
    this.preferredStart,
    this.preferredEnd,
  });
}

class Tick {
  final int tickDecimal;
  final double tickLength;
  //Color is not usable atm
  final Color tickColor;
  final double tickMargin;

  const Tick({
    this.tickDecimal = 0,
    this.tickLength = 0,
    this.tickColor = Colors.white,
    this.tickMargin = 5,
  });
}