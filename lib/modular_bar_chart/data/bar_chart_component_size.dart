import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/axis_info_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';

import 'bar_chart_data.dart';
import 'bar_chart_style.dart';

class BarChartComponentSize extends ChangeNotifier with StringSize, AxisInfo {
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final Size parentSize;

  BarChartComponentSize({
    @required this.dataModel,
    @required this.style,
    @required this.parentSize,
  });

  double _maxGroupNameWidth = 0, _maxGroupNameWidthWithSpace = 0;
  double _leftAxisWidth = 0, _rightAxisWidth = 0, _canvasWidth = 0, _xSectionWidth = 0, _barWidth = 0;
  double _titleHeight = 0, _spacingHeight = 0, _bottomAxisHeight = 0, _bottomLabelHeight = 0, _bottomLegendHeight = 0,
  _canvasHeight = 0;
  bool _hasYAxisOnTheRight = false;

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
  bool get hasYAxisOnTheRight => _hasYAxisOnTheRight;

  void init(){
    // Set whether the chart has y axis on the right
    _setHasYAxisOnTheRight();

    // Set original bar width from style
    _setBarWidth();

    // Set component heights
    _setComponentHeight();

    // Set maximum group name width
    _setMaxGroupNameWidth();

    // Set component widths
    _setComponentWidth();

    // Set xSectionWidth, this may also set a new bar width
    _setXSectionWidth();
  }

  void _setHasYAxisOnTheRight() => _hasYAxisOnTheRight = dataModel.type == BarChartType.GroupedSeparated;

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
}