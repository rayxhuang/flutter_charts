import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/components/canvas/chart_mini_canvas_painter.dart';

@immutable
class ChartCanvasMini extends StatelessWidget {
  final Size containerSize;

  const ChartCanvasMini({
    @required this.containerSize,
  });

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;
    final Size canvasSize = Size(displayInfo.xTotalLength, displayInfo.canvasHeight);
    return SizedBox.fromSize(
      size: containerSize,
      child: FittedBox(
        fit: BoxFit.fill,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: MiniCanvasPainter(
              size: canvasSize,
              displayInfo: displayInfo,
              dataModel: dataModel,
              style: style,
            ),
            size: canvasSize,
          ),
        ),
      ),
    );
  }
}