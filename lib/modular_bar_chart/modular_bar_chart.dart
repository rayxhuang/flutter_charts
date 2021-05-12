import 'dart:ui';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/canvas/chart_mini_canvas.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_event.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';
import 'components/chart_axis.dart';
import 'components/chart_legend.dart';
import 'components/chart_title.dart';
import 'components/canvas/chart_main_canvas_wrapper.dart';

@immutable
class ModularBarChart extends StatelessWidget with StringSize {
  final Map<String, dynamic> data;
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final BarChartType type;

  const ModularBarChart._({
    @required this.data,
    @required this.dataModel,
    @required this.type,
    this.style = const BarChartStyle(),
  }) : assert(data != null);

  ModularBarChart copyWith({
    BarChartStyle style,
    Map<String, Color> colorMap,
  }) {
    final ModularBarChartData dataModel = this.dataModel;
    dataModel.subGroupColors = colorMap ?? dataModel.subGroupColors;
    return ModularBarChart._(
      data: this.data,
      dataModel: dataModel,
      style: style ?? this.style,
      type: this.type
    );
  }

  factory ModularBarChart.ungrouped({
    @required Map<String, double> data,
    BarChartStyle style,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData.ungrouped(
      rawData: data,
      sortXAxis: style.sortXAxis,
      xGroupComparator: style.groupComparator
    );
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.Ungrouped,
      style: style,
    );
  }

  factory ModularBarChart.grouped({
    @required Map<String, Map<String, double>> data,
    BarChartStyle style,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData.grouped(
      rawData: data,
      sortXAxis: style.sortXAxis,
      xGroupComparator: style.groupComparator
    );
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.Grouped,
      style: style,
    );
  }

  factory ModularBarChart.groupedStacked({
    @required Map<String, Map<String, double>> data,
    BarChartStyle style,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData.groupedStacked(
      rawData: data,
      sortXAxis: style.sortXAxis,
      xGroupComparator: style.groupComparator
    );
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.GroupedStacked,
      style: style,
    );
  }

  factory ModularBarChart.groupedSeparated({
    @required Map<String, Map<String, double>> data,
    BarChartStyle style,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData.groupedSeparated(
      rawData: data,
      sortXAxis: style.sortXAxis,
      xGroupComparator: style.groupComparator
    );
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.GroupedSeparated,
      style: style,
    );
  }

  String get title => this.style.title.text;

  Size _getParentSize({
    @required BoxConstraints constraint,
    @required BuildContext context,
  }) {
    final double parentHeight = constraint.maxHeight < double.infinity
        ? constraint.maxHeight
        : MediaQuery.of(context).size.height;
    final double parentWidth = constraint.maxWidth < double.infinity
        ? constraint.maxWidth
        : MediaQuery.of(context).size.width;
    return Size(parentWidth, parentHeight);
  }

  Widget _buildMiniChart({@required DisplayInfo displayInfo,}) {
    final Size canvasSize = displayInfo.canvasSize;
    final BarChartStyle style = displayInfo.style;
    return Column(
      children: [
        ChartCanvasMini(containerSize: canvasSize),
        HorizontalAxisSimpleWrapper(
          size: Size(canvasSize.width, style.xAxisStyle.strokeWidth),
        ),
      ],
    );
  }

  Widget _buildChart({
    @required DisplayInfo displayInfo,
    @required Widget title,
    @required Widget spacing,
    @required Widget leftAxisWithLabel,
    @required Widget mainCanvasWithBottomAxis,
    @required Widget bottomLabel,
    @required Widget bottomLegend,
    @required Widget rightAxisWithLabel,
  }) {
    final Size canvasWrapperSize = displayInfo.canvasWrapperSize;
    final double titleHeight = displayInfo.titleHeight;
    final double spacingHeight = displayInfo.spacingHeight;
    final double leftAxisWidth = displayInfo.leftAxisCombinedWidth;
    final double bottomLabelHeight = displayInfo.bottomLabelHeight;
    return SizedBox.fromSize(
      size: displayInfo.parentSize,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Stack(children: [
          // Spacing between title and axis
          Positioned(
            left: 0,
            top: titleHeight,
            child: spacing,
          ),

          // Canvas and bottom axis
          Positioned(
            top: titleHeight + spacingHeight,
            left: leftAxisWidth,
            child: mainCanvasWithBottomAxis,
          ),

          // Left Axis
          Positioned(
            top: titleHeight + spacingHeight,
            child: leftAxisWithLabel,
          ),

          // Title
          Positioned(
            top: 0,
            left: 0,
            child: title,
          ),

          // Bottom Label
          Positioned(
            top: titleHeight + spacingHeight + canvasWrapperSize.height,
            left: leftAxisWidth,
            child: bottomLabel,
          ),

          // Bottom Legends
          Positioned(
            top: titleHeight + spacingHeight + canvasWrapperSize.height + bottomLabelHeight,
            left: leftAxisWidth,
            child: bottomLegend,
          ),

          // Right Axis
          Positioned(
            top: titleHeight + spacingHeight,
            left: leftAxisWidth + canvasWrapperSize.width,
            child: rightAxisWithLabel,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        final Size parentSize = _getParentSize(constraint: constraint, context: context);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<DisplayInfo>(
              create: (_) {
                final DisplayInfo sizeInfo = DisplayInfo(dataModel: dataModel, style: style, parentSize: parentSize);
                // init will calculate and set all component sizes
                sizeInfo.init();
                return sizeInfo;
              }
            ),
            ChangeNotifierProvider<BarChartEvent>(
              create: (_) => BarChartEvent(dataModel: dataModel, style: style)
            ),
          ],
          child: Consumer<DisplayInfo>(
            builder: (context, size, child) {
              final DisplayInfo displayInfo = context.read<DisplayInfo>();
              final BarChartStyle style = displayInfo.style;

              // Canvas and bottom axis
              final Widget chartCanvasWithAxis = displayInfo.isMini
                  ? _buildMiniChart(displayInfo: displayInfo)
                  : ChartCanvasWrapper();

              // Left Axis
              final VerticalAxisWithLabel leftAxis = VerticalAxisWithLabel();

              // Title
              final ChartTitle chartTitle = ChartTitle(
                width: parentSize.width,
                hasRightAxis: displayInfo.hasYAxisOnTheRight,
              );

              // Bottom Label
              final Widget bottomLabel = BottomAxisLabel();

              // Bottom Legend
              final Widget bottomLegend = style.legendStyle.visible && !style.isMini
                  ? ChartLegendHorizontal()
                  : SizedBox();

              // Right Axis
              final Widget rightAxis = displayInfo.hasYAxisOnTheRight
                  ? VerticalAxisWithLabel(isRightAxis: true)
                  : SizedBox();

              // TODO Too small to have a canvas?
              return _buildChart(
                displayInfo: displayInfo,
                title: chartTitle,
                spacing: SizedBox(height: displayInfo.spacingHeight,),
                leftAxisWithLabel: leftAxis,
                mainCanvasWithBottomAxis: chartCanvasWithAxis,
                bottomLabel: bottomLabel,
                bottomLegend: bottomLegend,
                rightAxisWithLabel: rightAxis,
              );
            },
          ),
        );
      }
    );
  }
}