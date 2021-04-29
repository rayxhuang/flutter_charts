import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/modular_fancy_bar_chart.dart';

import 'chart_canvas_painter.dart';

class ChartCanvas extends StatefulWidget {
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;
  final double length;
  final BarChartStyle style;
  final ScrollController scrollController;

  final BarChartType type;
  final List<String> xGroups;
  final List<String> subGroups;
  final List<double> valueRange;
  final double xSectionLength;
  final List<BarChartDataDouble> bars;
  final List<BarChartDataDoubleGrouped> groupedBars;
  final Map<String, Color> subGroupColors;
  final bool isStacked;

  const ChartCanvas._({
    @required this.type,
    @required this.xGroups,
    @required this.valueRange,
    @required this.xSectionLength,
    @required this.parentSize,
    @required this.length,
    @required this.scrollController,
    this.widthInPercentage = 0.7,
    this.heightInPercentage = 0.7,
    this.style = const BarChartStyle(),
    this.bars,
    this.groupedBars,
    this.subGroups,
    this.subGroupColors,
    this.isStacked = false,
  });

  factory ChartCanvas.ungrouped({
    @required List<String> xGroups,
    @required List<double> valueRange,
    @required double xSectionLength,
    @required Size parentSize,
    @required double length,
    @required ScrollController scrollController,
    @required List<BarChartDataDouble> bars,
    double widthInPercentage = 0.7,
    double heightInPercentage = 0.7,
    BarChartStyle style = const BarChartStyle(),
  }) {
    return ChartCanvas._(
      type: BarChartType.Ungrouped,
      xGroups: xGroups,
      valueRange: valueRange,
      xSectionLength: xSectionLength,
      parentSize: parentSize,
      length: length,
      scrollController: scrollController,
      widthInPercentage: widthInPercentage,
      heightInPercentage: heightInPercentage,
      style: style,
      bars: bars,
    );
  }

  factory ChartCanvas.grouped({
    @required List<String> xGroups,
    @required List<String> subGroups,
    @required List<double> valueRange,
    @required double xSectionLength,
    @required Size parentSize,
    @required double length,
    @required ScrollController scrollController,
    @required List<BarChartDataDoubleGrouped> groupedBars,
    @required Map<String, Color> subGroupColors,
    double widthInPercentage = 0.7,
    double heightInPercentage = 0.7,
    BarChartStyle style = const BarChartStyle(),
    bool isStacked = false,
  }) {
    return ChartCanvas._(
      isStacked: isStacked,
      type: BarChartType.Grouped,
      xGroups: xGroups,
      subGroups: subGroups,
      subGroupColors: subGroupColors,
      valueRange: valueRange,
      xSectionLength: xSectionLength,
      parentSize: parentSize,
      length: length,
      scrollController: scrollController,
      widthInPercentage: widthInPercentage,
      heightInPercentage: heightInPercentage,
      style: style,
      groupedBars: groupedBars,
    );
  }

  Size get size => Size(parentSize.width * widthInPercentage, parentSize.height * heightInPercentage);

  @override
  _ChartCanvasState createState() => _ChartCanvasState();
}

class _ChartCanvasState extends State<ChartCanvas> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      width: widget.parentSize.width * widget.widthInPercentage,
      height: widget.parentSize.height * widget.heightInPercentage,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: widget.scrollController,
        child: CustomPaint(
          painter: getPainter(),
          size: Size(widget.length, widget.size.height),
        ),
      ),
    );
  }

  DataPainter getPainter() {
    switch (widget.type) {
      case BarChartType.Ungrouped:
        return DataPainter.ungrouped(
          xGroups: widget.xGroups,
          valueRange: widget.valueRange,
          xSectionLength: widget.xSectionLength,
          style: widget.style,
          bars: widget.bars,
        );
      // case BarChartType.Grouped:
      //   return DataPainter.grouped(
      //     xGroups: widget.xGroups,
      //     subGroups: widget.subGroups,
      //     subGroupColors: widget.subGroupColors,
      //     valueRange: widget.valueRange,
      //     xSectionLength: widget.xSectionLength,
      //     style: widget.style,
      //     groupedBars: widget.groupedBars,
      //   );
      // case BarChartType.GroupedStacked:
      //   // TODO: Handle this case.
      //   break;
      case BarChartType.GroupedSeparated:
        // TODO: Handle this case.
        break;
      case BarChartType.Grouped3D:
        // TODO: Handle this case.
        break;
      default:
        return DataPainter.grouped(
          isStacked: widget.isStacked,
          xGroups: widget.xGroups,
          subGroups: widget.subGroups,
          subGroupColors: widget.subGroupColors,
          valueRange: widget.valueRange,
          xSectionLength: widget.xSectionLength,
          style: widget.style,
          groupedBars: widget.groupedBars,
        );
    }
  }
}