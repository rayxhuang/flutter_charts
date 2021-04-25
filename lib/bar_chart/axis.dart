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
  final bool onlyShowLastTick;
  final bool useLastTickForLabel;
  final String unit;
  final Color tickColor;
  final double tickMargin;
  final int tickDecimal;
  final double tickLength;
  //Color is not usable atm


  const Tick({
    this.onlyShowLastTick = false,
    this.useLastTickForLabel = true,
    this.unit = '',
    this.tickColor = Colors.black,
    this.tickMargin = 5,
    this.tickDecimal = 0,
    this.tickLength = 0,
  });
}