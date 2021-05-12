import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

@immutable
class ChartAxisHorizontalWrapper extends StatelessWidget {
  final ScrollController scrollController;
  final ScrollController labelController;

  const ChartAxisHorizontalWrapper({
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
class HorizontalAxisSingleGroupPainter extends CustomPainter {
  final String groupName;
  final AxisStyle axisStyle;
  final bool paintTickOnLeft;
  final bool paintTickOnRight;

  const HorizontalAxisSingleGroupPainter({
    @required this.groupName,
    this.axisStyle = const AxisStyle(),
    this.paintTickOnLeft = true,
    this.paintTickOnRight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint();
    axisPaint..color = axisStyle.axisColor;
    axisPaint..strokeWidth = axisStyle.strokeWidth;
    axisPaint..strokeCap = axisStyle.strokeCap;

    // Draw axis line
    final Offset start = Offset(0, axisStyle.strokeWidth / 2);
    final Offset end = Offset(size.width, axisStyle.strokeWidth / 2);
    canvas.drawLine(start, end, axisPaint);

    final TickStyle tick = axisStyle.tickStyle;
    final Paint tickPaint = Paint()
      ..strokeWidth = axisStyle.strokeWidth
      ..strokeCap = axisStyle.strokeCap
      ..color = tick.tickColor;

    Offset p1, p2;

    //Draw the tick line
    if (paintTickOnLeft) {
      p1 = start;
      p2 = p1.translate(0, tick.tickLength);
      canvas.drawLine(p1, p2, tickPaint);
    }

    if (paintTickOnRight) {
      p1 = end;
      p2 = p1.translate(0, tick.tickLength);
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

@immutable
class HorizontalAxisSimplePainter extends CustomPainter {
  final AxisStyle axisStyle;

  const HorizontalAxisSimplePainter({
    @required this.axisStyle
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPainter = Paint();
    axisPainter..color = axisStyle.axisColor;
    axisPainter..strokeWidth = axisStyle.strokeWidth;
    axisPainter..strokeCap = axisStyle.strokeCap;

    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), axisPainter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

@immutable
class VerticalAxisWithLabel extends StatelessWidget {
  // This widget display the label and data of a vertical axis
  final bool isRightAxis;

  VerticalAxisWithLabel({ this.isRightAxis = false });

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();

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
}

@immutable
class VerticalAxisPainter extends CustomPainter {
  final List<double> valueRange;
  final AxisStyle axisStyle;
  final bool isRight;
  final bool isMini;

  const VerticalAxisPainter({
    @required this.valueRange,
    @required this.axisStyle,
    @required this.isRight,
    this.isMini = false,
  }) : assert(valueRange != null);

  @override
  void paint(Canvas canvas, Size size) {
    final double length = size.height;
    final axisPaint = Paint();
    axisPaint..color = axisStyle.axisColor;
    axisPaint..strokeWidth = axisStyle.strokeWidth;
    // TODO use square at origin
    axisPaint..strokeCap = StrokeCap.square;

    final Offset start = Offset(isRight ? 0 : size.width, 0);
    final Offset end = Offset(isRight ? 0 : size.width, size.height);
    canvas.drawLine(start, end, axisPaint);

    // TODO Auto num ticks in mini mode
    final TickStyle tickStyle = axisStyle.tickStyle;
    final double lengthPerTick = length / (axisStyle.numTicks - 1);
    final double yMax = valueRange[1], yMin = valueRange[0];
    final double valuePerTick = (yMax - yMin) / (axisStyle.numTicks - 1);

    Offset p1;
    //Draw start value tick
    p1 = end;
    final String startText = yMin.toStringAsFixed(tickStyle.tickDecimal);
    _drawTickAndValue(
      canvas: canvas,
      offset: p1,
      value: startText,
    );

    //Draw end value tick
    p1 = start;
    final String endText = yMax.toStringAsFixed(tickStyle.tickDecimal);
    _drawTickAndValue(
      canvas: canvas,
      offset: p1,
      value: endText,
    );

    // Draw ticks in between
    if (!tickStyle.onlyShowTicksAtTwoSides) {
      int _numTicksBetween = axisStyle.numTicks - 2;
      for (int i = 1; i < _numTicksBetween + 1; i++) {
        // p1 is the point on axis
        p1 = end.translate(0, -1 * i * lengthPerTick);
        final String value = (yMin + i * valuePerTick).toStringAsFixed(tickStyle.tickDecimal);
        _drawTickAndValue(
          canvas: canvas,
          offset: p1,
          value: value,
        );
      }
    }
  }

  void _drawTickAndValue({
    @required Canvas canvas,
    @required Offset offset,
    @required String value,
  }) {
    final TickStyle tick = axisStyle.tickStyle;
    final Paint tickPaint = Paint()
      ..strokeWidth = axisStyle.strokeWidth
      ..strokeCap = axisStyle.strokeCap
      ..color = tick.tickColor;
    final TextStyle tickTextStyle = tick.labelTextStyle;
    final TextPainter _textPainter = TextPainter(
      text: TextSpan(),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();

    Offset p2, p3;
    if (!isMini) {
      p2 = offset.translate((isRight ? 1 : -1) * tick.tickLength, 0);     // p2 is the point at the end of each tick
      p3 = p2.translate((isRight ? 1 : -1) * tick.tickMargin, 0);         // p3 is p2 + margin set by user
    } else {
      p2 = offset;
      p3 = offset.translate((isRight ? 1 : -1) * tick.tickMargin, 0);
    }

    //Draw the tick line
    canvas.drawLine(offset, p2, tickPaint);
    _textPainter.text = TextSpan(text: '$value', style: tickTextStyle,);
    _textPainter.layout();
    //Draw the tick value text
    _textPainter.paint(canvas, p3.translate((isRight ? 0 : -1) * _textPainter.width, -(_textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
