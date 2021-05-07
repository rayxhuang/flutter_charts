import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/drawingMixin.dart';

@immutable
class MiniCanvasPainter extends CustomPainter with Drawing{
  final Size size;
  final ModularBarChartData dataModel;
  final BarChartStyle style;

  MiniCanvasPainter({
    @required this.size,
    @required this.dataModel,
    this.style = const BarChartStyle(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double xSectionLength = size.width / dataModel.xGroups.length;
    final double y1UnitPerPixel = (dataModel.y1ValueRange[2] - dataModel.y1ValueRange[0]) / size.height;
    final BarChartType type = dataModel.type;
    double y2UnitPerPixel = double.negativeInfinity;
    if (type == BarChartType.GroupedSeparated) {
      y2UnitPerPixel = (dataModel.y2ValueRange[2] - dataModel.y2ValueRange[0]) / size.height;
    }

    if (type == BarChartType.Ungrouped) {
      drawUngroupedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        y1UnitPerPixel: y1UnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.Grouped) {
      drawGroupedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        y1UnitPerPixel: y1UnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedStacked) {
      drawGroupedStackedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        y1UnitPerPixel: y1UnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedSeparated) {
      drawGroupedSeparatedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        y1UnitPerPixel: y1UnitPerPixel,
        y2UnitPerPixel: y2UnitPerPixel,
        bottomLeft: Offset(0, size.height),
      );
    }
  }

  void drawUngroupedData({
    @required Canvas canvas,
    @required double xSectionLength,
    @required double y1UnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    for (BarChartDataDouble bar in dataModel.bars) {
      paint..color = style.barStyle.color;
      int i = dataModel.xGroups.indexOf(bar.group);
      double x1FromBottomLeft = i * xSectionLength + style.groupMargin;
      double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
      double y1FromBottomLeft = (bar.data - dataModel.y1ValueRange[0]) / y1UnitPerPixel;
      drawSimpleBar(
        canvas: canvas,
        data: bar,
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        x2: x2FromBottomLeft,
        y1: y1FromBottomLeft,
        style: style.barStyle,
        paint: paint,
      );
    }
  }

  void drawGroupedData({
    @required Canvas canvas,
    @required double xSectionLength,
    @required double y1UnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    for (int j = 0; j < dataModel.groupedBars.length; j++) {
      int i = dataModel.xGroups.indexOf(dataModel.groupedBars[j].mainGroup);
      List<BarChartDataDouble> barList = dataModel.groupedBars[j].dataList;
      for (int i = 0; i < barList.length; i++) {
        // Grouped Data must use grouped Color
        paint..color = dataModel.subGroupColors[barList[i].group];
        double inGroupMargin = i == 0
            ? 0
            : style.barStyle.barInGroupMargin;
        double x1FromBottomLeft = j * xSectionLength + i * style.barStyle.barWidth + style.groupMargin + inGroupMargin * i;
        double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
        double y1FromBottomLeft = (barList[i].data - dataModel.y1ValueRange[0]) / y1UnitPerPixel;
        drawSimpleBar(
          canvas: canvas,
          data: barList[i],
          bottomLeft: bottomLeft,
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          style: style.barStyle,
          paint: paint,
        );
      }
    }
  }

  void drawGroupedStackedData({
    @required Canvas canvas,
    @required double xSectionLength,
    @required double y1UnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    // TODO Values cannot be negative
    for (int j = 0; j < dataModel.groupedBars.length; j++) {
      int i = dataModel.xGroups.indexOf(dataModel.groupedBars[j].mainGroup);
      List<BarChartDataDouble> barList = dataModel.groupedBars[j].dataList;
      double totalHeight = 0;
      barList.forEach((data) { totalHeight += data.data; });
      double previousYValue = 0;
      for (int i = barList.length - 1; i  >= 0; i--) {
        // Grouped Data must use grouped Color
        paint..color = dataModel.subGroupColors[barList[i].group];
        double x1FromBottomLeft = j * xSectionLength + style.groupMargin;
        double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
        double y1FromBottomLeft = (totalHeight - dataModel.y1ValueRange[0] - previousYValue) / y1UnitPerPixel;
        drawSimpleBar(
          canvas: canvas,
          data: barList[i],
          bottomLeft: bottomLeft,
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          style: style.barStyle,
          paint: paint,
          last: false,
        );
        previousYValue += barList[i].data;
      }
    }
  }

  void drawGroupedSeparatedData({
    @required Canvas canvas,
    @required double xSectionLength,
    @required double y1UnitPerPixel,
    @required double y2UnitPerPixel,
    @required Offset bottomLeft,
  }) {
    drawUngroupedData(
      canvas: canvas,
      xSectionLength: xSectionLength,
      y1UnitPerPixel: y1UnitPerPixel,
      bottomLeft: bottomLeft,
    );

    //This is the bar paint
    Paint paint = Paint();
    for (int i = 0; i < dataModel.points.length; i++) {
      final BarChartDataDouble current = dataModel.points[i];
      //Draw data as bars on grid
      //paint..color = style.barStyle.color;
      paint..color = Colors.blue;
      paint..strokeWidth = 2;
      double x1FromBottomLeft = i * xSectionLength + style.groupMargin + style.barStyle.barWidth / 2;
      double y1FromBottomLeft = (current.data - dataModel.y2ValueRange[0]) / y2UnitPerPixel;
      Offset currentPosition = bottomLeft.translate(x1FromBottomLeft, -y1FromBottomLeft);
      drawSimplePoint(
        canvas: canvas,
        data: current,
        center: currentPosition,
        radius: 4,
        paint: paint,
      );

      BarChartDataDouble previous, next;
      double differenceOfPrevious, differenceOfNext;
      Offset previousPosition, nextPosition;
      if (i != 0) {
        previous = dataModel.points[i - 1];
        differenceOfPrevious = ((current.data - previous.data) / 2).abs();
        double value = current.data < previous.data
            ? current.data + differenceOfPrevious
            : current.data - differenceOfPrevious;
        double y = (value - dataModel.y2ValueRange[0]) / y2UnitPerPixel;
        previousPosition = bottomLeft.translate(i * xSectionLength, -y);
        canvas.drawLine(currentPosition, previousPosition, paint);
      }
      if (i != dataModel.points.length - 1) {
        next = dataModel.points[i + 1];
        differenceOfNext = ((current.data - next.data) / 2).abs();
        double value = current.data < next.data
            ? current.data + differenceOfNext
            : current.data - differenceOfNext;
        double y = (value - dataModel.y2ValueRange[0]) / y2UnitPerPixel;
        nextPosition = bottomLeft.translate((i + 1) * xSectionLength, -y);
        canvas.drawLine(currentPosition, nextPosition, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MiniCanvasPainter oldDelegate) => false;
}