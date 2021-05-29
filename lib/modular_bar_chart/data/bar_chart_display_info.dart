import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';

import 'bar_chart_data.dart';
import 'bar_chart_style.dart';

class DisplayInfo extends ChangeNotifier with StringSize{
  final ModularBarChartData originalDataModel;
  // a new dataModel can be obtained by applying filter on the
  // original dataModel
  ModularBarChartData dataModel;
  final BarChartStyle style;
  final Size parentSize;

  DisplayInfo._({
    @required this.originalDataModel,
    @required this.dataModel,
    @required this.style,
    @required this.parentSize,
  });

  factory DisplayInfo.init({
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
    @required Size parentSize,
  }) {
    final DisplayInfo displayInfo = DisplayInfo._(
      originalDataModel: dataModel,
      dataModel: dataModel,
      style: style,
      parentSize: parentSize,
    );
    displayInfo._init();
    return displayInfo;
  }

  String _longestGroupName = '';
  String _longestSubGroupName = '';
  String _leftDisplayText = '';
  String _rightDisplayText = '';
  
  // Width
  double _maxGroupNameWidth = 0;
  double _leftAxisCombinedWidth = 0;
  double _leftAxisWidth = 0;
  double _leftAxisLabelWidth = 0;
  double _rightAxisCombinedWidth = 0;
  double _rightAxisWidth = 0;
  double _rightAxisLabelWidth = 0;
  double _canvasWidth = 0;
  double _xSectionWidth = 0;
  double _barWidth = 0;
  double _xTotalLength;
  
  // Height
  double _titleHeight = 0;
  double _spacingHeight = 0;
  double _filterPanelHeight = 0;
  double _bottomLabelHeight = 0;
  double _bottomLegendHeight = 0;
  double _valueOnBarHeight = 0;
  double _bottomAxisHeight = 0;
  double _canvasHeight = 0;
  double _y1UnitPerPixel = 0;
  double _y2UnitPerPixel = 0;
  
  // Size
  Size _canvasSize = Size.zero;
  Size _canvasWrapperSize = Size.zero;
  
  bool _hasXSubGroups = false;
  bool _hasYAxisOnTheRight = false;
  bool _needResetYAxisWidth = false;
  bool _isMini = false;
  bool _displayMiniCanvas = false;

  RangeValues _displayY1Range = RangeValues(0, 0);
  RangeValues _displayY2Range = RangeValues(0, 0);
  RangeValues _originalDisplayY1Range = RangeValues(0, 0);
  RangeValues _originalDisplayY2Range = RangeValues(0, 0);
  RangeValues _y1RangeFilter;
  RangeValues _y2RangeFilter;

  int _numOfGroupNamesToCombine = 1;

  bool _showToolBar = false;
  bool _showAverageLine = false;
  bool _showValueOnBar = false;
  bool _showGridLine = false;
  bool _showFilterPanel = false;

  Map<String, bool> _originalSelectedXGroups = {};
  Map<String, bool> _originalSelectedXSubGroups = {};
  Map<String, bool> _selectedXGroups = {};
  Map<String, bool> _selectedXSubGroups = {};

  // Getters
  String get longestGroupName => _longestGroupName;
  String get longestSubGroupName => _longestSubGroupName;
  String get leftDisplayText => _leftDisplayText;
  String get rightDisplayText => _rightDisplayText;

  double get leftAxisCombinedWidth => _leftAxisCombinedWidth;
  double get leftAxisWidth => _leftAxisWidth;
  double get leftAxisLabelWidth => _leftAxisLabelWidth;
  double get rightAxisCombinedWidth => _rightAxisCombinedWidth;
  double get rightAxisWidth => _rightAxisWidth;
  double get rightAxisLabelWidth => _rightAxisLabelWidth;
  double get canvasWidth => _canvasWidth;
  double get xSectionWidth => _xSectionWidth;
  double get barWidth => _barWidth;
  double get xTotalLength => _xTotalLength;
  double get titleHeight => _titleHeight;
  double get spacingHeight => _spacingHeight;
  double get filterPanelHeight => _filterPanelHeight;
  double get bottomAxisHeight => _bottomAxisHeight;
  double get bottomLabelHeight => _bottomLabelHeight;
  double get bottomLegendHeight => _bottomLegendHeight;
  double get canvasHeight => _canvasHeight;
  double get y1Min => _displayY1Range.start;
  double get y1Max => _displayY1Range.end;
  double get y2Min => _displayY2Range.start;
  double get y2Max => _displayY2Range.end;
  double get y1UnitPerPixel => _y1UnitPerPixel;
  double get y2UnitPerPixel => _y2UnitPerPixel;
  double get originalY1Min => _originalDisplayY1Range.start;
  double get originalY1Max => _originalDisplayY1Range.end;
  double get originalY2Min => _originalDisplayY2Range.start;
  double get originalY2Max => _originalDisplayY2Range.end;
  double get y1FilterMin => _y1RangeFilter.start;
  double get y1FilterMax => _y1RangeFilter.end;
  double get y2FilterMin => _y2RangeFilter.start;
  double get y2FilterMax => _y2RangeFilter.end;

  int get numOfGroupNamesToCombine => _numOfGroupNamesToCombine;

  Size get canvasSize => _canvasSize;
  Size get canvasWrapperSize => _canvasWrapperSize;

  bool get isMini => _isMini;
  bool get hasXSubGroups => _hasXSubGroups;
  bool get hasYAxisOnTheRight => _hasYAxisOnTheRight;
  bool get displayMiniCanvas => _displayMiniCanvas;
  bool get showToolBar => _showToolBar;
  bool get showAverageLine => _showAverageLine;
  bool get showValueOnBar =>  _showValueOnBar;
  bool get showGridLine => _showGridLine;
  bool get showFilterPanel => _showFilterPanel;

  RangeValues get y1RangeValues => _displayY1Range;
  RangeValues get y2RangeValues => _displayY2Range;
  RangeValues get y1RangeFilter => _y1RangeFilter;
  RangeValues get y2RangeFilter => _y2RangeFilter;

  Map<String, bool> get originalSelectedXGroups => _originalSelectedXGroups;
  Map<String, bool> get originalSelectedXSubGroups => _originalSelectedXSubGroups;
  Map<String, bool> get selectedXGroups => _selectedXGroups;
  Map<String, bool> get selectedXSubGroups => _selectedXSubGroups;

  // Public methods
  // Toggle whether or not to show tool bar
  void toggleToolBar() {
    _showToolBar =! _showToolBar;
    notifyListeners();
  }

  // Toggle whether or not to show the filter panel
  void toggleFilterPanel() {
    _showFilterPanel = !_showFilterPanel;
    notifyListeners();
  }

  // Toggle if the average line(s) should be drawn on the chart
  void toggleAverageLine() {
    _showAverageLine = !_showAverageLine;
    _setMiniDisplayText();
    notifyListeners();
  }

  // Toggle if value should be shown on bar
  void toggleValueOnBar() {
    _showValueOnBar = !_showValueOnBar;
    notifyListeners();
  }

  // Toggle if horizontal grid lines should be drawn
  void toggleGridLine() {
    _showGridLine = !_showGridLine;
    notifyListeners();
  }

  // Set and the apply filters on the original data model
  void setFilter({
    RangeValues y1Filter,
    RangeValues y2Filter,
    Map<String, bool> xGroupFilter,
    Map<String, bool> xSubGroupFilter,
  }) {
    // Hide Filter Panel
    toggleFilterPanel();

    // Filters
    _y1RangeFilter = y1Filter ?? this._y1RangeFilter;
    _y2RangeFilter = y2Filter ?? this._y2RangeFilter;
    _selectedXGroups = xGroupFilter ?? this._selectedXGroups;
    _selectedXSubGroups = xSubGroupFilter ?? this._selectedXSubGroups;

    // Obtain a new dataModel form applying filters on ORIGINAL dataModel
    dataModel = originalDataModel.applyFilter(
      y1Filter: _y1RangeFilter,
      y2Filter: _y2RangeFilter,
      xGroupFilter: _selectedXGroups,
      xSubGroupFilter: _selectedXSubGroups,
    );

    // Re-setup, this basically rebuilds the whole chart
    _setup();

    // Reset mini display text
    _setMiniDisplayText();

    notifyListeners();
  }



  // Private methods
  // init is called only when the instance is first created
  void _init() {
    // Set is mini version boolean
    _setIsMini();

    // Set whether the chart has x sub groups
    _setHasXSubGroups();

    // Set whether the chart has y axis on the right
    _setHasYAxisOnTheRight();

    // Set the height of value displayed on bar's height
    _setValueOnBarHeight();

    // Set original bar width from style
    _setBarWidth();

    // Set title Height;
    _setTitleHeight();

    // Set the spacing below title's height
    _setSpacingHeight();

    // Set bottom label height
    _setBottomLabelHeight();

    // Set bottom legend height
    _setBottomLegendHeight();
    
    // Set filter panel height
    _setFilterPanelHeight();

    // Call set up
    _setup();

    // Set initial display range for filter panel
    _setInitialDisplayRange();

    // Set initial selected groups for filter panel
    _setInitialSelectedXGroups();
  }

  void _setIsMini() => _isMini = style.isMini;

  void _setHasXSubGroups() => _hasXSubGroups = (dataModel.type == BarChartType.Grouped || dataModel.type == BarChartType.GroupedStacked);

  void _setHasYAxisOnTheRight() => _hasYAxisOnTheRight = dataModel.type == BarChartType.GroupedSeparated;

  void _setValueOnBarHeight() => _valueOnBarHeight = StringSize.getWidthOfString('1', const TextStyle());

  void _setTitleHeight() => _titleHeight = style.isMini ? StringSize.getHeight(style.title) : kMinInteractiveDimensionCupertino;

  void _setSpacingHeight() => _spacingHeight = 0.5 * StringSize.getHeightOfString('I', style.y1AxisStyle.tickStyle.labelTextStyle);

  void _setBottomLabelHeight() => _bottomLabelHeight = StringSize.getHeight(style.xAxisStyle.label);

  void _setBottomLegendHeight() =>
      _bottomLegendHeight = (style.legendStyle.visible && !_isMini) ? StringSize.getHeightOfString('I', style.legendStyle.legendTextStyle) + 4 : 0;

  void _setFilterPanelHeight() => _filterPanelHeight = parentSize.height - spacingHeight - kMinInteractiveDimensionCupertino;

  void _setInitialDisplayRange() {
    _originalDisplayY1Range = RangeValues(_displayY1Range.start, _displayY1Range.end);
    _originalDisplayY2Range = RangeValues(_displayY2Range.start, _displayY2Range.end);
  }

  void _setInitialSelectedXGroups() {
    originalDataModel.xGroups.forEach((group) {
      _originalSelectedXGroups[group] = true;
      _selectedXGroups[group] = true;
    });
    originalDataModel.xSubGroups.forEach((subGroup) {
      _originalSelectedXSubGroups[subGroup] = true;
      _selectedXSubGroups[subGroup] = true;
    });
  }



  // The following methods may be called again when
  // new filter is applied
  void _setup(){
    // Set original bar width from style
    _setBarWidth();

    // Set component heights
    _setComponentHeight();

    // Set maximum group name width
    _setMaxGroupNameWidth();

    // Set maximum sub group name
    _setLongestSubGroupName();

    // Set component widths
    _setComponentWidth();

    // Set canvas size
    _setCanvasSize();

    // Adjust the displayed y value range
    _adjustDisplayValueRange();

    // Set xSectionWidth, this may also set a new bar width
    _setXSectionWidth();

    // Set xTotalLength
    _setXTotalLength();

    // Set displayMiniCanvas bool
    _setDisplayMiniCanvas();

    // TODO should this be done in here???
    dataModel.populateDataWithMinimumValue(minimum: _displayY1Range.start);

    // Set Y unit per pixel
    _setYUnitPerPixel();

    // Combine group names
    _combineGroupName();

    // Reset the width in case of e.g 999 -> 1000, which the number of digits changed
    _setCanvasSize();

    // Set Canvas wrapper size
    _setCanvasWrapperSize();

    // Set y filter range
    _setYFilterRange();
  }

  void _setBarWidth() => _barWidth = style.barStyle.barWidth;

  void _setYFilterRange() {
    _y1RangeFilter ??= RangeValues(y1Min, y1Max);
    _y2RangeFilter ??= RangeValues(y2Min, y2Max);
  }

  void _setMiniDisplayText() {
    if (_showAverageLine) {
      _leftDisplayText = 'Avg: ${dataModel.y1Average.toStringAsFixed(2)}';
      if (_hasYAxisOnTheRight) {
        _rightDisplayText = 'Avg: ${dataModel.y2Average.toStringAsFixed(2)}';
      }
    } else {
      _leftDisplayText = '';
      _rightDisplayText = '';
    }
  }

  void _setComponentWidth() {
    // Set left axis width
    _setLeftAxisWidth();

    // Set right axis width
    _setRightAxisWidth();

    // Set canvas width
    _setCanvasWidth();
  }

  void _setLeftAxisWidth(){
    _leftAxisWidth = _getVerticalAxisWidth(
      axisMaxValue: _needResetYAxisWidth ? _displayY1Range.end : dataModel.y1ValueRange[1],
      axisStyle: style.y1AxisStyle,
    );
    _leftAxisLabelWidth = _isMini ? 0 : _getVerticalAxisLabelWidth(label: style.y1AxisStyle.label);
    _leftAxisCombinedWidth = _leftAxisWidth + _leftAxisLabelWidth;
  }

  void _setRightAxisWidth(){
    if (_hasYAxisOnTheRight) {
      _rightAxisWidth = _getVerticalAxisWidth(
        axisMaxValue: _needResetYAxisWidth ? _displayY2Range.end : dataModel.y2ValueRange[1],
        axisStyle: style.y2AxisStyle,
      );
      if (!style.isMini) {
        _rightAxisLabelWidth = _getVerticalAxisLabelWidth(label: style.y2AxisStyle.label);
      }
    }
    _rightAxisCombinedWidth = _rightAxisWidth + _rightAxisLabelWidth;
  }

  void _setCanvasWidth() {
    _canvasWidth = parentSize.width - _leftAxisCombinedWidth - _rightAxisCombinedWidth;
    if (_canvasWidth < 0) { _canvasWidth = 0; }
  }

  void _setMaxGroupNameWidth() {
    // Calculate max width for group names
    _maxGroupNameWidth = 0;
    _longestGroupName = '';
    final TextStyle textStyle = style.xAxisStyle.label.textStyle;
    dataModel.xGroups.forEach((name) {
      double singleNameWidth = StringSize.getWidthOfString(name, textStyle);
      if ( singleNameWidth >= _maxGroupNameWidth) {
        _maxGroupNameWidth = singleNameWidth;
        _longestGroupName = name;
      }
    });
  }

  void _setLongestSubGroupName() {
    if (_hasXSubGroups) {
      _longestSubGroupName = '';
      final TextStyle textStyle = const TextStyle();
      double longestNameWidth = double.negativeInfinity;
      dataModel.xSubGroups.forEach((name) {
        double singleNameWidth = StringSize.getWidthOfString(name, textStyle);
        if ( singleNameWidth >= longestNameWidth) {
          _longestSubGroupName = name;
        }
      });
    }
  }

  void _setXSectionWidth() {
    final double totalBarWidth = dataModel.numBarsInGroups * style.barStyle.barWidth;
    final double totalGroupMargin = style.groupMargin * 2;
    final double totalInGroupMargin = style.barStyle.barInGroupMargin * (dataModel.numBarsInGroups - 1);
    final double xSectionLengthCalculatedFromData = totalBarWidth + totalGroupMargin + totalInGroupMargin;
    final double xSectionLengthAvailable = canvasWidth / dataModel.xGroups.length;
    if (xSectionLengthCalculatedFromData > xSectionLengthAvailable) {
      _xSectionWidth = xSectionLengthCalculatedFromData;
    } else {
      _barWidth = (xSectionLengthAvailable - totalGroupMargin - totalInGroupMargin) / dataModel.numBarsInGroups;
      _xSectionWidth = xSectionLengthAvailable;
    }
  }

  void _setXTotalLength() => _xTotalLength = [_xSectionWidth * dataModel.xGroups.length, _canvasWidth].reduce(max);

  void _setDisplayMiniCanvas() => _displayMiniCanvas = _barWidth == style.barStyle.barWidth;

  void _setComponentHeight() {
    // Set bottom axis height
    _setBottomAxisHeight();

    // Set canvas height
    _setCanvasHeight();
  }

  void _setBottomAxisHeight() {
    final double labelHeight = StringSize.getHeightOfString('I', style.xAxisStyle.tickStyle.labelTextStyle);
    final TickStyle tickStyle = style.xAxisStyle.tickStyle;
    _bottomAxisHeight = labelHeight + tickStyle.tickLength + tickStyle.tickMargin + style.xAxisStyle.strokeWidth / 2;
    if (_isMini) {
      _bottomAxisHeight = style.xAxisStyle.strokeWidth / 2;
    }
  }

  void _setCanvasHeight() {
    _canvasHeight = parentSize.height -
        titleHeight -
        spacingHeight -
        bottomAxisHeight -
        bottomLabelHeight -
        bottomLegendHeight;
    if (_canvasHeight < 0) {
      _canvasHeight = 0;
    }
  }

  void _setCanvasSize() => _canvasSize = Size(_canvasWidth, _canvasHeight);

  void _setCanvasWrapperSize() => _canvasWrapperSize = isMini ? _canvasSize : Size(_canvasWidth, _canvasHeight + _bottomAxisHeight);

  void _adjustDisplayValueRange() {
    _displayY1Range = _adjustDisplayValueRangeHelper(
      originalRange: dataModel.y1ValueRange,
      axisStyle: style.y1AxisStyle,
    );
    if (_hasYAxisOnTheRight) {
      _displayY2Range = _adjustDisplayValueRangeHelper(
        originalRange: dataModel.y2ValueRange,
        axisStyle: style.y2AxisStyle,
      );
    }
    if (_needResetYAxisWidth) { _setComponentWidth(); }
  }

  RangeValues _adjustDisplayValueRangeHelper({
    @required List<double> originalRange,
    @required AxisStyle axisStyle,
  }) {
    final double start = axisStyle.preferredStartValue;
    final double end = axisStyle.preferredEndValue;
    double newStart, newEnd;
    start <= originalRange[0]
        ? newStart = start
        : newStart = originalRange[0];

    String max = originalRange[1].toStringAsExponential();
    int expInt = int.tryParse(max.substring(max.indexOf('e+') + 2));
    num exp = pow(10, expInt - 1);
    double value = (((originalRange[1] * (1 + (_valueOnBarHeight) / _canvasHeight) / exp).ceil() + 5) * exp).toDouble();
    end >= value
        ? newEnd = end
        : newEnd = value;

    final int newDigit = int.tryParse(value.toStringAsExponential().substring(value.toStringAsExponential().indexOf('e+') + 2));
    if (newDigit > expInt) { _needResetYAxisWidth = true; }

    return RangeValues(newStart, newEnd);
  }

  void _setYUnitPerPixel() {
    _y1UnitPerPixel = (y1Max - y1Min) / _canvasHeight;
    if (_hasYAxisOnTheRight) { _y2UnitPerPixel = (y2Max - y2Min) / _canvasHeight; }
  }

  void _combineGroupName() {
    if (_maxGroupNameWidth > _xSectionWidth) {
      bool success = false;
      int maxCombineGroup = 3, numGroupsToBeCombined = 1;
      for (int i = 1; i < maxCombineGroup + 1; i++) {
        double w = i * _xSectionWidth;
        if (w >= _maxGroupNameWidth) {
          success = true;
          numGroupsToBeCombined = i;
          break;
        }
      }
      if (!success) { numGroupsToBeCombined = maxCombineGroup; }
      _numOfGroupNamesToCombine = numGroupsToBeCombined;
    } else {
      _numOfGroupNamesToCombine = 1;
    }
  }
  
  double _getVerticalAxisLabelWidth({@required BarChartLabel label}) => label.text == '' ? 0 : StringSize.getHeight(label);

  double _getVerticalAxisWidth({
    @required double axisMaxValue,
    @required AxisStyle axisStyle,
  }) {
    final int decimal = axisStyle.tickStyle.tickDecimal;
    final TextStyle textStyle = axisStyle.tickStyle.labelTextStyle;
    final double valueWidth = StringSize.getWidthOfString(axisMaxValue.toStringAsFixed(decimal), textStyle);
    final double tickWidth = axisStyle.tickStyle.tickMargin + (style.isMini ? 0 : axisStyle.tickStyle.tickLength);
    return valueWidth + tickWidth;
  }
}