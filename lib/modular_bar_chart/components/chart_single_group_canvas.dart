import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_event.dart';
import 'package:provider/provider.dart';
import 'package:touchable/touchable.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

import 'chart_single_group_canvas_painter.dart';

@immutable
class SingleGroupedCanvas extends StatelessWidget {
  final Size size;
  final double barWidth;
  final int groupIndex;
  final bool isSelected;
  final BarChartDataDouble barSelected;
  final Animation<double> dataAnimation;
  final Function(int, BarChartDataDouble, TapDownDetails) onBarSelected;

  const SingleGroupedCanvas({
    this.size,
    this.barWidth,
    this.groupIndex,
    this.isSelected,
    this.barSelected,
    this.dataAnimation,
    this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();

    final bool clickable = style.clickable;

    return Consumer<BarChartEvent>(
      builder: (context, event, child) {
        //print('in consumer: ${event.showAverageLine}');
        return CanvasTouchDetector(
          builder: (BuildContext context) => CustomPaint(
            painter: SingleGroupDataPainter(
              context: context,
              dataModel: dataModel,
              dataIndex: groupIndex,
              style: style,
              xSectionLength: size.width,
              barWidth: barWidth,
              dataAnimation: dataAnimation,
              onBarSelected: (data, details) { onBarSelected(groupIndex, data, details); },
              groupSelected: isSelected,
              barSelected: barSelected,
              showAverageLine: event.showAverageLine,
              showValueOnBar: event.showValueOnBar,
              showGridLine: event.showGridLine,
              clickable: clickable,
            ),
            size: size,
            willChange: true,
          )
        );
      },
    );
  }
}