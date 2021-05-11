// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_charts/modular_bar_chart/components/chart_mini_canvas_painter.dart';
// import 'package:provider/provider.dart';
//
// import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
// import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
//
// @immutable
// class MiniChart extends StatelessWidget {
//   final int numberOfYTicks;
//
//   const MiniChart({
//     this.numberOfYTicks
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     ModularBarChartData dataModel = context.read<ModularBarChartData>();
//     BarChartStyle originalStyle = context.read<BarChartStyle>();
//     final BarChartStyle style = getStyle(originalStyle);
//     final double xSectionLength = dataModel.numBarsInGroups * 20.0 + 10;
//     final double yAxisWidth = 20.0;
//     final double lengthNeeded = dataModel.xGroups.length * xSectionLength + yAxisWidth;
//     final double heightNeeded = 20.0 * numberOfYTicks + 5;
//     print('length: $lengthNeeded');
//     print('height: $heightNeeded');
//
//     // Adjust y Max to fit number on bar and populate data
//     dataModel.adjustAxisValueRange(
//       heightNeeded,
//       valueRangeToBeAdjusted: dataModel.y1ValueRange,
//       start: style.y1AxisStyle.preferredStartValue,
//       end: style.y1AxisStyle.preferredEndValue,
//     );
//     if (dataModel.type == BarChartType.GroupedSeparated) {
//       dataModel.adjustAxisValueRange(
//         heightNeeded,
//         valueRangeToBeAdjusted: dataModel.y2ValueRange,
//         start: style.y2AxisStyle.preferredStartValue,
//         end: style.y2AxisStyle.preferredEndValue,
//       );
//     }
//     dataModel.populateDataWithMinimumValue();
//     return Container(
//       width: lengthNeeded,
//       height: heightNeeded,
//       decoration: BoxDecoration(border: Border.all(color: Colors.red)),
//       child: CustomPaint(
//         painter: MiniCanvasPainter(
//           size: Size(lengthNeeded, heightNeeded),
//           dataModel: dataModel,
//           style: style
//         ),
//         size: Size(lengthNeeded, heightNeeded),
//       ),
//     );
//   }
//
//   BarChartStyle getStyle(BarChartStyle originalStyle) {
//     return originalStyle.copyWith(
//         groupMargin: 5,
//         contentPadding: EdgeInsets.all(0),
//         xAxisStyle: originalStyle.xAxisStyle.copyWith(
//             tickStyle: originalStyle.xAxisStyle.tickStyle.copyWith(
//               tickLength: 0,
//               tickMargin: 0,
//             )
//         ),
//         y1AxisStyle: originalStyle.y1AxisStyle.copyWith(
//             numTicks: numberOfYTicks,
//             tickStyle: originalStyle.y1AxisStyle.tickStyle.copyWith(
//               tickLength: 0,
//               tickMargin: 0,
//             )
//         ),
//         y2AxisStyle: originalStyle.y2AxisStyle.copyWith(
//             numTicks: numberOfYTicks,
//             tickStyle: originalStyle.y2AxisStyle.tickStyle.copyWith(
//               tickLength: 0,
//               tickMargin: 0,
//             )
//         ),
//         barStyle: originalStyle.barStyle.copyWith(
//           barWidth: 20,
//           barInGroupMargin: 0,
//         )
//     );
//   }
// }