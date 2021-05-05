import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';

@immutable
class SplitCanvas extends StatelessWidget {
  final BarChartDataDoubleGrouped data;
  final BarChartStyle style;
  final Size size;
  final double yUnitPerPixel;
  final double yMin;
  final Map<String, Color> subGroupColors;
  final double barAnimationFraction;

  const SplitCanvas({
    this.data,
    this.style,
    this.size,
    this.yUnitPerPixel,
    this.yMin,
    this.subGroupColors,
    this.barAnimationFraction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SplitPainter(data, style, yUnitPerPixel, yMin, subGroupColors, barAnimationFraction),
      size: size,
    );
  }
}

@immutable
class SplitPainter extends CustomPainter{
  final BarChartDataDoubleGrouped data;
  final BarChartStyle style;
  final double yUnitPerPixel;
  final double yMin;
  final Map<String, Color> subGroupColors;
  final double barAnimationFraction;
  const SplitPainter(this.data, this.style, this.yUnitPerPixel, this.yMin, this.subGroupColors, this.barAnimationFraction);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    for (int i = 0; i < data.dataList.length; i++) {
      BarChartBarStyle _barStyle = style.barStyle;
      // Grouped Data must use grouped Color
      paint..color = subGroupColors[data.dataList[i].group];
      double inGroupMargin = i == 0
          ? 0
          : style.barStyle.barInGroupMargin;
      double x1FromBottomLeft = i * style.barStyle.barWidth + style.groupMargin + inGroupMargin * i;
      double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
      double y1FromBottomLeft = (data.dataList[i].data - yMin) / yUnitPerPixel;
      drawRect(canvas, Offset(0, size.height), x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint);

      // if (!isMini && barAnimationFraction == 1) {
      //   drawValueOnBar(canvas, data[i].data.toStringAsFixed(0), bottomLeft, x1FromBottomLeft, y1FromBottomLeft);
      // }
    }
  }

  @override
  bool shouldRepaint(covariant SplitPainter oldDelegate) {
    return oldDelegate.barAnimationFraction != barAnimationFraction;
  }

  void drawRect(Canvas canvas, Offset bottomLeft, double x1, double x2, double y1, BarChartBarStyle style, Paint paint, {bool last = true}) {
    Rect rect = Rect.fromPoints(
        bottomLeft.translate(x1, -y1 * barAnimationFraction),
        bottomLeft.translate(x2, 0)
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
}
