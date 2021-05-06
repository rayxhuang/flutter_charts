import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/textSizeInfo.dart';
import 'bar_chart_style.dart';

enum BarChartType {Ungrouped, Grouped, GroupedStacked, GroupedSeparated, Grouped3D}

class ModularBarChartData{
  final Map<String, dynamic> rawData;
  final BarChartType type;
  final bool sortXAxis;
  final Comparator<String> xGroupComparator;

  // Data processing variables
  List<String> xGroups = [], xSubGroups = [];
  List<double> _y1Values = [], _y2Values = [], yValueRange = [0, 0, 0];
  Map<String, Color> subGroupColors = {};
  List<BarChartDataDouble> bars = [];
  List<BarChartDataDoubleGrouped> groupedBars = [];
  int numInGroups = 1;
  double valueOnBarHeight;

  ModularBarChartData._({
    this.rawData,
    this.type,
    this.sortXAxis = false,
    this.xGroupComparator,
  });

  factory ModularBarChartData.ungrouped({
    @required Map<String, double> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
  }) => ModularBarChartData._(
    rawData: rawData,
    type: BarChartType.Ungrouped,
    sortXAxis: sortXAxis,
    xGroupComparator: xGroupComparator,
  );

  factory ModularBarChartData.grouped({
    @required Map<String, Map<String, double>> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
  }) => ModularBarChartData._(
    rawData: rawData,
    type: BarChartType.Grouped,
    sortXAxis: sortXAxis,
    xGroupComparator: xGroupComparator,
  );

  factory ModularBarChartData.groupedStacked({
    @required Map<String, Map<String, double>> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
  }) => ModularBarChartData._(
    rawData: rawData,
    type: BarChartType.GroupedStacked,
    sortXAxis: sortXAxis,
    xGroupComparator: xGroupComparator,
  );

  void analyseData() {
    // Sort X Axis
    xGroups = rawData.keys.toList();
    if (sortXAxis) {
      xGroupComparator == null
          ? xGroups.sort()
          : xGroups.sort(xGroupComparator);
    }

    switch (type) {
      case BarChartType.Ungrouped:
        for (String key in xGroups) {
          _y1Values.add(rawData[key]);
          bars.add(BarChartDataDouble(group: key, data: rawData[key]));
        }
        yValueRange[0] = _y1Values.reduce(min);
        yValueRange[1] = _y1Values.reduce(max);
        break;
      case BarChartType.GroupedSeparated:
      // TODO: Handle this case.
        break;
      case BarChartType.Grouped3D:
      // TODO: Handle this case.
        break;
      default:
      // default is shared by Grouped and GroupedStacked
        double localMaximum = double.negativeInfinity;
        rawData.forEach((key, map) {
          xSubGroups.addAll(map.keys.toList());
          //final List<BarChartDataDouble> dataInGroup = [];
          double sum = 0;
          map.forEach((subgroup, value) {
            xSubGroups.add(subgroup);
            _y1Values.add(value.toDouble());
            sum += value.toDouble();
          });
          if (sum >= localMaximum) { localMaximum = sum; }
        });
        xSubGroups = xSubGroups.toSet().toList();
        // TODO Allow subgroup comparator
        xSubGroups.sort();
        yValueRange[0] = _y1Values.reduce(min);
        // If data type is stacked, use local maximum
        yValueRange[1] = type == BarChartType.Grouped
            ? _y1Values.reduce(max)
            : localMaximum;
        break;
    }
    // Generate color for subgroups
    if (type != BarChartType.Ungrouped) {
      for (String subGroup in xSubGroups) { subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)]; }
    }

    numInGroups = xSubGroups.length;
    if (numInGroups <= 1) { numInGroups = 1; }
    if (type == BarChartType.GroupedStacked) { numInGroups = 1; }

    valueOnBarHeight = getSizeOfString('1', const TextStyle());
  }

  void adjustAxisValueRange(double yAxisHeight, {double start = 0, double end = 0}) {
    start <= yValueRange[0]
        ? yValueRange[0] = start
        : yValueRange[0] = yValueRange[0];

    String max = yValueRange[1].toStringAsExponential();
    int expInt = int.tryParse(max.substring(max.indexOf('e+') + 2));
    num exp = pow(10, expInt - 1);
    double value = (((yValueRange[1] * (1 + (valueOnBarHeight) / yAxisHeight) / exp).ceil() + 2) * exp).toDouble();
    end >= value
        ? yValueRange[2] = end
        : yValueRange[2] = value;
  }

  void populateDataWithMinimumValue() {
    if (type == BarChartType.Grouped || type == BarChartType.GroupedStacked) {
      groupedBars = [];
      // populate with data with min value
      rawData.forEach((key, map) {
        final List<BarChartDataDouble> dataInGroup = [];
        final List<String> keys = map.keys.toList();
        for (String key in xSubGroups) {
          keys.contains(key)
            ? dataInGroup.add(BarChartDataDouble(group: key, data: map[key].toDouble()))
            : dataInGroup.add(BarChartDataDouble(group: key, data: yValueRange[0]));
        }
        groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
      });
    }
  }
}

class BarChartDataDouble extends Equatable{
  final String group;
  final double data;
  final BarChartBarStyle style;

  const BarChartDataDouble({
    @required this.group,
    @required this.data,
    this.style,
  });

  @override
  String toString() => '${this.group.toString()}: ${this.data.toStringAsFixed(2)}';

  @override
  List<Object> get props => [this.group, this.data, this.style];
}

class BarChartDataDoubleGrouped {
  final String mainGroup;
  final List<BarChartDataDouble> dataList;
  final BarChartBarStyle sectionStyle;

  const BarChartDataDoubleGrouped({
    @required this.mainGroup,
    @required this.dataList,
    this.sectionStyle = const BarChartBarStyle(),
  });
}

class BarChartLabel {
  final String text;
  final TextStyle textStyle;

  const BarChartLabel({
    this.text = '',
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 20,
    )
  });
}