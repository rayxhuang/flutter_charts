import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_component_size.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_mini_canvas_painter.dart';

@immutable
class ChartCanvasMini extends StatelessWidget {
  final Size containerSize;
  final Size canvasSize;

  const ChartCanvasMini({
    @required this.containerSize,
    @required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;
    return SizedBox.fromSize(
      size: containerSize,
      child: FittedBox(
        fit: BoxFit.fill,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: MiniCanvasPainter(
              size: canvasSize,
              dataModel: dataModel,
              style: style,
              displayInfo: displayInfo,
            ),
            size: canvasSize,
          ),
        ),
      ),
    );
  }
}