import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'axis.dart';

class BarChart extends StatefulWidget {
  final BarChartData barChartData;
  final double width;
  final double height;
  final Offset actualDataGridAreaOffsetFromBottomLeft;
  final Offset actualDataGridAreaOffsetFromTopRight;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry contentPadding;
  final ShapeBorder outerShape;
  final AxisStyle xAxisStyle;
  final AxisStyle yAxisStyle;

  BarChart({
    @required this.barChartData,
    @required this.width,
    @required this.height,
    @required this.actualDataGridAreaOffsetFromBottomLeft,
    @required this.actualDataGridAreaOffsetFromTopRight,
    this.margin = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.all(10),
    this.outerShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    this.xAxisStyle = const AxisStyle(),
    this.yAxisStyle = const AxisStyle(),
  });

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  BarChartPainter _painter;

  @override
  void initState() {
    super.initState();

    _painter = BarChartPainter(
      startOffset: widget.actualDataGridAreaOffsetFromBottomLeft,
      endOffset: widget.actualDataGridAreaOffsetFromTopRight,
      barChartData: widget.barChartData,
      xStyle: widget.xAxisStyle,
      yStyle: widget.yAxisStyle,
    );

    _painter.analyseData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: widget.outerShape,
      margin: widget.margin,
      child: Center(
        child: Container(
          padding: widget.contentPadding,
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _painter,
          ),
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Offset startOffset, endOffset;
  final AxisStyle xStyle, yStyle;
  final BarChartData barChartData;
  List<BarData> _data;
  List<double> _xValueRange = [], _yValueRange = [];
  List<double> _xValueList1 = [], _xValueList2 = [], _yValueList = [];
  Offset _topLeft, _topRight, _bottomLeft, _bottomRight, _axisIntersection;
  Offset _axisXStartOffset, _axisXEndOffset, _axisYStartOffset, _axisYEndOffset;
  bool xSatisfied = false;
  bool ySatisfied = false;

  BarChartPainter({
    this.startOffset,
    this.endOffset,
    this.barChartData,
    this.xStyle,
    this.yStyle,
  });

  void analyseData() {
    _data = barChartData.data;
    if (barChartData.type == BarChartDataType.Double) {
      double xMin, xMax, yMin, yMax;
      _data.forEach((bar) {
        _xValueList1.add(bar.x1);
        _xValueList2.add(bar.x2);
        _yValueList.add(bar.y);
      });
      xMin = _xValueList1.reduce(min);
      xMax = _xValueList2.reduce(max);
      _xValueRange = [xMin, xMax];
      yMin = _yValueList.reduce(min);
      yMax = _yValueList.reduce(max);
      _yValueRange = [yMin, yMax];

      print(_xValueRange);
      print(_yValueRange);
    }
  }

  // TODO
  void canFitAsDesired() {
    if (_xValueRange[1] <= xStyle.preferredEnd && _xValueRange[0] >= xStyle.preferredStart) { xSatisfied = true; }
    if (_yValueRange[1] <= yStyle.preferredEnd && _yValueRange[0] >= yStyle.preferredStart) { ySatisfied = true; }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // DEBUG USE ONLY
    //canvas.drawRect(Offset(0, 0) & size, Paint()..color = Colors.white);

    //Get actual size available for data
    double actualLengthX = size.width - startOffset.dx - endOffset.dx;
    double actualLengthY = size.height - startOffset.dy - endOffset.dy;
    Size actualGridSize = Size(actualLengthX, actualLengthY);

    //Set four useful points
    _topLeft = Offset(0, 0).translate(startOffset.dx, endOffset.dy);
    _topRight = _topLeft.translate(actualGridSize.width, 0);
    _bottomLeft = _topLeft.translate(0, actualGridSize.height);
    _bottomRight = _topLeft.translate(actualGridSize.width, actualGridSize.height);

    // DEBUG USE ONLY
    Paint p = Paint()..color = Colors.red;
    canvas.drawLine(_topLeft, _topRight, p);
    canvas.drawLine(_topLeft, _bottomLeft, p);
    canvas.drawLine(_topRight, _bottomRight, p);
    canvas.drawLine(_bottomLeft, _bottomRight, p);

    canFitAsDesired();

    // Draw X Axis
    if (xStyle.visible) {
      _axisXStartOffset = _bottomLeft.translate(0, - xStyle.shift);
      _axisXEndOffset = _bottomRight.translate(0, - xStyle.shift);
      final paintX = Paint()
        ..color = xStyle.color
        ..strokeWidth = xStyle.strokeWidth
        ..strokeCap = xStyle.strokeCap;
      canvas.drawLine(_axisXStartOffset, _axisXEndOffset, paintX);

      // Adjust size according to stroke taken by the axis
      double strokeWidth = xStyle.strokeWidth / 2;
      _bottomLeft = _bottomLeft.translate(0, - strokeWidth);
      _bottomRight = _bottomRight.translate(0, - strokeWidth);
      actualLengthY -= strokeWidth;
    }

    // Draw Y Axis
    if (yStyle.visible) {
      _axisYStartOffset = _bottomLeft.translate(yStyle.shift, 0);
      _axisYEndOffset = _topLeft.translate(yStyle.shift, 0);
      final paintY = Paint()
        ..color = yStyle.color
        ..strokeWidth = yStyle.strokeWidth
        ..strokeCap = yStyle.strokeCap;
      canvas.drawLine(_axisYStartOffset, _axisYEndOffset, paintY);
      // Adjust size according to stroke taken by the axis
      double strokeWidth = yStyle.strokeWidth / 2;
      _bottomLeft = _bottomLeft.translate(strokeWidth, 0);
      _topLeft = _topLeft.translate(strokeWidth, 0);
      actualLengthX -= strokeWidth;
    }

    actualGridSize = Size(actualLengthX, actualLengthY);
    _axisIntersection = _bottomLeft.translate(yStyle.shift, -xStyle.shift);

    //Calculate unitPerPixel
    double xUnitPerPixel, yUnitPerPixel;
    if (xSatisfied) { xUnitPerPixel = (xStyle.preferredEnd - xStyle.preferredStart) / actualLengthX; }
    if (ySatisfied) { yUnitPerPixel = (yStyle.preferredEnd - yStyle.preferredStart) / actualLengthY; }

    //Draw ticks on X Axis
    if (xStyle.visible) {
      if (xSatisfied) {
        final Tick tick = xStyle.tick;
        final double lengthPerTick = actualLengthX / (xStyle.numTicks - 1);
        final double valuePerTick = (xStyle.preferredEnd - xStyle.preferredStart) / (xStyle.numTicks - 1);
        final Paint tickPaint = Paint()
        ..strokeWidth = xStyle.strokeWidth
        ..strokeCap = xStyle.strokeCap
        ..color = tick.tickColor;
        final TextStyle tickTextStyle = TextStyle(color: tick.textColor, fontSize: tick.labelTextSize);
        final TextPainter _textPainter = TextPainter(
          text: TextSpan(),
          textDirection: TextDirection.ltr,
        );
        _textPainter.layout();

        if (!tick.onlyShowTicksAtTwoSides) {
          int _numTicksBetween = xStyle.numTicks - 2;
          for (int i = 1; i < _numTicksBetween + 1; i++) {
            // TODO is this divided by pi?
            Offset p1 = _bottomLeft.translate(i * lengthPerTick, tickPaint.strokeWidth / 2);
            Offset p2 = p1.translate(0, tick.tickLength);
            Offset p3 = p2.translate(0, tick.tickMargin);
            //Draw the tick line
            canvas.drawLine(p1, p2, tickPaint);
            final String value = (xStyle.preferredStart + i * valuePerTick).toStringAsFixed(tick.tickDecimal);
            _textPainter.text = TextSpan(
              text: '$value',
              style: tickTextStyle,
            );
            _textPainter.layout();
            //Draw the tick value text
            _textPainter.paint(canvas, p3.translate(-(_textPainter.width / 2), 0));
          }
        }

        //Draw start value
        Offset p1 = _bottomLeft.translate(0, tickPaint.strokeWidth / 2);
        Offset p2 = p1.translate(0, tick.tickLength);
        Offset p3 = p2.translate(0, tick.tickMargin);
        canvas.drawLine(p1, p2, tickPaint);
        final String startValue = xStyle.preferredStart.toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(
          text: '$startValue',
          style: tickTextStyle,
        );
        _textPainter.layout();
        _textPainter.paint(canvas, p3.translate(-(_textPainter.width / 2), 0));

        //Draw end value
        p1 = _bottomRight.translate(0, tickPaint.strokeWidth / 2);
        p2 = p1.translate(0, tick.tickLength);
        p3 = p2.translate(0, tick.tickMargin);
        canvas.drawLine(p1, p2, tickPaint);
        String _endValue;
        //If the user want last tick to show unit as text
        tick.lastTickWithUnit
            ? _endValue = xStyle.preferredEnd.toStringAsFixed(tick.tickDecimal) + tick.unit
            : _endValue = xStyle.preferredEnd.toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(
          text: '$_endValue',
          style: tickTextStyle,
        );
        _textPainter.layout();
        _textPainter.paint(canvas, p3.translate(-(_textPainter.width / 2), 0));
      }
    }

    //Draw ticks on Y Axis
    if (yStyle.visible) {
      if (ySatisfied) {
        final Tick tick = yStyle.tick;
        final double lengthPerTick = actualLengthY / (yStyle.numTicks - 1);
        final double valuePerTick = (yStyle.preferredEnd - yStyle.preferredStart) / (yStyle.numTicks - 1);
        final Paint tickPaint = Paint()
          ..strokeWidth = yStyle.strokeWidth
          ..strokeCap = yStyle.strokeCap
          ..color = tick.tickColor;
        final TextStyle tickTextStyle = TextStyle(color: tick.textColor, fontSize: tick.labelTextSize);
        final TextPainter _textPainter = TextPainter(
          text: TextSpan(),
          textDirection: TextDirection.ltr,
        );
        _textPainter.layout();

        if (!tick.onlyShowTicksAtTwoSides) {
          int _numTicksBetween = yStyle.numTicks - 2;
          for (int i = 1; i < _numTicksBetween + 1; i++) {
            //TODO pi?
            Offset p1 = _bottomLeft.translate(-tickPaint.strokeWidth / 2, -(i * lengthPerTick));
            Offset p2 = p1.translate(-tick.tickLength, 0);
            Offset p3 = p2.translate(-tick.tickMargin, 0);
            //Draw the tick line
            canvas.drawLine(p1, p2, tickPaint);
            final String value = (yStyle.preferredStart + i * valuePerTick).toStringAsFixed(tick.tickDecimal);
            _textPainter.text = TextSpan(
              text: '$value',
              style: tickTextStyle,
            );
            _textPainter.layout();
            //Draw the tick value text
            _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));
          }
        }

        //Draw start value
        Offset p1 = _bottomLeft.translate(-(tickPaint.strokeWidth / 2), 0);
        Offset p2 = p1.translate(-(tick.tickLength), 0);
        Offset p3 = p2.translate(-tick.tickMargin, 0);
        canvas.drawLine(p1, p2, tickPaint);
        final String startValue = yStyle.preferredStart.toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(
          text: '$startValue',
          style: tickTextStyle,
        );
        _textPainter.layout();
        _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));

        //Draw end value
        p1 = _topLeft.translate(-(tickPaint.strokeWidth / 2), 0);
        p2 = p1.translate(-(tick.tickLength), 0);
        p3 = p2.translate(-tick.tickMargin, 0);
        canvas.drawLine(p1, p2, tickPaint);
        String _endValue;
        //If the user want last tick to show unit as text
        tick.lastTickWithUnit
            ? _endValue = yStyle.preferredEnd.toStringAsFixed(tick.tickDecimal) + tick.unit
            : _endValue = yStyle.preferredEnd.toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(
          text: '$_endValue',
          style: tickTextStyle,
        );
        _textPainter.layout();
        _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));
      }
    }

    //This is the bar paint
    Paint paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    //Draw data as bars on grid
    for (BarData bar in _data) {
      double x1FromBottomLeft = (bar.x1 - xStyle.preferredStart) / xUnitPerPixel;
      double x2FromBottomLeft = x1FromBottomLeft + (bar.x2 - bar.x1) / xUnitPerPixel;
      double yFromBottomLeft = (bar.y - yStyle.preferredStart) / yUnitPerPixel;
      Rect rect = Rect.fromPoints(
        _bottomLeft.translate(x1FromBottomLeft, -yFromBottomLeft),
        _bottomLeft.translate(x2FromBottomLeft, 0)
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}