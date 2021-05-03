import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

@immutable
class ChartTitle extends StatelessWidget {
  final BarChartLabel title;
  final double width;

  const ChartTitle({
    @required this.title,
    @required this.width,
  });

  @override
  Widget build(BuildContext context) {
    //final BarChartLabel title = context.read<BarChartStyle>().title;
    return SizedBox(
      width: width,
      height: size.height,
      child: Center(
        child: Text(
          title.text,
          style: title.textStyle,
        ),
      ),
    );
  }

  Size get size => Size(width, getHeight(title));

  static double getHeight(BarChartLabel title) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: title.text, style: title.textStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return title.text == '' ? 0 : painter.height;
  }
}