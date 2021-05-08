import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_single_group_canvas.dart';
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
  // Interaction
  int indexSelected, previousIndex;
  BarChartDataDouble barSelected;
  TapDownDetails tapDownDetails;
  List<OverlayEntry> barDetailOverlay;
  List<bool> needsRemoval;

  // Controllers
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2;
  double scrollOffset, dataAnimationValue;
  AnimationController _dataAnimationController;

  @override
  void initState() {
    super.initState();
    barDetailOverlay = [];
    needsRemoval = [];
    previousIndex = 0;
    scrollOffset = 0;
    dataAnimationValue = 1;

    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();
    _linkedScrollControllerGroup.addOffsetChangedListener(() {
      setState(() { scrollOffset = _linkedScrollControllerGroup.offset; });
    });

    // Animation
    final Tween<double> _tween = Tween(begin: 0, end: 1);
    if (widget.animation.animateData) {
      _dataAnimationController = AnimationController(
        vsync: this,
        duration: widget.animation.dataAnimationDuration,
      );
      _tween.animate(_dataAnimationController)
        ..addListener(() {
          setState(() {
            dataAnimationValue = _dataAnimationController.value;
          });
        });
      _dataAnimationController.forward();
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
    final Size canvasSize = widget.canvasSize;
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();
    final double xSectionLength = getXSectionLengthFromBarWidth(data: dataModel, style: style, barWidth: widget.barWidth);
    final double xLength = getXLength(dataModel: dataModel, canvasWidth: canvasSize.width, xSectionLength: xSectionLength);
    final double xHeight = getXHeight(style.xAxisStyle);
    final double miniCanvasWidth = canvasSize.width * 0.2;
    final double miniCanvasHeight = canvasSize.height * 0.2 + 3;
    final Size miniCanvasContainerSize = Size(miniCanvasWidth, miniCanvasHeight - 3);

    // Bottom Axis
    final Widget bottomAxis = ChartAxisHorizontalWrapper(
      containerSize: Size(canvasSize.width, xHeight),
      singleCanvasSize: Size(xSectionLength, xHeight),
      scrollController: _scrollController1,
    );

    // Mini Canvas
    Widget inViewContainerOnMiniCanvas, miniCanvasDataBars;
    final double inViewContainerOffset = (1 - scrollOffset / (xLength - canvasSize.width));
    final double inViewContainerMovingDistance = widget.displayMiniCanvas
        ? (1 - canvasSize.width / xLength) * miniCanvasWidth
        : 0;
    if (widget.displayMiniCanvas) {
      // Mini Canvas background
      inViewContainerOnMiniCanvas = Container(
        width: (canvasSize.width / xLength) * miniCanvasWidth,
        height: miniCanvasHeight,
        color: Colors.white12,
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

    // Main Canvas
    Widget chartCanvas = SizedBox.fromSize(
      size: canvasSize,
      child: ListView.builder(
        controller: _scrollController2,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        itemCount: dataModel.xGroups.length,
        itemBuilder: (context, index) {
          return SingleGroupedCanvas(
            groupIndex: index,
            isSelected: index == indexSelected ? true : false,
            barSelected: barSelected,
            size: Size(xSectionLength, canvasSize.height),
            barWidth: widget.barWidth,
            barAnimationFraction: dataAnimationValue,
            onBarSelected: (index, bar, details) {
              setState(() {
                _createOverlay(context: context, dataModel: dataModel, index: index, bar: bar, details: details);
              });
            },
          );
        },
      ),
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
              child: SafeArea(
                child: chartCanvas,
              ),
            ),

            // Mini Canvas background
            widget.displayMiniCanvas
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
            widget.displayMiniCanvas
                ? Positioned(
                  top: 0,
                  right: 0,
                  child:  miniCanvasDataBars,
                )
                : SizedBox(),

            // Mini Canvas in View Container
            widget.displayMiniCanvas
                ? Positioned(
                  top: 0,
                  right: inViewContainerOffset * inViewContainerMovingDistance,
                  child:  inViewContainerOnMiniCanvas,
                )
                : SizedBox(),

            // // Bottom Axis
            // Positioned(
            //   top: canvasSize.height - style.xAxisStyle.strokeWidth / 2,
            //   left: 0,
            //   child: bottomAxis,
            // )
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

  void _createOverlay({
    @required BuildContext context,
    @required ModularBarChartData dataModel,
    @required int index,
    @required BarChartDataDouble bar,
    @required TapDownDetails details,
  }) {
    OverlayState overlayState = Overlay.of(context);
    // Remove all the previous overlays
    for (int i = previousIndex; i < barDetailOverlay.length; i++) {
      if (needsRemoval[i]) {
        barDetailOverlay[i].remove();
        needsRemoval[i] = false;
      }
      previousIndex = i;
    }
    indexSelected = index;
    barSelected = bar;
    tapDownDetails = details;
    final currentBarDetailOverlay = OverlayEntry(
        builder: (context) {
          final String separatedGroupName = dataModel.type == BarChartType.GroupedSeparated
              ? bar.separatedGroupName
              : bar.group;
          final String detailString = (dataModel.type == BarChartType.Ungrouped)
              ? '${bar.group}: ${bar.data.toStringAsFixed(2)}'
              : '$separatedGroupName\n${dataModel.xGroups[index]}: ${bar.data.toStringAsFixed(2)}';
          final TextStyle detailTextStyle = const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          );
          final double width = StringSize.getWidthOfString(detailString, detailTextStyle) + 16;
          final double height = StringSize.getHeightOfString(detailString, detailTextStyle) + 10;
          return _buildOverlayWidget(
            tapDownDetails: details,
            height: height,
            width: width,
            detailString: detailString,
            detailTextStyle: detailTextStyle,
          );
        }
    );
    overlayState.insert(currentBarDetailOverlay);
    barDetailOverlay.add(currentBarDetailOverlay);
    needsRemoval.add(true);
    registerRemoval(barDetailOverlay.length - 1);
  }

  Widget _buildOverlayWidget({
    TapDownDetails tapDownDetails,
    double height,
    double width,
    String detailString,
    TextStyle detailTextStyle,
  }) {
    return Positioned(
      top: tapDownDetails.globalPosition.dy - height - 5,
      left: tapDownDetails.globalPosition.dx - width / 2,
      child: FittedBox(
        child: Material(
          type: MaterialType.canvas,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 8,
            ),
            child: Text(
              detailString,
              style: detailTextStyle,
            ),
          ),
        ),
      ),
    );
  }
  
  void registerRemoval(int i) async {
    await Future.delayed(const Duration(seconds: 2)).then((_) => {
      if (needsRemoval[i]) {
        barDetailOverlay[i].remove(),
        needsRemoval[i] = false
      }
    });
  }
}
