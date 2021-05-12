import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/stateful/chart_main_canvas.dart';
import 'package:flutter_charts/modular_bar_chart/components/stateful/chart_mini_canvas_in_view_container.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_component_size.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import '../chart_axis.dart';
import '../chart_mini_canvas.dart';

class ChartCanvasWrapper extends StatefulWidget {
  final Size size;
  final Size canvasSize;
  final double barWidth;
  final bool displayMiniCanvas;
  final BarChartAnimation animation;

  ChartCanvasWrapper({
    @required this.size,
    @required this.canvasSize,
    @required this.barWidth,
    @required this.displayMiniCanvas,
    @required this.animation,
  });

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
    final Size canvasSize = widget.canvasSize;
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;
    final double xSectionLength = getXSectionLengthFromBarWidth(data: dataModel, style: style, barWidth: widget.barWidth);
    final double xLength = getXLength(dataModel: dataModel, canvasWidth: canvasSize.width, xSectionLength: xSectionLength);
    //final double xHeight = getXHeight(style.xAxisStyle);
    // TODO
    final double miniCanvasWidth = canvasSize.width * 0.2;
    final double miniCanvasHeight = canvasSize.height * 0.2 + 3;
    final Size miniCanvasContainerSize = Size(miniCanvasWidth, miniCanvasHeight - 3);

    // Bottom Axis
    final Widget bottomAxis = ChartAxisHorizontalWrapper(
      //containerSize: Size(canvasSize.width, widget.labelInfo[0] + style.xAxisStyle.tickStyle.tickLength),
      containerSize: widget.size,
      singleCanvasSize: Size(xSectionLength, style.xAxisStyle.tickStyle.tickLength),
      scrollController: _scrollController1,
      labelController: _scrollController3,
      //labelInfo: widget.labelInfo,
    );

    // Mini Canvas
    Widget inViewContainerOnMiniCanvas, miniCanvasDataBars;
    if (widget.displayMiniCanvas && !style.isMini) {
      // Mini Canvas in-view Container
      inViewContainerOnMiniCanvas = MiniCanvasInViewContainer(
        controllerGroup: _linkedScrollControllerGroup,
        containerSize: widget.size,
        canvasWidth: canvasSize.width,
        inViewContainerMovingDistance: (1 - canvasSize.width / xLength) * miniCanvasWidth,
        inViewContainerSize: Size(
          (canvasSize.width / xLength) * miniCanvasWidth,
          miniCanvasHeight
        ),
        xLength: xLength,
      );

      // Mini Canvas Data Bars
      miniCanvasDataBars = Padding(
        padding: const EdgeInsets.only(top: 3),
        child: ChartCanvasMini(
          containerSize: miniCanvasContainerSize,
          canvasSize: Size(xLength, widget.canvasSize.height),
        ),
      );
    }

    Widget chartCanvas = MainCanvas(
      canvasSize: canvasSize,
      xSectionLength: xSectionLength,
      barWidth: widget.barWidth,
      animation: widget.animation,
      scrollController: _scrollController2,
    );

    return RepaintBoundary(
      child: SizedBox.fromSize(
        size: widget.size,
        child: Stack(
          children: [
            // Main Canvas
            Positioned(
              top: 0,
              left: 0,
              child: chartCanvas,
            ),

            // Mini Canvas background
            widget.displayMiniCanvas && !style.isMini
                ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: miniCanvasWidth,
                    height: miniCanvasHeight,
                    color: Colors.black12,
                  )
                )
                : SizedBox(),

            // Mini Canvas Data Bars
            widget.displayMiniCanvas && !style.isMini
                ? Positioned(
                  top: 0,
                  right: 0,
                  child:  miniCanvasDataBars,
                )
                : SizedBox(),

            // Mini Canvas in View Container
            widget.displayMiniCanvas && !style.isMini
                ? Positioned(
                  top: 0,
                  left: 0,
                  child:  inViewContainerOnMiniCanvas,
                )
                : SizedBox(),

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

  double getXSectionLengthFromBarWidth({
    @required ModularBarChartData data,
    @required BarChartStyle style,
    @required double barWidth,
  }) {
    int numBarsInGroup = (data.type == BarChartType.Ungrouped || data.type == BarChartType.GroupedStacked || data.type == BarChartType.GroupedSeparated)
        ? 1
        : data.xSubGroups.length;
    double totalBarWidth = numBarsInGroup * barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin = style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
    return totalBarWidth + totalGroupMargin + totalInGroupMargin;
  }

  double getXLength({
    @required ModularBarChartData dataModel,
    @required double canvasWidth,
    @required double xSectionLength,
  }) => [xSectionLength * dataModel.xGroups.length, canvasWidth].reduce(max);

  double getXHeight(AxisStyle xAxisStyle) =>
      StringSize.getHeightOfString('I', xAxisStyle.tickStyle.labelTextStyle) + xAxisStyle.tickStyle.tickLength + xAxisStyle.tickStyle.tickMargin;
}

// class ChartCanvasWrapper extends StatefulWidget {
//   final Size size;
//   final Size canvasSize;
//   final double barWidth;
//   final bool displayMiniCanvas;
//   final BarChartAnimation animation;
//   final List<double> labelInfo;
//
//   ChartCanvasWrapper({
//     @required this.size,
//     @required this.canvasSize,
//     @required this.barWidth,
//     @required this.displayMiniCanvas,
//     @required this.animation,
//     @required this.labelInfo,
//   });
//
//   @override
//   _ChartCanvasWrapperState createState() => _ChartCanvasWrapperState();
// }
//
// class _ChartCanvasWrapperState extends State<ChartCanvasWrapper> with SingleTickerProviderStateMixin, StringSize {
//   // Scroll Controllers
//   LinkedScrollControllerGroup _linkedScrollControllerGroup;
//   ScrollController _scrollController1, _scrollController2, _scrollController3;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Scrolling actions
//     _linkedScrollControllerGroup = LinkedScrollControllerGroup();
//     _scrollController1 = _linkedScrollControllerGroup.addAndGet();
//     _scrollController2 = _linkedScrollControllerGroup.addAndGet();
//     _scrollController3 = _linkedScrollControllerGroup.addAndGet();
//   }
//
//   @override
//   void dispose() {
//     _scrollController1.dispose();
//     _scrollController2.dispose();
//     _scrollController3.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size canvasSize = widget.canvasSize;
//     final ModularBarChartData dataModel = context.read<ModularBarChartData>();
//     final BarChartStyle style = context.read<BarChartStyle>();
//     final double xSectionLength = getXSectionLengthFromBarWidth(data: dataModel, style: style, barWidth: widget.barWidth);
//     final double xLength = getXLength(dataModel: dataModel, canvasWidth: canvasSize.width, xSectionLength: xSectionLength);
//     //final double xHeight = getXHeight(style.xAxisStyle);
//     // TODO
//     final double miniCanvasWidth = canvasSize.width * 0.2;
//     final double miniCanvasHeight = canvasSize.height * 0.2 + 3;
//     final Size miniCanvasContainerSize = Size(miniCanvasWidth, miniCanvasHeight - 3);
//
//     // Bottom Axis
//     final Widget bottomAxis = ChartAxisHorizontalWrapper(
//       containerSize: Size(canvasSize.width, widget.labelInfo[0] + style.xAxisStyle.tickStyle.tickLength),
//       singleCanvasSize: Size(xSectionLength, style.xAxisStyle.tickStyle.tickLength),
//       scrollController: _scrollController1,
//       labelController: _scrollController3,
//       labelInfo: widget.labelInfo,
//     );
//
//     // Mini Canvas
//     Widget inViewContainerOnMiniCanvas, miniCanvasDataBars;
//     if (widget.displayMiniCanvas && !style.isMini) {
//       // Mini Canvas in-view Container
//       inViewContainerOnMiniCanvas = MiniCanvasInViewContainer(
//         controllerGroup: _linkedScrollControllerGroup,
//         containerSize: widget.size,
//         canvasWidth: canvasSize.width,
//         inViewContainerMovingDistance: (1 - canvasSize.width / xLength) * miniCanvasWidth,
//         inViewContainerSize: Size(
//             (canvasSize.width / xLength) * miniCanvasWidth,
//             miniCanvasHeight
//         ),
//         xLength: xLength,
//       );
//
//       // Mini Canvas Data Bars
//       miniCanvasDataBars = Padding(
//         padding: const EdgeInsets.only(top: 3),
//         child: ChartCanvasMini(
//           containerSize: miniCanvasContainerSize,
//           canvasSize: Size(xLength, widget.canvasSize.height),
//         ),
//       );
//     }
//
//     Widget chartCanvas = MainCanvas(
//       canvasSize: canvasSize,
//       xSectionLength: xSectionLength,
//       barWidth: widget.barWidth,
//       animation: widget.animation,
//       scrollController: _scrollController2,
//     );
//
//     return RepaintBoundary(
//       child: SizedBox.fromSize(
//         size: widget.size,
//         child: Stack(
//           children: [
//             // Main Canvas
//             Positioned(
//               top: 0,
//               left: 0,
//               child: chartCanvas,
//             ),
//
//             // Mini Canvas background
//             widget.displayMiniCanvas && !style.isMini
//                 ? Positioned(
//                 top: 0,
//                 right: 0,
//                 child: Container(
//                   width: miniCanvasWidth,
//                   height: miniCanvasHeight,
//                   color: Colors.black12,
//                 )
//             )
//                 : SizedBox(),
//
//             // Mini Canvas Data Bars
//             widget.displayMiniCanvas && !style.isMini
//                 ? Positioned(
//               top: 0,
//               right: 0,
//               child:  miniCanvasDataBars,
//             )
//                 : SizedBox(),
//
//             // Mini Canvas in View Container
//             widget.displayMiniCanvas && !style.isMini
//                 ? Positioned(
//               top: 0,
//               left: 0,
//               child:  inViewContainerOnMiniCanvas,
//             )
//                 : SizedBox(),
//
//             // Bottom Axis
//             Positioned(
//               top: canvasSize.height - style.xAxisStyle.strokeWidth / 2,
//               left: 0,
//               child: bottomAxis,
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   double getXSectionLengthFromBarWidth({
//     @required ModularBarChartData data,
//     @required BarChartStyle style,
//     @required double barWidth,
//   }) {
//     int numBarsInGroup = (data.type == BarChartType.Ungrouped || data.type == BarChartType.GroupedStacked || data.type == BarChartType.GroupedSeparated)
//         ? 1
//         : data.xSubGroups.length;
//     double totalBarWidth = numBarsInGroup * barWidth;
//     double totalGroupMargin = style.groupMargin * 2;
//     double totalInGroupMargin = style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
//     return totalBarWidth + totalGroupMargin + totalInGroupMargin;
//   }
//
//   double getXLength({
//     @required ModularBarChartData dataModel,
//     @required double canvasWidth,
//     @required double xSectionLength,
//   }) => [xSectionLength * dataModel.xGroups.length, canvasWidth].reduce(max);
//
//   double getXHeight(AxisStyle xAxisStyle) =>
//       StringSize.getHeightOfString('I', xAxisStyle.tickStyle.labelTextStyle) + xAxisStyle.tickStyle.tickLength + xAxisStyle.tickStyle.tickMargin;
// }
