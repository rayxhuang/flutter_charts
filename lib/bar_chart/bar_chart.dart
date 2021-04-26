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
  final Offset gridAreaOffsetFromBottomLeft;
  final Offset gridAreaOffsetFromTopRight;
  final EdgeInsetsGeometry contentPadding;
  final AxisStyle xAxisStyle;
  final AxisStyle yAxisStyle;
  final BarChartAnimation animation;

  BarChart({
    @required this.barChartData,
    @required this.width,
    @required this.height,
    @required this.gridAreaOffsetFromBottomLeft,
    @required this.gridAreaOffsetFromTopRight,
    this.contentPadding = const EdgeInsets.all(10),
    this.xAxisStyle = const AxisStyle(),
    this.yAxisStyle = const AxisStyle(),
    this.animation = const BarChartAnimation(),
  });

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> with TickerProviderStateMixin{
  // BarChartPainter _painter;
  List<double> _xValueRange = [], _yValueRange = [];
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  @override
  void initState() {
    super.initState();

    analyseData();

    final BarChartAnimation animation = widget.animation;
    final Tween<double> _tween = Tween(begin: 0, end: 1);
    if (animation.animateAxis) {
      _axisAnimationController = AnimationController(
        vsync: this,
        duration: animation.axisAnimationDuration,
      );
      _tween.animate(_axisAnimationController)..addListener(() {
        setState(() {
          axisAnimationValue = _axisAnimationController.value;
        });
      });
    }
    if (animation.animateData) {
      _dataAnimationController = AnimationController(
        vsync: this,
        duration: animation.dataAnimationDuration,
      );
      _tween.animate(_dataAnimationController)..addListener(() {
        setState(() {
          dataAnimationValue = _dataAnimationController.value;
        });
      });
    }

    //Animate both axis and data?
    if (animation.animateAxis && animation.animateData) {
      if (animation.animateDataAfterAxis) {
        _axisAnimationController.forward(from: 0).then((value) => _dataAnimationController.forward(from: 0));
      } else {
        _axisAnimationController.forward(from: 0);
        _dataAnimationController.forward(from: 0);
      }
    } else {
      if (animation.animateAxis) { _axisAnimationController.forward(from: 0); dataAnimationValue = 1; }
      if (animation.animateData) { _dataAnimationController.forward(from: 0); axisAnimationValue = 1; }
      if (!animation.animateData && !animation.animateAxis) { dataAnimationValue = 1; axisAnimationValue = 1; }
    }
  }

  void analyseData() {
    List<double> _xValueList1 = [], _xValueList2 = [], _yValueList = [];
    var data = widget.barChartData.data;
    if (widget.barChartData.type == BarChartDataType.Double) {
      double xMin, xMax, yMin, yMax;
      data.forEach((bar) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Padding(
        padding: widget.contentPadding,
        child: CustomPaint(
          painter: BarChartPainter(
            startOffset: widget.gridAreaOffsetFromBottomLeft,
            endOffset: widget.gridAreaOffsetFromTopRight,
            barChartData: widget.barChartData,
            xValueRange: _xValueRange,
            yValueRange: _yValueRange,
            xStyle: widget.xAxisStyle,
            yStyle: widget.yAxisStyle,
            axisAnimationFraction: axisAnimationValue,
            barAnimationFraction: dataAnimationValue,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _axisAnimationController.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }
}

class BarChartPainter extends CustomPainter {
  final Offset startOffset, endOffset;
  final AxisStyle xStyle, yStyle;
  final BarChartData barChartData;
  final List<double> xValueRange, yValueRange;
  List<BarData> _data;
  double axisAnimationFraction, barAnimationFraction;
  Offset _topLeft, _topRight, _bottomLeft, _bottomRight, _axisIntersection;
  Offset _axisXStartOffset, _axisXEndOffset, _axisYStartOffset, _axisYEndOffset;
  bool xSatisfied = false;
  bool ySatisfied = false;

  BarChartPainter({
    this.startOffset,
    this.endOffset,
    this.barChartData,
    this.xValueRange,
    this.yValueRange,
    this.xStyle,
    this.yStyle,
    this.axisAnimationFraction,
    this.barAnimationFraction,
  });

  // TODO Adjust start and end value
  void canFitAsDesired() {
    if (xValueRange[1] <= xStyle.preferredEndValue && xValueRange[0] >= xStyle.preferredStartValue) { xSatisfied = true; }
    if (yValueRange[1] <= yStyle.preferredEndValue && yValueRange[0] >= yStyle.preferredStartValue) { ySatisfied = true; }
  }

  void drawTicksOnAxis(
    Canvas canvas,
    AxisStyle style,
    double length,
    double startValue,
    double endValue,
    {bool isHorizontal = true}
  ) {
    final Tick tick = style.tick;
    final double lengthPerTick = length / (style.numTicks - 1);
    final double valuePerTick = (endValue - startValue) / (style.numTicks - 1);
    final Paint tickPaint = Paint()
      ..strokeWidth = style.strokeWidth
      ..strokeCap = style.strokeCap
      ..color = tick.tickColor;
    final TextStyle tickTextStyle = TextStyle(color: tick.textColor, fontSize: tick.labelTextSize);
    final TextPainter _textPainter = TextPainter(
      text: TextSpan(),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();

    Offset p1, p2, p3;
    if (!tick.onlyShowTicksAtTwoSides) {
      int _numTicksBetween = style.numTicks - 2;
      for (int i = 1; i < _numTicksBetween + 1; i++) {
        // TODO is this divided by pi?
        if (isHorizontal) {
          p1 = _bottomLeft.translate(i * lengthPerTick, tickPaint.strokeWidth / 2);
          p2 = p1.translate(0, tick.tickLength);
          p3 = p2.translate(0, tick.tickMargin);
        } else {
          p1 = _bottomLeft.translate(-tickPaint.strokeWidth / 2, -(i * lengthPerTick));
          p2 = p1.translate(-tick.tickLength, 0);
          p3 = p2.translate(-tick.tickMargin, 0);
        }

        //Draw the tick line
        canvas.drawLine(p1, p2, tickPaint);
        final String value = (startValue + i * valuePerTick).toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(
          text: '$value',
          style: tickTextStyle,
        );
        _textPainter.layout();
        //Draw the tick value text
        isHorizontal
            ? _textPainter.paint(canvas, p3.translate(-(_textPainter.width / 2), 0))
            : _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));
      }
    }

    //Draw start value
    if (isHorizontal) {
      p1 = _bottomLeft.translate(0, tickPaint.strokeWidth / 2);
      p2 = p1.translate(0, tick.tickLength);
      p3 = p2.translate(0, tick.tickMargin);
    } else {
      p1 = _bottomLeft.translate(-(tickPaint.strokeWidth / 2), 0);
      p2 = p1.translate(-(tick.tickLength), 0);
      p3 = p2.translate(-tick.tickMargin, 0);
    }
    canvas.drawLine(p1, p2, tickPaint);
    final String startText = startValue.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(
      text: '$startText',
      style: tickTextStyle,
    );
    _textPainter.layout();
    isHorizontal
        ? _textPainter.paint(canvas, p3.translate(-(_textPainter.width / 2), 0))
        : _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));

    //Draw end value
    if (isHorizontal) {
      p1 = _bottomRight.translate(0, tickPaint.strokeWidth / 2);
      p2 = p1.translate(0, tick.tickLength);
      p3 = p2.translate(0, tick.tickMargin);
    } else {
      p1 = _topLeft.translate(-(tickPaint.strokeWidth / 2), 0);
      p2 = p1.translate(-(tick.tickLength), 0);
      p3 = p2.translate(-tick.tickMargin, 0);
    }
    canvas.drawLine(p1, p2, tickPaint);
    String endText;
    //If the user want last tick to show unit as text
    tick.lastTickWithUnit
        ? endText = style.preferredEndValue.toStringAsFixed(tick.tickDecimal) + tick.unit
        : endText = style.preferredEndValue.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(
      text: '$endText',
      style: tickTextStyle,
    );
    _textPainter.layout();
    isHorizontal
        ? _textPainter.paint(canvas, p3.translate(-(_textPainter.width / 2), 0))
        : _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));
  }

  void drawData(Canvas canvas, double xUnitPerPixel, double yUnitPerPixel) {
    //This is the bar paint
    Paint paint = Paint()
      ..color = barChartData.style.color
      ..strokeWidth = 2;
    //Draw data as bars on grid
    for (BarData bar in _data) {
      double x1FromBottomLeft = (bar.x1 - xStyle.preferredStartValue) / xUnitPerPixel;
      double x2FromBottomLeft = x1FromBottomLeft + (bar.x2 - bar.x1) / xUnitPerPixel;
      double yFromBottomLeft = (bar.y - yStyle.preferredStartValue) / yUnitPerPixel;
      Rect rect = Rect.fromPoints(
          _bottomLeft.translate(x1FromBottomLeft, -yFromBottomLeft * barAnimationFraction),
          _bottomLeft.translate(x2FromBottomLeft, 0)
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _data = barChartData.data;
    // DEBUG USE ONLY
    //canvas.drawRect(Offset(0, 0) & size, Paint()..color = Colors.white);
    //print(axisAnimationFraction);

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
    // Paint p = Paint()..color = Colors.red;
    // canvas.drawLine(_topLeft, _topRight, p);
    // canvas.drawLine(_topLeft, _bottomLeft, p);
    // canvas.drawLine(_topRight, _bottomRight, p);
    // canvas.drawLine(_bottomLeft, _bottomRight, p);
    canFitAsDesired();

    // Draw X Axis
    if (xStyle.visible) {
      _axisXStartOffset = _bottomLeft.translate(0, - xStyle.shift);
      _axisXEndOffset = _bottomRight.translate(0, - xStyle.shift);
      double axisXLength = _axisXEndOffset.dx - _axisXStartOffset.dx;
      final paintX = Paint()
        ..color = xStyle.axisColor
        ..strokeWidth = xStyle.strokeWidth
        ..strokeCap = xStyle.strokeCap;
      //canvas.drawLine(_axisXStartOffset, _axisXEndOffset, paintX);
      canvas.drawLine(_axisXStartOffset, _axisXStartOffset.translate(axisXLength * axisAnimationFraction, 0), paintX);

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
      double axisYLength = _axisYEndOffset.dy - _axisYStartOffset.dy;
      final paintY = Paint()
        ..color = yStyle.axisColor
        ..strokeWidth = yStyle.strokeWidth
        ..strokeCap = yStyle.strokeCap;
      canvas.drawLine(_axisYStartOffset, _axisYStartOffset.translate(0, axisYLength * axisAnimationFraction), paintY);
      // Adjust size according to stroke taken by the axis
      double strokeWidth = yStyle.strokeWidth / 2;
      _bottomLeft = _bottomLeft.translate(strokeWidth, 0);
      _topLeft = _topLeft.translate(strokeWidth, 0);
      actualLengthX -= strokeWidth;
    }

    // These might be useful later
    actualGridSize = Size(actualLengthX, actualLengthY);
    _axisIntersection = _bottomLeft.translate(yStyle.shift, -xStyle.shift);

    // Draw ticks on X Axis
    if (xStyle.visible && xSatisfied && axisAnimationFraction == 1) {
      // TODO Remove use of value in style
      drawTicksOnAxis(canvas, xStyle, actualLengthX, xStyle.preferredStartValue, xStyle.preferredEndValue);
    }

    // Draw ticks on Y Axis
    if (yStyle.visible && ySatisfied && axisAnimationFraction == 1) {
      // TODO Remove use of value in style
      drawTicksOnAxis(canvas, yStyle, actualLengthY, yStyle.preferredStartValue, yStyle.preferredEndValue, isHorizontal: false);
    }

    // Calculate unitPerPixel then draw data
    double xUnitPerPixel, yUnitPerPixel;
    // TODO Remove use of value in style
    if (xSatisfied) { xUnitPerPixel = (xStyle.preferredEndValue - xStyle.preferredStartValue) / actualLengthX; }
    if (ySatisfied) { yUnitPerPixel = (yStyle.preferredEndValue - yStyle.preferredStartValue) / actualLengthY; }
    drawData(canvas, xUnitPerPixel, yUnitPerPixel);
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return (oldDelegate.axisAnimationFraction != axisAnimationFraction || oldDelegate.barAnimationFraction != barAnimationFraction);
  }
}