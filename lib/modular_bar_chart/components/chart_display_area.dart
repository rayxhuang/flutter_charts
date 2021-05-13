import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:provider/provider.dart';

import 'canvas/chart_main_canvas_wrapper.dart';
import 'canvas/chart_mini_canvas.dart';
import 'chart_axis.dart';
import 'chart_legend.dart';

class ChartDisplayArea extends StatelessWidget {
  const ChartDisplayArea({Key key}) : super(key: key);

  Widget _buildMiniChart({@required DisplayInfo displayInfo,}) {
    final Size canvasSize = displayInfo.canvasSize;
    final BarChartStyle style = displayInfo.style;
    return Column(
      children: [
        ChartCanvasMini(containerSize: canvasSize),
        HorizontalAxisSimpleWrapper(
          size: Size(canvasSize.width, style.xAxisStyle.strokeWidth),
        ),
      ],
    );
  }

  Widget _buildChart({
    @required DisplayInfo displayInfo,
    @required Widget leftAxisWithLabel,
    @required Widget mainCanvasWithBottomAxis,
    @required Widget bottomLabel,
    @required Widget bottomLegend,
    @required Widget rightAxisWithLabel,
  }) {
    final Size canvasWrapperSize = displayInfo.canvasWrapperSize;
    final double titleHeight = displayInfo.titleHeight;
    final double spacingHeight = displayInfo.spacingHeight;
    final double leftAxisWidth = displayInfo.leftAxisCombinedWidth;
    final double bottomLabelHeight = displayInfo.bottomLabelHeight;
    final double height = displayInfo.parentSize.height - titleHeight - spacingHeight;
    return SizedBox.fromSize(
      size: Size(displayInfo.parentSize.width, height),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Stack(children: [
          // Canvas and bottom axis
          Positioned(
            top: 0,
            left: leftAxisWidth,
            child: mainCanvasWithBottomAxis,
          ),

          // Left Axis
          Positioned(
            top: 0,
            left: 0,
            child: leftAxisWithLabel,
          ),

          // Bottom Label
          Positioned(
            top: canvasWrapperSize.height,
            left: leftAxisWidth,
            child: bottomLabel,
          ),

          // Bottom Legends
          Positioned(
            top: canvasWrapperSize.height + bottomLabelHeight,
            left: leftAxisWidth,
            child: bottomLegend,
          ),

          // Right Axis
          Positioned(
            top: 0,
            left: leftAxisWidth + canvasWrapperSize.width,
            child: rightAxisWithLabel,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayInfo>(
      builder: (context, displayInfo, child) {
        // Canvas and bottom axis
        final Widget chartCanvasWithAxis = displayInfo.isMini
            ? _buildMiniChart(displayInfo: displayInfo)
            : ChartCanvasWrapper();

        // Left Axis
        final VerticalAxisWithLabel leftAxis = VerticalAxisWithLabel();

        // Bottom Label
        final Widget bottomLabel = BottomAxisLabel();

        // Bottom Legend
        final Widget bottomLegend = displayInfo.style.legendStyle.visible && !displayInfo.isMini
            ? ChartLegendHorizontal()
            : SizedBox();

        // Right Axis
        final Widget rightAxis = displayInfo.hasYAxisOnTheRight
            ? VerticalAxisWithLabel(isRightAxis: true)
            : SizedBox();

        return _buildChart(
          displayInfo: displayInfo,
          leftAxisWithLabel: leftAxis,
          mainCanvasWithBottomAxis: chartCanvasWithAxis,
          bottomLabel: bottomLabel,
          bottomLegend: bottomLegend,
          rightAxisWithLabel: rightAxis,
        );
      },
    );
  }
}
