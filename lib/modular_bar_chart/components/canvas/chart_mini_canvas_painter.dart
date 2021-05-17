import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/drawing_mixin.dart';

@immutable
class MiniCanvasPainter extends CustomPainter with Drawing{
  final Size size;
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final DisplayInfo displayInfo;
  Animation<double> dataAnimation;

  MiniCanvasPainter({
    @required this.size,
    @required this.dataModel,
    @required this.displayInfo,
    @required this.style,
    this.dataAnimation,
  }) : super(repaint: dataAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final double xSectionLength = displayInfo.xSectionWidth;
    final BarChartType type = dataModel.type;
    if (type == BarChartType.Ungrouped) {
      drawUngroupedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.Grouped) {
      drawGroupedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedStacked) {
      drawGroupedStackedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedSeparated) {
      drawGroupedSeparatedData(
        canvas: canvas,
        xSectionLength: xSectionLength,
        bottomLeft: Offset(0, size.height),
      );
    }
  }

  void drawUngroupedData({
    @required Canvas canvas,
    @required double xSectionLength,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    for (BarChartDataDouble bar in dataModel.bars) {
      paint..color = style.barStyle.color;
      int i = dataModel.xGroups.indexOf(bar.group);
      double x1FromBottomLeft = i * xSectionLength + style.groupMargin;
      double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
      double y1FromBottomLeft = (bar.data - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;
      drawBar(
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
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    for (int j = 0; j < dataModel.groupedBars.length; j++) {
      List<BarChartDataDouble> barList = dataModel.groupedBars[j].dataList;
      for (int i = 0; i < barList.length; i++) {
        // Grouped Data must use grouped Color
        paint..color = dataModel.xSubGroupColorMap[barList[i].group];
        double inGroupMargin = i == 0
            ? 0
            : style.barStyle.barInGroupMargin;
        double x1FromBottomLeft = j * xSectionLength + i * style.barStyle.barWidth + style.groupMargin + inGroupMargin * i;
        double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
        double y1FromBottomLeft = (barList[i].data - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;
        drawBar(
          canvas: canvas,
          data: barList[i],
          bottomLeft: bottomLeft,
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          style: style.barStyle,
          paint: paint,
          barAnimationFraction: dataAnimation == null ? 1 : dataAnimation.value,
        );
      }
    }
  }

  void drawGroupedStackedData({
    @required Canvas canvas,
    @required double xSectionLength,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    // TODO Values cannot be negative
    for (int j = 0; j < dataModel.groupedBars.length; j++) {
      List<BarChartDataDouble> barList = dataModel.groupedBars[j].dataList;
      double totalHeight = 0;
      barList.forEach((data) { totalHeight += data.data; });
      double previousYValue = 0;
      for (int i = barList.length - 1; i  >= 0; i--) {
        // Grouped Data must use grouped Color
        paint..color = dataModel.xSubGroupColorMap[barList[i].group];
        double x1FromBottomLeft = j * xSectionLength + style.groupMargin;
        double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
        double y1FromBottomLeft = (totalHeight - dataModel.y1ValueRange[0] - previousYValue) / displayInfo.y1UnitPerPixel;
        drawBar(
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
    @required Offset bottomLeft,
  }) {
    drawUngroupedData(
      canvas: canvas,
      xSectionLength: xSectionLength,
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
      double y1FromBottomLeft = (current.data - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
      Offset currentPosition = bottomLeft.translate(x1FromBottomLeft, -y1FromBottomLeft);
      drawPoint(
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
        double y = (value - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
        previousPosition = bottomLeft.translate(i * xSectionLength, -y);
        canvas.drawLine(currentPosition, previousPosition, paint);
      }
      if (i != dataModel.points.length - 1) {
        next = dataModel.points[i + 1];
        differenceOfNext = ((current.data - next.data) / 2).abs();
        double value = current.data < next.data
            ? current.data + differenceOfNext
            : current.data - differenceOfNext;
        double y = (value - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
        nextPosition = bottomLeft.translate((i + 1) * xSectionLength, -y);
        canvas.drawLine(currentPosition, nextPosition, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MiniCanvasPainter oldDelegate) => true;
}