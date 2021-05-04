import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'chart_axis.dart';
import 'chart_canvas.dart';

class ChartCanvasWithAxis extends StatefulWidget {
  final Size size;
  final Size canvasSize;
  final ModularBarChartData data;
  final BarChartStyle style;

  ChartCanvasWithAxis({
    @required this.size,
    @required this.canvasSize,
    @required this.data,
    @required this.style,
  });

  @override
  _ChartCanvasWithAxisState createState() => _ChartCanvasWithAxisState();
}

class _ChartCanvasWithAxisState extends State<ChartCanvasWithAxis> {
  ModularBarChartData data;
  BarChartStyle style;
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2;
  double scrollOffset = -1;
  AnimationController _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  Size canvasSize;
  var bottomAxis, chartCanvas, miniCanvas, miniCanvasData, inViewContainer, miniCanvasWidth, miniCanvasHeight;

  @override
  void initState() {
    super.initState();
    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();
    _linkedScrollControllerGroup.addOffsetChangedListener(() {
      final double offset = _linkedScrollControllerGroup.offset * 2 / (bottomAxis.length - canvasSize.width);
      final double res = (-1 + offset).toDouble();
      setState(() { scrollOffset = res; });
    });

    canvasSize = widget.canvasSize;
    data = widget.data;
    style = widget.style;

    // Bottom Axis
    bottomAxis = ChartAxisHorizontal(
      axisLength: canvasSize.width,
      xGroups: data.xGroups,
      barWidth: style.barWidth,
      numBarsInGroup: data.numInGroups,
      style: style,
      scrollController: _scrollController1,
    );

    // Canvas
    switch (data.type) {
      case BarChartType.Ungrouped:
        chartCanvas = ChartCanvas.ungrouped(
          canvasSize: canvasSize,
          length: bottomAxis.length,
          scrollController: _scrollController2,
          xGroups: data.xGroups,
          valueRange: data.yValueRange,
          xSectionLength: bottomAxis.xSectionLength,
          bars: data.bars,
          style: style,
        );
        break;
      case BarChartType.GroupedSeparated:
      // TODO: Handle this case.
        break;
      case BarChartType.Grouped3D:
      // TODO: Handle this case.
        break;
      default:
        chartCanvas = ChartCanvas.grouped(
          isStacked: data.type == BarChartType.GroupedStacked ? true : false,
          canvasSize: canvasSize,
          length: bottomAxis.length,
          scrollController: _scrollController2,
          xGroups: data.xGroups,
          subGroups: data.xSubGroups,
          subGroupColors: data.subGroupColors,
          valueRange: data.yValueRange,
          xSectionLength: bottomAxis.xSectionLength,
          groupedBars: data.groupedBars,
          style: style,
        );
        break;
    }

    miniCanvasWidth = canvasSize.width * 0.2;
    miniCanvasHeight = canvasSize.height * 0.2 + 3;

    inViewContainer = Container(
      width: (canvasSize.width / bottomAxis.length) * canvasSize.width * 0.2,
      height: canvasSize.height * 0.2 + 3,
      color: Colors.white12,
    );

    miniCanvasData = Padding(
      padding: const EdgeInsets.only(top: 3),
      child: ChartCanvas.mini(
        type: data.type,
        canvasSize: Size(canvasSize.width * 0.2, canvasSize.height * 0.2),
        length: canvasSize.width * 0.2,
        xGroups: data.xGroups,
        subGroups: data.xSubGroups,
        subGroupColors: data.subGroupColors,
        valueRange: data.yValueRange,
        xSectionLength: bottomAxis.xSectionLength * (canvasSize.width * 0.2 / bottomAxis.length),
        groupedBars: data.groupedBars,
        style: style,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('called build in cp');
    //MiniCanvas
    final miniCanvas = Container(
      width: miniCanvasWidth,
      height: miniCanvasHeight,
      color: Colors.black12,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(scrollOffset, 0),
            child: inViewContainer,
          ),
          miniCanvasData,
        ],
      ),
    );
    return RepaintBoundary(
      child: SizedBox.fromSize(
        size: widget.size,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: chartCanvas,
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: miniCanvas,
            ),

            Positioned(
              top: canvasSize.height - style.xAxisStyle.strokeWidth / 2,
              left: 0,
              child: bottomAxis,
            )
          ],
        ),
      ),
    );
  }
}