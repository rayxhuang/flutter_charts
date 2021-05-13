import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

import 'chart_axis_painter.dart';

@immutable
class HorizontalAxisWrapper extends StatelessWidget {
  final ScrollController scrollController;
  final ScrollController labelController;

  const HorizontalAxisWrapper({
    @required this.scrollController,
    @required this.labelController,
  });

  Widget _buildXAxis({
    @required DisplayInfo displayInfo,
  }) {
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;
    return SizedBox(
      height: style.xAxisStyle.tickStyle.tickLength + style.xAxisStyle.strokeWidth,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        itemCount: dataModel.xGroups.length,
        itemBuilder: (context, index) =>
          _buildSingleGroupXAxisCanvas(
            dataModel: dataModel,
            style: style,
            index: index,
            numGroupsToCombine: displayInfo.numOfGroupNamesToCombine,
            xSectionWidth: displayInfo.xSectionWidth
          )
      ),
    );
  }

  CustomPaint _buildSingleGroupXAxisCanvas({
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
    @required int index,
    @required int numGroupsToCombine,
    @required double xSectionWidth,
  }) {
    final bool isFirstOfAll = index == 0 ? true : false;
    final bool isLastOfAll = index == dataModel.xGroups.length - 1 ? true : false;
    final bool isFirstInGroup = index.remainder(numGroupsToCombine) == 0 ? true : false;
    final bool isLastInGroup = index.remainder(numGroupsToCombine) == numGroupsToCombine - 1 ? true : false;
    final bool paintTickOnLeft = !isFirstOfAll &&  isFirstInGroup;
    final bool paintTickOnRight = !isLastOfAll && isLastInGroup;
    return CustomPaint(
      painter: HorizontalAxisSingleGroupPainter(
        groupName: dataModel.xGroups[index],
        axisStyle: style.xAxisStyle,
        paintTickOnLeft: paintTickOnLeft,
        paintTickOnRight: paintTickOnRight,
      ),
      size: Size(xSectionWidth, style.xAxisStyle.tickStyle.tickLength),
    );
  }

  Widget _buildXGroupName({@required DisplayInfo displayInfo}) {
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;

    final Size singleCanvasSize = Size(displayInfo.xSectionWidth, style.xAxisStyle.tickStyle.tickLength);
    final int numGroupNames = (dataModel.xGroups.length / displayInfo.numOfGroupNamesToCombine).ceil();
    final int difference = numGroupNames * displayInfo.numOfGroupNamesToCombine - dataModel.xGroups.length;
    final double singleCombinedGroupNameWidth = singleCanvasSize.width * displayInfo.numOfGroupNamesToCombine;
    return SizedBox(
      height: displayInfo.bottomAxisHeight - style.xAxisStyle.tickStyle.tickLength - style.xAxisStyle.strokeWidth,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        controller: labelController,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        itemCount: numGroupNames,
        itemBuilder: (context, index) {
          final bool notEnoughGroupsAtTheEnd = index == numGroupNames - 1 && difference > 0 ? true : false;
          return SizedBox(
            width: notEnoughGroupsAtTheEnd
                ? singleCombinedGroupNameWidth - difference * singleCanvasSize.width
                : singleCombinedGroupNameWidth,
            height: displayInfo.bottomAxisHeight - style.xAxisStyle.tickStyle.tickLength - style.xAxisStyle.strokeWidth,
            child: Center(
              child: Text(
                dataModel.xGroups[index * displayInfo.numOfGroupNamesToCombine],
                maxLines: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();

    return SizedBox.fromSize(
      size: Size(displayInfo.canvasWidth, displayInfo.bottomAxisHeight),
      child: Column(
        children: [
          _buildXAxis(displayInfo: displayInfo),
          _buildXGroupName(displayInfo: displayInfo)
        ],
      ),
    );
  }
}

@immutable
class HorizontalAxisSimpleWrapper extends StatelessWidget {
  final Size size;

  const HorizontalAxisSimpleWrapper({
    @required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final BarChartStyle style = context.read<DisplayInfo>().style;
    return SizedBox.fromSize(
      size: size,
      child: CustomPaint(
        painter: HorizontalAxisSimplePainter(axisStyle: style.xAxisStyle,),
        size: Size(size.width, style.xAxisStyle.strokeWidth),
      ),
    );
  }
}

@immutable
class VerticalAxisWithLabel extends StatelessWidget {
  // This widget display the label and data of a vertical axis
  final bool isRightAxis;

  VerticalAxisWithLabel({ this.isRightAxis = false });

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayInfo>(
      builder: (context, displayInfo, child) {
        final AxisStyle axisStyle = isRightAxis
            ? displayInfo.style.y2AxisStyle
            : displayInfo.style.y1AxisStyle;

        final List<double> yValueRange = isRightAxis
            ? displayInfo.y2ValueRange
            : displayInfo.y1ValueRange;

        final double combinedWidth = isRightAxis
            ? displayInfo.rightAxisCombinedWidth
            : displayInfo.leftAxisCombinedWidth;

        final double axisWidth = isRightAxis
            ? displayInfo.rightAxisWidth
            : displayInfo.leftAxisWidth;

        final double labelWidth = isRightAxis
            ? displayInfo.rightAxisLabelWidth
            : displayInfo.leftAxisLabelWidth;

        // Does not display label when in mini mode
        final Widget axisLabel = displayInfo.isMini
            ? SizedBox()
            : SizedBox(
              width: displayInfo.canvasHeight,
              height: labelWidth,
              child: Center(
                child: Text(
                  axisStyle.label.text,
                  style: axisStyle.label.textStyle,
                ),
              ),
            );

        return SizedBox(
            height: displayInfo.canvasHeight,
            width: combinedWidth,
            child: Row(
              children: [
                isRightAxis
                    ? SizedBox()
                    : RotatedBox(
                      quarterTurns: 1,
                      child: axisLabel
                    ),
                SizedBox(
                  width: axisWidth,
                  height: displayInfo.canvasHeight,
                  child: CustomPaint(
                    painter: VerticalAxisPainter(
                      valueRange: yValueRange,
                      axisStyle: axisStyle,
                      isRight: isRightAxis,
                      isMini: displayInfo.isMini,
                    ),
                  ),
                ),
                isRightAxis
                    ? RotatedBox(
                      quarterTurns: 3,
                      child: axisLabel
                    )
                    : SizedBox(),
              ],
            )
        );
      }
    );
  }
}

@immutable
class BottomAxisLabel extends StatelessWidget {
  const BottomAxisLabel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final BarChartLabel label = displayInfo.style.xAxisStyle.label;
    return SizedBox(
      width: displayInfo.canvasWidth,
      height: displayInfo.bottomLabelHeight,
      child: Center(
        child: Text(
          label.text,
          style: label.textStyle,
        ),
      ),
    );
  }
}
