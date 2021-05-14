import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

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
class VerticalAxisPainter extends CustomPainter {
  final RangeValues rangeValues;
  final AxisStyle axisStyle;
  final bool isRight;
  final bool isMini;

  const VerticalAxisPainter({
    @required this.rangeValues,
    @required this.axisStyle,
    @required this.isRight,
    this.isMini = false,
  }) : assert(rangeValues != null);

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
    final double yMax = rangeValues.end, yMin = rangeValues.start;
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