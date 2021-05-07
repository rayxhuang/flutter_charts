import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchable/touchable.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/drawingMixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

import 'chart_single_group_canvas_painter.dart';

@immutable
class GroupedBars extends StatelessWidget {
  final Size size;
  final double barWidth;
  final int groupIndex;
  final bool isSelected;
  final BarChartDataDouble barSelected;
  final double barAnimationFraction;
  final Function(int, BarChartDataDouble, TapDownDetails) onBarSelected;

  const GroupedBars({
    this.size,
    this.barWidth,
    this.groupIndex,
    this.isSelected,
    this.barSelected,
    this.barAnimationFraction,
    this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();
    return CanvasTouchDetector(
      builder: (BuildContext context) {
        return CustomPaint(
          painter: SingleGroupDataPainter(
            context: context,
            dataModel: dataModel,
            dataIndex: groupIndex,
            style: style,
            xSectionLength: size.width,
            barWidth: barWidth,
            barAnimationFraction: barAnimationFraction,
            onBarSelected: (data, details) {
              onBarSelected(groupIndex, data, details);
            },
            groupSelected: isSelected ? true : false,
            barSelected: barSelected,
          ),
          size: size,
        );
      },
    );
  }
}