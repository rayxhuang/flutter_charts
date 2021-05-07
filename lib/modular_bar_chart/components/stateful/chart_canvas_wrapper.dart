import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/data/textSizeInfo.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_single_group_canvas.dart';
import '../chart_canvas_mini.dart';
import 'chart_axis.dart';

class ChartCanvasWrapper extends StatefulWidget {
  final Size size;
  final Size canvasSize;
  final ModularBarChartData data;
  final BarChartStyle style;
  final double barWidth;
  final bool displayMiniCanvas;

  ChartCanvasWrapper({
    @required this.size,
    @required this.canvasSize,
    @required this.data,
    @required this.style,
    @required this.barWidth,
    @required this.displayMiniCanvas,
  });

  @override
  _ChartCanvasWrapperState createState() => _ChartCanvasWrapperState();
}

class _ChartCanvasWrapperState extends State<ChartCanvasWrapper> with SingleTickerProviderStateMixin {
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
    final ModularBarChartData data = widget.data;
    final BarChartStyle style = widget.style;
    final double xSectionLength = getXSectionLengthFromBarWidth(data: widget.data, style: widget.style, barWidth: widget.barWidth);
    final double miniCanvasWidth = canvasSize.width * 0.2;
    final double miniCanvasHeight = canvasSize.height * 0.2 + 3;
    final Size miniCanvasContainerSize = Size(miniCanvasWidth, miniCanvasHeight - 3);

    // Bottom Axis
    final ChartAxisHorizontal bottomAxis = ChartAxisHorizontal(
      axisLength: canvasSize.width,
      xGroups: data.xGroups,
      barWidth: style.barStyle.barWidth,
      numBarsInGroup: data.numInGroups,
      style: style,
      scrollController: _scrollController1,
    );

    final double inViewContainerOffset = (1 - scrollOffset / (bottomAxis.length - widget.canvasSize.width));
    Widget inViewContainerOnMiniCanvas, miniCanvasDataBars, chartCanvas;
    if (widget.displayMiniCanvas) {
      // Mini Canvas
      inViewContainerOnMiniCanvas = Container(
        width: (canvasSize.width / bottomAxis.length) * miniCanvasWidth,
        height: miniCanvasHeight,
        color: Colors.white12,
      );

      miniCanvasDataBars = Padding(
        padding: const EdgeInsets.only(top: 3),
        child: ChartCanvasMini(
          containerSize: miniCanvasContainerSize,
          canvasSize: Size(bottomAxis.length, widget.canvasSize.height),
        ),
      );
    }

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
            isSelected: index == indexSelected ? true : false,
            barSelected: barSelected,
            size: Size(xSectionLength, canvasSize.height),
            barWidth: widget.barWidth,
            barAnimationFraction: dataAnimationValue,
            onBarSelected: (index, bar, details) async {
              setState(() {
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
                    final String separatedGroupName = data.type == BarChartType.GroupedSeparated
                        ? bar.separatedGroupName
                        : data.xGroups[index];
                    final String detailString = (data.type == BarChartType.Ungrouped)
                        ? '${bar.group}: ${bar.data.toStringAsFixed(2)}'
                        : '${bar.group}\n$separatedGroupName: ${bar.data.toStringAsFixed(2)}';
                    final TextStyle detailTextStyle = const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    );
                    final double width = getSizeOfString(detailString, detailTextStyle) + 16;
                    final double height = getSizeOfString(detailString, detailTextStyle, isHeight: true) + 10;
                    return _buildOverlay(
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
              });
            },
            //animation: _dataAnimationController,
          );
        },
      ),
    );
    final double inViewContainerMovingDistance = widget.displayMiniCanvas
        ? (1 - canvasSize.width / bottomAxis.length) * miniCanvasWidth
        : 0;
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
            Positioned(
              top: 0,
              right: 0,
              child: widget.displayMiniCanvas
                  ? Container(
                    width: miniCanvasWidth,
                    height: miniCanvasHeight,
                    color: Colors.black12,
                  )
                  : SizedBox()
            ),

            // Mini Canvas Data Bars
            Positioned(
              top: 0,
              right: 0,
              child: widget.displayMiniCanvas ? miniCanvasDataBars : SizedBox(),
            ),

            // Mini Canvas in View Container
            Positioned(
              top: 0,
              right: inViewContainerOffset * inViewContainerMovingDistance,
              child: widget.displayMiniCanvas ? inViewContainerOnMiniCanvas : SizedBox(),
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

  Widget _buildOverlay({
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
}
