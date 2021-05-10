import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'bar_chart_style.dart';

enum BarChartType {Ungrouped, Grouped, GroupedStacked, GroupedSeparated, Grouped3D}

class ModularBarChartData with StringSize{
  final Map<String, dynamic> rawData;
  final BarChartType type;
  final bool sortXAxis;
  final Comparator<String> xGroupComparator;
  Map<String, Color> subGroupColors;

  ModularBarChartData._({
    this.rawData,
    this.type,
    this.sortXAxis = false,
    this.xGroupComparator,
    this.subGroupColors,
  });

  factory ModularBarChartData.ungrouped({
    @required Map<String, double> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData._(
      rawData: rawData,
      type: BarChartType.Ungrouped,
      sortXAxis: sortXAxis,
      xGroupComparator: xGroupComparator,
      subGroupColors: const {},
    );
    dataModel._analyseData();
    return dataModel;
  }

  factory ModularBarChartData.grouped({
    @required Map<String, Map<String, double>> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
    Map<String, Color> subGroupColors,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData._(
      rawData: rawData,
      type: BarChartType.Grouped,
      sortXAxis: sortXAxis,
      xGroupComparator: xGroupComparator,
      subGroupColors: subGroupColors ?? {},
    );
    dataModel._analyseData();
    return dataModel;
  }

  factory ModularBarChartData.groupedStacked({
    @required Map<String, Map<String, double>> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
    Map<String, Color> subGroupColors,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData._(
      rawData: rawData,
      type: BarChartType.GroupedStacked,
      sortXAxis: sortXAxis,
      xGroupComparator: xGroupComparator,
      subGroupColors: subGroupColors ?? {},
    );
    dataModel._analyseData();
    return dataModel;
  }

  factory ModularBarChartData.groupedSeparated({
    @required Map<String, Map<String, double>> rawData,
    bool sortXAxis = false,
    Comparator<String> xGroupComparator,
    Map<String, Color> subGroupColors,
  }) {
    final ModularBarChartData dataModel = ModularBarChartData._(
      rawData: rawData,
      type: BarChartType.GroupedSeparated,
      sortXAxis: sortXAxis,
      xGroupComparator: xGroupComparator,
      subGroupColors: subGroupColors ?? {},
    );
    dataModel._analyseData();
    return dataModel;
  }

  // Data processing variables
  List<String> xGroups = [], xSubGroups = [];
  List<double> _y1Values = [], _y2Values = [], y1ValueRange = [0, 0, 0], y2ValueRange = [0, 0, 0];
  List<BarChartDataDouble> bars = [], points = [];
  List<BarChartDataDoubleGrouped> groupedBars = [];
  int numBarsInGroups = 1;
  double valueOnBarHeight, maxGroupNameWidth, maxGroupNameWidthWithSpace;

  void _analyseData() {
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
        y1ValueRange[0] = _y1Values.reduce(min);
        y1ValueRange[1] = _y1Values.reduce(max);
        break;
      case BarChartType.GroupedSeparated:
        rawData.forEach((key, map) {
          if (map.keys.toList().length != 2) {
            throw Exception(['Type: Grouped Separated must have only one subgroup']);
          }
          xSubGroups = map.keys.toList();
          for (int i = 0; i < 2; i++) {
            if (i == 0) {
              _y1Values.add(map[xSubGroups[i]]);
              bars.add(BarChartDataDouble(group: key, data: map[xSubGroups[i]], separatedGroupName: xSubGroups[i]));
            } else {
              _y2Values.add(map[xSubGroups[i]]);
              points.add(BarChartDataDouble(group: key, data: map[xSubGroups[i]], separatedGroupName: xSubGroups[i]));
            }
          }
        });
        y1ValueRange[0] = _y1Values.reduce(min);
        y1ValueRange[1] = _y1Values.reduce(max);
        y2ValueRange[0] = _y2Values.reduce(min);
        y2ValueRange[1] = _y2Values.reduce(max);
        break;
      case BarChartType.Grouped3D:
      // TODO: Handle this case.
        break;
      default:
        // default is shared by Grouped and GroupedStacked
        double localMaximum = double.negativeInfinity;
        rawData.forEach((key, map) {
          xSubGroups.addAll(map.keys.toList());
          double sum = 0;
          map.forEach((subgroup, value) {
            xSubGroups.add(subgroup);
            _y1Values.add(value.toDouble());
            sum += value.toDouble();
          });
          if (sum >= localMaximum) { localMaximum = sum; }
        });
        xSubGroups = xSubGroups.toSet().toList();
        xSubGroups.sort();
        y1ValueRange[0] = _y1Values.reduce(min);
        // If data type is stacked, use local maximum
        y1ValueRange[1] = type == BarChartType.Grouped
            ? _y1Values.reduce(max)
            : localMaximum;
        break;
    }

    // Generate color for subgroups
    if (type != BarChartType.Ungrouped && type != BarChartType.GroupedSeparated) {
      final List<String> inputColorList = subGroupColors.keys.toList();
      xSubGroups.forEach((group) {
        if (!inputColorList.contains(group)) {
          subGroupColors[group] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
        }
      });
    }

    // Set the number of bars in one group
    numBarsInGroups = xSubGroups.length;
    if (numBarsInGroups <= 1) { numBarsInGroups = 1; }
    if (type == BarChartType.GroupedStacked || type == BarChartType.GroupedSeparated) { numBarsInGroups = 1; }

    // Set the height on value string on bar
    valueOnBarHeight = StringSize.getWidthOfString('1', const TextStyle());
  }

  void setMaxGroupNameWidth(TextStyle textStyle) {
    // Calculate max width for group names
    maxGroupNameWidth = double.negativeInfinity;
    xGroups.forEach((name) {
      double singleNameWidth = StringSize.getWidthOfString(name, textStyle);
      if ( singleNameWidth >= maxGroupNameWidth) {
        maxGroupNameWidth = singleNameWidth;
        maxGroupNameWidthWithSpace = StringSize.getWidthOfString(name + "  ", textStyle);
      }
    });
  }

  void adjustAxisValueRange(double yAxisHeight, {@required List<double> valueRangeToBeAdjusted, double start = 0, double end = 0,}) {
    start <= valueRangeToBeAdjusted[0]
        ? valueRangeToBeAdjusted[0] = start
        : valueRangeToBeAdjusted[0] = valueRangeToBeAdjusted[0];

    String max = valueRangeToBeAdjusted[1].toStringAsExponential();
    int expInt = int.tryParse(max.substring(max.indexOf('e+') + 2));
    num exp = pow(10, expInt - 1);
    double value = (((valueRangeToBeAdjusted[1] * (1 + (valueOnBarHeight) / yAxisHeight) / exp).ceil() + 5) * exp).toDouble();
    end >= value
        ? valueRangeToBeAdjusted[2] = end
        : valueRangeToBeAdjusted[2] = value;
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
            : dataInGroup.add(BarChartDataDouble(group: key, data: y1ValueRange[0]));
        }
        groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
      });
    }
  }
}

@immutable
class BarChartDataDouble extends Equatable{
  final String group;
  final String separatedGroupName;
  final double data;
  final BarChartBarStyle style;

  const BarChartDataDouble({
    @required this.group,
    @required this.data,
    this.style,
    this.separatedGroupName = '',
  });

  @override
  String toString() => '${this.group.toString()}: ${this.data.toStringAsFixed(2)}';

  @override
  List<Object> get props => [this.group, this.data, this.style];
}

@immutable
class BarChartDataDoubleGrouped {
  final String mainGroup;
  final List<BarChartDataDouble> dataList;

  const BarChartDataDoubleGrouped({
    @required this.mainGroup,
    @required this.dataList,
  });
}

@immutable
class DataForBarToBeDrawnLast {
  final BarChartDataDouble data;
  final double x1;
  final double x2;
  final double y1;
  final double y2;
  final Paint paint;
  final bool isLastInStack;

  const DataForBarToBeDrawnLast({
    this.data,
    this.x1,
    this.x2,
    this.y1,
    this.y2 = 0,
    this.paint,
    this.isLastInStack = false,
  });
}

@immutable
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