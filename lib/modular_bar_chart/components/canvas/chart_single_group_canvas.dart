import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';
import 'package:touchable/touchable.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

import 'chart_single_group_canvas_painter.dart';

@immutable
class SingleGroupedCanvas extends StatelessWidget {
  final Size size;
  final int groupIndex;
  final bool isSelected;
  final BarChartDataDouble barSelected;
  final Animation<double> dataAnimation;
  final Function(int, BarChartDataDouble, TapDownDetails) onBarSelected;

  const SingleGroupedCanvas({
    this.size,
    this.groupIndex,
    this.isSelected,
    this.barSelected,
    this.dataAnimation,
    this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayInfo>(
      builder: (context, displayInfo, child) {
        final ModularBarChartData dataModel = displayInfo.dataModel;
        final BarChartStyle style = displayInfo.style;
        final bool clickable = style.clickable;
        return CanvasTouchDetector(
          builder: (BuildContext context) => CustomPaint(
            painter: SingleGroupDataPainter(
              context: context,
              dataModel: dataModel,
              dataIndex: groupIndex,
              style: style,
              displayInfo: displayInfo,
              dataAnimation: dataAnimation,
              onBarSelected: (data, details) { onBarSelected(groupIndex, data, details); },
              groupSelected: isSelected,
              barSelected: barSelected,
              showAverageLine: displayInfo.showAverageLine,
              showValueOnBar: displayInfo.showValueOnBar,
              showGridLine: displayInfo.showGridLine,
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