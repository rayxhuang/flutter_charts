import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:touchable/touchable.dart';

mixin Drawing {
  void drawPoint({
    @required canvas,
    @required BarChartDataDouble data,
    @required Offset center,
    @required double radius,
    @required Paint paint,
    Function(BarChartDataDouble, TapDownDetails) onBarSelected,
  }) {
    if (canvas is TouchyCanvas) {
      canvas.drawCircle(
        center,
        radius,
        paint,
        onTapDown: (details) { onBarSelected(data, details); }
      );
    } else {
      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }
  }

  void drawBar({
    @required canvas,
    @required BarChartDataDouble data,
    @required Offset bottomLeft,
    @required double x1,
    @required double x2,
    @required double y1,
    double y2 = 0,
    @required BarChartBarStyle style,
    @required Paint paint,
    double barAnimationFraction = 1,
    bool last = true,
    Function(BarChartDataDouble, TapDownDetails) onBarSelected,
  }) {
    Rect rect = Rect.fromPoints(
        bottomLeft.translate(x1, -y1 * barAnimationFraction),
        bottomLeft.translate(x2, -y2)
    );
    if (style.shape == BarChartBarShape.RoundedRectangle && last) {
      if (canvas is TouchyCanvas) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: style.topLeft,
            topRight: style.topRight,
            bottomLeft: style.bottomLeft,
            bottomRight: style.bottomRight,
          ),
          paint,
          onTapDown: (details) { onBarSelected(data, details); }
        );
      } else {
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
    } else {
      if (canvas is TouchyCanvas) {
        canvas.drawRect(
          rect,
          paint,
          onTapDown: (details) { onBarSelected(data, details); }
        );
      } else {
        canvas.drawRect(rect, paint,);
      }
    }
  }

  void drawValueOnBar({
    @required Canvas canvas,
    @required String value,
    @required Offset bottomLeft,
    @required double x1,
    @required double y1,
    @required double barWidth,
    TextStyle textStyle = const TextStyle(color: Colors.white),
  }) {
    TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        // TODO style
        style: textStyle,
      ),
      ellipsis: ' ',
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout(maxWidth: barWidth);
    valuePainter.paint(canvas, bottomLeft.translate(x1 + barWidth / 2 - valuePainter.width / 2, -y1 - valuePainter.height));
  }

  void drawBarHighlight({
    @required Canvas canvas,
    @required Offset bottomLeft,
    @required double x1,
    @required double x2,
    @required double y1,
    double y2 = 0,
    double barAnimationFraction = 1,
    bool isStacked = false,
  }) {
    final Rect rect = Rect.fromPoints(
      bottomLeft.translate(x1, -y1 * barAnimationFraction),
      bottomLeft.translate(x2, -y2)
    );
    canvas.drawRect(rect, Paint()..color = Colors.lightBlueAccent);
  }
}