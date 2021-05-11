import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';

mixin AxisInfo {
  // Calculate each section's length, if returned a list of two
  // this indicates a overwrite bar width is calculated
  List<double> calculateXSectionLength({
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
    @required double canvasWidth,
  }) {
    final double totalBarWidth = dataModel.numBarsInGroups * style.barStyle.barWidth;
    final double totalGroupMargin = style.groupMargin * 2;
    final double totalInGroupMargin = style.barStyle.barInGroupMargin * (dataModel.numBarsInGroups - 1);
    final double xSectionLengthCalculatedFromData = totalBarWidth + totalGroupMargin + totalInGroupMargin;
    double xSectionLengthAvailable = canvasWidth / dataModel.xGroups.length;
    if (xSectionLengthCalculatedFromData > xSectionLengthAvailable) {
      return [xSectionLengthCalculatedFromData];
    } else {
      double newBarWidth =
          (xSectionLengthAvailable - totalGroupMargin - totalInGroupMargin) /
              dataModel.numBarsInGroups;
      return [xSectionLengthAvailable, newBarWidth];
    }
  }
  
  double getXSectionLengthFromBarWidth({
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
    @required double barWidth,
  }) {
    double totalBarWidth = dataModel.numBarsInGroups * barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin = style.barStyle.barInGroupMargin * (dataModel.numBarsInGroups - 1);
    return totalBarWidth + totalGroupMargin + totalInGroupMargin;
  }

  double getXAxisTotalLength({
    @required ModularBarChartData dataModel,
    @required double canvasWidth,
    @required double xSectionLength,
  }) => [xSectionLength * dataModel.xGroups.length, canvasWidth].reduce(max);

  double getVerticalAxisCombinedWidth({
    @required double axisMaxValue, 
    @required AxisStyle style, 
    bool isMini = false,
  }) {
    final double label = isMini ? 0 : getVerticalAxisLabelWidth(label: style.label);
    return label + getVerticalAxisWidth(max: axisMaxValue, style: style, isMini: isMini);
  }

  double getVerticalAxisLabelWidth({@required BarChartLabel label}) => label.text == '' ? 0 : 5 + StringSize.getHeight(label);

  double getVerticalAxisWidth({
    @required double max,
    @required AxisStyle style,
    bool isMini = false,
  }) => StringSize.getWidthOfString(max.toStringAsFixed(style.tickStyle.tickDecimal), style.tickStyle.labelTextStyle)
          + style.tickStyle.tickMargin + (isMini ? 0 : style.tickStyle.tickLength);
}