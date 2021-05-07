import 'dart:ui';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:provider/provider.dart';
import 'components/chart_axis.dart';
import 'components/chart_legend.dart';
import 'components/chart_title.dart';
import 'components/stateful/chart_axis.dart';
import 'components/stateful/chart_canvas_wrapper.dart';

@immutable
class ModularBarChart extends StatelessWidget {
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
    // print('called copy with');
    // print(dataModel.subGroupColors);
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
    dataModel.analyseData();
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
    dataModel.analyseData();
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
    dataModel.analyseData();
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
    dataModel.analyseData();
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.GroupedSeparated,
      style: style,
    );
  }

  String get title => this.style.title.text;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BarChartStyle>(create: (_) => style),
        Provider<ModularBarChartData>(create: (_) => dataModel),
      ],
      child: LayoutBuilder(builder: (context, constraint) {
        ModularBarChartData data = context.read<ModularBarChartData>();
        BarChartStyle style = context.read<BarChartStyle>();
        // Size data
        Size leftAxisSize = Size.zero,
            titleSize = Size.zero,
            canvasSize = Size.zero,
            bottomLabelSize = Size.zero,
            rightAxisSize = Size.zero;
        final double parentHeight = constraint.maxHeight < double.infinity
            ? constraint.maxHeight
            : MediaQuery.of(context).size.height;
        final double parentWidth = constraint.maxWidth < double.infinity
            ? constraint.maxWidth
            : MediaQuery.of(context).size.width;
        final Size parentSize = Size(parentWidth, parentHeight);

        final bool hasYAxisOnTheRight =
            type == BarChartType.GroupedSeparated ? true : false;
        // Get static sizes of components
        double leftAxisStaticWidth, rightAxisStaticWidth;
        if (hasYAxisOnTheRight) {
          leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(
              style.y1AxisStyle.label.text,
              data.y1ValueRange[1],
              style.y1AxisStyle);
          rightAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(
              style.y1AxisStyle.label.text,
              data.y2ValueRange[1],
              style.y1AxisStyle);
        } else {
          leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(
              style.y1AxisStyle.label.text,
              data.y1ValueRange[1],
              style.y1AxisStyle);
          rightAxisStaticWidth = 0;
        }
        final double titleStaticHeight = ChartTitle.getHeight(style.title);
        final double bottomAxisStaticHeight =
            ChartAxisHorizontal.getHeight(style.xAxisStyle);
        final double bottomLabelStaticHeight =
            ChartTitle.getHeight(style.xAxisStyle.label);
        final double bottomLegendStaticHeight = style.legendStyle.visible
            ? ChartLegendHorizontal.getHeight(BarChartLabel(
                text: 'Title', textStyle: style.legendStyle.legendTextStyle))
            : 0;
        double canvasWidth =
            parentWidth - leftAxisStaticWidth - rightAxisStaticWidth;
        if (canvasWidth < 0) {
          canvasWidth = 0;
        }
        double canvasHeight = parentHeight -
            titleStaticHeight -
            bottomAxisStaticHeight -
            bottomLabelStaticHeight -
            bottomLegendStaticHeight;
        if (canvasHeight < 0) {
          canvasHeight = 0;
        }
        canvasSize = Size(canvasWidth, canvasHeight);

        // Adjust xSectionLength in case of data is too small
        final List<double> xSectionLength =
            calculateXSectionLength(data, style, canvasWidth);
        bool overrideInputBarWidth = false;
        double overrideBarWidth;
        // This means a new bar width is calculated
        if (xSectionLength.length == 2) {
          overrideInputBarWidth = true;
          overrideBarWidth = xSectionLength[1];
        }

        // Adjust y Max to fit number on bar and populate data
        data.adjustAxisValueRange(
          canvasHeight,
          valueRangeToBeAdjusted: data.y1ValueRange,
          start: style.y1AxisStyle.preferredStartValue,
          end: style.y1AxisStyle.preferredEndValue,
        );
        if (hasYAxisOnTheRight) {
          data.adjustAxisValueRange(
            canvasHeight,
            valueRangeToBeAdjusted: data.y2ValueRange,
            start: style.y1AxisStyle.preferredStartValue,
            end: style.y1AxisStyle.preferredEndValue,
          );
        }
        data.populateDataWithMinimumValue();

        // Canvas and bottom axis
        final ChartCanvasWrapper chartCanvasWithAxis = ChartCanvasWrapper(
          size: Size(canvasWidth, canvasHeight + bottomAxisStaticHeight),
          canvasSize: canvasSize,
          data: data,
          style: style,
          barWidth: overrideInputBarWidth
              ? overrideBarWidth
              : style.barStyle.barWidth,
          displayMiniCanvas: overrideInputBarWidth ? false : true,
        );
        final Size chartCanvasWithAxisSize = chartCanvasWithAxis.size;

        // Left Axis
        final ChartAxisVerticalWithLabel leftAxis = ChartAxisVerticalWithLabel(
          axisHeight: canvasHeight,
        );
        leftAxisSize = leftAxis.size(data.y1ValueRange[2], style.y1AxisStyle);

        // Title
        final ChartTitle chartTitle = ChartTitle(
          width: parentSize.width,
        );
        titleSize = chartTitle.size(style.title);

        // Bottom Label
        final ChartTitle bottomLabel = ChartTitle(
          width: canvasWidth,
          isXAxisLabel: true,
        );
        bottomLabelSize = bottomLabel.size(style.xAxisStyle.label);

        // Bottom Legend
        ChartLegendHorizontal bottomLegend;
        if (style.legendStyle.visible) {
          bottomLegend = ChartLegendHorizontal(width: canvasWidth);
        }

        // Right Axis
        final ChartAxisVerticalWithLabel rightAxis = ChartAxisVerticalWithLabel(
          axisHeight: canvasHeight,
          isRightAxis: true,
        );
        rightAxisSize = rightAxis.size(data.y2ValueRange[2], style.y2AxisStyle);

        // TODO Too small to have a canvas?
        return SizedBox(
          width: parentWidth,
          height: parentHeight,
          child: Padding(
            // TODO padding
            padding: EdgeInsets.all(0),
            child: Stack(children: [
              // Canvas and bottom axis
              Positioned(
                top: titleSize.height,
                left: leftAxisSize.width,
                child: chartCanvasWithAxis,
              ),

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

              // Bottom Label
              Positioned(
                top: titleSize.height + chartCanvasWithAxisSize.height,
                left: leftAxisSize.width,
                child: bottomLabel,
              ),

              // Bottom Legends
              style.legendStyle.visible
                  ? Positioned(
                      top: titleSize.height +
                          chartCanvasWithAxisSize.height +
                          bottomLabelSize.height,
                      left: leftAxisSize.width,
                      child: bottomLegend,
                    )
                  : SizedBox(),

              // Right Axis
              hasYAxisOnTheRight
                  ? Positioned(
                      top: titleSize.height,
                      left: leftAxisSize.width + canvasWidth,
                      child: rightAxis,
                    )
                  : SizedBox(),
            ]),
          ),
        );
      }),
    );
  }

  List<double> calculateXSectionLength(
      ModularBarChartData data, BarChartStyle style, double canvasWidth) {
    int numBarsInGroup = (data.type == BarChartType.Ungrouped ||
            data.type == BarChartType.GroupedStacked ||
            data.type == BarChartType.GroupedSeparated)
        ? 1
        : data.xSubGroups.length;
    double totalBarWidth = numBarsInGroup * style.barStyle.barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin =
        style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
    double xSectionLengthCalculatedFromData =
        totalBarWidth + totalGroupMargin + totalInGroupMargin;
    double xSectionLengthAvailable = canvasWidth / data.xGroups.length;
    if (xSectionLengthCalculatedFromData > xSectionLengthAvailable) {
      return [xSectionLengthCalculatedFromData];
    } else {
      double newBarWidth =
          (xSectionLengthAvailable - totalGroupMargin - totalInGroupMargin) /
              numBarsInGroup;
      return [xSectionLengthAvailable, newBarWidth];
    }
  }
}
