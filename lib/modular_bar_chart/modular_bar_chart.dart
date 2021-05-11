import 'dart:math';
import 'dart:ui';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_mini_canvas.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_event.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';
import 'components/chart_axis.dart';
import 'components/chart_legend.dart';
import 'components/chart_title.dart';
import 'components/stateful/chart_main_canvas_wrapper.dart';
import 'mixin/axis_info_mixin.dart';

@immutable
class ModularBarChart extends StatelessWidget with StringSize, AxisInfo {
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
    final double parentHeight = constraint.maxHeight < double.infinity
        ? constraint.maxHeight
        : MediaQuery.of(context).size.height;
    final double parentWidth = constraint.maxWidth < double.infinity
        ? constraint.maxWidth
        : MediaQuery.of(context).size.width;
    return Size(parentWidth, parentHeight);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ModularBarChartData>(create: (_) => dataModel),
        Provider<BarChartStyle>(create: (_) => style),
        ChangeNotifierProvider<BarChartEvent>(create: (_) => BarChartEvent(dataModel: dataModel, style: style),),
      ],
      child: LayoutBuilder(builder: (context, constraint) {
        final ModularBarChartData dataModel = context.read<ModularBarChartData>();
        final BarChartStyle style = context.read<BarChartStyle>();
        final Size parentSize = _getParentSize(constraint: constraint, context: context);

        // TODO Separate one more class which combines style and data to do calculation
        // Set max group name width
        dataModel.setMaxGroupNameWidth(textStyle: style.xAxisStyle.tickStyle.labelTextStyle);

        // Width information
        final bool hasYAxisOnTheRight = type == BarChartType.GroupedSeparated;
        final double leftAxisStaticWidth =
          getVerticalAxisCombinedWidth(axisMaxValue: dataModel.y1ValueRange[1], style: style.y1AxisStyle, isMini: style.isMini);
        final double rightAxisStaticWidth = hasYAxisOnTheRight
            ? getVerticalAxisCombinedWidth(axisMaxValue: dataModel.y2ValueRange[1], style: style.y2AxisStyle, isMini: style.isMini)
            : 0;
        double canvasWidth = parentSize.width - leftAxisStaticWidth - rightAxisStaticWidth;
        if (canvasWidth < 0) { canvasWidth = 0; }
        // Adjust xSectionLength and bar width in case of user-set bar width is too small
        final List<double> xSectionLength =
          calculateXSectionLength(dataModel: dataModel, style: style, canvasWidth: canvasWidth);
        final double barWidth = xSectionLength.length == 2
            ? xSectionLength[1]
            : style.barStyle.barWidth;

        // Height information
        final double titleStaticHeight = StringSize.getHeight(style.title);
        // TODO
        final double spacingStaticHeight = 0.5 * StringSize.getHeightOfString('I', style.y1AxisStyle.tickStyle.labelTextStyle);
        // TODO
        double a = 2 * StringSize.getHeightOfString('I', style.xAxisStyle.tickStyle.labelTextStyle);
        final List<double> bottomAxisHeightInformation = getXRotatedHeight(
          axisStyle: style.xAxisStyle,
          nameMaxWidth: dataModel.maxGroupNameWidth + a - a,
          nameMaxWidthWithSpace: dataModel.maxGroupNameWidthWithSpace,
          xSectionLength: xSectionLength[0],
        );
        final double bottomAxisStaticHeight = bottomAxisHeightInformation[0] + style.xAxisStyle.tickStyle.tickLength + style.xAxisStyle.tickStyle.tickMargin;
        final double bottomLabelStaticHeight = style.isMini ? 0 : StringSize.getHeight(style.xAxisStyle.label);
        final double bottomLegendStaticHeight = style.legendStyle.visible && !style.isMini
            ? StringSize.getHeightOfString('Title', style.legendStyle.legendTextStyle)
            : 0;
        //print(bottomLabelStaticHeight);
        double canvasHeight = parentSize.height -
            titleStaticHeight -
            spacingStaticHeight -
            bottomAxisStaticHeight -
            bottomLabelStaticHeight -
            bottomLegendStaticHeight;
        if (canvasHeight < 0) { canvasHeight = 0; }
        final Size canvasSize = Size(canvasWidth, canvasHeight);
        // Adjust y Max to fit number on bar and populate data
        _adjustVerticalAxisValueRange(canvasHeight: canvasHeight, hasYAxisOnTheRight: hasYAxisOnTheRight);
        dataModel.populateDataWithMinimumValue();

        // Canvas and bottom axis
        Widget chartCanvasWithAxis;
        Size chartCanvasWithAxisSize;
        if (style.isMini) {
          chartCanvasWithAxis = _buildMiniChart(canvasSize: canvasSize, dataModel: dataModel, style: style, barWidth: barWidth);
          chartCanvasWithAxisSize = canvasSize;
        } else {
          final Size wrapperSize = Size(canvasWidth, canvasHeight + bottomAxisHeightInformation[0] + style.xAxisStyle.tickStyle.tickLength);
          chartCanvasWithAxis = ChartCanvasWrapper(
            size: wrapperSize,
            labelInfo: bottomAxisHeightInformation,
            canvasSize: canvasSize,
            barWidth: barWidth,
            displayMiniCanvas: barWidth == style.barStyle.barWidth ? true : false,
            animation: style.animation,
          );
          chartCanvasWithAxisSize = wrapperSize;
        }

        // Left Axis
        final VerticalAxisWithLabel leftAxis = VerticalAxisWithLabel(axisHeight: canvasHeight,);

        // TODO Change the height of title in full mode
        // Title
        final ChartTitle chartTitle = ChartTitle(
          width: parentSize.width,
          hasRightAxis: hasYAxisOnTheRight,
        );

        // Bottom Label
        final Widget bottomLabel = !style.isMini
            ? ChartTitle(
              width: canvasWidth,
              isXAxisLabel: true,
              hasRightAxis: hasYAxisOnTheRight,
            )
            : SizedBox();

        // Bottom Legend
        final Widget bottomLegend = style.legendStyle.visible && !style.isMini
            ? ChartLegendHorizontal(width: canvasWidth)
            : SizedBox();

        // Right Axis
        final Widget rightAxis = hasYAxisOnTheRight
            ? VerticalAxisWithLabel(
              axisHeight: canvasHeight,
              isRightAxis: true,
            )
            : SizedBox();

        // TODO Too small to have a canvas?
        return _buildChart(
          parentSize: parentSize,
          canvasSize: chartCanvasWithAxisSize,
          title: chartTitle,
          spacing: SizedBox(height: spacingStaticHeight,),
          leftAxisWithLabel: leftAxis,
          mainCanvasWithBottomAxis: chartCanvasWithAxis,
          bottomLabel: bottomLabel,
          bottomLegend: bottomLegend,
          rightAxisWithLabel: rightAxis,
          titleHeight: titleStaticHeight,
          spacingHeight: spacingStaticHeight,
          leftAxisWidth: leftAxisStaticWidth,
          bottomLabelHeight: bottomLabelStaticHeight,
        );
      }),
    );
  }

  void _adjustVerticalAxisValueRange({
    @required double canvasHeight,
    @required hasYAxisOnTheRight
  }) {
    dataModel.adjustAxisValueRange(
      canvasHeight,
      valueRangeToBeAdjusted: dataModel.y1ValueRange,
      start: style.y1AxisStyle.preferredStartValue,
      end: style.y1AxisStyle.preferredEndValue,
    );
    if (hasYAxisOnTheRight) {
      dataModel.adjustAxisValueRange(
        canvasHeight,
        valueRangeToBeAdjusted: dataModel.y2ValueRange,
        start: style.y2AxisStyle.preferredStartValue,
        end: style.y2AxisStyle.preferredEndValue,
      );
    }
  }

  Widget _buildMiniChart({
    @required Size canvasSize,
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
    @required double barWidth,
  }) {
    // TODO Correct data is done, work on x Axis
    final double xSectionLength =
      getXSectionLengthFromBarWidth(dataModel: dataModel, style: style, barWidth: barWidth);
    final double xLength =
      getXAxisTotalLength(dataModel: dataModel, canvasWidth: canvasSize.width, xSectionLength: xSectionLength);
    return Column(
      children: [
        ChartCanvasMini(
          containerSize: canvasSize,
          canvasSize: Size(xLength, canvasSize.height)
        ),
        HorizontalAxisSimpleLine(
          size: Size(canvasSize.width, style.xAxisStyle.strokeWidth),
        ),
        Center(
          child: Text(
            style.xAxisStyle.label.text,
            style: style.xAxisStyle.label.textStyle,
          ),
        )
      ],
    );
  }

  Widget _buildChart({
    @required Size parentSize,
    @required Size canvasSize,
    @required Widget title,
    @required Widget spacing,
    @required Widget leftAxisWithLabel,
    @required Widget mainCanvasWithBottomAxis,
    @required Widget bottomLabel,
    @required Widget bottomLegend,
    @required Widget rightAxisWithLabel,
    @required double titleHeight,
    @required double spacingHeight,
    @required double leftAxisWidth,
    @required double bottomLabelHeight,
  }) {
    return SizedBox.fromSize(
      size: parentSize,
      child: Padding(
        // TODO padding
        padding: EdgeInsets.all(0),
        child: Stack(children: [
          // Spacing between title and axis
          Positioned(
            left: 0,
            top: titleHeight,
            child: spacing,
          ),

          // Canvas and bottom axis
          Positioned(
            top: titleHeight + spacingHeight,
            left: leftAxisWidth,
            child: mainCanvasWithBottomAxis,
          ),

          // Left Axis
          Positioned(
            top: titleHeight + spacingHeight,
            child: leftAxisWithLabel,
          ),

          // Title
          Positioned(
            top: 0,
            left: 0,
            child: title,
          ),

          // Bottom Label
          Positioned(
            top: titleHeight + spacingHeight + canvasSize.height,
            left: leftAxisWidth,
            child: bottomLabel,
          ),

          // Bottom Legends
          Positioned(
            top: titleHeight + spacingHeight + canvasSize.height + bottomLabelHeight,
            left: leftAxisWidth,
            child: bottomLegend,
          ),

          // Right Axis
          Positioned(
            top: titleHeight + spacingHeight,
            left: leftAxisWidth + canvasSize.width,
            child: rightAxisWithLabel,
          ),
        ]),
      ),
    );
  }

  List<double> getXRotatedHeight({
    @required AxisStyle axisStyle,
    @required double nameMaxWidth,
    @required double nameMaxWidthWithSpace,
    @required double xSectionLength,
  }) {
    double rotatedAngle = 0;
    if (nameMaxWidth > xSectionLength) {
      final double ratio = 2;
      //final double maxHeight = xSectionLength * ratio;
      double maxHeight = 30, maxRotatedAngle = 0, spaceLeft = 0;
      bool success = false;
      // print('got it');
      // print(xSectionLength);
      // print(maxHeight);
      double maxCombineGroup = 3, numGroupsToBeCombined = 1;
      for (int i = 1; i < maxCombineGroup + 1; i++) {
        double w = i * xSectionLength;
        if (w >= nameMaxWidth) {
          // print('success at $i, simple width: $w');
          // print('text len: $nameMaxWidth');
          success = true;
          numGroupsToBeCombined = i.toDouble();
          final double tickLength = axisStyle.tickStyle.tickLength + axisStyle.tickStyle.tickMargin;
          maxHeight = StringSize.getHeightOfString('I', axisStyle.tickStyle.labelTextStyle) + tickLength;
          break;
        }
        double diagonalLength = sqrt(pow(w, 2) + pow(maxHeight, 2));
        if (diagonalLength >= nameMaxWidthWithSpace) {
          // print('success at $i, dia len: $diagonalLength');
          // print('text len: $nameMaxWidthWithSpace');
          maxRotatedAngle = asin(maxHeight / diagonalLength);
          success = true;
          numGroupsToBeCombined = i.toDouble();
          spaceLeft = diagonalLength - nameMaxWidthWithSpace;
          //print('space left: $spaceLeft');
          break;
        }
      }
      if (!success) {
        maxRotatedAngle = asin(maxHeight / sqrt(pow(maxCombineGroup * xSectionLength, 2) + pow(maxHeight, 2)));
        numGroupsToBeCombined = maxCombineGroup;
      }
      // print('success? $success');
      // print('max angle: $maxRotatedAngle');
      // print('groups combined: $numGroupsToBeCombined');
      final List<double> result = [maxHeight, maxRotatedAngle, numGroupsToBeCombined, spaceLeft];
      //print(result);
      return result;
    } else {
      final double tickLength = axisStyle.tickStyle.tickLength + axisStyle.tickStyle.tickMargin;
      return [
        StringSize.getHeightOfString('I', axisStyle.tickStyle.labelTextStyle) + tickLength,
        0,
        1
      ];
    }
  }
}