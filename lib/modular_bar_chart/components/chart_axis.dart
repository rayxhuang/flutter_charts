import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/axis_info_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

@immutable
class ChartAxisHorizontalWrapper extends StatelessWidget {
  final Size containerSize;
  final Size singleCanvasSize;
  final ScrollController scrollController;
  final ScrollController labelController;
  final List<double> labelInfo;
  final bool isMini;

  const ChartAxisHorizontalWrapper({
    @required this.containerSize,
    @required this.singleCanvasSize,
    @required this.scrollController,
    @required this.labelController,
    @required this.labelInfo,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();
    final int numGroupsToCombine = labelInfo[2].toInt();
    final int numGroupNames = (dataModel.xGroups.length / numGroupsToCombine).ceil();
    final int difference = numGroupNames * numGroupsToCombine - dataModel.xGroups.length;
    final double singleCombinedGroupNameWidth = singleCanvasSize.width * numGroupsToCombine;

    final double rotatedBoxWidth = singleCanvasSize.width * numGroupsToCombine;
    final bool widthIsGreaterThanHeight = rotatedBoxWidth >= labelInfo[0] ? true : false;
    final double startingValue = widthIsGreaterThanHeight ? 0 : 0.5 * pi;
    final int quarterTurn = widthIsGreaterThanHeight ? 0 : -1;
    return SizedBox.fromSize(
      size: containerSize,
      child: Column(
        children: [
          SizedBox(
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
                  numGroupsToCombine: numGroupsToCombine,
                )
            ),
          ),
          SizedBox(
            height: labelInfo[0] - style.xAxisStyle.strokeWidth,
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
                  height: labelInfo[0],
                  child: Transform.rotate(
                    angle: startingValue - labelInfo[1],
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: quarterTurn,
                        child: Text(
                          dataModel.xGroups[index * numGroupsToCombine],
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  CustomPaint _buildSingleGroupXAxisCanvas({
    @required ModularBarChartData dataModel,
    @required BarChartStyle style,
    @required int index,
    @required int numGroupsToCombine,
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
      size: Size(singleCanvasSize.width, style.xAxisStyle.tickStyle.tickLength),
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
    final BarChartStyle style = context.read<BarChartStyle>();
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
    // final TextStyle tickTextStyle = tick.labelTextStyle;
    // final TextPainter _textPainter = TextPainter(
    //   text: TextSpan(),
    //   textDirection: TextDirection.ltr,
    // );
    // _textPainter.layout();

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

    // // Draw group name
    // _textPainter.text = TextSpan(text: '$groupName', style: tickTextStyle);
    // _textPainter.layout(maxWidth: size.width);
    // //Draw the tick value text
    // _textPainter.paint(canvas, Offset(
    //     (size.width - _textPainter.width) / 2,
    //     tick.tickLength + tick.tickMargin
    // ));
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

// @immutable
// class ChartAxisHorizontal extends StatelessWidget with StringSize{
//   final ModularBarChartData dataModel;
//   final double barWidth;
//   final BarChartStyle style;
//   final double axisLength;
//   final ScrollController scrollController;
//
//   const ChartAxisHorizontal({
//     @required this.dataModel,
//     @required this.barWidth,
//     @required this.axisLength,
//     @required this.scrollController,
//     this.style = const BarChartStyle(),
//   });
//
//   Size get size => Size(axisLength, getHeight(style.xAxisStyle));
//   double get xSectionLength {
//     return dataModel.numBarsInGroups * barWidth + style.groupMargin * 2
//         + style.barStyle.barInGroupMargin * (dataModel.numBarsInGroups - 1);
//   }
//   double get length => [xSectionLength * dataModel.xGroups.length, axisLength].reduce(max);
//   double get height => getHeight(style.xAxisStyle);
//
//   static double getHeight(AxisStyle xAxisStyle) =>
//       StringSize.getHeightOfString('I', xAxisStyle.tickStyle.labelTextStyle) + xAxisStyle.tickStyle.tickLength + xAxisStyle.tickStyle.tickMargin;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: axisLength,
//       height: height,
//       child: SingleChildScrollView(
//         physics: ClampingScrollPhysics(),
//         scrollDirection: Axis.horizontal,
//         controller: scrollController,
//         child: CustomPaint(
//           painter: HorizontalAxisPainter(
//             xGroups: dataModel.xGroups,
//             axisStyle: style.xAxisStyle,
//           ),
//           size: Size(length, height),
//         ),
//       ),
//     );
//   }
// }

@immutable
class HorizontalAxisPainter extends CustomPainter {
  final List<String> xGroups;
  final AxisStyle axisStyle;

  const HorizontalAxisPainter({
    @required this.xGroups,
    this.axisStyle = const AxisStyle(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final xGroupNum = xGroups.length;
    final double length = size.width;
    final axisPaint = Paint();
    axisPaint..color = axisStyle.axisColor;
    axisPaint..strokeWidth = axisStyle.strokeWidth;
    axisPaint..strokeCap = axisStyle.strokeCap;

    // Draw axis line
    final Offset start = Offset(0, axisStyle.strokeWidth / 2);
    final Offset end = Offset(length, axisStyle.strokeWidth / 2);
    canvas.drawLine(start, end, axisPaint);

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

    final double xSectionLength = length / xGroupNum;
    Offset p1, p2, p3;
    List<Offset> tickPositions = [];

    // Does not draw the start and ending tick
    for (int i = 1; i < xGroupNum; i++) {
      p1 = start.translate(i * xSectionLength, tickPaint.strokeWidth / 2);
      p2 = p1.translate(0, tick.tickLength);
      p3 = p2.translate(0, tick.tickMargin);
      tickPositions.add(p3);
      //Draw the tick line
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Draw group names
    for (int i = 0; i < xGroupNum; i++) {
      final String groupName = xGroups[i];
      _textPainter.text = TextSpan(text: '$groupName', style: tickTextStyle);
      _textPainter.layout(maxWidth: xSectionLength);
      //Draw the tick value text
      _textPainter.paint(canvas, Offset(
        i * xSectionLength + (xSectionLength - _textPainter.width) / 2,
        tick.tickLength + tick.tickMargin
      ));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

@immutable
class ChartAxisVerticalWithLabel extends StatelessWidget with StringSize, AxisInfo {
  // This widget display the label and data of a vertical axis
  final double axisHeight;
  final bool isRightAxis;

  ChartAxisVerticalWithLabel({ @required this.axisHeight, this.isRightAxis = false });

  Size size(double maxValue, AxisStyle axisStyle, {bool isMini = false})
    => Size(
      getVerticalAxisCombinedWidth(
        axisMaxValue: maxValue,
        style: axisStyle,
        isMini: isMini,
      ),
      axisHeight
    );

  @override
  Widget build(BuildContext context) {
    final BarChartStyle style = context.read<BarChartStyle>();
    final AxisStyle axisStyle = isRightAxis
        ? style.y2AxisStyle
        : style.y1AxisStyle;
    final List<double> yValueRange = isRightAxis
        ? context.read<ModularBarChartData>().y2ValueRange
        : context.read<ModularBarChartData>().y1ValueRange;
    final Widget axisLabel = style.isMini
        ? SizedBox()
        : SizedBox(
          width: axisHeight,
          height: getVerticalAxisLabelWidth(label: axisStyle.label),
          child: Center(
            child: Text(
              axisStyle.label.text,
              style: axisStyle.label.textStyle,
            ),
          ),
        );

    return SizedBox(
      height: axisHeight,
      width: getVerticalAxisCombinedWidth(
        axisMaxValue: yValueRange[2],
        style: axisStyle,
        isMini: style.isMini
      ),
      child: Row(
        children: [
          isRightAxis
              ? SizedBox()
              : RotatedBox(
                quarterTurns: 1,
                child: axisLabel
              ),
          SizedBox(
            width: getVerticalAxisWidth(max: yValueRange[2], style: axisStyle, isMini: style.isMini),
            height: axisHeight,
            child: CustomPaint(
              painter: VerticalAxisPainter(
                valueRange: yValueRange,
                axisStyle: axisStyle,
                isRight: isRightAxis,
                isMini: style.isMini,
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
    axisPaint..strokeCap = axisStyle.strokeCap;
    axisPaint..strokeCap = StrokeCap.square;

    final Offset start = Offset(isRight ? 0 : size.width, 0);
    final Offset end = Offset(isRight ? 0 : size.width, size.height);
    canvas.drawLine(start, end, axisPaint);

    // TODO Auto num ticks in mini mode
    final TickStyle tickStyle = axisStyle.tickStyle;
    final double lengthPerTick = length / (axisStyle.numTicks - 1);
    final double yMax = valueRange[2], yMin = valueRange[0];
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