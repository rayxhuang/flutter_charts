import 'package:flutter/cupertino.dart';

TextPainter painter = TextPainter(
  text: TextSpan(),
  textDirection: TextDirection.ltr
);

double getSizeOfString(String string, TextStyle textStyle, {bool isHeight = false}) {
  painter..text = TextSpan(text: string, style: textStyle);
  painter.layout();
  return string == ''
      ? 0
      : isHeight
          ? painter.height
          : painter.width;
}