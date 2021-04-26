import 'package:flutter/material.dart';

class AxisStyle {
  final double shift;
  final bool visible;
  final int numTicks;
  final Tick tick;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final double preferredStart;
  final double preferredEnd;
  final String label;

  const AxisStyle({
    this.shift = 0,
    this.visible = true,
    this.numTicks = 11,
    this.tick = const Tick(),
    this.color = Colors.black,
    this.strokeWidth = 3,
    this.strokeCap = StrokeCap.round,
    this.preferredStart,
    this.preferredEnd,
    this.label = '',
  });
}

class Tick {
  final bool onlyShowTicksAtTwoSides;
  final bool lastTickWithUnit;
  final double labelTextSize;
  final String unit;
  final Color textColor;
  final Color tickColor;
  final double tickMargin;
  final int tickDecimal;
  final double tickLength;
  //Color is not usable atm


  const Tick({
    this.onlyShowTicksAtTwoSides = false,
    this.lastTickWithUnit = true,
    this.labelTextSize = 14,
    this.unit = '',
    this.textColor = Colors.white,
    this.tickColor = Colors.white,
    this.tickMargin = 3,
    this.tickDecimal = 0,
    this.tickLength = 0,
  });
}