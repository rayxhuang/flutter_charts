import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/stateful/chart_main_canvas.dart';
import 'package:flutter_charts/modular_bar_chart/components/stateful/chart_mini_canvas_in_view_container.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import '../chart_axis.dart';
import '../chart_mini_canvas.dart';

class ChartCanvasWrapper extends StatefulWidget {
  const ChartCanvasWrapper();

  @override
  _ChartCanvasWrapperState createState() => _ChartCanvasWrapperState();
}

class _ChartCanvasWrapperState extends State<ChartCanvasWrapper> with SingleTickerProviderStateMixin, StringSize {
  // Scroll Controllers
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2, _scrollController3;

  @override
  void initState() {
    super.initState();

    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();
    _scrollController3 = _linkedScrollControllerGroup.addAndGet();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final BarChartStyle style = displayInfo.style;

    final Size canvasSize = displayInfo.canvasSize;
    final double xLength = displayInfo.xTotalLength;
    final double miniCanvasWidth = canvasSize.width * 0.2;
    final double miniCanvasHeight = canvasSize.height * 0.2 + 3;
    final Size miniCanvasContainerSize = Size(miniCanvasWidth, miniCanvasHeight - 3);
    final bool displayMiniCanvas = displayInfo.displayMiniCanvas && !displayInfo.isMini;

    // Bottom Axis
    final Widget bottomAxis = ChartAxisHorizontalWrapper(
      scrollController: _scrollController2,
      labelController: _scrollController3,
    );

    // Mini Canvas background
    final Widget miniCanvasBackground = displayMiniCanvas
        ? Container(
          width: miniCanvasWidth,
          height: miniCanvasHeight,
          color: Colors.black12,
        )
        : SizedBox();

    // In-view Container
    final Widget inViewContainerOnMiniCanvas = displayMiniCanvas
        ? MiniCanvasInViewContainer(
          controllerGroup: _linkedScrollControllerGroup,
          inViewContainerMovingDistance: (1 - canvasSize.width / xLength) * miniCanvasWidth,
          inViewContainerSize: Size(
            (canvasSize.width / xLength) * miniCanvasWidth,
            miniCanvasHeight
          ),
        )
        : SizedBox();

    // Mini canvas data
    final Widget miniCanvasDataBars = displayMiniCanvas
        ? Padding(
          padding: const EdgeInsets.only(top: 3),
          child: ChartCanvasMini(containerSize: miniCanvasContainerSize,),
        )
        : SizedBox();

    // Main canvas
    final Widget chartCanvas = MainCanvas(
      animation: displayInfo.style.animation,
      scrollController: _scrollController1,
    );

    return RepaintBoundary(
      child: SizedBox.fromSize(
        size: displayInfo.canvasWrapperSize,
        child: Stack(
          children: [
            // Main Canvas
            Positioned(
              top: 0,
              left: 0,
              child: chartCanvas,
            ),

            // Mini Canvas background
            Positioned(
              top: 0,
              right: 0,
              child: miniCanvasBackground
            ),

            // Mini Canvas Data Bars
            Positioned(
              top: 0,
              right: 0,
              child: miniCanvasDataBars
            ),

            // Mini Canvas in View Container
            Positioned(
              top: 0,
              left: 0,
              child: inViewContainerOnMiniCanvas
            ),

            // Bottom Axis
            Positioned(
              top: canvasSize.height - style.xAxisStyle.strokeWidth / 2,
              left: 0,
              child: bottomAxis,
            ),
          ],
        ),
      ),
    );
  }
}
