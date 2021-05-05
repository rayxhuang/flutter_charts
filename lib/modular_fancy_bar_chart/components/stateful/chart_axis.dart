import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/textSizeInfo.dart';
import '../chart_axis.dart';

// class ChartAxisHorizontal extends StatefulWidget {
//   final List<String> xGroups;
//   final int numBarsInGroup;
//   final double barWidth;
//   final BarChartStyle style;
//   final double axisLength;
//   final ScrollController scrollController;
//
//   const ChartAxisHorizontal({
//     @required this.xGroups,
//     @required this.numBarsInGroup,
//     @required this.barWidth,
//     @required this.axisLength,
//     @required this.scrollController,
//     this.style = const BarChartStyle(),
//   });
//
//   @override
//   _ChartAxisHorizontalState createState() => _ChartAxisHorizontalState();
//
//   Size get size => Size(axisLength, getHeight(style.xAxisStyle));
//   double get xSectionLength => numBarsInGroup * barWidth + style.groupMargin * 2 + style.barMargin * (numBarsInGroup - 1);
//   double get length => [xSectionLength * xGroups.length, axisLength].reduce(max);
//   double get height => getHeight(style.xAxisStyle);
//
//   static double getHeight(AxisStyle xAxisStyle) => getSizeOfString('I', xAxisStyle.tick.labelTextStyle, isHeight: true) + xAxisStyle.tick.tickLength + xAxisStyle.tick.tickMargin;
// }
//
// class _ChartAxisHorizontalState extends State<ChartAxisHorizontal> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.axisLength,
//       height: widget.height,
//       child: SingleChildScrollView(
//         physics: ClampingScrollPhysics(),
//         scrollDirection: Axis.horizontal,
//         controller: widget.scrollController,
//         child: CustomPaint(
//           painter: HorizontalAxisPainter(
//             xGroups: widget.xGroups,
//             axisStyle: widget.style.xAxisStyle,
//           ),
//           size: Size(widget.length, widget.height),
//         ),
//       ),
//     );
//   }
// }

class ChartAxisHorizontal extends StatelessWidget {
  final List<String> xGroups;
  final int numBarsInGroup;
  final double barWidth;
  final BarChartStyle style;
  final double axisLength;
  final ScrollController scrollController;

  const ChartAxisHorizontal({
    @required this.xGroups,
    @required this.numBarsInGroup,
    @required this.barWidth,
    @required this.axisLength,
    @required this.scrollController,
    this.style = const BarChartStyle(),
  });

  Size get size => Size(axisLength, getHeight(style.xAxisStyle));
  double get xSectionLength => numBarsInGroup * barWidth + style.groupMargin * 2 + style.barStyle.barInGroupMargin * (numBarsInGroup - 1);
  double get length => [xSectionLength * xGroups.length, axisLength].reduce(max);
  double get height => getHeight(style.xAxisStyle);

  static double getHeight(AxisStyle xAxisStyle) => getSizeOfString('I', xAxisStyle.tickStyle.labelTextStyle, isHeight: true) + xAxisStyle.tickStyle.tickLength + xAxisStyle.tickStyle.tickMargin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: axisLength,
      height: height,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: CustomPaint(
          painter: HorizontalAxisPainter(
            xGroups: xGroups,
            axisStyle: style.xAxisStyle,
          ),
          size: Size(length, height),
        ),
      ),
    );
  }
}