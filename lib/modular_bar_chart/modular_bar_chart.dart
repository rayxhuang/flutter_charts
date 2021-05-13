import 'dart:core';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_display_area.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_filter_panel.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'components/chart_title.dart';

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
    this.style = BarChartStyle.standard,
  }) : assert(data != null);

  // ! ... something you shouldn't do
  ModularBarChart copyWith({
    BarChartStyle style,
    Map<String, Color> colorMap,
  }) {
    final ModularBarChartData dataModel = this.dataModel;
    dataModel.subGroupColors = colorMap ?? dataModel.subGroupColors;
    return ModularBarChart._(data: this.data, dataModel: dataModel, style: style ?? this.style, type: this.type);
  }

  factory ModularBarChart.ungrouped({
    @required Map<String, double> data,
    BarChartStyle style = BarChartStyle.standard,
  }) {
    final ModularBarChartData dataModel =
        ModularBarChartData.ungrouped(rawData: data, sortXAxis: style.sortXAxis, xGroupComparator: style.groupComparator);
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.Ungrouped,
      style: style,
    );
  }

  factory ModularBarChart.grouped({
    @required Map<String, Map<String, double>> data,
    BarChartStyle style = BarChartStyle.standard,
  }) {
    final ModularBarChartData dataModel =
        ModularBarChartData.grouped(rawData: data, sortXAxis: style.sortXAxis, xGroupComparator: style.groupComparator);
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.Grouped,
      style: style,
    );
  }

  factory ModularBarChart.groupedStacked({
    @required Map<String, Map<String, double>> data,
    BarChartStyle style = BarChartStyle.standard,
  }) {
    final ModularBarChartData dataModel =
        ModularBarChartData.groupedStacked(rawData: data, sortXAxis: style.sortXAxis, xGroupComparator: style.groupComparator);
    return ModularBarChart._(
      data: data,
      dataModel: dataModel,
      type: BarChartType.GroupedStacked,
      style: style,
    );
  }

  factory ModularBarChart.groupedSeparated({
    @required Map<String, Map<String, double>> data,
    BarChartStyle style = BarChartStyle.standard,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData.groupedSeparated(
        rawData: data, sortXAxis: style.sortXAxis, xGroupComparator: style.groupComparator);
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
    final double parentHeight =
        constraint.maxHeight < double.infinity ? constraint.maxHeight : MediaQuery.of(context).size.height;
    final double parentWidth = constraint.maxWidth < double.infinity ? constraint.maxWidth : MediaQuery.of(context).size.width;
    return Size(parentWidth, parentHeight);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      final Size parentSize = _getParentSize(constraint: constraint, context: context);
      // ! ideally, provider should be the first widget
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<DisplayInfo>(create: (_) {
            // init will calculate and set all component sizes
            final DisplayInfo sizeInfo = DisplayInfo.init(dataModel: dataModel, style: style, parentSize: parentSize);
            return sizeInfo;
          }),
        ],
        child: Consumer<DisplayInfo>(
          builder: (context, displayInfo, child) {
            return Column(
              children: [
                ChartTitle(),
                SizedBox(
                  height: displayInfo.spacingHeight,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: displayInfo.showFilterPanel
                      ? FilterPanel(
                          displayInfo: displayInfo,
                        )
                      : ChartDisplayArea(),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
