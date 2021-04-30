import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/modular_fancy_bar_chart.dart';

//enum BarChartType {Ungrouped, Grouped, GroupedStacked}

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
  }) : assert(rawData != null);

  @override
  _FancyBarChartState createState() => _FancyBarChartState();
}

class _FancyBarChartState extends State<FancyBarChart> with TickerProviderStateMixin{
  BarChartStyle style;
  List<String> xGroups = [], subGroups = [];
  Map<String, Color> subGroupColors;
  List<double> _yValues = [];
  List<BarChartDataDouble> _bars = [];
  List<BarChartDataDoubleGrouped> _groupedBars = [];
  bool chartIsGrouped;

  List<double> _yValueRange = [];
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  ScrollController _scrollController;
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      print(widget.width * 1.5);
      print(_scrollController.offset);
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });
    style = widget.style;
    subGroupColors = style.subGroupColors ?? {};

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
        chartIsGrouped = true;
      } else if (sampleValue is num) {
        chartIsGrouped = false;
      }
      xGroups = widget.rawData.keys.toList();
      if (style.sortXAxis) {
        style.groupComparator != null
            ? xGroups.sort(style.groupComparator)
            : xGroups.sort();
      }

      double maxTotalValueOverall = 0;
      if (!chartIsGrouped) {
        for (String key in xGroups) {
          // TODO Add try catch?
          final double d = widget.rawData[key].toDouble();
          _yValues.add(d);
          _bars.add(BarChartDataDouble(group: key, data: d, style: style.barStyle));
        }
      } else {
        for (String key in xGroups) {
          double maxTotalValue = 0;
          final Map<String, num> groupData = widget.rawData[key];
          final List<BarChartDataDouble> dataInGroup = [];
          groupData.forEach((subgroup, value) {
            maxTotalValue += value;
            subGroups.add(subgroup);
            dataInGroup.add(BarChartDataDouble(group: subgroup, data: value.toDouble()));
            _yValues.add(value.toDouble());
          });
          _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
          if (maxTotalValue >= maxTotalValueOverall) { maxTotalValueOverall = maxTotalValue; }
        }
        subGroups = subGroups.toSet().toList();
        final List<String> existedGroupColor = subGroupColors.keys.toList();
        for (String subGroup in subGroups) {
          if (!existedGroupColor.contains(subGroup)) {
            // Generate random color for subgroup if not specified
            // TODO Better function?
            subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
          }
        }
      }
      _yValueRange = [_yValues.reduce(min), _yValues.reduce(max), maxTotalValueOverall];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: style.contentPadding,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: CustomPaint(
              size: Size(widget.width * 1.5, widget.height),
              painter: BarChartPainter(
                startOffset: style.gridAreaOffsetFromBottomLeft,
                endOffset: style.gridAreaOffsetFromTopRight,
                xGroups: xGroups,
                subGroups: subGroups,
                subGroupColors: subGroupColors,
                type: chartIsGrouped
                    ? widget.style.isStacked
                    ? BarChartType.GroupedStacked
                    : BarChartType.Grouped
                    : BarChartType.Ungrouped,
                bars: _bars,
                groupedBars: _groupedBars,
                yValues: _yValues,
                yValueRange: _yValueRange,
                style: widget.style,
                axisAnimationFraction: axisAnimationValue,
                barAnimationFraction: dataAnimationValue,
                scrollOffset: scrollOffset,
              ),
            ),
          ),
          Padding(
            padding: widget.style.contentPadding,
            child: CustomPaint(
              painter: BoringPainter(
                startOffset: style.gridAreaOffsetFromBottomLeft,
                endOffset: style.gridAreaOffsetFromTopRight,
                yValues: _yValues,
                yValueRange: _yValueRange,
                xStrokeWidth: widget.style.xAxisStyle.strokeWidth / 2,
                style: widget.style.yAxisStyle,
              )
            )
          ),
        ]
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _axisAnimationController.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }
}

class BoringPainter extends CustomPainter {
  final Offset startOffset, endOffset;
  final List<double> yValues;
  final List<double> yValueRange;
  final AxisStyle style;
  final double xStrokeWidth;

  const BoringPainter({
    this.startOffset,
    this.endOffset,
    this.yValues,
    this.yValueRange,
    this.style,
    this.xStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0,0), Offset(0, 200), Paint()..color = Colors.lightBlueAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

class BarChartPainter extends CustomPainter {
  final Offset startOffset, endOffset;
  final BarChartType type;
  final List<String> xGroups, subGroups;
  final BarChartStyle style;
  final Map<String, Color> subGroupColors;
  final List<BarChartDataDouble> bars;
  final List<BarChartDataDoubleGrouped> groupedBars;
  final List<double> yValues;
  final List<double> yValueRange;
  double axisAnimationFraction, barAnimationFraction;

  final double scrollOffset;

  // Local
  AxisStyle xStyle, yStyle;
  BarChartBarStyle barStyle;
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
    this.subGroups,
    this.subGroupColors,
    this.type,
    this.bars,
    this.groupedBars,
    this.yValues,
    this.yValueRange,
    this.style,
    this.axisAnimationFraction,
    this.barAnimationFraction,
    this.scrollOffset,
  }) : assert((bars != null || groupedBars != null));

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

    if (type != BarChartType.GroupedStacked) {
      yStyle.preferredEndValue >= yValueRange[1]
          ? yMax = yStyle.preferredEndValue
          : yMax = yValueRange[1];
    } else {
      yStyle.preferredEndValue >= yValueRange[2]
          ? yMax = yStyle.preferredEndValue
          : yMax = yValueRange[2];
    }
  }

  void drawTicksOnXAxis(Canvas canvas, AxisStyle style,) {
    final TickStyle tick = style.tick;
    final Paint tickPaint = Paint()
      ..strokeWidth = style.strokeWidth
      ..strokeCap = style.strokeCap
      ..color = tick.tickColor;
    final TextStyle tickTextStyle = tick.labelTextStyle;
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
    double endLabelSize = _textPainter.height;
    _textPainter.text = TextSpan(
      text: '${style.label.text}',
      style: style.label.textStyle,
    );
    _textPainter.layout();
    _textPainter.paint(canvas, p3.translate(-((actualLengthX + _textPainter.width) / 2), endLabelSize));
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
    final TextStyle tickTextStyle = tick.labelTextStyle;
    final TextPainter _textPainter = TextPainter(
      text: TextSpan(),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();

    Offset p1, p2, p3, p4;
    if (!tick.onlyShowTicksAtTwoSides) {
      int _numTicksBetween = style.numTicks - 2;
      for (int i = 1; i < _numTicksBetween + 1; i++) {
        //p1 = _bottomLeft.translate(-tickPaint.strokeWidth / 2, -(i * lengthPerTick));
        p1 = _bottomLeft.translate(-tickPaint.strokeWidth / 2 + scrollOffset, -(i * lengthPerTick));
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
    p1 = _bottomLeft.translate(-(tickPaint.strokeWidth / 2) + scrollOffset, 0);
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
    p1 = _topLeft.translate(-(tickPaint.strokeWidth / 2) + scrollOffset, 0);
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
      text: '${style.label.text}',
      style: style.label.textStyle,
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
      for (BarChartDataDouble bar in bars) {
        BarChartBarStyle _barStyle = bar.style;
        if (_barStyle == null) { _barStyle = barStyle; }
        paint..color = _barStyle.color;
        int section = groupSectionMap[bar.group];
        double x1FromBottomLeft = section * xSectionLength + style.groupMargin / 2;
        double x2FromBottomLeft = x1FromBottomLeft + xSectionLength - style.groupMargin;
        double y1FromBottomLeft = (bar.data - yMin) / yUnitPerPixel;
        drawRect(canvas, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint);
      }
    } else if (type == BarChartType.Grouped) {
      for (BarChartDataDoubleGrouped dataInGroup in groupedBars) {
        int section = groupSectionMap[dataInGroup.mainGroup];
        List<BarChartDataDouble> data = dataInGroup.dataList;
        for (int i = 0; i < data.length; i++) {
          BarChartBarStyle _barStyle = barStyle;
          // Grouped Data must use grouped Color
          paint..color = subGroupColors[data[i].group];
          double barWidth = (xSectionLength -  style.groupMargin) / data.length;
          double x1FromBottomLeft = section * xSectionLength + style.groupMargin / 2 + i * barWidth;
          double x2FromBottomLeft = x1FromBottomLeft + barWidth;
          double y1FromBottomLeft = (data[i].data - yMin) / yUnitPerPixel;
          drawRect(canvas, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint);
        }
      }
    } else if (type == BarChartType.GroupedStacked) {
      // Values cannot be negative
      for (BarChartDataDoubleGrouped dataInGroup in groupedBars) {
        int section = groupSectionMap[dataInGroup.mainGroup];
        List<BarChartDataDouble> data = dataInGroup.dataList;
        double totalHeight = 0;
        data.forEach((data) { totalHeight += data.data; });
        double previousYValue = 0;
        for (int i = data.length - 1; i  >= 0; i--) {
          BarChartBarStyle _barStyle = barStyle;
          // Grouped Data must use grouped Color
          paint..color = subGroupColors[data[i].group];
          double x1FromBottomLeft = section * xSectionLength + style.groupMargin / 2;
          double x2FromBottomLeft = x1FromBottomLeft + xSectionLength - style.groupMargin;
          double y1FromBottomLeft = (totalHeight - yMin - previousYValue) / yUnitPerPixel;
          drawRect(canvas, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint, last: false);
          previousYValue += data[i].data;
        }
      }
    }
  }

  void drawRect(Canvas canvas, double x1, double x2, double y1, BarChartBarStyle style, Paint paint, {bool last = true}) {
    Rect rect = Rect.fromPoints(
      _bottomLeft.translate(x1, -y1 * barAnimationFraction),
      _bottomLeft.translate(x2, 0)
    );
    if (style.shape == BarChartBarShape.RoundedRectangle && last) {
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
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  void drawTitle(Canvas canvas, TextPainter _textPainter) {
    final Paint titlePaint = Paint()
      ..strokeWidth = 3
      ..color = style.title.textStyle.color;
    final Offset p = _topLeft.translate(actualLengthX / 2 - _textPainter.width / 2, -(_textPainter.height + 5));
    _textPainter.paint(canvas, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    xStyle = style.xAxisStyle;
    yStyle = style.yAxisStyle;
    barStyle = style.barStyle;
    xGroupNum = xGroups.length;
    // DEBUG USE ONLY
    //canvas.drawRect(Offset(0, 0) & size, Paint()..color = Colors.white);
    //print(axisAnimationFraction);

    //Get actual size available for data
    actualLengthX = size.width - startOffset.dx - endOffset.dx;
    actualLengthY = size.height - startOffset.dy - endOffset.dy;
    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: '${style.title.text}',
        style: style.title.textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    actualLengthY -= titlePainter.height + 5;
    Size actualGridSize = Size(actualLengthX, actualLengthY);

    //Set four useful points
    _topLeft = Offset(0, 0).translate(startOffset.dx, endOffset.dy + titlePainter.height + 5);
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
    if (yStyle.visible) { canvas.drawLine(_axisYStartOffset.translate(scrollOffset, 0), _axisYStartOffset.translate(scrollOffset, axisYLength * axisAnimationFraction), getAxisPaint(yStyle)); }
    //if (yStyle.visible) { canvas.drawLine(_axisYStartOffset, _axisYStartOffset.translate(0, axisYLength * axisAnimationFraction), getAxisPaint(yStyle)); }
    // Adjust size according to stroke taken by the axis
    _bottomLeft = _bottomLeft.translate(yStyle.strokeWidth / 2, 0);
    _topLeft = _topLeft.translate(yStyle.strokeWidth / 2, 0);
    actualLengthX -= yStyle.strokeWidth / 2;

    // Draw Bar Chart Title
    drawTitle(canvas, titlePainter);

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
          endOffset.dy + titlePainter.height + 5 + actualLengthY / 2,
          -(size.width - endOffset.dx - actualLengthX - tick.tickMargin - tick.tickLength - yStyle.strokeWidth / 2 + scrollOffset)
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
    return (
        oldDelegate.axisAnimationFraction != axisAnimationFraction
        || oldDelegate.barAnimationFraction != barAnimationFraction
        || oldDelegate.type != type
        || oldDelegate.scrollOffset != scrollOffset
    );
  }
}