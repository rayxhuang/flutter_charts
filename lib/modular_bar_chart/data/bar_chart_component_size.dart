import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/axis_info_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';

import 'bar_chart_data.dart';
import 'bar_chart_style.dart';

class DisplayInfo extends ChangeNotifier with StringSize, AxisInfo {
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final Size parentSize;

  DisplayInfo({
    @required this.dataModel,
    @required this.style,
    @required this.parentSize,
  });

  double _maxGroupNameWidth = 0, _maxGroupNameWidthWithSpace = 0;
  double _leftAxisWidth = 0, _rightAxisWidth = 0, _canvasWidth = 0, _xSectionWidth = 0, _barWidth = 0;
  double _titleHeight = 0, _spacingHeight = 0, _bottomAxisHeight = 0, _bottomLabelHeight = 0, _bottomLegendHeight = 0,
  _canvasHeight = 0, _valueOnBarHeight = 0;
  Size _canvasSize = Size.zero;
  bool _hasYAxisOnTheRight = false;
  List<double> _displayY1Range = [0, 0], _displayY2Range = [0, 0];
  double _y1UnitPerPixel = 0, _y2UnitPerPixel = 0;

  double get leftAxisWidth => _leftAxisWidth;
  double get rightAxisWidth => _rightAxisWidth;
  double get canvasWidth => _canvasWidth;
  double get xSectionWidth => _xSectionWidth;
  double get barWidth => _barWidth;
  double get titleHeight => _titleHeight;
  double get spacingHeight => _spacingHeight;
  double get bottomAxisHeight => _bottomAxisHeight;
  double get bottomLabelHeight => _bottomLabelHeight;
  double get bottomLegendHeight => _bottomLegendHeight;
  double get canvasHeight => _canvasHeight;
  Size get canvasSize => _canvasSize;

  bool get hasYAxisOnTheRight => _hasYAxisOnTheRight;
  double get y1Min => _displayY1Range[0];
  double get y1Max => _displayY1Range[1];
  double get y2Min => _displayY2Range[0];
  double get y2Max => _displayY2Range[1];
  List<double> get y1ValueRange => _displayY1Range;
  List<double> get y2ValueRange => _displayY2Range;
  double get y1UnitPerPixel => _y1UnitPerPixel;
  double get y2UnitPerPixel => _y2UnitPerPixel;

  void init(){
    // Set whether the chart has y axis on the right
    _setHasYAxisOnTheRight();

    // Set the height of value displayed on bar's height
    _setValueOnBarHeight();

    // Set original bar width from style
    _setBarWidth();

    // Set component heights
    _setComponentHeight();

    // Set maximum group name width
    _setMaxGroupNameWidth();

    // Set component widths
    _setComponentWidth();

    // Set canvas size
    _setCanvasSize();

    // Set xSectionWidth, this may also set a new bar width
    _setXSectionWidth();

    // Adjust the displayed y value range
    _adjustDisplayValueRange();

    // TODO should this be done in here???
    dataModel.populateDataWithMinimumValue();

    // Set Y unit per pixel
    _setYUnitPerPixel();
  }

  void _setHasYAxisOnTheRight() => _hasYAxisOnTheRight = dataModel.type == BarChartType.GroupedSeparated;

  void _setValueOnBarHeight() => _valueOnBarHeight = StringSize.getWidthOfString('1', const TextStyle());

  void _setBarWidth() => _barWidth = style.barStyle.barWidth;

  void _setComponentWidth() {
    // Set left axis width
    _setLeftAxisWidth();

    // Set right axis width
    _setRightAxisWidth();

    // Set canvas width
    _setCanvasWidth();
  }

  void _setLeftAxisWidth(){
    _leftAxisWidth = getVerticalAxisCombinedWidth(
      axisMaxValue: dataModel.y1ValueRange[1],
      style: style.y1AxisStyle,
      isMini: style.isMini,
    );
  }

  void _setRightAxisWidth(){
    _rightAxisWidth = hasYAxisOnTheRight
        ? getVerticalAxisCombinedWidth(
          axisMaxValue: dataModel.y2ValueRange[1],
          style: style.y2AxisStyle,
          isMini: style.isMini,
        )
        : 0;
  }

  void _setCanvasWidth() {
    _canvasWidth = parentSize.width - _leftAxisWidth - _rightAxisWidth;
    if (_canvasWidth < 0) { _canvasWidth = 0; }
  }

  void _setMaxGroupNameWidth() {
    // Calculate max width for group names
    _maxGroupNameWidth = 0;
    final TextStyle textStyle = style.xAxisStyle.label.textStyle;
    dataModel.xGroups.forEach((name) {
      double singleNameWidth = StringSize.getWidthOfString(name, textStyle);
      if ( singleNameWidth >= _maxGroupNameWidth) {
        _maxGroupNameWidth = singleNameWidth;
        _maxGroupNameWidthWithSpace = StringSize.getWidthOfString(name + "  ", textStyle);
      }
    });
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

  void _setComponentHeight() {
    // Set title Height;
    _setTitleHeight();

    // Set the spacing below title's height
    _setSpacingHeight();

    // Set bottom axis height
    _setBottomAxisHeight();

    // Set bottom label height
    _setBottomLabelHeight();

    // Set bottom legend height
    _setBottomLegendHeight();

    // Set canvas height
    _setCanvasHeight();
  }

  void _setTitleHeight() => _titleHeight = StringSize.getHeight(style.title);

  void _setSpacingHeight() => _spacingHeight = 0.5 * StringSize.getHeightOfString('I', style.y1AxisStyle.tickStyle.labelTextStyle);

  void _setBottomAxisHeight() {
    final double labelHeight = StringSize.getHeightOfString('I', style.xAxisStyle.tickStyle.labelTextStyle);
    final TickStyle tickStyle = style.xAxisStyle.tickStyle;
    _bottomAxisHeight = labelHeight + tickStyle.tickLength + tickStyle.tickMargin;
  }

  void _setBottomLabelHeight() => _bottomLabelHeight = style.isMini ? 0 : StringSize.getHeight(style.xAxisStyle.label);

  void _setBottomLegendHeight() => style.legendStyle.visible && !style.isMini ? StringSize.getHeightOfString('I', style.legendStyle.legendTextStyle) : 0;

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

  void _adjustDisplayValueRange() {
    _adjustDisplayValueRangeHelper(
      originalRange: dataModel.y1ValueRange,
      valueRangeToBeAdjusted: _displayY1Range,
      axisStyle: style.y1AxisStyle,
    );
    if (_hasYAxisOnTheRight) {
      _adjustDisplayValueRangeHelper(
        originalRange: dataModel.y2ValueRange,
        valueRangeToBeAdjusted: _displayY2Range,
        axisStyle: style.y2AxisStyle,
      );
    }
  }

  void _adjustDisplayValueRangeHelper({
    @required List<double> originalRange,
    @required List<double> valueRangeToBeAdjusted,
    @required AxisStyle axisStyle,
  }) {
    final double start = axisStyle.preferredStartValue;
    final double end = axisStyle.preferredEndValue;
    start <= originalRange[0]
        ? valueRangeToBeAdjusted[0] = start
        : valueRangeToBeAdjusted[0] = originalRange[0];

    String max = originalRange[1].toStringAsExponential();
    int expInt = int.tryParse(max.substring(max.indexOf('e+') + 2));
    num exp = pow(10, expInt - 1);
    double value = (((originalRange[1] * (1 + (_valueOnBarHeight) / _canvasHeight) / exp).ceil() + 5) * exp).toDouble();
    end >= value
        ? valueRangeToBeAdjusted[1] = end
        : valueRangeToBeAdjusted[1] = value;

    // If after adjustment, number of digit changed then...
    // TODO
    final int newDigit = int.tryParse(value.toStringAsExponential().substring(value.toStringAsExponential().indexOf('e+') + 2));
    if (newDigit > expInt) {
      print('We need to fix this, e.g 999 -> 1000, width might be wrong');
    }
  }

  void _setYUnitPerPixel() {
    _y1UnitPerPixel = (y1Max - y1Min) / _canvasHeight;
    if (_hasYAxisOnTheRight) { _y2UnitPerPixel = (y2Max - y2Min) / _canvasHeight; }
  }
}