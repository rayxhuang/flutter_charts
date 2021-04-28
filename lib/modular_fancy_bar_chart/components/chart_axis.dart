import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartAxisHorizontal extends StatelessWidget {
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  ChartAxisHorizontal({
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

class ChartAxisVertical extends StatelessWidget {
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  ChartAxisVertical({
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