import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartCanvas extends StatefulWidget {
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  ChartCanvas({
    @required this.parentSize,
    this.widthInPercentage = 0.7,
    this.heightInPercentage = 0.7,
  });

  Size get size => Size(parentSize.width * widthInPercentage, parentSize.height * heightInPercentage);

  @override
  _ChartCanvasState createState() => _ChartCanvasState();
}

class _ChartCanvasState extends State<ChartCanvas> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      width: widget.parentSize.width * widget.widthInPercentage,
      height: widget.parentSize.height * widget.heightInPercentage,
    );
  }
}