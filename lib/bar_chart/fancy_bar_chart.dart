import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'axis.dart';

typedef Comparator<T> = int Function(T a, T b);
class FancyBarChart extends StatefulWidget {
  final Map<String, dynamic> rawData;
  final Comparator<String> groupComparator;
  final bool sortXAxis;
  //final BarChartData barChartData;
  final double width;
  final double height;
  final Offset gridAreaOffsetFromBottomLeft;
  final Offset gridAreaOffsetFromTopRight;
  final EdgeInsetsGeometry contentPadding;
  final AxisStyle xAxisStyle;
  final AxisStyle yAxisStyle;
  final BarChartAnimation animation;

  FancyBarChart({
    @required this.rawData,
    //@required this.barChartData,
    @required this.width,
    @required this.height,
    @required this.gridAreaOffsetFromBottomLeft,
    @required this.gridAreaOffsetFromTopRight,
    this.groupComparator,
    this.sortXAxis = false,
    this.contentPadding = const EdgeInsets.all(10),
    this.xAxisStyle = const AxisStyle(),
    this.yAxisStyle = const AxisStyle(),
    this.animation = const BarChartAnimation(),
  });

  @override
  _FancyBarChartState createState() => _FancyBarChartState();
}

class _FancyBarChartState extends State<FancyBarChart> with TickerProviderStateMixin{
  List<String> xGroups = [];
  List<double> _yValues = [];
  List<BarChartBarDataDouble> _bars= [];
  bool chartIsGrouped;

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
    var valueType = widget.rawData.values;
    if (valueType.isNotEmpty) {
      var sampleValue = valueType.first;
      if (sampleValue is Map) {
        print('This is a grouped chart');
        chartIsGrouped = true;
      } else if (sampleValue is num) {
        print('This is an ungrouped chart');
        chartIsGrouped = false;
      }
    }
    if (!chartIsGrouped) {
      xGroups = widget.rawData.keys.toList();
      if (widget.sortXAxis) {
        widget.groupComparator != null
            ? xGroups.sort(widget.groupComparator)
            : xGroups.sort();
      }
      for (String key in xGroups) {
        // TODO Add try catch?
        final double d = widget.rawData[key].toDouble();
        _yValues.add(d);
        _bars.add(BarChartBarDataDouble(group: key, data: d));
      }
      _yValueRange = [_yValues.reduce(min), _yValues.reduce(max)];
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
            xGroups: xGroups,
            bars: _bars,
            yValues: _yValues,
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
  final List<String> xGroups;
  final List<BarChartBarDataDouble> bars;
  final List<double> yValues;
  final List<double> yValueRange;
  final AxisStyle xStyle, yStyle;
  double axisAnimationFraction, barAnimationFraction;

  // Local
  int xGroupNum;
  double xSectionLength, actualLengthX, actualLengthY;
  Map<String, int> groupSectionMap = {};
  Offset _topLeft, _topRight, _bottomLeft, _bottomRight, _axisIntersection;
  Offset _axisXStartOffset, _axisXEndOffset, _axisYStartOffset, _axisYEndOffset;
  double xMin, xMax, yMin, yMax;

  BarChartPainter({
    this.startOffset,
    this.endOffset,
    this.xGroups,
    this.bars,
    this.yValues,
    this.yValueRange,
    this.xStyle,
    this.yStyle,
    this.axisAnimationFraction,
    this.barAnimationFraction,
  });

  Paint getAxisPaint(AxisStyle style) {
    return Paint()
      ..color = style.axisColor
      ..strokeWidth = style.strokeWidth
      ..strokeCap = style.strokeCap;
  }

  void adjustAxisValueRange() {
    yStyle.preferredStartValue <= yValueRange[0]
        ? yMin = yStyle.preferredStartValue
        : yMin = yValueRange[0];

    yStyle.preferredEndValue >= yValueRange[1]
        ? yMax = yStyle.preferredEndValue
        : yMax = yValueRange[1];
  }

  void drawTicksOnXAxis(Canvas canvas, AxisStyle style,) {
    final Tick tick = style.tick;
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
    List<Offset> tickPositions = [];
    for (int i = 0; i < xGroupNum + 1; i++) {
      p1 = _bottomLeft.translate(i * xSectionLength, tickPaint.strokeWidth / 2);
      p2 = p1.translate(0, tick.tickLength);
      p3 = p2.translate(0, tick.tickMargin);
      tickPositions.add(p3);
      //Draw the tick line
      canvas.drawLine(p1, p2, tickPaint);
    }
    for (int i = 0; i < xGroupNum; i++) {
      final String groupName = xGroups[i];
      _textPainter.text = TextSpan(
        text: '$groupName',
        style: tickTextStyle,
      );
      _textPainter.layout();
      //Draw the tick value text
      _textPainter.paint(canvas, _bottomLeft.translate(
        i * xSectionLength + (xSectionLength - _textPainter.width) / 2,
        tick.tickLength + tick.tickMargin
      ));
    }
    // TODO Maybe allow unit at the last tick?
  }

  void drawTicksOnYAxis(Canvas canvas, AxisStyle style, Offset py,) {
    final Tick tick = style.tick;
    final double lengthPerTick = actualLengthY / (style.numTicks - 1);
    final double valuePerTick = (yMax - yMin) / (style.numTicks - 1);
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

    Offset p1, p2, p3, p4;
    if (!tick.onlyShowTicksAtTwoSides) {
      int _numTicksBetween = style.numTicks - 2;
      for (int i = 1; i < _numTicksBetween + 1; i++) {
        p1 = _bottomLeft.translate(-tickPaint.strokeWidth / 2, -(i * lengthPerTick));
        p2 = p1.translate(-tick.tickLength, 0);
        p3 = p2.translate(-tick.tickMargin, 0);

        //Draw the tick line
        canvas.drawLine(p1, p2, tickPaint);
        final String value = (yMin + i * valuePerTick).toStringAsFixed(tick.tickDecimal);
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
    p1 = _bottomLeft.translate(-(tickPaint.strokeWidth / 2), 0);
    p2 = p1.translate(-(tick.tickLength), 0);
    p3 = p2.translate(-tick.tickMargin, 0);
    canvas.drawLine(p1, p2, tickPaint);
    final String startText = yMin.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(
      text: '$startText',
      style: tickTextStyle,
    );
    _textPainter.layout();
    _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));

    //Draw end value
    p1 = _topLeft.translate(-(tickPaint.strokeWidth / 2), 0);
    p2 = p1.translate(-(tick.tickLength), 0);
    p3 = p2.translate(-tick.tickMargin, 0);
    canvas.drawLine(p1, p2, tickPaint);
    String endText;
    //If the user want last tick to show unit as text
    endText = yMax.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(
      text: '$endText',
      style: tickTextStyle,
    );
    _textPainter.layout();
    p4 = p3.translate(-(_textPainter.width), -(_textPainter.height / 2));
    _textPainter.paint(canvas, p4);
    final Size endLabelSize = Size(_textPainter.width, _textPainter.height);

    // Draw axis label
    _textPainter.text = TextSpan(
      text: '${style.label}',
      style: tickTextStyle,
    );
    _textPainter.layout();
    canvas.save();
    canvas.rotate(1.5708);
    py = py.translate(-_textPainter.width / 2, endLabelSize.width + tick.tickMargin);
    _textPainter.paint(canvas, py);
    canvas.restore();
  }

  void drawData(Canvas canvas, double yUnitPerPixel) {
    final BarChartBarStyle barStyle = const BarChartBarStyle();
    //This is the bar paint
    Paint paint = Paint()
      ..strokeWidth = 2;
    //Draw data as bars on grid
    for (BarChartBarDataDouble bar in bars) {
      BarChartBarStyle style = bar.style;
      String group = bar.group;
      double d = bar.data;
      if (style == null) {
        // If individual bar style is not set, then it comes from parent
        style = barStyle;
      }
      paint..color = style.color;
      int section = groupSectionMap[group];
      // Temp 80% width
      double x1FromBottomLeft = section * xSectionLength + xSectionLength * 0.1;
      double x2FromBottomLeft = x1FromBottomLeft + xSectionLength * 0.8;
      double y1FromBottomLeft = (d - yMin) / yUnitPerPixel;

      //double y2FromBottomLeft = y1FromBottomLeft + (bar.y2 - bar.y1) / yUnitPerPixel;
      //print(y1FromBottomLeft);
      //print(y2FromBottomLeft);
      //print(-y2FromBottomLeft * barAnimationFraction);
      Rect rect = Rect.fromPoints(
        // Top Left
        _bottomLeft.translate(x1FromBottomLeft, -y1FromBottomLeft * barAnimationFraction),
        // Bottom Right
        _bottomLeft.translate(x2FromBottomLeft, 0)
      );
      if (style.shape == BarChartBarShape.Rectangle) { canvas.drawRect(rect, paint); }
      if (style.shape == BarChartBarShape.RoundedRectangle) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: style.topLeft,
            topRight: style.topRight,
            bottomLeft: style.bottomLeft,
            bottomRight: style.bottomRight,
          ),
          paint,
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    xGroupNum = xGroups.length;
    // DEBUG USE ONLY
    //canvas.drawRect(Offset(0, 0) & size, Paint()..color = Colors.white);
    //print(axisAnimationFraction);

    //Get actual size available for data
    actualLengthX = size.width - startOffset.dx - endOffset.dx;
    actualLengthY = size.height - startOffset.dy - endOffset.dy;
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
    adjustAxisValueRange();

    // Draw X Axis
    _axisXStartOffset = _bottomLeft.translate(0, - xStyle.shift);
    _axisXEndOffset = _bottomRight.translate(0, - xStyle.shift);
    double axisXLength = _axisXEndOffset.dx - _axisXStartOffset.dx;
    if (xStyle.visible) {
      canvas.drawLine(_axisXStartOffset, _axisXStartOffset.translate(axisXLength * axisAnimationFraction, 0), getAxisPaint(xStyle));
    }
    // Adjust size according to stroke taken by the axis
    double strokeWidth = xStyle.strokeWidth / 2;
    _bottomLeft = _bottomLeft.translate(0, - strokeWidth);
    _bottomRight = _bottomRight.translate(0, - strokeWidth);
    actualLengthY -= strokeWidth;

    // Draw Y Axis
    if (yStyle.visible) {
      _axisYStartOffset = _bottomLeft.translate(yStyle.shift, 0);
      _axisYEndOffset = _topLeft.translate(yStyle.shift, 0);
      double axisYLength = _axisYEndOffset.dy - _axisYStartOffset.dy;
      canvas.drawLine(_axisYStartOffset, _axisYStartOffset.translate(0, axisYLength * axisAnimationFraction), getAxisPaint(yStyle));
      // Adjust size according to stroke taken by the axis
      double strokeWidth = yStyle.strokeWidth / 2;
      _bottomLeft = _bottomLeft.translate(strokeWidth, 0);
      _topLeft = _topLeft.translate(strokeWidth, 0);
      actualLengthX -= strokeWidth;
    }

    // Calculate the x length of each group, and allocate area
    xSectionLength = actualLengthX / xGroupNum;
    for (int i = 0; i < xGroupNum; i++) { groupSectionMap[xGroups[i]] = i; }
    // This might be useful later
    actualGridSize = Size(actualLengthX, actualLengthY);
    //Draw ticks on X Axis
    if (xStyle.visible && axisAnimationFraction == 1) { drawTicksOnXAxis(canvas, xStyle); }

    // Draw ticks on Y Axis
    if (yStyle.visible && axisAnimationFraction == 1) {
      final Tick tick = yStyle.tick;
      Offset py = Offset(0, 0).translate(
          endOffset.dy + actualLengthY / 2,
          -(size.width - endOffset.dx - actualLengthX - tick.tickMargin - tick.tickLength - yStyle.strokeWidth / 2)
      );
      drawTicksOnYAxis(canvas, yStyle, py);
    }

    //Calculate unitPerPixel then draw data
    if (axisAnimationFraction == 1) {
      double yUnitPerPixel;
      yUnitPerPixel = (yMax - yMin) / actualLengthY;
      drawData(canvas, yUnitPerPixel);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return (oldDelegate.axisAnimationFraction != axisAnimationFraction || oldDelegate.barAnimationFraction != barAnimationFraction);
  }
}