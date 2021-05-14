import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:touchable/touchable.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/drawing_mixin.dart';

@immutable
class SingleGroupDataPainter extends CustomPainter with Drawing{
  final BuildContext context;
  final int dataIndex;
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final DisplayInfo displayInfo;
  final Animation<double> dataAnimation;
  final BarChartDataDouble barSelected;
  final Function(BarChartDataDouble, TapDownDetails) onBarSelected;
  final bool groupSelected, clickable, showAverageLine, showValueOnBar, showGridLine;

  const SingleGroupDataPainter({
    @required this.context,
    @required this.dataIndex,
    @required this.dataModel,
    @required this.displayInfo,
    @required this.style,
    this.dataAnimation,
    this.onBarSelected,
    this.groupSelected,
    this.barSelected,
    this.clickable = true,
    this.showAverageLine = false,
    this.showValueOnBar = false,
    this.showGridLine = false,
  }) : super(repaint: dataAnimation);

  @override
  void paint(Canvas originCanvas, Size size) {
    var canvas = TouchyCanvas(context, originCanvas);
    final BarChartType type = dataModel.type;

    if (type == BarChartType.Ungrouped) {
      drawUngroupedData(
        originCanvas: originCanvas,
        canvas: canvas,
        bottomLeft: Offset(0, size.height),
        height: size.height,
      );
    } else if (type == BarChartType.Grouped) {
      drawGroupedData(
        originCanvas: originCanvas,
        canvas: canvas,
        bottomLeft: Offset(0, size.height),
        height: size.height,
      );
    } else if (type == BarChartType.GroupedStacked) {
      drawGroupedStackedData(
        originCanvas: originCanvas,
        canvas: canvas,
        bottomLeft: Offset(0, size.height),
        height: size.height,
      );
    } else if (type == BarChartType.GroupedSeparated) {
      drawGroupedSeparatedData(
        originCanvas: originCanvas,
        canvas: canvas,
        bottomLeft: Offset(0, size.height),
        xSectionLength: size.width,
        height: size.height,
      );
    }
  }

  void drawUngroupedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required Offset bottomLeft,
    @required double height,
  }) {
    // Grid line
    if (showGridLine) { drawGrid(canvas: originCanvas, bottomLeft: bottomLeft, height: height); }

    // Average line
    if (showAverageLine) {
      final double avgYValue = (dataModel.y1Average - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;
      drawAverageLine(
        canvas: originCanvas,
        length: displayInfo.xSectionWidth,
        start: bottomLeft.translate(0, -avgYValue),
      );
    }

    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDouble bar = dataModel.bars[dataIndex];
    //Draw data as bars on grid
    paint..color = style.barStyle.color;
    double x1FromBottomLeft = style.groupMargin;
    double x2FromBottomLeft = x1FromBottomLeft + displayInfo.barWidth;
    double y1FromBottomLeft = (bar.data - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;

    if (bar == barSelected) {
      double x1 = x1FromBottomLeft - 2;
      double x2 = x2FromBottomLeft + 2;
      double y = y1FromBottomLeft + 2;
      drawBarHighlight(
        canvas: originCanvas,
        bottomLeft: bottomLeft,
        x1: x1,
        x2: x2,
        y1: y,
        barAnimationFraction: dataAnimation.value,
      );
    }
    drawBar(
      canvas: clickable ? canvas : originCanvas,
      data: bar,
      bottomLeft: bottomLeft,
      x1: x1FromBottomLeft,
      x2: x2FromBottomLeft,
      y1: y1FromBottomLeft,
      style: style.barStyle,
      paint: paint,
      barAnimationFraction: dataAnimation.value,
      onBarSelected: (data, details) {
        onBarSelected(data, details);
      },
    );

    if (dataAnimation.value == 1 && showValueOnBar) {
      drawValueOnBar(
        canvas: originCanvas,
        value: bar.data.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        y1: y1FromBottomLeft,
        barWidth: displayInfo.barWidth,
      );
    }
  }

  void drawGroupedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required Offset bottomLeft,
    @required double height,
  }) {
    // Grid line
    if (showGridLine) { drawGrid(canvas: originCanvas, bottomLeft: bottomLeft, height: height); }

    // Average line
    if (showAverageLine) {
      final double avgYValue = (dataModel.y1Average - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;
      drawAverageLine(
        canvas: originCanvas,
        length: displayInfo.xSectionWidth,
        start: bottomLeft.translate(0, -avgYValue),
      );
    }

    //This is the bar paint
    Paint paint = Paint();
    final List<BarChartDataDouble> dataList = dataModel.groupedBars[dataIndex].dataList;
    DataForBarToBeDrawnLast savedBar;
    final List<double> _x = [], _y = [];
    //Draw data as bars on grid
    for (int i = 0; i < dataList.length; i++) {
      // Grouped Data must use defined Color for its group
      paint..color = dataModel.xSubGroupColorMap[dataList[i].group];
      double inGroupMargin = i == 0
          ? 0
          : style.barStyle.barInGroupMargin;
      double x1FromBottomLeft = i * displayInfo.barWidth + style.groupMargin + inGroupMargin * i;
      double x2FromBottomLeft = x1FromBottomLeft + displayInfo.barWidth;
      double y1FromBottomLeft = (dataList[i].data - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;

      _x.add(x1FromBottomLeft);
      _y.add(y1FromBottomLeft);

      if (groupSelected && dataList[i] == barSelected) {
        savedBar = DataForBarToBeDrawnLast(
          data: dataList[i],
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          paint: Paint()..color = paint.color,
        );
      }

      drawBar(
        canvas: clickable ? canvas : originCanvas,
        data: dataList[i],
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        x2: x2FromBottomLeft,
        y1: y1FromBottomLeft,
        style: style.barStyle,
        paint: paint,
        barAnimationFraction: dataAnimation.value,
        onBarSelected: (data, details) { onBarSelected(data, details); },
      );
    }

    if (dataAnimation.value == 1 && showValueOnBar) {
      for (int i = 0; i < dataList.length; i++) {
        drawValueOnBar(
          canvas: originCanvas,
          value: dataList[i].data.toStringAsFixed(0),
          bottomLeft: bottomLeft,
          x1: _x[i],
          y1: _y[i],
          barWidth: displayInfo.barWidth,
        );
      }
    }

    if (savedBar != null) {
      drawBarHighlight(
        canvas: originCanvas,
        bottomLeft: bottomLeft,
        x1: savedBar.x1 - 2,
        x2: savedBar.x2 + 2,
        y1: savedBar.y1 + 2,
        barAnimationFraction: dataAnimation.value,
      );
      drawBar(
        canvas: clickable ? canvas : originCanvas,
        data: savedBar.data,
        bottomLeft: bottomLeft,
        x1: savedBar.x1,
        x2: savedBar.x2,
        y1: savedBar.y1,
        style: style.barStyle,
        paint: savedBar.paint,
        barAnimationFraction: dataAnimation.value,
        onBarSelected: (data, details) { onBarSelected(data, details); },
      );
    }
  }

  void drawGroupedStackedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required Offset bottomLeft,
    @required double height,
  }) {
    // Grid line
    if (showGridLine) { drawGrid(canvas: originCanvas, bottomLeft: bottomLeft, height: height); }

    // Average line
    if (showAverageLine) {
      final double avgYValue = (dataModel.y1Average - displayInfo.y1Min) / displayInfo.y1UnitPerPixel;
      drawAverageLine(
        canvas: originCanvas,
        length: displayInfo.xSectionWidth,
        start: bottomLeft.translate(0, -avgYValue),
      );
    }

    //This is the bar paint
    Paint paint = Paint();
    //Draw data as bars on grid
    final List<BarChartDataDouble> data = dataModel.groupedBars[dataIndex].dataList;
    DataForBarToBeDrawnLast savedBar;
    double totalHeight = 0, previousYValue = 0, lastBarX1, lastBarY1;
    data.forEach((data) { totalHeight += data.data; });
    for (int i = data.length - 1; i >= 0; i--) {
      // Grouped Data must use grouped Color
      paint..color = dataModel.xSubGroupColorMap[data[i].group];
      double x1FromBottomLeft = style.groupMargin;
      double x2FromBottomLeft = x1FromBottomLeft + displayInfo.barWidth;
      double y1FromBottomLeft = (totalHeight - displayInfo.y1Min - previousYValue) / displayInfo.y1UnitPerPixel;
      if (i == data.length - 1) {
        lastBarX1 = x1FromBottomLeft;
        lastBarY1 = y1FromBottomLeft;
      }

      if (groupSelected && data[i] == barSelected) {
        double y2FromBottomLeft = (y1FromBottomLeft - data[i].data / displayInfo.y1UnitPerPixel);
        savedBar = DataForBarToBeDrawnLast(
          data: data[i],
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          y2: y2FromBottomLeft,
          paint: Paint()..color = paint.color,
          isLastInStack: i == 0 ? true : false,
        );
      }

      drawBar(
        canvas: clickable ? canvas : originCanvas,
        data: data[i],
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        x2: x2FromBottomLeft,
        y1: y1FromBottomLeft,
        style: style.barStyle,
        paint: paint,
        last: false,
        barAnimationFraction: dataAnimation.value,
        onBarSelected: (data, details) { onBarSelected(data, details); },
      );

      previousYValue += data[i].data;

      if (savedBar != null) {
        drawBarHighlight(
          canvas: originCanvas,
          bottomLeft: bottomLeft,
          x1: savedBar.x1 - 2,
          x2: savedBar.x2 + 2,
          y1: savedBar.y1 + 2,
          y2: savedBar.y2 - (savedBar.isLastInStack ? 0 : 2),
          isStacked: true,
          barAnimationFraction: dataAnimation.value,
        );
        drawBar(
          canvas: clickable ? canvas : originCanvas,
          data: savedBar.data,
          bottomLeft: bottomLeft,
          x1: savedBar.x1,
          x2: savedBar.x2,
          y1: savedBar.y1,
          y2: savedBar.y2,
          style: style.barStyle,
          paint: savedBar.paint,
          barAnimationFraction: dataAnimation.value,
          onBarSelected: (data, details) { onBarSelected(data, details); },
        );
      }
    }

    if (dataAnimation.value == 1 && showValueOnBar) {
      drawValueOnBar(
        canvas: originCanvas,
        value: totalHeight.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x1: lastBarX1,
        y1: lastBarY1,
        barWidth: displayInfo.barWidth,
      );
    }
  }

  void drawGroupedSeparatedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required Offset bottomLeft,
    @required double xSectionLength,
    @required double height,
  }) {
    // Grid line
    if (showGridLine) { drawGrid(canvas: originCanvas, bottomLeft: bottomLeft, height: height); }

    // Average line
    if (showAverageLine) {
      final double avgY2Value = (dataModel.y2Average - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
      drawAverageLine(
        canvas: originCanvas,
        length: xSectionLength,
        start: bottomLeft.translate(0, -avgY2Value),
        color: Colors.white,
      );
    }

    drawUngroupedData(
      originCanvas: originCanvas,
      canvas: canvas,
      bottomLeft: bottomLeft,
      height: height,
    );

    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDouble current = dataModel.points[dataIndex];
    //Draw data as bars on grid
    paint..color = Colors.blue;
    paint..strokeWidth = 2;
    double x1FromBottomLeft = style.groupMargin + displayInfo.barWidth / 2;
    double y1FromBottomLeft = (current.data - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
    Offset currentPosition = bottomLeft.translate(x1FromBottomLeft, -y1FromBottomLeft);
    drawPoint(
      canvas: clickable ? canvas : originCanvas,
      data: current,
      center: currentPosition,
      radius: 4,
      paint: paint,
      onBarSelected: (data, details) { onBarSelected(data, details); },
    );

    BarChartDataDouble previous, next;
    double differenceOfPrevious, differenceOfNext;
    Offset previousPosition, nextPosition;
    if (dataIndex != 0) {
      previous = dataModel.points[dataIndex - 1];
      differenceOfPrevious = ((current.data - previous.data) / 2).abs();
      double value = current.data < previous.data
          ? current.data + differenceOfPrevious
          : current.data - differenceOfPrevious;
      double y = (value - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
      previousPosition = bottomLeft.translate(0, -y);
      originCanvas.drawLine(currentPosition, previousPosition, paint);
    }
    if (dataIndex != dataModel.points.length - 1) {
      next = dataModel.points[dataIndex + 1];
      differenceOfNext = ((current.data - next.data) / 2).abs();
      double value = current.data < next.data
          ? current.data + differenceOfNext
          : current.data - differenceOfNext;
      double y = (value - displayInfo.y2Min) / displayInfo.y2UnitPerPixel;
      nextPosition = bottomLeft.translate(xSectionLength, -y);
      originCanvas.drawLine(currentPosition, nextPosition, paint);
    }

    // Highlight the selected point
    if (current == barSelected && groupSelected) {
      drawPoint(
        canvas: clickable ? canvas : originCanvas,
        data: current,
        center: currentPosition,
        radius: 6,
        paint: paint,
        onBarSelected: (data, details) { onBarSelected(data, details); },
      );
    }
  }

  void drawGrid({
    @required Canvas canvas,
    @required Offset bottomLeft,
    @required double height,
  }) {
    final int numberOfTicksInBetween = style.y1AxisStyle.numTicks - 2;
    if (numberOfTicksInBetween > 0) {
      drawGridLine(
        canvas: canvas,
        numberOfTicksInBetween: numberOfTicksInBetween,
        start: bottomLeft,
        length: displayInfo.xSectionWidth,
        height: height,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SingleGroupDataPainter oldDelegate) {
    return oldDelegate.groupSelected != groupSelected
        || oldDelegate.barSelected != barSelected
        || oldDelegate.drawAverageLine != drawAverageLine;
  }
}