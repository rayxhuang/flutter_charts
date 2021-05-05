import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';

import 'chart_canvas_painter.dart';

@immutable
class ChartCanvasMini extends StatelessWidget {
  final Size canvasSize;
  final double length;
  final BarChartStyle style;

  final BarChartType type;
  final List<String> xGroups;
  final List<String> subGroups;
  final List<double> valueRange;
  final double xSectionLength;
  final List<BarChartDataDouble> bars;
  final List<BarChartDataDoubleGrouped> groupedBars;
  final Map<String, Color> subGroupColors;

  const ChartCanvasMini._({
    @required this.type,
    @required this.xGroups,
    @required this.valueRange,
    @required this.xSectionLength,
    @required this.canvasSize,
    @required this.length,
    this.style = const BarChartStyle(),
    this.bars,
    this.groupedBars,
    this.subGroups,
    this.subGroupColors,
  });

  factory ChartCanvasMini.ungrouped({
    @required List<String> xGroups,
    @required List<double> valueRange,
    @required double xSectionLength,
    @required Size canvasSize,
    @required double length,
    @required List<BarChartDataDouble> bars,
    BarChartStyle style = const BarChartStyle(),
  }) {
    return ChartCanvasMini._(
      type: BarChartType.Ungrouped,
      xGroups: xGroups,
      valueRange: valueRange,
      xSectionLength: xSectionLength,
      canvasSize: canvasSize,
      length: length,
      style: style,
      bars: bars,
    );
  }

  factory ChartCanvasMini.grouped({
    @required List<String> xGroups,
    @required List<String> subGroups,
    @required List<double> valueRange,
    @required double xSectionLength,
    @required Size canvasSize,
    @required double length,
    @required List<BarChartDataDoubleGrouped> groupedBars,
    @required Map<String, Color> subGroupColors,
    BarChartStyle style = const BarChartStyle(),
    bool isStacked = false,
  }) {
    return ChartCanvasMini._(
      type: isStacked ? BarChartType.GroupedStacked : BarChartType.Grouped,
      xGroups: xGroups,
      subGroups: subGroups,
      subGroupColors: subGroupColors,
      valueRange: valueRange,
      xSectionLength: xSectionLength,
      canvasSize: canvasSize,
      length: length,
      style: style,
      groupedBars: groupedBars,
    );
  }

  Size get size => canvasSize;

  @override
  Widget build(BuildContext context) {
    int numGroups;
    double barWidth;
    if (type == BarChartType.GroupedStacked || type == BarChartType.Ungrouped) { numGroups = 1; }
    else { numGroups = subGroups.length; }
    barWidth = (xSectionLength - 2) / numGroups;
    return SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: CustomPaint(
        painter: DataPainter.mini(
          type: type,
          xGroups: xGroups,
          subGroups: subGroups,
          subGroupColors: subGroupColors,
          valueRange: valueRange,
          xLength: canvasSize.width,
          style: BarChartStyle(
            barStyle: BarChartBarStyle(
              barWidth: barWidth
            ),
            groupMargin: 1,
          ),
          bars: bars,
          groupedBars: groupedBars,
        ),
        size: Size(length, size.height),
      ),
    );
  }
}