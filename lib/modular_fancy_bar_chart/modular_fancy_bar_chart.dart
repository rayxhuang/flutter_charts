import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

import 'components/chart_axis.dart';
import 'components/chart_canvas.dart';
import 'components/chart_legend.dart';

enum BarChartType {Ungrouped, Grouped, GroupedStacked, GroupedSeparated, Grouped3D}

abstract class AbstractModularBarChart {
  final Map<String, double> rawDataUngrouped;
  final Map<String, Map<String, double>> rawDataGrouped;
  final Map<String, Map<String, Map<String, double>>> rawDataGrouped3D;
  final double width;
  final double height;
  final BarChartStyle style;
  final BarChartType type;

  const  AbstractModularBarChart({
    this.rawDataUngrouped,
    this.rawDataGrouped,
    this.rawDataGrouped3D,
    this.width,
    this.height,
    this.style,
    this.type,
  });
}

class ModularFancyBarChart extends StatefulWidget {
  final Map<String, double> rawDataUngrouped;
  // TODO 2D data can have 3 styles
  final Map<String, Map<String, double>> rawDataGrouped;
  final Map<String, Map<String, Map<String, double>>> rawDataGrouped3D;
  final double width;
  final double height;
  final BarChartStyle style;

  ModularFancyBarChart.Ungrouped({
    this.rawDataUngrouped,
    @required this.width,
    @required this.height,
    this.style,
  }) : assert(rawData != null) : su;

  @override
  _ModularFancyBarChartState createState() => _ModularFancyBarChartState();
}

class _ModularFancyBarChartState extends State<ModularFancyBarChart> with TickerProviderStateMixin{
  BarChartStyle style;
  List<String> xGroups = [], subGroups = [];
  Map<String, Color> subGroupColors;
  List<double> _yValues = [];
  List<BarChartDataDouble> _bars = [];
  List<BarChartDataDoubleGrouped> _groupedBars = [];
  bool chartIsGrouped;

  List<double> _yValueRange = [];
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  ScrollController _scrollController;
  double scrollOffset = 0;

  Size leftAxisSize  = Size.zero, titleSize = Size.zero, canvasSize = Size.zero, bottomAxisSize = Size.zero,
      bottomLegendSize = Size.zero, rightAxisSize = Size.zero, rightLegendSize = Size.zero;

  Size parentSize;
  ChartTitle chartTitle;
  ChartCanvas chartCanvas;
  ChartAxisHorizontal topAxis, bottomAxis;
  ChartAxisVertical leftAxis, rightAxis;
  ChartLegendHorizontal bottomLegend;
  ChartLegendVertical rightLegend;

  @override
  void initState() {
    super.initState();
    parentSize = Size(widget.width, widget.height);
    chartTitle = ChartTitle(title: 'Bar Chart Title', parentSize: parentSize);
    titleSize = chartTitle.size;
    // topAxis = ChartAxisHorizontal(parentSize: parentSize);
    // topAxisSize = topAxis.size;
    chartCanvas = ChartCanvas(parentSize: parentSize);
    canvasSize = chartCanvas.size;
    bottomAxis = ChartAxisHorizontal(parentSize: parentSize);
    bottomAxisSize = bottomAxis.size;
    bottomLegend = ChartLegendHorizontal(parentSize: parentSize);
    bottomLegendSize = bottomLegend.size;

    leftAxis = ChartAxisVertical(parentSize: parentSize);
    leftAxisSize = leftAxis.size;

    rightAxis = ChartAxisVertical(parentSize: parentSize);
    rightAxisSize = rightAxis.size;
    rightLegend = ChartLegendVertical(parentSize: parentSize);
    rightLegendSize = rightLegend.size;
    // _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   print(widget.width * 1.5);
    //   print(_scrollController.offset);
    //   setState(() {
    //     scrollOffset = _scrollController.offset;
    //   });
    // });
    // style = widget.style;
    // subGroupColors = style.subGroupColors ?? {};

    // analyseData();
    //
    // final BarChartAnimation animation = style.animation;
    // final Tween<double> _tween = Tween(begin: 0, end: 1);
    // if (animation.animateAxis) {
    //   _axisAnimationController = AnimationController(
    //     vsync: this,
    //     duration: animation.axisAnimationDuration,
    //   );
    //   _tween.animate(_axisAnimationController)..addListener(() {
    //     setState(() {
    //       axisAnimationValue = _axisAnimationController.value;
    //     });
    //   });
    // }
    // if (animation.animateData) {
    //   _dataAnimationController = AnimationController(
    //     vsync: this,
    //     duration: animation.dataAnimationDuration,
    //   );
    //   _tween.animate(_dataAnimationController)..addListener(() {
    //     setState(() {
    //       dataAnimationValue = _dataAnimationController.value;
    //     });
    //   });
    // }
    //
    // //Animate both axis and data?
    // if (animation.animateAxis && animation.animateData) {
    //   if (animation.animateDataAfterAxis) {
    //     _axisAnimationController.forward(from: 0).then((value) => _dataAnimationController.forward(from: 0));
    //   } else {
    //     _axisAnimationController.forward(from: 0);
    //     _dataAnimationController.forward(from: 0);
    //   }
    // } else {
    //   if (animation.animateAxis) { _axisAnimationController.forward(from: 0); dataAnimationValue = 1; }
    //   if (animation.animateData) { _dataAnimationController.forward(from: 0); axisAnimationValue = 1; }
    //   if (!animation.animateData && !animation.animateAxis) { dataAnimationValue = 1; axisAnimationValue = 1; }
    // }
  }

  void analyseData() {
    var valueType = widget.rawData.values;
    if (valueType.isNotEmpty) {
      var sampleValue = valueType.first;
      if (sampleValue is Map) {
        chartIsGrouped = true;
      } else if (sampleValue is num) {
        chartIsGrouped = false;
      }
      xGroups = widget.rawData.keys.toList();
      if (style.sortXAxis) {
        style.groupComparator != null
            ? xGroups.sort(style.groupComparator)
            : xGroups.sort();
      }

      double maxTotalValueOverall = 0;
      if (!chartIsGrouped) {
        for (String key in xGroups) {
          // TODO Add try catch?
          final double d = widget.rawData[key].toDouble();
          _yValues.add(d);
          _bars.add(BarChartDataDouble(group: key, data: d, style: style.barStyle));
        }
      } else {
        for (String key in xGroups) {
          double maxTotalValue = 0;
          final Map<String, num> groupData = widget.rawData[key];
          final List<BarChartDataDouble> dataInGroup = [];
          groupData.forEach((subgroup, value) {
            maxTotalValue += value;
            subGroups.add(subgroup);
            dataInGroup.add(BarChartDataDouble(group: subgroup, data: value.toDouble()));
            _yValues.add(value.toDouble());
          });
          _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
          if (maxTotalValue >= maxTotalValueOverall) { maxTotalValueOverall = maxTotalValue; }
        }
        subGroups = subGroups.toSet().toList();
        final List<String> existedGroupColor = subGroupColors.keys.toList();
        for (String subGroup in subGroups) {
          if (!existedGroupColor.contains(subGroup)) {
            // Generate random color for subgroup if not specified
            // TODO Better function?
            subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
          }
        }
      }
      _yValueRange = [_yValues.reduce(min), _yValues.reduce(max), maxTotalValueOverall];
    }
  }

  final Container a = Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(border: Border.all(color: Colors.red)),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Padding(
        // TODO
        padding: EdgeInsets.all(0),
        child: Stack(
          children: [
            // Left Axis
            Positioned(
              top: titleSize.height,
              child: leftAxis,
            ),

            // Title
            Positioned(
              top: 0,
              left: 0,
              child: chartTitle,
            ),
            // Canvas
            Positioned(
              top: titleSize.height,
              left: leftAxisSize.width,
              child: chartCanvas,
            ),
            // Bottom Axis
            Positioned(
              top: titleSize.height + canvasSize.height,
              left: leftAxisSize.width,
              child: bottomAxis,
            ),
            // Bottom Legends
            Positioned(
              top: titleSize.height + canvasSize.height + bottomAxisSize.height,
              left: leftAxisSize.width,
              child: bottomLegend,
            ),

            // Right Axis
            Positioned(
              top: titleSize.height,
              left: leftAxisSize.width + canvasSize.width,
              child: rightAxis,
            ),
            // Right Legends
            Positioned(
              top: titleSize.height,
              left: leftAxisSize.width + canvasSize.width + rightAxisSize.width,
              child: rightLegend,
            ),
          ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _axisAnimationController.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }
}

@immutable
class ChartTitle extends StatelessWidget {
  final String title;
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  ChartTitle({
    @required this.title,
    @required this.parentSize,
    this.widthInPercentage = 1,
    this.heightInPercentage = 0.1,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      width: parentSize.width * widthInPercentage,
      height: parentSize.height * heightInPercentage,
      child: Center(
        child: Text(
          title,
          style: textStyle,
        ),
      ),
    );
  }

  Size get size => Size(parentSize.width * widthInPercentage, parentSize.height * heightInPercentage);
}