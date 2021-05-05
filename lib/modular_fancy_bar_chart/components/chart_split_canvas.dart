import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';

@immutable
class GroupedBars extends StatelessWidget {
  final Size size;
  final int groupIndex;
  final double barAnimationFraction;

  const GroupedBars({
    this.size,
    this.groupIndex,
    this.barAnimationFraction,
  });

  @override
  Widget build(BuildContext context) {
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();
    return CustomPaint(
      painter: SingleGroupDataPainter(
        dataModel: dataModel,
        dataIndex: groupIndex,
        style: style,
        xSectionLength: size.width,
        barAnimationFraction: barAnimationFraction,
      ),
      size: size,
    );
  }
}

// class GroupedBars extends StatefulWidget {
//   final Size size;
//   final int groupIndex;
//   //final double barAnimationFraction;
//   final AnimationController animation;
//
//   const GroupedBars({
//     this.size,
//     this.groupIndex,
//     //this.barAnimationFraction,
//     this.animation,
//   });
//
//   @override
//   _GroupedBarsState createState() => _GroupedBarsState();
// }
//
// class _GroupedBarsState extends State<GroupedBars> {
//   double barAnimationFraction;
//
//   @override
//   void initState() {
//     super.initState();
//     barAnimationFraction = widget.animation.value;
//     widget.animation.addListener(() { setState(() {
//       barAnimationFraction = widget.animation.value;
//     }); });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final ModularBarChartData dataModel = context.read<ModularBarChartData>();
//     final BarChartStyle style = context.read<BarChartStyle>();
//     return CustomPaint(
//       painter: SingleGroupDataPainter(
//         dataModel: dataModel,
//         dataIndex: widget.groupIndex,
//         style: style,
//         xSectionLength: widget.size.width,
//         barAnimationFraction: barAnimationFraction,
//       ),
//       size: widget.size,
//     );
//   }
// }

@immutable
class SingleGroupDataPainter extends CustomPainter {
  final double xSectionLength;
  final double barAnimationFraction;
  final int dataIndex;
  final ModularBarChartData dataModel;
  final BarChartStyle style;

  SingleGroupDataPainter({
    @required this.dataIndex,
    @required this.dataModel,
    @required this.xSectionLength,
    this.style = const BarChartStyle(),
    this.barAnimationFraction = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double yUnitPerPixel = (dataModel.yValueRange[2] - dataModel.yValueRange[0]) / size.height;
    final BarChartType type = dataModel.type;
    if (type == BarChartType.Ungrouped) {
      drawUngroupedData(
        canvas: canvas,
        yUnitPerPixel: yUnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.Grouped) {
      drawGroupedData(
        canvas: canvas,
        yUnitPerPixel: yUnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedStacked) {
      drawGroupedStackedData(
        canvas: canvas,
        yUnitPerPixel: yUnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    }
  }

  @override
  bool shouldRepaint(covariant SingleGroupDataPainter oldDelegate) => oldDelegate.barAnimationFraction != barAnimationFraction;

  void drawUngroupedData({@required Canvas canvas, @required double yUnitPerPixel, @required Offset bottomLeft}) {
    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDouble bar = dataModel.bars[dataIndex];
    //Draw data as bars on grid
    paint..color = style.barStyle.color;
    double x1FromBottomLeft = style.groupMargin;
    double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
    double y1FromBottomLeft = (bar.data - dataModel.yValueRange[0]) / yUnitPerPixel;
    drawBar(canvas, bottomLeft, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, style.barStyle, paint);

    if (barAnimationFraction == 1) {
      drawValueOnBar(
        canvas: canvas,
        value: bar.data.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x: x1FromBottomLeft,
        y: y1FromBottomLeft,
      );
    }
  }

  void drawGroupedData({@required Canvas canvas, @required double yUnitPerPixel, @required Offset bottomLeft}) {
    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDoubleGrouped groupedData = dataModel.groupedBars[dataIndex];
    //Draw data as bars on grid
    for (int i = 0; i < groupedData.dataList.length; i++) {
      BarChartBarStyle _barStyle = style.barStyle;
      // Grouped Data must use defined Color for its group
      paint..color = dataModel.subGroupColors[groupedData.dataList[i].group];
      double inGroupMargin = i == 0
          ? 0
          : style.barStyle.barInGroupMargin;
      double x1FromBottomLeft = i * style.barStyle.barWidth + style.groupMargin + inGroupMargin * i;
      double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
      double y1FromBottomLeft = (groupedData.dataList[i].data - dataModel.yValueRange[0]) / yUnitPerPixel;
      drawBar(canvas, bottomLeft, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, _barStyle, paint);

      if (barAnimationFraction == 1) {
        drawValueOnBar(
          canvas: canvas,
          value: groupedData.dataList[i].data.toStringAsFixed(0),
          bottomLeft: bottomLeft,
          x: x1FromBottomLeft,
          y: y1FromBottomLeft,
        );
      }
    }
  }

  void drawGroupedStackedData({@required Canvas canvas, @required double yUnitPerPixel, @required Offset bottomLeft}) {
    //This is the bar paint
    Paint paint = Paint();
    //Draw data as bars on grid
    final List<BarChartDataDouble> data = dataModel.groupedBars[dataIndex].dataList;
    double totalHeight = 0;
    data.forEach((data) { totalHeight += data.data; });
    double previousYValue = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      // Grouped Data must use grouped Color
      paint..color = dataModel.subGroupColors[data[i].group];
      double x1FromBottomLeft = style.groupMargin;
      double x2FromBottomLeft = x1FromBottomLeft + style.barStyle.barWidth;
      double y1FromBottomLeft = (totalHeight - dataModel.yValueRange[0] - previousYValue) / yUnitPerPixel;
      drawBar(canvas, bottomLeft, x1FromBottomLeft, x2FromBottomLeft, y1FromBottomLeft, style.barStyle, paint, last: false);
      previousYValue += data[i].data;

      if (i == data.length - 1 && barAnimationFraction == 1) {
        drawValueOnBar(
          canvas: canvas,
          value: totalHeight.toStringAsFixed(0),
          bottomLeft: bottomLeft,
          x: x1FromBottomLeft,
          y: y1FromBottomLeft,
        );
      }
    }
  }

  void drawBar(Canvas canvas, Offset bottomLeft, double x1, double x2, double y1, BarChartBarStyle style, Paint paint, {bool last = true}) {
    Rect rect = Rect.fromPoints(
      bottomLeft.translate(x1, -y1 * barAnimationFraction),
      bottomLeft.translate(x2, 0)
    );
    if (style.shape == BarChartBarShape.RoundedRectangle && last) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: style.topLeft,
          topRight: style.topRight,
          bottomLeft: style.bottomLeft,
          bottomRight: style.bottomRight,
        ),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  void drawValueOnBar({Canvas canvas, String value, Offset bottomLeft, double x, double y}) {
    TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        // TODO style
        style: TextStyle(color: Colors.white),
      ),
      ellipsis: '..',
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout(maxWidth: style.barStyle.barWidth);
    valuePainter.paint(canvas, bottomLeft.translate(x + style.barStyle.barWidth / 2 - valuePainter.width / 2, -y - valuePainter.height));
  }
}
