import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

mixin StringSize {
  static TextPainter _painter = TextPainter(
      text: TextSpan(),
      textDirection: TextDirection.ltr
  );

  static double getWidthOfString(String string, TextStyle textStyle) {
    _painter..text = TextSpan(text: string, style: textStyle);
    _painter.layout();
    return string == ''
        ? 0
        : _painter.width;
  }

  static double getHeightOfString(String string, TextStyle textStyle) {
    _painter..text = TextSpan(text: string, style: textStyle);
    _painter.layout();
    return string == ''
        ? 0
        : _painter.height;
  }

  static double getWidth(BarChartLabel title) => getWidthOfString(title.text, title.textStyle);

  static double getHeight(BarChartLabel title) => getHeightOfString(title.text, title.textStyle);
}