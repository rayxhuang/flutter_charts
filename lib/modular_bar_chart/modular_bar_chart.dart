import 'dart:math';
import 'dart:ui';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_mini_canvas.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_mini_version.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';
import 'components/chart_axis.dart';
import 'components/chart_legend.dart';
import 'components/chart_title.dart';
import 'components/stateful/chart_main_canvas_wrapper.dart';

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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BarChartStyle>(create: (_) => style),
        Provider<ModularBarChartData>(create: (_) => dataModel),
      ],
      child: LayoutBuilder(builder: (context, constraint) {
        ModularBarChartData data = context.read<ModularBarChartData>();
        BarChartStyle style = context.read<BarChartStyle>();

        // Set max group name width
        data.setMaxGroupNameWidth(style.xAxisStyle.tickStyle.labelTextStyle);

        // Size data
        Size leftAxisSize = Size.zero,
            titleSize = Size.zero,
            canvasSize = Size.zero,
            bottomLabelSize = Size.zero;
        final double parentHeight = constraint.maxHeight < double.infinity
            ? constraint.maxHeight
            : MediaQuery.of(context).size.height;
        final double parentWidth = constraint.maxWidth < double.infinity
            ? constraint.maxWidth
            : MediaQuery.of(context).size.width;
        final Size parentSize = Size(parentWidth, parentHeight);

        // Width
        final bool hasYAxisOnTheRight =
            type == BarChartType.GroupedSeparated ? true : false;

        // Get static sizes of components
        double leftAxisStaticWidth, rightAxisStaticWidth;
        leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(
          style.y1AxisStyle.label.text,
          data.y1ValueRange[1],
          style.y1AxisStyle,
          isMini: style.isMini,
        );
        rightAxisStaticWidth = hasYAxisOnTheRight
            ? ChartAxisVerticalWithLabel.getWidth(
              style.y2AxisStyle.label.text,
              data.y2ValueRange[1],
              style.y2AxisStyle,
              isMini: style.isMini,
            )
            : 0;
        double canvasWidth = parentWidth - leftAxisStaticWidth - rightAxisStaticWidth;
        if (canvasWidth < 0) { canvasWidth = 0; }

        // Adjust xSectionLength in case of data is too small
        final List<double> xSectionLength = calculateXSectionLength(data, style, canvasWidth);
        bool overrideInputBarWidth = false;
        double overrideBarWidth;
        // This means a new bar width is calculated
        if (xSectionLength.length == 2) {
          overrideInputBarWidth = true;
          overrideBarWidth = xSectionLength[1];
        }

        // Height
        final double titleStaticHeight = StringSize.getHeight(style.title);
        double a = 2 * StringSize.getHeightOfString('I', style.xAxisStyle.tickStyle.labelTextStyle);
        final List<double> bottomAxisHeightInformation = getXRotatedHeight(
          axisStyle: style.xAxisStyle,
          nameMaxWidth: data.maxGroupNameWidth + a - a,
          nameMaxWidthWithSpace: data.maxGroupNameWidthWithSpace,
          xSectionLength: xSectionLength[0],
        );
        final double bottomLabelStaticHeight = style.isMini ? 0 : StringSize.getHeight(style.xAxisStyle.label);
        final double bottomLegendStaticHeight = style.legendStyle.visible && !style.isMini
            ? StringSize.getHeightOfString('Title', style.legendStyle.legendTextStyle)
            : 0;
        double canvasHeight = parentHeight -
            titleStaticHeight -
            bottomAxisHeightInformation[0] -
            style.xAxisStyle.tickStyle.tickLength -
            bottomLabelStaticHeight -
            bottomLegendStaticHeight;
        if (canvasHeight < 0) {
          canvasHeight = 0;
        }
        canvasSize = Size(canvasWidth, canvasHeight);

        // Adjust y Max to fit number on bar and populate data
        data.adjustAxisValueRange(
          canvasHeight,
          valueRangeToBeAdjusted: data.y1ValueRange,
          start: style.y1AxisStyle.preferredStartValue,
          end: style.y1AxisStyle.preferredEndValue,
        );
        if (hasYAxisOnTheRight) {
          data.adjustAxisValueRange(
            canvasHeight,
            valueRangeToBeAdjusted: data.y2ValueRange,
            start: style.y2AxisStyle.preferredStartValue,
            end: style.y2AxisStyle.preferredEndValue,
          );
        }
        data.populateDataWithMinimumValue();

        // Canvas and bottom axis
        var chartCanvasWithAxis, chartCanvasWithAxisSize;
        if (style.isMini) {
          // TODO Correct data is done, work on x Axis
          final double barWidth = overrideInputBarWidth
              ? overrideBarWidth
              : style.barStyle.barWidth;
          final double xSectionLength = getXSectionLengthFromBarWidth(data: dataModel, style: style, barWidth: barWidth);
          final double xLength = getXLength(dataModel: dataModel, canvasWidth: canvasSize.width, xSectionLength: xSectionLength);
          //chartCanvasWithAxis = Container();
          chartCanvasWithAxis = ChartCanvasMini(
            containerSize: Size(canvasWidth, canvasHeight),
            canvasSize: Size(xLength, canvasHeight)
          );
          chartCanvasWithAxisSize = Size(canvasWidth, canvasHeight);
        } else {
          chartCanvasWithAxis = ChartCanvasWrapper(
            size: Size(canvasWidth, canvasHeight + bottomAxisHeightInformation[0] + style.xAxisStyle.tickStyle.tickLength),
            labelInfo: bottomAxisHeightInformation,
            canvasSize: canvasSize,
            barWidth: overrideInputBarWidth
                ? overrideBarWidth
                : style.barStyle.barWidth,
            displayMiniCanvas: overrideInputBarWidth ? false : true,
            animation: style.animation,
          );
          chartCanvasWithAxisSize = chartCanvasWithAxis.size;
        }

        // Left Axis
        final ChartAxisVerticalWithLabel leftAxis = ChartAxisVerticalWithLabel(
          axisHeight: canvasHeight,
        );
        leftAxisSize = leftAxis.size(data.y1ValueRange[2], style.y1AxisStyle, isMini: style.isMini);

        // Title
        final ChartTitle chartTitle = ChartTitle(
          width: parentSize.width,
        );
        titleSize = chartTitle.size(style.title);

        // Bottom Label
        final ChartTitle bottomLabel = ChartTitle(
          width: canvasWidth,
          isXAxisLabel: true,
        );
        bottomLabelSize = bottomLabel.size(style.xAxisStyle.label);

        // Bottom Legend
        ChartLegendHorizontal bottomLegend;
        if (style.legendStyle.visible && !style.isMini) { bottomLegend = ChartLegendHorizontal(width: canvasWidth); }

        // Right Axis
        final ChartAxisVerticalWithLabel rightAxis = ChartAxisVerticalWithLabel(
          axisHeight: canvasHeight,
          isRightAxis: true,
        );

        // TODO Too small to have a canvas?
        return SizedBox(
          width: parentWidth,
          height: parentHeight,
          child: Padding(
            // TODO padding
            padding: EdgeInsets.all(0),
            child: Stack(children: [
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
              !style.isMini
                  ? Positioned(
                    top: titleSize.height + chartCanvasWithAxisSize.height,
                    left: leftAxisSize.width,
                    child: bottomLabel,
                  )
                  : SizedBox(),

              // Bottom Legends
              style.legendStyle.visible && !style.isMini
                  ? Positioned(
                      top: titleSize.height +
                          chartCanvasWithAxisSize.height +
                          bottomLabelSize.height,
                      left: leftAxisSize.width,
                      child: bottomLegend,
                    )
                  : SizedBox(),

              // Right Axis
              hasYAxisOnTheRight
                  ? Positioned(
                      top: titleSize.height,
                      left: leftAxisSize.width + canvasWidth,
                      child: rightAxis,
                    )
                  : SizedBox(),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildMiniChart({
    @required Size size,
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
  }) {
    int numberOfYTicks = size.height ~/ 50;
    if (numberOfYTicks == 0 ) { numberOfYTicks = 1; }
    if (numberOfYTicks >= 4) { numberOfYTicks = 4; }
    return SizedBox.fromSize(
      size: size,
      child: Column(
        children: [
          Container(
            height: 20,
            width: size.width,
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          ),
          SizedBox(
            height: size.height - 20 - 20,
            width: size.width,
            child: FittedBox(
              fit: BoxFit.fill,
              child: MiniChart(
                numberOfYTicks: numberOfYTicks,
              ),
            ),
          ),
          Container(
            height: 20,
            width: size.width,
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<double> calculateXSectionLength(
      ModularBarChartData data, BarChartStyle style, double canvasWidth) {
    double totalBarWidth = data.numBarsInGroups * style.barStyle.barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin =
        style.barStyle.barInGroupMargin * (data.numBarsInGroups - 1);
    double xSectionLengthCalculatedFromData =
        totalBarWidth + totalGroupMargin + totalInGroupMargin;
    double xSectionLengthAvailable = canvasWidth / data.xGroups.length;
    if (xSectionLengthCalculatedFromData > xSectionLengthAvailable) {
      return [xSectionLengthCalculatedFromData];
    } else {
      double newBarWidth =
          (xSectionLengthAvailable - totalGroupMargin - totalInGroupMargin) /
              data.numBarsInGroups;
      return [xSectionLengthAvailable, newBarWidth];
    }
  }

  double getXSectionLengthFromBarWidth({
    @required ModularBarChartData data,
    @required BarChartStyle style,
    @required double barWidth,
  }) {
    int numBarsInGroup = (data.type == BarChartType.Ungrouped || data.type == BarChartType.GroupedStacked || data.type == BarChartType.GroupedSeparated)
        ? 1
        : data.xSubGroups.length;
    double totalBarWidth = numBarsInGroup * barWidth;
    double totalGroupMargin = style.groupMargin * 2;
    double totalInGroupMargin = style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
    return totalBarWidth + totalGroupMargin + totalInGroupMargin;
  }

  double getXLength({
    @required ModularBarChartData dataModel,
    @required double canvasWidth,
    @required double xSectionLength,
  }) => [xSectionLength * dataModel.xGroups.length, canvasWidth].reduce(max);

  double getXHeight(AxisStyle xAxisStyle) =>
      StringSize.getHeightOfString('I', xAxisStyle.tickStyle.labelTextStyle) + xAxisStyle.tickStyle.tickLength + xAxisStyle.tickStyle.tickMargin;

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
      print(result);
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
