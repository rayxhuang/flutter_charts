import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/drawing_mixin.dart';
import 'package:provider/provider.dart';
import 'package:touchable/touchable.dart';

import 'chart_mini_canvas_painter.dart';

@immutable
class MultipleGroupedCanvas extends StatelessWidget {
  final Size size;
  final int groupIndex;
  final bool isSelected;
  final BarChartDataDouble barSelected;
  final Animation<double> dataAnimation;
  final Function(int, BarChartDataDouble, TapDownDetails) onBarSelected;

  const MultipleGroupedCanvas({
    this.size,
    this.groupIndex,
    this.isSelected,
    this.barSelected,
    this.dataAnimation,
    this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayInfo>(
      builder: (context, displayInfo, child) {
        final ModularBarChartData dataModel = displayInfo.dataModel;
        final BarChartStyle style = displayInfo.style;
        final bool clickable = style.clickable;
        return CanvasTouchDetector(
            builder: (BuildContext context) => CustomPaint(
              painter: MultipleGroupDataPainter(
                context: context,
                dataModel: dataModel,
                dataIndex: groupIndex,
                style: style,
                displayInfo: displayInfo,
                dataAnimation: dataAnimation,
                onBarSelected: (data, details) { onBarSelected(groupIndex, data, details); },
                groupSelected: isSelected,
                barSelected: barSelected,
                showAverageLine: displayInfo.showAverageLine,
                showValueOnBar: displayInfo.showValueOnBar,
                showGridLine: displayInfo.showGridLine,
                clickable: clickable,
              ),
              size: size,
              willChange: true,
            )
        );
      },
    );
  }
}

class MultipleGroupDataPainter extends CustomPainter with Drawing {
  final BuildContext context;
  final int dataIndex;
  final int maxNumGroupOnScreen;
  final int numGroupOnScreen;
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final DisplayInfo displayInfo;
  final Animation<double> dataAnimation;
  final BarChartDataDouble barSelected;
  final Function(BarChartDataDouble, TapDownDetails) onBarSelected;
  final bool groupSelected, clickable, showAverageLine, showValueOnBar, showGridLine;

  const MultipleGroupDataPainter({
    @required this.context,
    @required this.dataIndex,
    @required this.maxNumGroupOnScreen,
    @required this.numGroupOnScreen,
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

    drawGroupedData(
      originCanvas: originCanvas,
      canvas: canvas,
      bottomLeft: Offset(0, size.height),
      height: size.height,
    );
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
    for (int i = 0; i < numGroupOnScreen; i++) {
      final int j = dataIndex * maxNumGroupOnScreen;
      final List<BarChartDataDouble> dataList = dataModel.groupedBars[i + j].dataList;
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
  bool shouldRepaint(covariant MultipleGroupDataPainter oldDelegate) {
    return oldDelegate.groupSelected != groupSelected
        || oldDelegate.barSelected != barSelected
        || oldDelegate.drawAverageLine != drawAverageLine;
  }
}


@immutable
class ChartCanvasMini1 extends StatelessWidget {
  final Size containerSize;
  final Animation<double> dataAnimation;

  const ChartCanvasMini1({
    @required this.containerSize,
    @required this.dataAnimation
  });

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;
    final Size canvasSize = Size(displayInfo.xTotalLength, displayInfo.canvasHeight);
    return SizedBox.fromSize(
      size: containerSize,
      child: FittedBox(
        fit: BoxFit.fill,
        child: CustomPaint(
          painter: MiniCanvasPainter(
            size: canvasSize,
            displayInfo: displayInfo,
            dataModel: dataModel,
            style: style,
            dataAnimation: dataAnimation,
          ),
          size: canvasSize,
        ),
      ),
    );
  }
}