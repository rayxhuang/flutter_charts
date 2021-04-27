import 'package:flutter/material.dart';

typedef Comparator<T> = int Function(T a, T b);
enum BarChartBarShape {Rectangle, RoundedRectangle}

class BarChartStyle {
  final bool sortXAxis;
  final Comparator<String> groupComparator;
  final EdgeInsetsGeometry contentPadding;
  final Offset gridAreaOffsetFromBottomLeft;
  final Offset gridAreaOffsetFromTopRight;
  final AxisStyle xAxisStyle;
  final AxisStyle yAxisStyle;
  final BarChartBarStyle barStyle;
  final BarChartAnimation animation;

  const BarChartStyle({
    this.sortXAxis = false,
    this.groupComparator,
    this.contentPadding = const EdgeInsets.all(10),
    this.gridAreaOffsetFromBottomLeft = const Offset(20, 20),
    this.gridAreaOffsetFromTopRight = const Offset(5, 5),
    this.xAxisStyle = const AxisStyle(),
    this.yAxisStyle = const AxisStyle(),
    this.barStyle = const BarChartBarStyle(),
    this.animation = const BarChartAnimation(),
  });
}

class AxisStyle {
  final double shift;
  final bool visible;
  final int numTicks;
  final TickStyle tick;
  final Color axisColor;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final double preferredStartValue;
  final double preferredEndValue;
  final String label;

  const AxisStyle({
    this.shift = 0,
    this.visible = true,
    this.numTicks = 11,
    this.tick = const TickStyle(),
    this.axisColor = Colors.black,
    this.strokeWidth = 3,
    this.strokeCap = StrokeCap.round,
    this.preferredStartValue = 0,
    this.preferredEndValue = 1,
    this.label = '',
  });
}

class TickStyle {
  final bool onlyShowTicksAtTwoSides;
  final bool lastTickWithUnit;
  final double labelTextSize;
  final String unit;
  final Color textColor;
  final Color tickColor;
  final double tickMargin;
  final int tickDecimal;
  final double tickLength;

  const TickStyle({
    this.onlyShowTicksAtTwoSides = false,
    this.lastTickWithUnit = true,
    this.labelTextSize = 14,
    this.unit = '',
    this.textColor = Colors.white,
    this.tickColor = Colors.white,
    this.tickMargin = 3,
    this.tickDecimal = 0,
    this.tickLength = 0,
  });
}

class BarChartBarStyle {
  final Color color;
  final BarChartBarShape shape;
  final Radius topLeft;
  final Radius topRight;
  final Radius bottomLeft;
  final Radius bottomRight;

  const BarChartBarStyle({
    this.color = Colors.red,
    this.shape = BarChartBarShape.Rectangle,
    this.topLeft = const Radius.circular(0),
    this.topRight = const Radius.circular(0),
    this.bottomLeft = const Radius.circular(0),
    this.bottomRight = const Radius.circular(0),
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
    this.axisAnimationDuration = const Duration(milliseconds: 1000),
    this.dataAnimationDuration = const Duration(milliseconds: 1000),
    this.animateDataAfterAxis = true,
  });
}