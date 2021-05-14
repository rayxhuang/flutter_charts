import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

import '../modular_bar_chart.dart';

mixin CreateChart {
  ModularBarChart createChart({
    @required Map<String, dynamic> rawData,
    @required BarChartType chartType,
    @required BarChartStyle style,
    Map<String, Color> xSubGroupColorMap,
  }) {
    if (chartType != BarChartType.Ungrouped && xSubGroupColorMap == null) {
      xSubGroupColorMap = _generateXSubGroupColorMap(
        rawData: rawData,
      );
    }
    switch (chartType) {
      case BarChartType.Ungrouped:
        return _buildUngroupedChart(
          rawData: rawData,
          style: style,
        );
        break;
      case BarChartType.Grouped:
        return _buildGroupedChart(
          rawData: rawData,
          style: style,
          xSubGroupColorMap: xSubGroupColorMap,
        );
        break;
      case BarChartType.GroupedStacked:
        return _buildGroupedStackedChart(
          rawData: rawData,
          style: style,
          xSubGroupColorMap: xSubGroupColorMap,
        );
        break;
      case BarChartType.GroupedSeparated:
        return _buildGroupedSeparatedChart(
          rawData: rawData,
          style: style,
          xSubGroupColorMap: xSubGroupColorMap,
        );
        break;
      case BarChartType.Grouped3D:
        throw UnimplementedError('Grouped 3D chart is not currently supported');
        break;
    }
  }

  Map<String, Color> _generateXSubGroupColorMap({
    @required Map<String, Map<String, double>> rawData,
  }) {
    final Map<String, Color> xSubGroupColorMap = {};
    final List<String> subGroups = [];
    rawData.forEach((group, map) {
      subGroups.addAll(map.keys.toList());
    });
    subGroups.forEach((subgroup) {
      xSubGroupColorMap[subgroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    });
    return xSubGroupColorMap;
  }

  ModularBarChart _buildUngroupedChart({
    @required Map<String, double> rawData,
    @required BarChartStyle style,
  }) {
    return ModularBarChart.ungrouped(
      rawData: rawData,
      style: style,
    );
  }

  ModularBarChart _buildGroupedChart({
    @required Map<String, Map<String,double>> rawData,
    @required BarChartStyle style,
    @required Map<String, Color> xSubGroupColorMap,
  }) {
    return ModularBarChart.grouped(
      rawData: rawData,
      style: style,
      xSubGroupColorMap: xSubGroupColorMap,
    );
  }

  ModularBarChart _buildGroupedStackedChart({
    @required Map<String, Map<String,double>> rawData,
    @required BarChartStyle style,
    @required Map<String, Color> xSubGroupColorMap,
  }) {
    return ModularBarChart.groupedStacked(
      rawData: rawData,
      style: style,
      xSubGroupColorMap: xSubGroupColorMap,
    );
  }

  ModularBarChart _buildGroupedSeparatedChart({
    @required Map<String, Map<String,double>> rawData,
    @required BarChartStyle style,
    @required Map<String, Color> xSubGroupColorMap,
  }) {
    return ModularBarChart.groupedSeparated(
      rawData: rawData,
      style: style,
      xSubGroupColorMap: xSubGroupColorMap,
    );
  }
}