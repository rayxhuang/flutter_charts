import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

enum BarChartType {Ungrouped, Grouped}

class FancyBarChart extends StatefulWidget {
  final Map<String, dynamic> rawData;
  final double width;
  final double height;
  final BarChartStyle style;

  FancyBarChart({
    @required this.rawData,
    @required this.width,
    @required this.height,
    this.style,
  });

  @override
  _FancyBarChartState createState() => _FancyBarChartState();
}

class _FancyBarChartState extends State<FancyBarChart> with TickerProviderStateMixin{
  BarChartStyle style;
  List<String> xGroups = [];
  List<double> _yValues = [];
  List<BarChartBarDataDouble> _bars = [];
  List<BarChartBarDataDoubleGrouped> _groupedBars = [];
  bool chartIsGrouped;

  List<double> _yValueRange = [];
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  @override
  void initState() {
    super.initState();
    style = widget.style;

    analyseData();

    final BarChartAnimation animation = style.animation;
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

    xGroups = widget.rawData.keys.toList();
    if (style.sortXAxis) {
      style.groupComparator != null
          ? xGroups.sort(style.groupComparator)
          : xGroups.sort();
    }
    if (!chartIsGrouped) {
      for (String key in xGroups) {
        // TODO Add try catch?
        final double d = widget.rawData[key].toDouble();
        _yValues.add(d);
        _bars.add(BarChartBarDataDouble(group: key, data: d, style: style.barStyle));
      }
    } else {
      for (String key in xGroups) {
        final Map<String, num> groupData = widget.rawData[key];
        final List<BarChartBarDataDouble> dataInGroup = [];
        groupData.values.forEach((d) { dataInGroup.add(BarChartBarDataDouble(group: key, data: d.toDouble())); _yValues.add(d.toDouble()); });
        _groupedBars.add(BarChartBarDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
      }
    }
    _yValueRange = [_yValues.reduce(min), _yValues.reduce(max)];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Padding(
        padding: style.contentPadding,
        child: CustomPaint(
          painter: BarChartPainter(
            startOffset: style.gridAreaOffsetFromBottomLeft,
            endOffset: style.gridAreaOffsetFromTopRight,
            xGroups: xGroups,
            type: chartIsGrouped ? BarChartType.Grouped : BarChartType.Ungrouped,
            bars: _bars,
            groupedBars: _groupedBars,
            yValues: _yValues,
            yValueRange: _yValueRange,
            xStyle: style.xAxisStyle,
            yStyle: style.yAxisStyle,
            barStyle: style.barStyle,
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
  final BarChartType type;
  final List<String> xGroups;
  final List<BarChartBarDataDouble> bars;
  final List<BarChartBarDataDoubleGrouped> groupedBars;
  final List<double> yValues;
  final List<double> yValueRange;
  final AxisStyle xStyle, yStyle;
  final BarChartBarStyle barStyle;
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
    this.type,
    this.bars,
    this.groupedBars,
    this.yValues,
    this.yValueRange,
    this.xStyle,
    this.yStyle,
    this.barStyle,
    this.axisAnimationFraction,
    this.barAnimationFraction,
  }) : assert(!(bars == null && groupedBars == null));

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
    final TickStyle tick = style.tick;
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
    final TickStyle tick = style.tick;
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
    //This is the bar paint
    Paint paint = Paint()
      ..strokeWidth = 2;
    //Draw data as bars on grid
    if (type == BarChartType.Ungrouped) {
      for (BarChartBarDataDouble bar in bars) {
        BarChartBarStyle style = bar.style;
        String group = bar.group;
        double d = bar.data;
        if (style == null) { style = barStyle; }
        paint..color = style.color;
        int section = groupSectionMap[group];
        // Temp 80% width
        double x1FromBottomLeft = section * xSectionLength + xSectionLength * 0.1;
        double x2FromBottomLeft = x1FromBottomLeft + xSectionLength * 0.8;
        double y1FromBottomLeft = (d - yMin) / yUnitPerPixel;
        Rect rect = Rect.fromPoints(
          _bottomLeft.translate(x1FromBottomLeft, -y1FromBottomLeft * barAnimationFraction),
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
    } else if (type == BarChartType.Grouped) {
      for (BarChartBarDataDoubleGrouped dataInGroup in groupedBars) {
        int section = groupSectionMap[dataInGroup.mainGroup];
        List<BarChartBarDataDouble> data = dataInGroup.dataList;
        int j = 0;
        for (BarChartBarDataDouble bar in data) {
          BarChartBarStyle style = bar.style;
          String group = bar.group;
          double d = bar.data;
          if (style == null) { style = barStyle; }
          paint..color = style.color;
          // Temp 80% width
          double barWidth = xSectionLength * 0.8 / data.length;
          double x1FromBottomLeft = section * xSectionLength + xSectionLength * 0.1 + j * barWidth;
          double x2FromBottomLeft = x1FromBottomLeft + barWidth;
          double y1FromBottomLeft = (d - yMin) / yUnitPerPixel;
          Rect rect = Rect.fromPoints(
              _bottomLeft.translate(x1FromBottomLeft, -y1FromBottomLeft * barAnimationFraction),
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
          j++;
        }
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
    if (xStyle.visible) { canvas.drawLine(_axisXStartOffset, _axisXStartOffset.translate(axisXLength * axisAnimationFraction, 0), getAxisPaint(xStyle)); }
    // Adjust size according to stroke taken by the axis
    _bottomLeft = _bottomLeft.translate(0, - xStyle.strokeWidth / 2);
    _bottomRight = _bottomRight.translate(0, - xStyle.strokeWidth / 2);
    actualLengthY -= xStyle.strokeWidth / 2;

    // Draw Y Axis
    _axisYStartOffset = _bottomLeft.translate(yStyle.shift, 0);
    _axisYEndOffset = _topLeft.translate(yStyle.shift, 0);
    double axisYLength = _axisYEndOffset.dy - _axisYStartOffset.dy;
    if (yStyle.visible) { canvas.drawLine(_axisYStartOffset, _axisYStartOffset.translate(0, axisYLength * axisAnimationFraction), getAxisPaint(yStyle)); }
    // Adjust size according to stroke taken by the axis
    _bottomLeft = _bottomLeft.translate(yStyle.strokeWidth / 2, 0);
    _topLeft = _topLeft.translate(yStyle.strokeWidth / 2, 0);
    actualLengthX -= yStyle.strokeWidth / 2;


    // Calculate the x length of each group, and allocate area
    xSectionLength = actualLengthX / xGroupNum;
    for (int i = 0; i < xGroupNum; i++) { groupSectionMap[xGroups[i]] = i; }
    // This might be useful later
    actualGridSize = Size(actualLengthX, actualLengthY);
    //Draw ticks on X Axis
    if (xStyle.visible && axisAnimationFraction == 1) { drawTicksOnXAxis(canvas, xStyle); }

    // Draw ticks on Y Axis
    if (yStyle.visible && axisAnimationFraction == 1) {
      final TickStyle tick = yStyle.tick;
      Offset py = Offset(0, 0).translate(
          endOffset.dy + actualLengthY / 2,
          -(size.width - endOffset.dx - actualLengthX - tick.tickMargin - tick.tickLength - yStyle.strokeWidth / 2)
      );
      drawTicksOnYAxis(canvas, yStyle, py);
    }

    //Calculate unitPerPixel then draw data
    double yUnitPerPixel;
    yUnitPerPixel = (yMax - yMin) / actualLengthY;
    drawData(canvas, yUnitPerPixel);
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return (oldDelegate.axisAnimationFraction != axisAnimationFraction || oldDelegate.barAnimationFraction != barAnimationFraction);
  }
}