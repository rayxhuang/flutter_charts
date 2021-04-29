import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

import 'components/chart_axis.dart';
import 'components/chart_canvas.dart';
import 'components/chart_legend.dart';

enum BarChartType {Ungrouped, Grouped, GroupedStacked, GroupedSeparated, Grouped3D}

abstract class AbstractModularBarChartData {
  final Map<String, dynamic> rawData;
  final BarChartType type;

  const AbstractModularBarChartData._({
    this.rawData,
    this.type,
  });
}

class ModularBarChartData extends AbstractModularBarChartData{
  const ModularBarChartData.ungrouped({
    @required Map<String, double> rawData,
  }) : super._(
    rawData: rawData ?? const {},
    type: BarChartType.Ungrouped,
  );

  const ModularBarChartData.grouped({
    @required Map<String, Map<String, double>> rawData,
  }) : super._(
    rawData: rawData ?? const {},
    type: BarChartType.Grouped,
  );

  const ModularBarChartData.groupedStacked({
    @required Map<String, Map<String, double>> rawData,
  }) : super._(
    rawData: rawData ?? const {},
    type: BarChartType.GroupedStacked,
  );
}

class ModularFancyBarChart extends StatefulWidget {
  final AbstractModularBarChartData rawData;
  final double width;
  final double height;
  final BarChartStyle style;

  ModularFancyBarChart({
    @required this.rawData,
    @required this.width,
    @required this.height,
    this.style = const BarChartStyle(),
  }) : assert(rawData != null);

  @override
  _ModularFancyBarChartState createState() => _ModularFancyBarChartState();
}

class _ModularFancyBarChartState extends State<ModularFancyBarChart> with TickerProviderStateMixin{
  BarChartStyle style;
  List<String> xGroups = [], xSubGroups = [];
  List<double> y1Values = [], y2Values = [], yValueRange = [0, 0, 0];
  Map<String, Color> subGroupColors = {};

  List<BarChartDataDouble> _bars = [];
  List<BarChartDataDoubleGrouped> _groupedBars = [];

  // Var for scrolling and animation
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2;
  double scrollOffset = 0;
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  Size leftLabelSize = Size.zero, leftAxisSize  = Size.zero, titleSize = Size.zero, canvasSize = Size.zero, bottomAxisSize = Size.zero,
      bottomLegendSize = Size.zero, rightAxisSize = Size.zero, rightLegendSize = Size.zero;

  Size parentSize;
  ChartTitle chartTitle;
  ChartCanvas chartCanvas;
  ChartAxisHorizontal topAxis, bottomAxis;
  ChartAxisVertical leftAxis, rightAxis;
  ChartLabelVertical leftLabel;
  ChartLegendHorizontal bottomLegend;
  ChartLegendVertical rightLegend;

  @override
  void initState() {
    super.initState();
    analyseData();
    adjustAxisValueRange();

    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();

    parentSize = Size(widget.width, widget.height);
    chartTitle = ChartTitle(title: 'Bar Chart Title', parentSize: parentSize);
    titleSize = chartTitle.size;
    // topAxis = ChartAxisHorizontal(parentSize: parentSize);
    // topAxisSize = topAxis.size;
    int numInGroups = xSubGroups.length;
    if (numInGroups <= 1) { numInGroups = 1; }
    if (widget.rawData.type == BarChartType.GroupedStacked) { numInGroups = 1; }
    bottomAxis = ChartAxisHorizontal(
      parentSize: parentSize,
      xGroups: xGroups,
      barWidth: widget.style.barWidth,
      numBarsInGroup: numInGroups,
      style: widget.style,
      scrollController: _scrollController2,
    );
    bottomAxisSize = bottomAxis.size;
    bottomLegend = ChartLegendHorizontal(parentSize: parentSize);
    bottomLegendSize = bottomLegend.size;

    switch (widget.rawData.type) {
      case BarChartType.Ungrouped:
        chartCanvas = ChartCanvas.ungrouped(
          parentSize: parentSize,
          length: bottomAxis.length,
          scrollController: _scrollController1,
          xGroups: xGroups,
          valueRange: yValueRange,
          xSectionLength: bottomAxis.xSectionLength,
          bars: _bars,
          style: widget.style,
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
          isStacked: widget.rawData.type == BarChartType.GroupedStacked ? true : false,
          parentSize: parentSize,
          length: bottomAxis.length,
          scrollController: _scrollController1,
          xGroups: xGroups,
          subGroups: xSubGroups,
          subGroupColors: subGroupColors,
          valueRange: yValueRange,
          xSectionLength: bottomAxis.xSectionLength,
          groupedBars: _groupedBars,
          style: widget.style,
        );
        break;
    }
    canvasSize = chartCanvas.size;

    leftLabel = ChartLabelVertical(parentSize: parentSize, label: 'Y Axis',);
    leftLabelSize = leftLabel.size;
    leftAxis = ChartAxisVertical(
      parentSize: parentSize,
      yValueRange: yValueRange,
      axisStyle: widget.style.yAxisStyle,
    );
    leftAxisSize = leftAxis.size;

    rightAxis = ChartAxisVertical(parentSize: parentSize, yValueRange: yValueRange, axisStyle: widget.style.yAxisStyle);
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
    final AbstractModularBarChartData data = widget.rawData;
    final BarChartType type = data.type;
    final BarChartStyle style = widget.style;
    xGroups = data.rawData.keys.toList();
    if (style.sortXAxis) {
      style.groupComparator == null
          ? xGroups.sort()
          : xGroups.sort(style.groupComparator);
    }
    switch (type) {
      case BarChartType.Ungrouped:
        for (String key in xGroups) {
          y1Values.add(data.rawData[key]);
          _bars.add(BarChartDataDouble(group: key, data: data.rawData[key]));
        }
        yValueRange[0] = y1Values.reduce(min);
        yValueRange[1] = y1Values.reduce(max);
        break;
      case BarChartType.GroupedSeparated:
      // TODO: Handle this case.
        break;
      case BarChartType.Grouped3D:
      // TODO: Handle this case.
        break;
      default:
        // default is shared by Grouped and GroupedStacked
        // TODO Fix missing middle group shift
        double localMaximum = double.negativeInfinity;
        data.rawData.forEach((key, map) {
          xSubGroups.addAll(map.keys.toList());
          final List<BarChartDataDouble> dataInGroup = [];
          double sum = 0;
          map.forEach((subgroup, value) {
            xSubGroups.add(subgroup);
            dataInGroup.add(BarChartDataDouble(group: subgroup, data: value.toDouble()));
            y1Values.add(value.toDouble());
            sum += value.toDouble();
          });
          if (sum >= localMaximum) { localMaximum = sum; }
          _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
        });
        xSubGroups = xSubGroups.toSet().toList();
        yValueRange[0] = y1Values.reduce(min);
        yValueRange[1] = type == BarChartType.Grouped
            ? y1Values.reduce(max)
            : localMaximum;
        break;
    }
    // Generate color for subgroups
    if (type != BarChartType.Ungrouped) {
      for (String subGroup in xSubGroups) { subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)]; }
    }
  }

  void adjustAxisValueRange() {
    widget.style.yAxisStyle.preferredStartValue <= yValueRange[0]
        ? yValueRange[0] = widget.style.yAxisStyle.preferredStartValue
        : yValueRange[0] = yValueRange[0];

    // if (type != BarChartType.GroupedStacked) {
    //   yStyle.preferredEndValue >= yValueRange[1]
    //       ? yMax = yStyle.preferredEndValue
    //       : yMax = yValueRange[1];
    // } else {
    //   widget.style.yAxisStyle.preferredEndValue >= yValueRange[2]
    //       ? yMax = widget.style.yAxisStyle.preferredEndValue
    //       : yMax = yValueRange[2];
    // }
    widget.style.yAxisStyle.preferredEndValue >= yValueRange[1]
        ? yValueRange[1] = widget.style.yAxisStyle.preferredEndValue
        : yValueRange[1] = yValueRange[1];
  }

    //   double maxTotalValueOverall = 0;
    //   if (!chartIsGrouped) {
    //     for (String key in xGroups) {
    //       // TODO Add try catch?
    //       final double d = widget.rawData[key].toDouble();
    //       _yValues.add(d);
    //       _bars.add(BarChartDataDouble(group: key, data: d, style: style.barStyle));
    //     }
    //   } else {
    //     for (String key in xGroups) {
    //       double maxTotalValue = 0;
    //       final Map<String, num> groupData = widget.rawData[key];
    //       final List<BarChartDataDouble> dataInGroup = [];
    //       groupData.forEach((subgroup, value) {
    //         maxTotalValue += value;
    //         subGroups.add(subgroup);
    //         dataInGroup.add(BarChartDataDouble(group: subgroup, data: value.toDouble()));
    //         _yValues.add(value.toDouble());
    //       });
    //       _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
    //       if (maxTotalValue >= maxTotalValueOverall) { maxTotalValueOverall = maxTotalValue; }
    //     }
    //     subGroups = subGroups.toSet().toList();
    //     final List<String> existedGroupColor = subGroupColors.keys.toList();
    //     for (String subGroup in subGroups) {
    //       if (!existedGroupColor.contains(subGroup)) {
    //         // Generate random color for subgroup if not specified
    //         // TODO Better function?
    //         subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    //       }
    //     }
    //   }
    //   _yValueRange = [_yValues.reduce(min), _yValues.reduce(max), maxTotalValueOverall];
    // }

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
            // Left Label
            Positioned(
              top: titleSize.height,
              child: leftLabel,
            ),
            // Left Axis
            Positioned(
              left: leftLabelSize.width,
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
              left: leftAxisSize.width + leftLabelSize.width,
              child: chartCanvas,
            ),
            // Bottom Axis
            Positioned(
              top: titleSize.height + canvasSize.height - widget.style.yAxisStyle.strokeWidth / 2,
              left: leftAxisSize.width + leftLabelSize.width,
              child: bottomAxis,
            ),
            // Bottom Legends
            Positioned(
              top: titleSize.height + canvasSize.height + bottomAxisSize.height,
              left: leftAxisSize.width + leftLabelSize.width,
              child: bottomLegend,
            ),

            // Right Axis
            Positioned(
              top: titleSize.height,
              left: leftAxisSize.width + leftLabelSize.width + canvasSize.width,
              child: rightAxis,
            ),
            // Right Legends
            Positioned(
              top: titleSize.height,
              left: leftAxisSize.width + leftLabelSize.width + canvasSize.width + rightAxisSize.width,
              child: rightLegend,
            ),
          ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
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
      //decoration: BoxDecoration(border: Border.all(color: Colors.red)),
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