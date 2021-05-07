import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

typedef Comparator<T> = int Function(T a, T b);
enum BarChartBarShape {Rectangle, RoundedRectangle}

class BarChartStyle {
  final BarChartLabel title;
  final double groupMargin;
  final Map<String, Color> subGroupColors;
  final bool sortXAxis;
  final Comparator<String> groupComparator;
  final EdgeInsetsGeometry contentPadding;
  final AxisStyle xAxisStyle, y1AxisStyle, y2AxisStyle;
  final BarChartLegendStyle legendStyle;
  final BarChartBarStyle barStyle;
  final BarChartAnimation animation;
  final bool clickable;

  const BarChartStyle({
    this.title = const BarChartLabel(),
    this.groupMargin = 12,
    this.sortXAxis = false,
    this.subGroupColors,
    this.groupComparator,
    this.contentPadding = const EdgeInsets.all(10),
    this.xAxisStyle = const AxisStyle(),
    this.y1AxisStyle = const AxisStyle(),
    this.y2AxisStyle = const AxisStyle(),
    this.barStyle = const BarChartBarStyle(),
    this.legendStyle = const BarChartLegendStyle(),
    this.animation = const BarChartAnimation(),
    this.clickable = true,
  });

  BarChartStyle copyWith({
    BarChartLabel title,
    double groupMargin,
    bool sortXAxis,
    Map<String, Color> subGroupColors,
    Comparator<String> groupComparator,
    EdgeInsetsGeometry contentPadding,
    AxisStyle xAxisStyle,
    AxisStyle y1AxisStyle,
    AxisStyle y2AxisStyle,
    BarChartBarStyle barStyle,
    BarChartLegendStyle legendStyle,
    BarChartAnimation animation,
    bool clickable,
  }) => BarChartStyle(
      title: title ?? this.title,
      groupMargin: groupMargin ?? this.groupMargin,
      sortXAxis: sortXAxis ?? this.sortXAxis,
      subGroupColors: subGroupColors ?? this.subGroupColors,
      groupComparator: groupComparator ?? this.groupComparator,
      contentPadding: contentPadding ?? this.contentPadding,
      xAxisStyle: xAxisStyle ?? this.xAxisStyle,
      y1AxisStyle: y1AxisStyle ?? this.y1AxisStyle,
      y2AxisStyle: y2AxisStyle ?? this.y2AxisStyle,
      barStyle: barStyle ?? this.barStyle,
      legendStyle: legendStyle ?? this.legendStyle,
      animation: animation ?? this.animation,
      clickable: clickable ?? this.clickable,
    );
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

  AxisStyle copyWith({
    bool visible,
    int numTicks,
    Color axisColor,
    double strokeWidth,
    StrokeCap strokeCap,
    double preferredStartValue,
    double preferredEndValue,
    TickStyle tickStyle,
    BarChartLabel label,
  }) => AxisStyle(
    visible: visible ?? this.visible,
    numTicks: numTicks ?? this.numTicks,
    axisColor: axisColor ?? this.axisColor,
    strokeWidth: strokeWidth ?? this.strokeWidth,
    strokeCap: strokeCap ?? this.strokeCap,
    preferredStartValue: preferredStartValue ?? this.preferredStartValue,
    preferredEndValue: preferredEndValue ?? this.preferredEndValue,
    tickStyle: tickStyle ?? this.tickStyle,
    label: label ?? this.label,
  );
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

  TickStyle copyWith({
    bool onlyShowTicksAtTwoSides,
    bool lastTickWithUnit,
    TextStyle labelTextStyle,
    String unit,
    Color tickColor,
    double tickMargin,
    int tickDecimal,
    double tickLength,
  }) => TickStyle(
    onlyShowTicksAtTwoSides: onlyShowTicksAtTwoSides ?? this.onlyShowTicksAtTwoSides,
    lastTickWithUnit: lastTickWithUnit ?? this.lastTickWithUnit,
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    unit: unit ?? this.unit,
    tickColor: tickColor ?? this.tickColor,
    tickMargin: tickMargin ?? this.tickMargin,
    tickDecimal: tickDecimal ?? this.tickDecimal,
    tickLength: tickLength ?? this.tickLength,
  );
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

  BarChartBarStyle copyWith({
    double barWidth,
    double barInGroupMargin,
    bool isStacked,
    Color color,
    BarChartBarShape shape,
    Radius topLeft,
    Radius topRight,
    Radius bottomLeft,
    Radius bottomRight,
  }) => BarChartBarStyle(
    barWidth: barWidth ?? this.barWidth,
    barInGroupMargin: barInGroupMargin ?? this.barInGroupMargin,
    isStacked: isStacked ?? this.isStacked,
    color: color ?? this.color,
    shape: shape ?? this.shape,
    topLeft: topLeft ?? this.topLeft,
    topRight: topRight ?? this.topRight,
    bottomLeft: bottomLeft ?? this.bottomLeft,
    bottomRight: bottomRight ?? this.bottomRight,
  );
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

  BarChartLegendStyle copyWith({
    bool visible,
    TextStyle legendTextStyle,
    int preferredNumLegendsOnScreen,
    double minimumSize,
  }) => BarChartLegendStyle(
    visible: visible ?? this.visible,
    legendTextStyle: legendTextStyle ?? this.legendTextStyle,
    preferredNumLegendsOnScreen: preferredNumLegendsOnScreen ?? this.preferredNumLegendsOnScreen,
    minimumSize: minimumSize ?? this.minimumSize,
  );
}

class BarChartAnimation {
  final bool animateData;
  final Duration dataAnimationDuration;

  const BarChartAnimation({
    this.animateData = false,
    this.dataAnimationDuration = const Duration(milliseconds: 1000),
  });

  BarChartAnimation copyWith({
    bool animateData,
    Duration dataAnimationDuration,
  }) => BarChartAnimation(
    animateData: animateData ?? this.animateData,
    dataAnimationDuration: dataAnimationDuration ?? this.dataAnimationDuration,
  );
}