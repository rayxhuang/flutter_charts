import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/textSizeInfo.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/components/chart_split_canvas.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

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
  ModularBarChartData data;
  BarChartStyle style;
  int indexSelected;
  BarChartDataDouble barSelected;
  TapDownDetails tapDownDetails;
  List<OverlayEntry> barDetailOverlay = [];
  List<bool> needsRemoval = [];
  int previousIndex = 0;


  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2;
  double scrollOffset = 0;
  double dataAnimationValue = 1;
  AnimationController _dataAnimationController;

  Size canvasSize;
  ChartAxisHorizontal bottomAxis;
  Widget chartCanvas, miniCanvas, miniCanvasDataBars, inViewContainerOnMiniCanvas;
  double miniCanvasWidth, miniCanvasHeight, xSectionLength;

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
    xSectionLength = getXSectionLengthFromBarWidth(data, widget.barWidth);

    // Bottom Axis
    bottomAxis = ChartAxisHorizontal(
      axisLength: canvasSize.width,
      xGroups: data.xGroups,
      barWidth: style.barStyle.barWidth,
      numBarsInGroup: data.numInGroups,
      style: style,
      scrollController: _scrollController1,
    );

    if (widget.displayMiniCanvas) {
      // Mini Canvas
      miniCanvasWidth = canvasSize.width * 0.2;
      miniCanvasHeight = canvasSize.height * 0.2 + 3;
      final Size miniCanvasSize = Size(miniCanvasWidth, miniCanvasHeight - 3);

      inViewContainerOnMiniCanvas = Container(
        width: (canvasSize.width / bottomAxis.length) * miniCanvasWidth,
        height: miniCanvasHeight,
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
              xSectionLength: canvasSize.width * 0.2  / data.xGroups.length,
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
              xSectionLength: canvasSize.width * 0.2  / data.xGroups.length,
              groupedBars: data.groupedBars,
              style: style,
            ),
          );
          break;
      }
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
                //print('Selected index: $index, group:${data.xGroups[index]}, $bar');
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
                    final String detail = (data.type == BarChartType.Ungrouped)
                        ? '${bar.group}: ${bar.data.toStringAsFixed(2)}'
                        : '${bar.group}\n${data.xGroups[index]}: ${bar.data.toStringAsFixed(2)}';
                    final TextStyle detailTextStyle = const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    );
                    final double width = getSizeOfString(detail, detailTextStyle) + 16;
                    final double height = getSizeOfString(detail, detailTextStyle, isHeight: true) + 10;
                    return Positioned(
                      top: details.globalPosition.dy - height - 5,
                      left: details.globalPosition.dx - width / 2,
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
                              detail,
                              style: detailTextStyle,
                            ),
                          ),
                        ),
                      ),
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
              right: (1 - scrollOffset) * inViewContainerMovingDistance,
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

  void registerRemoval(int i) async {
    await Future.delayed(const Duration(seconds: 2)).then((_) => {
      if (needsRemoval[i]) {
        barDetailOverlay[i].remove(),
        needsRemoval[i] = false
      }
    });
  }

  double getXSectionLengthFromBarWidth(ModularBarChartData data, double barWidth) {
    int numBarsInGroup = (data.type == BarChartType.Ungrouped || data.type == BarChartType.GroupedStacked)
        ? 1
        : data.xSubGroups.length;
    double totalBarWidth = numBarsInGroup * barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin = style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
    return totalBarWidth + totalGroupMargin + totalInGroupMargin;
  }
}
