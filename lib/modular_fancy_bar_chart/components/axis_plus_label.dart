import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

import 'chart_axis.dart';

@immutable
class AxisLabel extends StatelessWidget {
  // This widget force display the label and data
  final TextStyle textStyle;
  final double axisHeight;
  final List<double> yValueRange;
  final AxisStyle axisStyle;

  AxisLabel({
    @required this.axisHeight,
    @required this.yValueRange,
    this.axisStyle = const AxisStyle(),
    this.textStyle
  });

  Size get size => Size(getWidth(axisStyle.label.text, yValueRange[1], axisStyle), axisHeight);

  static double getWidth(String axisLabel, double axisData, AxisStyle style) {
    return labelWidth(style.label) + axisWidth(axisData, style);
  }

  static double labelWidth(BarChartLabel label) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: label.text, style: label.textStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return label.text == '' ? 0 : 5 + painter.height;
  }

  static double axisWidth(double max, AxisStyle style) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: max.toStringAsFixed(style.tick.tickDecimal), style: style.tick.labelTextStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return painter.width + style.tick.tickMargin + style.tick.tickLength;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: axisHeight,
      width: size.width,
      child: Row(
        children: [
          RotatedBox(
            // TODO 1 or 3
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
            width: axisWidth(yValueRange[1], axisStyle),
            height: axisHeight,
            child: CustomPaint(
              painter: VerticalAxisPainter(
                valueRange: yValueRange,
                axisStyle: axisStyle,
              )
            ),
          ),
        ],
      )
    );
  }
}
