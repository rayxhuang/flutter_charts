import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

import '../modular_fancy_bar_chart.dart';

@immutable
class DataPainter extends CustomPainter {
  final List<String> xGroups;
  final List<String> subGroups;
  final Map<String, Color> subGroupColors;
  final BarChartType type;
  final double xSectionLength;
  final List<double> valueRange;
  final List<BarChartDataDouble> bars;
  final List<BarChartDataDoubleGrouped> groupedBars;

  final BarChartStyle style;
  final BarChartBarStyle barStyle;

  DataPainter._({
    @required this.xGroups,
    @required this.type,
    @required this.valueRange,
    @required this.xSectionLength,
    this.bars,
    this.subGroups,
    this.subGroupColors,
    this.groupedBars,
    this.style = const BarChartStyle(),
    this.barStyle = const BarChartBarStyle(),
  });

  factory DataPainter.ungrouped({
    @required List<String> xGroups,
    @required List<double> valueRange,
    @required double xSectionLength,
    BarChartStyle style = const BarChartStyle(),
    BarChartBarStyle barStyle = const BarChartBarStyle(),
    List<BarChartDataDouble> bars = const [],
  }) {
    return DataPainter._(
      type: BarChartType.Ungrouped,
      xGroups: xGroups,
      bars: bars,
      valueRange: valueRange,
      xSectionLength: xSectionLength,
      style: style,
      barStyle: barStyle,
    );
  }

  factory DataPainter.grouped({
    @required bool isStacked,
    @required List<String> xGroups,
    @required List<String> subGroups,
    @required Map<String, Color> subGroupColors,
    @required List<double> valueRange,
    @required double xSectionLength,
    @required List<BarChartDataDoubleGrouped> groupedBars,
    BarChartStyle style = const BarChartStyle(),
    BarChartBarStyle barStyle = const BarChartBarStyle(),
  }) {
    return DataPainter._(
      type: isStacked ? BarChartType.GroupedStacked : BarChartType.Grouped,
      xGroups: xGroups,
      subGroups: subGroups,
      subGroupColors: subGroupColors,
      groupedBars: groupedBars,
      valueRange: valueRange,
      xSectionLength: xSectionLength,
      style: style,
      barStyle: barStyle,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    p..color = Colors.white;
    canvas.drawLine(Offset(0,0), Offset(size.width,size.height), p);
    canvas.drawLine(Offset(0,size.height), Offset(size.width,0), p);

    drawData(canvas, (valueRange[1] - valueRange[0]) / size.height, Offset(0, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) { return false; }

  void drawData(Canvas canvas, double yUnitPerPixel, Offset bottomLeft) {
    //This is the bar paint
    Paint paint = Paint();
    //Draw data as bars on grid
    if (type == BarChartType.Ungrouped) {
      for (BarChartDataDouble bar in bars) {
        BarChartBarStyle _barStyle = bar.style;
        if (_barStyle == null) { _barStyle = barStyle; }
        paint..color = _barStyle.color;
        int i = xGroups.indexOf(bar.group);
        double x1FromBottomLeft = i * xSectionLength + style.groupMargin;
        double x2FromBottomLeft = x1FromBottomLeft + style.barWidth;
        double y1FromBottomLeft = (bar.data - valueRange[0]) / yUnitPerPixel;
        drawRect(canvas, bottomLeft, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint);
      }
    } else if (type == BarChartType.Grouped) {
      for (int j = 0; j < groupedBars.length; j++) {
        int i = xGroups.indexOf(groupedBars[j].mainGroup);
        List<BarChartDataDouble> data = groupedBars[j].dataList;
        for (int i = 0; i < data.length; i++) {
          BarChartBarStyle _barStyle = barStyle;
          // Grouped Data must use grouped Color
          paint..color = subGroupColors[data[i].group];
          double inGroupMargin = i == 0
              ? 0
              : style.barMargin;
          double x1FromBottomLeft = j * xSectionLength + i * style.barWidth + style.groupMargin + inGroupMargin * i;
          double x2FromBottomLeft = x1FromBottomLeft + style.barWidth;
          double y1FromBottomLeft = (data[i].data - valueRange[0]) / yUnitPerPixel;
          drawRect(canvas, bottomLeft, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint);
        }
      }
    } else if (type == BarChartType.GroupedStacked) {
      // TODO Values cannot be negative
      for (int j = 0; j < groupedBars.length; j++) {
        int i = xGroups.indexOf(groupedBars[j].mainGroup);
        List<BarChartDataDouble> data = groupedBars[j].dataList;
        double totalHeight = 0;
        data.forEach((data) { totalHeight += data.data; });
        double previousYValue = 0;
        for (int i = data.length - 1; i  >= 0; i--) {
          BarChartBarStyle _barStyle = barStyle;
          // Grouped Data must use grouped Color
          paint..color = subGroupColors[data[i].group];
          double x1FromBottomLeft = j * xSectionLength + style.groupMargin;
          double x2FromBottomLeft = x1FromBottomLeft + style.barWidth;
          double y1FromBottomLeft = (totalHeight - valueRange[0] - previousYValue) / yUnitPerPixel;
          drawRect(canvas, bottomLeft, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint, last: false);
          previousYValue += data[i].data;
        }
      }
    }
  }

  void drawRect(Canvas canvas, Offset bottomLeft, double x1, double x2, double y1, BarChartBarStyle style, Paint paint, {bool last = true}) {
    Rect rect = Rect.fromPoints(
      //_bottomLeft.translate(x1, -y1 * barAnimationFraction),
        bottomLeft.translate(x1, -y1 * 1),
        bottomLeft.translate(x2, 0)
    );
    if (style.shape == BarChartBarShape.RoundedRectangle && last) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: style.topLeft,
          topRight: style.topRight,
          bottomLeft: style.bottomLeft,
          bottomRight: style.bottomRight,
        ),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool hitTest(Offset position) {
    // TODO: implement hitTest
    return super.hitTest(position);
  }
}