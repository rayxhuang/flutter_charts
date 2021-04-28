import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartLegendHorizontal extends StatelessWidget {
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  ChartLegendHorizontal({
    @required this.parentSize,
    this.widthInPercentage = 0.7,
    this.heightInPercentage = 0.1,
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