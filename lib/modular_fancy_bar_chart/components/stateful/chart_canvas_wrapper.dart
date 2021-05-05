import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/components/chart_split_canvas.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../chart_canvas_mini.dart';
import 'chart_axis.dart';
import 'chart_canvas.dart';

class ChartCanvasWrapper extends StatefulWidget {
  final Size size;
  final Size canvasSize;
  final ModularBarChartData data;
  final BarChartStyle style;

  ChartCanvasWrapper({
    @required this.size,
    @required this.canvasSize,
    @required this.data,
    @required this.style,
  });

  @override
  _ChartCanvasWrapperState createState() => _ChartCanvasWrapperState();
}

class _ChartCanvasWrapperState extends State<ChartCanvasWrapper>
    with SingleTickerProviderStateMixin {
  ModularBarChartData data;
  BarChartStyle style;
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2;
  double scrollOffset = 0;

  double dataAnimationValue = 0;
  AnimationController _dataAnimationController;

  Size canvasSize;
  var bottomAxis,
      chartCanvas,
      miniCanvas,
      miniCanvasDataBars,
      inViewContainerOnMiniCanvas,
      miniCanvasWidth,
      miniCanvasHeight;

  @override
  void initState() {
    super.initState();

    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();
    _linkedScrollControllerGroup.addOffsetChangedListener(() {
      final double offset = _linkedScrollControllerGroup.offset / (bottomAxis.length - canvasSize.width);
      setState(() {
        scrollOffset = offset;
      });
    });

    final BarChartAnimation animation = widget.style.animation;
    final Tween<double> _tween = Tween(begin: 0, end: 1);
    if (animation.animateData) {
      _dataAnimationController = AnimationController(
        vsync: this,
        duration: animation.dataAnimationDuration,
      );
      _tween.animate(_dataAnimationController)
        ..addListener(() {
          setState(() {
            dataAnimationValue = _dataAnimationController.value;
          });
        });
      _dataAnimationController.forward();
    }

    canvasSize = widget.canvasSize;
    data = widget.data;
    style = widget.style;

    // Bottom Axis
    bottomAxis = ChartAxisHorizontal(
      axisLength: canvasSize.width,
      xGroups: data.xGroups,
      barWidth: style.barStyle.barWidth,
      numBarsInGroup: data.numInGroups,
      style: style,
      scrollController: _scrollController1,
    );

    // Mini Canvas
    miniCanvasWidth = canvasSize.width * 0.2;
    miniCanvasHeight = canvasSize.height * 0.2 + 3;
    final Size miniCanvasSize = Size(miniCanvasWidth, miniCanvasHeight);

    inViewContainerOnMiniCanvas = Container(
      width: (canvasSize.width / bottomAxis.length) * miniCanvasWidth,
      height: miniCanvasHeight + 3,
      color: Colors.white12,
    );

    switch (data.type) {
      case BarChartType.Ungrouped:
        miniCanvasDataBars = Padding(
          padding: const EdgeInsets.only(top: 3),
          child: ChartCanvasMini.ungrouped(
            canvasSize: miniCanvasSize,
            length: canvasSize.width * 0.2,
            xGroups: data.xGroups,
            valueRange: data.yValueRange,
            xSectionLength: bottomAxis.xSectionLength *
                (canvasSize.width * 0.2 / bottomAxis.length),
            bars: data.bars,
            style: style,
          ),
        );
        break;
      case BarChartType.GroupedSeparated:
        // TODO: Handle this case.
        break;
      case BarChartType.Grouped3D:
        // TODO: Handle this case.
        break;
      default:
        miniCanvasDataBars = Padding(
          padding: const EdgeInsets.only(top: 3),
          child: ChartCanvasMini.grouped(
            isStacked: data.type == BarChartType.GroupedStacked ? true: false,
            canvasSize: miniCanvasSize,
            length: canvasSize.width * 0.2,
            xGroups: data.xGroups,
            subGroups: data.xSubGroups,
            subGroupColors: data.subGroupColors,
            valueRange: data.yValueRange,
            xSectionLength: bottomAxis.xSectionLength *
                (canvasSize.width * 0.2 / bottomAxis.length),
            groupedBars: data.groupedBars,
            style: style,
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Canvas
    chartCanvas = SizedBox.fromSize(
      size: canvasSize,
      child: ListView.builder(
        controller: _scrollController2,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        itemCount: data.xGroups.length,
        itemBuilder: (context, index) {
          return GroupedBars(
            groupIndex: index,
            size: Size(bottomAxis.xSectionLength, canvasSize.height),
            barAnimationFraction: dataAnimationValue,
          );
        },
      ),
    );
    final double inViewContainerMovingDistance = (1 - canvasSize.width / bottomAxis.length) * miniCanvasWidth;
    return RepaintBoundary(
      child: SizedBox.fromSize(
        size: widget.size,
        child: Stack(
          children: [
            // Canvas
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: chartCanvas,
              ),
            ),

            // Mini Canvas background
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: miniCanvasWidth,
                height: miniCanvasHeight,
                color: Colors.black12,
              )
            ),

            // Mini Canvas Data Bars
            Positioned(
              top: 0,
              right: 0,
              child: miniCanvasDataBars,
            ),

            // Mini Canvas in View Container
            Positioned(
              top: 0,
              right: (1 - scrollOffset) * inViewContainerMovingDistance,
              child: inViewContainerOnMiniCanvas,
            ),

            // Bottom Axis
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
