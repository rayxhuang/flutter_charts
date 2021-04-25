import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'axis.dart';

class BarChart extends StatefulWidget {
  final BarChartData barChartData;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry contentPadding;
  final ShapeBorder outerShape;
  final bool showXAxis;
  final bool showYAxis;
  final BaseAxis axisX;
  final BaseAxis axisY;

  BarChart({
    @required this.barChartData,
    @required this.width,
    @required this.height,
    this.margin = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.all(10),
    this.outerShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    this.showXAxis = true,
    this.showYAxis = true,
    this.axisX = const AxisWithNum.X(),
    this.axisY = const AxisWithNum.Y(),
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
      // Temp
      startOffset: Offset(20, 20),
      showXAxis: widget.showXAxis,
      showYAxis: widget.showYAxis,
      axisX: widget.axisX,
      axisY: widget.axisY,
      barChartData: widget.barChartData,
    );
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
  final bool showXAxis, showYAxis;
  final BaseAxis axisX, axisY;
  final BarChartData barChartData;
  Offset absoluteStart, startOffset;
  // AxisThemeData axisXStyle, axisYStyle;
  // Offset axisXStartOffset, axisXEndOffset, axisYStartOffset, axisYEndOffset;
  // Paint paintX, paintY;

  BarChartPainter({
    this.startOffset,
    this.showXAxis,
    this.showYAxis,
    this.axisX,
    this.axisY,
    this.barChartData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print('Called paint function');
    // Draw X Axis
    if (showXAxis) {
      final axisXStyle = axisX.style;
      final axisXStartOffset = Offset(
        axisXStyle.startMarginX,
        size.height - axisXStyle.startMarginY,
      );
      final axisXEndOffset = Offset(
        size.width - axisXStyle.endMarginX,
        size.height - axisXStyle.endMarginY,
      );
      final paintX = Paint()
        ..color = axisXStyle.color
        ..strokeWidth = axisXStyle.strokeWidth
        ..strokeCap = axisXStyle.strokeCap;
      drawAxis(canvas, paintX, axisX, axisXStartOffset, axisXEndOffset);
    }

    // Draw Y Axis
    if (showYAxis) {
      final axisYStyle = axisY.style;
      final axisYStartOffset = Offset(
        axisYStyle.startMarginX,
        size.height - axisYStyle.startMarginY,
      );
      final axisYEndOffset = Offset(
        axisYStyle.endMarginX,
        axisYStyle.endMarginY,
      );
      final paintY = Paint()
        ..color = axisYStyle.color
        ..strokeWidth = axisYStyle.strokeWidth
        ..strokeCap = axisYStyle.strokeCap;
      drawAxis(canvas, paintY, axisY, axisYStartOffset, axisYEndOffset);
    }

    // Draw Data
    if (barChartData.data.isNotEmpty) {
      print(size);
      Map data = barChartData.data;
      double xUnit;
      if (showXAxis) {
        double canvasLength = size.width - axisX.totalMargin;
        xUnit = axisX.valueRange / canvasLength;
        // print(canvasLength);
        // print(axisX.valueRange);
        print(xUnit);
      }
      double yUnit;
      if (showYAxis) {
        double canvasHeight = size.height - axisY.totalMargin;
        yUnit = axisY.valueRange / canvasHeight;
        // print(canvasHeight);
        // print(axisY.valueRange);
        print(yUnit);
      }
      final Offset bottomLeftPoint = Offset(0, size.height);
      absoluteStart = bottomLeftPoint.translate(startOffset.dx, -startOffset.dy);
      print(absoluteStart);
      Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
      List<Offset> points = [];
      data.forEach((x, y) {
        print('$x,$y');
        Offset p = absoluteStart.translate(x / xUnit, -(y / yUnit));
        print(p);
        points.add(p);
        print(points);
      });
      canvas.drawPoints(PointMode.points, points, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void drawAxis(Canvas canvas, Paint paint, BaseAxis axis, Offset start, Offset end,) {
    // Draw the axis line
    canvas.drawLine(start, end, paint);

    // Draw the ticks if any
    double axisLength;
    axis.type == AxisType.XWithNum
        ? axisLength = end.dx - start.dx
        : axisLength = start.dy - end.dy;
    int tickUnitLength = axisLength ~/ axis.style.numTicks;
    double tickUnitValue = (axis.endValue - axis.startValue) / axis.style.numTicks;
    for (int i = 0; i < axis.style.numTicks + 1; i++) {
      // Draw ticks on axis
      Offset p1, p2;
      if (axis.type == AxisType.XWithNum) {
        p1 = start.translate((i * tickUnitLength).toDouble(), 0);
        p2 = p1.translate(0, axis.style.tick.tickLength);
      } else {
        p1 = start.translate(0, - (i * tickUnitLength).toDouble());
        p2 = p1.translate(-axis.style.tick.tickLength, 0);
      }
      canvas.drawLine(p1, p2, paint);

      final String label = (axis.startValue + i * tickUnitValue).toStringAsFixed(axis.style.tick.tickDecimal);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$label',
          style: TextStyle(color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        //TODO
      );

      // This aligns the text to the center of the tick
      final sizeOfLabel = textPainter.size;
      if (axis.type == AxisType.XWithNum) {
        p2 = p2.translate(
          -(sizeOfLabel.width / 2),
          axis.style.tick.tickMargin.abs() + axis.style.tick.tickLength.abs(),
        );
      } else {
        p2 = p2.translate(
          -(sizeOfLabel.width + axis.style.tick.tickMargin.abs() + axis.style.tick.tickLength.abs()),
          -(sizeOfLabel.height / 2),
        );
      }
      textPainter.paint(canvas, p2);
    }
  }
}