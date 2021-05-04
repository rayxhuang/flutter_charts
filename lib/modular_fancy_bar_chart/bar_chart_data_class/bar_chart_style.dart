import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';

typedef Comparator<T> = int Function(T a, T b);
enum BarChartBarShape {Rectangle, RoundedRectangle}

class BarChartStyle {
  final BarChartLabel title;
  final double groupMargin;
  final Map<String, Color> subGroupColors;
  final bool sortXAxis;
  final Comparator<String> groupComparator;
  final EdgeInsetsGeometry contentPadding;
  final AxisStyle xAxisStyle, yAxisStyle;
  final BarChartLegendStyle legendStyle;
  final BarChartBarStyle barStyle;
  final BarChartAnimation animation;

  const BarChartStyle({
    this.title = const BarChartLabel(),
    this.groupMargin = 12,
    this.sortXAxis = false,
    this.subGroupColors,
    this.groupComparator,
    this.contentPadding = const EdgeInsets.all(10),
    this.xAxisStyle = const AxisStyle(),
    this.yAxisStyle = const AxisStyle(),
    this.barStyle = const BarChartBarStyle(),
    this.legendStyle = const BarChartLegendStyle(),
    this.animation = const BarChartAnimation(),
  });
}

class AxisStyle {
  final bool visible;
  final int numTicks;
  final Color axisColor;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final double preferredStartValue;
  final double preferredEndValue;
  final TickStyle tickStyle;
  final BarChartLabel label;

  const AxisStyle({
    this.visible = true,
    this.numTicks = 11,
    this.axisColor = Colors.black,
    this.strokeWidth = 3,
    this.strokeCap = StrokeCap.round,
    this.preferredStartValue = 0,
    this.preferredEndValue = 10,
    this.tickStyle = const TickStyle(),
    this.label = const BarChartLabel(),
  });
}

class TickStyle {
  final bool onlyShowTicksAtTwoSides;
  final bool lastTickWithUnit;
  final TextStyle labelTextStyle;
  final String unit;
  final Color tickColor;
  final double tickMargin;
  final int tickDecimal;
  final double tickLength;

  const TickStyle({
    this.onlyShowTicksAtTwoSides = false,
    this.lastTickWithUnit = true,
    this.labelTextStyle = const TextStyle(),
    this.unit = '',
    this.tickColor = Colors.white,
    this.tickMargin = 4,
    this.tickDecimal = 0,
    this.tickLength = 0,
  });
}

class BarChartBarStyle {
  final double barWidth;
  final double barInGroupMargin;
  final bool isStacked;
  final Color color;
  final BarChartBarShape shape;
  final Radius topLeft;
  final Radius topRight;
  final Radius bottomLeft;
  final Radius bottomRight;

  const BarChartBarStyle({
    this.barWidth = 28,
    this.barInGroupMargin = 0,
    this.isStacked = false,
    this.color = Colors.red,
    this.shape = BarChartBarShape.Rectangle,
    this.topLeft = const Radius.circular(0),
    this.topRight = const Radius.circular(0),
    this.bottomLeft = const Radius.circular(0),
    this.bottomRight = const Radius.circular(0),
  });
}

class BarChartLegendStyle {
  final bool visible;
  final TextStyle legendTextStyle;
  final int preferredNumLegendsOnScreen;
  final double minimumSize;

  const BarChartLegendStyle({
    this.visible = true,
    this.legendTextStyle = const TextStyle(),
    this.preferredNumLegendsOnScreen = 5,
    this.minimumSize = 20,
  });
}

class BarChartAnimation {
  //final bool animateAxis;
  final bool animateData;
  //final Duration axisAnimationDuration;
  final Duration dataAnimationDuration;
  //final bool animateDataAfterAxis;

  const BarChartAnimation({
    //this.animateAxis = false,
    this.animateData = false,
    //this.axisAnimationDuration = const Duration(milliseconds: 1000),
    this.dataAnimationDuration = const Duration(milliseconds: 1000),
    //this.animateDataAfterAxis = true,
  });
}