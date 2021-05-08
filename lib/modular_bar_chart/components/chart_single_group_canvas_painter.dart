import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:touchable/touchable.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/drawing_mixin.dart';

@immutable
class SingleGroupDataPainter extends CustomPainter with Drawing{
  final BuildContext context;
  final double xSectionLength;
  final double barWidth;
  final Animation<double> dataAnimation;
  final int dataIndex;
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final Function(BarChartDataDouble, TapDownDetails) onBarSelected;
  final bool groupSelected;
  final BarChartDataDouble barSelected;
  final bool clickable;

  const SingleGroupDataPainter({
    @required this.context,
    @required this.dataIndex,
    @required this.dataModel,
    @required this.xSectionLength,
    @required this.barWidth,
    this.style = const BarChartStyle(),
    this.dataAnimation,
    this.onBarSelected,
    this.groupSelected,
    this.barSelected,
    this.clickable = true,
  }) : super(repaint: dataAnimation);

  @override
  void paint(Canvas originCanvas, Size size) {
    var canvas = TouchyCanvas(context, originCanvas);
    final double y1UnitPerPixel = (dataModel.y1ValueRange[2] - dataModel.y1ValueRange[0]) / size.height;
    final BarChartType type = dataModel.type;
    double y2UnitPerPixel = double.negativeInfinity;
    if (type == BarChartType.GroupedSeparated) {
      y2UnitPerPixel = (dataModel.y2ValueRange[2] - dataModel.y2ValueRange[0]) / size.height;
    }

    if (type == BarChartType.Ungrouped) {
      drawUngroupedData(
        originCanvas: originCanvas,
        canvas: canvas,
        y1UnitPerPixel: y1UnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.Grouped) {
      drawGroupedData(
        originCanvas: originCanvas,
        canvas: canvas,
        y1UnitPerPixel: y1UnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedStacked) {
      drawGroupedStackedData(
        originCanvas: originCanvas,
        canvas: canvas,
        y1UnitPerPixel: y1UnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedSeparated) {
      drawGroupedSeparatedData(
        originCanvas: originCanvas,
        canvas: canvas,
        y1UnitPerPixel: y1UnitPerPixel,
        y2UnitPerPixel: y2UnitPerPixel,
        bottomLeft: Offset(0, size.height),
        xSectionLength: size.width,
      );
    }
  }

  void drawUngroupedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required double y1UnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDouble bar = dataModel.bars[dataIndex];
    //Draw data as bars on grid
    paint..color = style.barStyle.color;
    double x1FromBottomLeft = style.groupMargin;
    double x2FromBottomLeft = x1FromBottomLeft + barWidth;
    double y1FromBottomLeft = (bar.data - dataModel.y1ValueRange[0]) / y1UnitPerPixel;
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

    if (dataAnimation.value == 1) {
      drawValueOnBar(
        canvas: originCanvas,
        value: bar.data.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        y1: y1FromBottomLeft,
        barWidth: barWidth,
      );
    }
  }

  void drawGroupedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required double y1UnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    final List<BarChartDataDouble> data = dataModel.groupedBars[dataIndex].dataList;
    DataForBarToBeDrawnLast savedBar;
    //Draw data as bars on grid
    for (int i = 0; i < data.length; i++) {
      // Grouped Data must use defined Color for its group
      paint..color = dataModel.subGroupColors[data[i].group];
      double inGroupMargin = i == 0
          ? 0
          : style.barStyle.barInGroupMargin;
      double x1FromBottomLeft = i * barWidth + style.groupMargin + inGroupMargin * i;
      double x2FromBottomLeft = x1FromBottomLeft + barWidth;
      double y1FromBottomLeft = (data[i].data - dataModel.y1ValueRange[0]) / y1UnitPerPixel;

      if (groupSelected && data[i] == barSelected) {
        savedBar = DataForBarToBeDrawnLast(
          data: data[i],
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          paint: Paint()..color = paint.color,
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
        barAnimationFraction: dataAnimation.value,
        onBarSelected: (data, details) { onBarSelected(data, details); },
      );

      if (dataAnimation.value == 1) {
        drawValueOnBar(
          canvas: originCanvas,
          value: data[i].data.toStringAsFixed(0),
          bottomLeft: bottomLeft,
          x1: x1FromBottomLeft,
          y1: y1FromBottomLeft,
          barWidth: barWidth,
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
    @required double y1UnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    //Draw data as bars on grid
    final List<BarChartDataDouble> data = dataModel.groupedBars[dataIndex].dataList;
    DataForBarToBeDrawnLast savedBar;
    double totalHeight = 0, previousYValue = 0, lastBarX1, lastBarY1;
    data.forEach((data) { totalHeight += data.data; });
    for (int i = data.length - 1; i >= 0; i--) {
      // Grouped Data must use grouped Color
      paint..color = dataModel.subGroupColors[data[i].group];
      double x1FromBottomLeft = style.groupMargin;
      double x2FromBottomLeft = x1FromBottomLeft + barWidth;
      double y1FromBottomLeft = (totalHeight - dataModel.y1ValueRange[0] - previousYValue) / y1UnitPerPixel;
      if (i == data.length - 1) {
        lastBarX1 = x1FromBottomLeft;
        lastBarY1 = y1FromBottomLeft;
      }

      if (groupSelected && data[i] == barSelected) {
        double y2FromBottomLeft = (y1FromBottomLeft - data[i].data / y1UnitPerPixel);
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

    if (dataAnimation.value == 1) {
      drawValueOnBar(
        canvas: originCanvas,
        value: totalHeight.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x1: lastBarX1,
        y1: lastBarY1,
        barWidth: barWidth,
      );
    }
  }

  void drawGroupedSeparatedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required double y1UnitPerPixel,
    @required double y2UnitPerPixel,
    @required Offset bottomLeft,
    @required double xSectionLength,
  }) {
    drawUngroupedData(
      originCanvas: originCanvas,
      canvas: canvas,
      y1UnitPerPixel: y1UnitPerPixel,
      bottomLeft: bottomLeft,
    );

    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDouble current = dataModel.points[dataIndex];
    //Draw data as bars on grid
    paint..color = Colors.blue;
    paint..strokeWidth = 2;
    double x1FromBottomLeft = style.groupMargin + barWidth / 2;
    double y1FromBottomLeft = (current.data - dataModel.y2ValueRange[0]) / y2UnitPerPixel;
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
      double y = (value - dataModel.y2ValueRange[0]) / y2UnitPerPixel;
      previousPosition = bottomLeft.translate(0, -y);
      originCanvas.drawLine(currentPosition, previousPosition, paint);
    }
    if (dataIndex != dataModel.points.length - 1) {
      next = dataModel.points[dataIndex + 1];
      differenceOfNext = ((current.data - next.data) / 2).abs();
      double value = current.data < next.data
          ? current.data + differenceOfNext
          : current.data - differenceOfNext;
      double y = (value - dataModel.y2ValueRange[0]) / y2UnitPerPixel;
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

  @override
  bool shouldRepaint(covariant SingleGroupDataPainter oldDelegate) {
    return oldDelegate.groupSelected != groupSelected
        || oldDelegate.barSelected != barSelected;
  }
}