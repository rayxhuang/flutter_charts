import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/data/textSizeInfo.dart';

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
    // This does not draw the start and ending tick
    for (int i = 1; i < xGroupNum; i++) {
      p1 = start.translate(i * xSectionLength, tickPaint.strokeWidth / 2);
      p2 = p1.translate(0, tick.tickLength);
      p3 = p2.translate(0, tick.tickMargin);
      tickPositions.add(p3);
      //Draw the tick line
      canvas.drawLine(p1, p2, tickPaint);
    }
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
class ChartAxisVerticalWithLabel extends StatelessWidget {
  // This widget display the label and data of a vertical axis
  final double axisHeight;
  final bool isRightAxis;

  ChartAxisVerticalWithLabel({ @required this.axisHeight, this.isRightAxis = false });

  Size size(double maxValue, AxisStyle axisStyle) => Size(getWidth(axisStyle.label.text, maxValue, axisStyle), axisHeight);

  static double getWidth(String axisLabel, double axisData, AxisStyle style) => labelWidth(style.label) + axisWidth(axisData, style);

  static double labelWidth(BarChartLabel label) => label.text == '' ? 0 : 5 + getSizeOfString(label.text, label.textStyle, isHeight: true);

  static double axisWidth(double max, AxisStyle style) => getSizeOfString(max.toStringAsFixed(style.tickStyle.tickDecimal), style.tickStyle.labelTextStyle) + style.tickStyle.tickMargin + style.tickStyle.tickLength;

  @override
  Widget build(BuildContext context) {
    final AxisStyle axisStyle = isRightAxis
        ? context.read<BarChartStyle>().y2AxisStyle
        : context.read<BarChartStyle>().y1AxisStyle;
    final List<double> yValueRange = isRightAxis
        ? context.read<ModularBarChartData>().y2ValueRange
        : context.read<ModularBarChartData>().y1ValueRange;
    return SizedBox(
      height: axisHeight,
      width: getWidth(axisStyle.label.text, yValueRange[2], axisStyle),
      child: Row(
        children: [
          isRightAxis
              ? SizedBox()
              : RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  width: axisHeight,
                  height: labelWidth(axisStyle.label),
                  child: Center(
                    child: Text(
                      axisStyle.label.text,
                      style: axisStyle.label.textStyle,
                    ),
                  ),
                ),
              ),
          SizedBox(
            width: axisWidth(yValueRange[2], axisStyle),
            height: axisHeight,
            child: CustomPaint(
              painter: VerticalAxisPainter(
                valueRange: yValueRange,
                axisStyle: axisStyle,
                isLeft: isRightAxis ? false : true,
              ),
            ),
          ),
          isRightAxis
              ? RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  width: axisHeight,
                  height: labelWidth(axisStyle.label),
                  child: Center(
                    child: Text(
                      axisStyle.label.text,
                      style: axisStyle.label.textStyle,
                    ),
                  ),
                ),
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
  final bool isLeft;

  const VerticalAxisPainter({
    @required this.valueRange,
    @required this.axisStyle,
    @required this.isLeft,
  }) : assert(valueRange != null);

  @override
  void paint(Canvas canvas, Size size) {
    final double length = size.height;
    final axisPaint = Paint();
    axisPaint..color = axisStyle.axisColor;
    axisPaint..strokeWidth = axisStyle.strokeWidth;
    axisPaint..strokeCap = axisStyle.strokeCap;
    axisPaint..strokeCap = StrokeCap.square;

    final Offset start = Offset(isLeft ? size.width : 0, 0);
    final Offset end = Offset(isLeft ? size.width : 0, size.height);
    canvas.drawLine(start, end, axisPaint);

    final TickStyle tick = axisStyle.tickStyle;
    final double lengthPerTick = length / (axisStyle.numTicks - 1);
    final double yMax = valueRange[2], yMin = valueRange[0];
    final double valuePerTick = (yMax - yMin) / (axisStyle.numTicks - 1);
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

    Offset p1, p2, p3, p4;
    if (!tick.onlyShowTicksAtTwoSides) {
      int _numTicksBetween = axisStyle.numTicks - 2;
      for (int i = 1; i < _numTicksBetween + 1; i++) {
        p1 = end.translate(0, -1 * i * lengthPerTick);                     // p1 is the point on axis
        p2 = p1.translate((isLeft ? -1 : 1) * tick.tickLength, 0);         // p2 is the point at the end of each tick
        p3 = p2.translate((isLeft ? -1 : 1) * tick.tickMargin, 0);         // p3 is p2 + margin set by user

        //Draw the tick line
        canvas.drawLine(p1, p2, tickPaint);
        final String value = (yMin + i * valuePerTick).toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(text: '$value', style: tickTextStyle,);
        _textPainter.layout();
        //Draw the tick value text
        _textPainter.paint(canvas, p3.translate((isLeft ? -1 : 0) * _textPainter.width, -(_textPainter.height / 2)));
      }
    }

    //Draw start value
    p1 = end;
    p2 = p1.translate((isLeft ? -1 : 1) * tick.tickLength, 0);
    p3 = p2.translate((isLeft ? -1 : 1) * tick.tickMargin, 0);
    canvas.drawLine(p1, p2, tickPaint);
    final String startText = yMin.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(text: '$startText', style: tickTextStyle,);
    _textPainter.layout();
    _textPainter.paint(canvas, p3.translate((isLeft ? -1 : 0) * _textPainter.width, -(_textPainter.height / 2)));

    //Draw end value
    p1 = start;
    p2 = p1.translate((isLeft ? -1 : 1) * tick.tickLength, 0);
    p3 = p2.translate((isLeft ? -1 : 1) * tick.tickMargin, 0);
    canvas.drawLine(p1, p2, tickPaint);
    String endText;
    //If the user want last tick to show unit as text
    endText = yMax.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(text: '$endText', style: tickTextStyle,);
    _textPainter.layout();
    p4 = p3.translate((isLeft ? -1 : 0) * _textPainter.width, -(_textPainter.height / 2));
    _textPainter.paint(canvas, p4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}