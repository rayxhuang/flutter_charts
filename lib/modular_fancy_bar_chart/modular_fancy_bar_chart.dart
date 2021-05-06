import 'dart:ui';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
import 'package:provider/provider.dart';

import 'components/chart_axis.dart';
import 'components/chart_legend.dart';
import 'components/chart_title.dart';
import 'components/stateful/chart_axis.dart';
import 'components/stateful/chart_canvas_wrapper.dart';

class ModularBarChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final BarChartStyle style;
  final BarChartType type;

  ModularBarChart._({
    @required this.data,
    @required this.type,
    this.style = const BarChartStyle(),
  }) : assert(data != null);

  factory ModularBarChart.ungrouped({
    @required Map<String, double> data,
    BarChartStyle style,
  }) => ModularBarChart._(
    data: data,
    type: BarChartType.Ungrouped,
    style: style,
  );

  factory ModularBarChart.grouped({
    @required Map<String, Map<String,double>> data,
    BarChartStyle style,
  }) => ModularBarChart._(
    data: data,
    type: BarChartType.Grouped,
    style: style,
  );

  factory ModularBarChart.groupedStacked({
    @required Map<String, Map<String,double>> data,
    BarChartStyle style,
  }) => ModularBarChart._(
    data: data,
    type: BarChartType.GroupedStacked,
    style: style,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BarChartStyle>(create: (_) => style),
        Provider<ModularBarChartData>(create: (_) {
          ModularBarChartData dataModel;
           switch (type) {
            case BarChartType.Ungrouped:
              dataModel = ModularBarChartData.ungrouped(rawData: data, sortXAxis: style.sortXAxis, xGroupComparator: style.groupComparator);
              break;
            case BarChartType.Grouped:
              dataModel = ModularBarChartData.grouped(
                rawData: data,
                sortXAxis: style.sortXAxis,
                xGroupComparator: style.groupComparator,
                subGroupColors: style.subGroupColors ?? {},
              );
              break;
            case BarChartType.GroupedStacked:
              dataModel = ModularBarChartData.groupedStacked(
                rawData: data,
                sortXAxis: style.sortXAxis,
                xGroupComparator: style.groupComparator,
                subGroupColors: style.subGroupColors ?? {},
              );
              break;
            case BarChartType.GroupedSeparated:
              // TODO: Handle this case.
              break;
            case BarChartType.Grouped3D:
              // TODO: Handle this case.
              break;
          }
          dataModel.analyseData();
          return dataModel;
        }),
      ],
      child: LayoutBuilder(
        builder: (context, constraint) {
          ModularBarChartData data = context.read<ModularBarChartData>();
          BarChartStyle style = context.read<BarChartStyle>();
          // Size data
          Size leftAxisSize = Size.zero, titleSize = Size.zero, canvasSize = Size.zero, bottomLabelSize = Size.zero;
          final double parentHeight = constraint.maxHeight < double.infinity ? constraint.maxHeight : MediaQuery.of(context).size.height;
          final double parentWidth = constraint.maxWidth < double.infinity ? constraint.maxWidth : MediaQuery.of(context).size.width;
          final Size parentSize = Size(parentWidth, parentHeight);

          // Get static sizes of components
          final double leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(style.yAxisStyle.label.text, data.yValueRange[1], style.yAxisStyle);
          final double titleStaticHeight = ChartTitle.getHeight(style.title);
          final double bottomAxisStaticHeight = ChartAxisHorizontal.getHeight(style.xAxisStyle);
          final double bottomLabelStaticHeight = ChartTitle.getHeight(style.xAxisStyle.label);
          final double bottomLegendStaticHeight =
          style.legendStyle.visible
              ? ChartLegendHorizontal.getHeight(BarChartLabel(text: 'Title', textStyle: style.legendStyle.legendTextStyle))
              : 0;
          double canvasWidth = parentWidth - leftAxisStaticWidth;
          if (canvasWidth < 0) { canvasWidth = 0; }
          double canvasHeight = parentHeight - titleStaticHeight - bottomAxisStaticHeight - bottomLabelStaticHeight - bottomLegendStaticHeight;
          if (canvasHeight < 0) { canvasHeight = 0; }
          canvasSize = Size(canvasWidth, canvasHeight);

          // Adjust xSectionLength in case of data is too small
          final List<double> xSectionLength = calculateXSectionLength(data, style, canvasWidth);
          bool overrideInputBarWidth = false;
          double overrideBarWidth;
          // This means a new bar width is calculated
          if (xSectionLength.length == 2) { overrideInputBarWidth = true; overrideBarWidth = xSectionLength[1];}

          // Adjust y Max to fit number on bar and populate data
          data.adjustAxisValueRange(canvasHeight, start: style.yAxisStyle.preferredStartValue, end: style.yAxisStyle.preferredEndValue);
          data.populateDataWithMinimumValue();

          // Canvas and bottom axis
          final ChartCanvasWrapper chartCanvasWithAxis = ChartCanvasWrapper(
            size: Size(canvasWidth, canvasHeight + bottomAxisStaticHeight),
            canvasSize: canvasSize,
            data: data,
            style: style,
            barWidth: overrideInputBarWidth ? overrideBarWidth : style.barStyle.barWidth,
            displayMiniCanvas: overrideInputBarWidth ? false : true,
          );
          final Size chartCanvasWithAxisSize = chartCanvasWithAxis.size;

          // Left Axis
          final ChartAxisVerticalWithLabel leftAxis = ChartAxisVerticalWithLabel(axisHeight: canvasHeight,);
          leftAxisSize = leftAxis.size(data.yValueRange[2], style.yAxisStyle);

          // Title
          final ChartTitle chartTitle = ChartTitle(width: parentSize.width,);
          titleSize = chartTitle.size(style.title);

          // Bottom Label
          final ChartTitle bottomLabel = ChartTitle(width: canvasWidth, isXAxisLabel: true,);
          bottomLabelSize = bottomLabel.size(style.xAxisStyle.label);

          // Bottom Legend
          ChartLegendHorizontal bottomLegend;
          if (style.legendStyle.visible) { bottomLegend = ChartLegendHorizontal(width: canvasWidth); }

          // TODO Too small to have a canvas?
          return SizedBox(
            width: parentWidth,
            height: parentHeight,
            child: Padding(
              // TODO padding
              padding: EdgeInsets.all(0),
              child: Stack(
                children: [
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
                        top: titleSize.height + chartCanvasWithAxisSize.height + bottomLabelSize.height,
                        left: leftAxisSize.width,
                        child: bottomLegend,
                      )
                      : SizedBox(),
                ]
              ),
            ),
          );
        }),
      )
    ;
  }

  List<double> calculateXSectionLength(ModularBarChartData data, BarChartStyle style, double canvasWidth) {
    int numBarsInGroup = (data.type == BarChartType.Ungrouped || data.type == BarChartType.GroupedStacked)
        ? 1
        : data.xSubGroups.length;
    double totalBarWidth = numBarsInGroup * style.barStyle.barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin = style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
    double xSectionLengthCalculatedFromData = totalBarWidth + totalGroupMargin + totalInGroupMargin;
    double xSectionLengthAvailable = canvasWidth / data.xGroups.length;
    if (xSectionLengthCalculatedFromData >= xSectionLengthAvailable) {
      return [xSectionLengthCalculatedFromData];
    } else {
      double newBarWidth = (xSectionLengthAvailable - totalGroupMargin - totalInGroupMargin) / numBarsInGroup;
      return [xSectionLengthAvailable, newBarWidth];
    }
  }
}