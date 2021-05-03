import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

class ChartLegendHorizontal extends StatelessWidget {
  final BarChartLabel label;
  final Color color;
  final double width;

  ChartLegendHorizontal({
    @required this.width,
    @required this.label,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: size.height,
      // TODO wrap in a tooltip
      child: Tooltip(
        message: label.text,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: color, size: 8,),
            SizedBox(width: 5,),
            Expanded(
              child: Text(
                label.text,
                style: label.textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Size get size => Size(width, getHeight(label));

  static double getHeight(BarChartLabel label) {
    // TODO safe to use sample character?
    TextPainter painter = TextPainter(
      text: TextSpan(text: 'I', style: label.textStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return painter.height + 5;
  }
}

class ChartLegendVertical extends StatelessWidget {
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  ChartLegendVertical({
    @required this.parentSize,
    this.widthInPercentage = 0.1,
    this.heightInPercentage = 0.7,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      width: parentSize.width * widthInPercentage,
      height: parentSize.height * heightInPercentage,
    );
  }

  Size get size => Size(parentSize.width * widthInPercentage, parentSize.height * heightInPercentage);
}