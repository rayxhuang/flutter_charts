import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'bar_chart_style.dart';

enum BarChartType {Ungrouped, Grouped, GroupedStacked, GroupedSeparated, Grouped3D}

class ModularBarChartData with StringSize {
  final Map<String, dynamic> rawData;
  final BarChartType type;
  final bool sortXAxis;
  final Comparator<String> xGroupComparator;
  final Comparator<String> xSubGroupComparator;
  Map<String, Color> subGroupColors;

  ModularBarChartData._({
    this.rawData,
    this.type,
    this.sortXAxis = false,
    this.xGroupComparator,
    this.xSubGroupComparator,
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
  List<String> _xGroups = [], _xSubGroups = [];
  List<double> _y1Values = [], _y2Values = [], _stackedValues = [], _y1ValueRange = [0, 0, 0], _y2ValueRange = [0, 0, 0];
  List<BarChartDataDouble> _bars = [], _points = [];
  List<BarChartDataDoubleGrouped> _groupedBars = [];
  int _numBarsInGroups = 1;
  double _y1Average = 0, _y2Average = 0,_valueOnBarHeight = 0, _maxGroupNameWidth = 0, _maxGroupNameWidthWithSpace = 0;

  List<String> get xGroups => _xGroups;
  List<String> get xSubGroups => _xSubGroups;
  List<double> get y1ValueRange => _y1ValueRange;
  List<double> get y2ValueRange => _y2ValueRange;
  List<BarChartDataDouble> get bars => _bars;
  List<BarChartDataDouble> get points => _points;
  List<BarChartDataDoubleGrouped> get groupedBars => _groupedBars;
  int get numBarsInGroups => _numBarsInGroups;
  double get y1Average => _y1Average;
  double get y2Average => _y2Average;
  double get valueOnBarHeight => _valueOnBarHeight;
  double get maxGroupNameWidth => _maxGroupNameWidth;
  double get maxGroupNameWidthWithSpace => _maxGroupNameWidthWithSpace;

  void _setXGroups() => _xGroups = rawData.keys.toList();

  void _sortXGroups() {
    if (sortXAxis) {
      xGroupComparator != null
          ? _xGroups.sort(xGroupComparator)
          : _xGroups.sort();
    }
  }

  void _sortXSubGroups() {
    if (sortXAxis) {
      xSubGroupComparator != null
          ? _xSubGroups.sort(xSubGroupComparator)
          : _xSubGroups.sort();
    }
  }

  void _setY1ValueRange() {
    _y1ValueRange[0] = _y1Values.reduce(min);
    _y1ValueRange[1] = _y1Values.reduce(max);
  }

  void _setY2ValueRange() {
    _y2ValueRange[0] = _y2Values.reduce(min);
    _y2ValueRange[1] = _y2Values.reduce(max);
  }

  void _initUngroupedData() {
    for (String key in _xGroups) {
      _y1Values.add(rawData[key]);
      _bars.add(BarChartDataDouble(group: key, data: rawData[key]));
    }
    _setY1ValueRange();
  }

  void _initGroupedData() {
    double localMaximum = double.negativeInfinity;
    rawData.forEach((key, map) {
      _xSubGroups.addAll(map.keys.toList());
      double sum = 0;
      map.forEach((subgroup, value) {
        _xSubGroups.add(subgroup);
        _y1Values.add(value.toDouble());
        sum += value.toDouble();
      });
      _stackedValues.add(sum);
      if (sum >= localMaximum) { localMaximum = sum; }
    });
    _xSubGroups = _xSubGroups.toSet().toList();
    _sortXSubGroups();
    _y1ValueRange[0] = _y1Values.reduce(min);
    // If data type is stacked, use local maximum
    _y1ValueRange[1] = type == BarChartType.Grouped
        ? _y1Values.reduce(max)
        : localMaximum;
  }

  void _initGroupedSeparatedData() {
    rawData.forEach((key, map) {
      if (map.keys.toList().length != 2) {
        throw Exception(['Type: Grouped Separated must have only one subgroup']);
      }
      _xSubGroups = map.keys.toList();
      for (int i = 0; i < 2; i++) {
        final String name = _xSubGroups[i];
        if (i == 0) {
          _y1Values.add(map[name]);
          _bars.add(BarChartDataDouble(group: key, data: map[name], separatedGroupName: name));
        } else {
          _y2Values.add(map[name]);
          _points.add(BarChartDataDouble(group: key, data: map[name], separatedGroupName: name));
        }
      }
    });
    _setY1ValueRange();
    _setY2ValueRange();
  }

  void _generateSubGroupColors() {
    if (type != BarChartType.Ungrouped && type != BarChartType.GroupedSeparated) {
      final List<String> inputColorList = subGroupColors.keys.toList();
      _xSubGroups.forEach((group) {
        if (!inputColorList.contains(group)) {
          subGroupColors[group] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
        }
      });
    }
  }

  void _setNumberOfBarsInGroups() {
    _numBarsInGroups = _xSubGroups.length;
    if (_numBarsInGroups <= 1) { _numBarsInGroups = 1; }
    if (type == BarChartType.GroupedStacked || type == BarChartType.GroupedSeparated) { _numBarsInGroups = 1; }
  }

  void _setValueOnBarHeight() => _valueOnBarHeight = StringSize.getWidthOfString('1', const TextStyle());

  void _setYAverage() {
    if (type == BarChartType.GroupedStacked) {
      _y1Average = _stackedValues.reduce((a, b) => a + b) / _xGroups.length;
    } else {
      _y1Average = _y1Values.reduce((a, b) => a + b) / _y1Values.length;
    }
    if (_y2Values.isNotEmpty) {
      _y2Average = _y2Values.reduce((a, b) => a + b) / _y2Values.length;
    }
  }

  void _analyseData() {
    // Set X Groups
    _setXGroups();
    // Sort X Groups
    _sortXGroups();

    switch (type) {
      case BarChartType.Ungrouped:
        _initUngroupedData();
        break;
      case BarChartType.GroupedSeparated:
        _initGroupedSeparatedData();
        break;
      case BarChartType.Grouped3D:
        // TODO: Handle this case.
        break;
      default:
        // default is shared by Grouped and GroupedStacked
        _initGroupedData();
        break;
    }

    // Generate color for subgroups
    _generateSubGroupColors();

    // Set the number of bars in one group
    _setNumberOfBarsInGroups();

    // Set the height on value string on bar
    _setValueOnBarHeight();

    // Set average for y1 and y2
    _setYAverage();
  }

  void setMaxGroupNameWidth({@required TextStyle textStyle}) {
    // Calculate max width for group names
    _maxGroupNameWidth = double.negativeInfinity;
    _xGroups.forEach((name) {
      double singleNameWidth = StringSize.getWidthOfString(name, textStyle);
      if ( singleNameWidth >= _maxGroupNameWidth) {
        _maxGroupNameWidth = singleNameWidth;
        _maxGroupNameWidthWithSpace = StringSize.getWidthOfString(name + "  ", textStyle);
      }
    });
  }

  void adjustAxisValueRange({@required double yAxisHeight, @required List<double> valueRangeToBeAdjusted, double start = 0, double end = 0,}) {
    start <= valueRangeToBeAdjusted[0]
        ? valueRangeToBeAdjusted[0] = start
        : valueRangeToBeAdjusted[0] = valueRangeToBeAdjusted[0];

    String max = valueRangeToBeAdjusted[1].toStringAsExponential();
    int expInt = int.tryParse(max.substring(max.indexOf('e+') + 2));
    num exp = pow(10, expInt - 1);
    double value = (((valueRangeToBeAdjusted[1] * (1 + (_valueOnBarHeight) / yAxisHeight) / exp).ceil() + 5) * exp).toDouble();
    end >= value
        ? valueRangeToBeAdjusted[2] = end
        : valueRangeToBeAdjusted[2] = value;
  }

  void populateDataWithMinimumValue() {
    if (type == BarChartType.Grouped || type == BarChartType.GroupedStacked) {
      _groupedBars = [];
      // populate with data with min value
      rawData.forEach((key, map) {
        final List<BarChartDataDouble> dataInGroup = [];
        final List<String> keys = map.keys.toList();
        for (String key in _xSubGroups) {
          keys.contains(key)
            ? dataInGroup.add(BarChartDataDouble(group: key, data: map[key].toDouble()))
            : dataInGroup.add(BarChartDataDouble(group: key, data: _y1ValueRange[0]));
        }
        _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
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