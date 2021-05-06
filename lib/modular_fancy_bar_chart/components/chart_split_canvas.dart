import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/textSizeInfo.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
import 'package:touchable/touchable.dart';

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

// class GroupedBars extends StatefulWidget {
//   final Size size;
//   final int groupIndex;
//   final bool isSelected;
//   final BarChartDataDouble barSelected;
//   //final double barAnimationFraction;
//   final AnimationController animation;
//   final Function(int, BarChartDataDouble, TapDownDetails) onBarSelected;
//
//   const GroupedBars({
//     this.size,
//     this.groupIndex,
//     this.isSelected,
//     this.barSelected,
//     //this.barAnimationFraction,
//     this.animation,
//     this.onBarSelected,
//   });
//
//   @override
//   _GroupedBarsState createState() => _GroupedBarsState();
// }
//
// class _GroupedBarsState extends State<GroupedBars> {
//   double barAnimationFraction;
//   BarChartDataDouble selectedBar;
//   final key = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//     barAnimationFraction = widget.animation.value;
//     widget.animation.addListener(() {
//       setState(() {
//         barAnimationFraction = widget.animation.value;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ModularBarChartData dataModel = context.read<ModularBarChartData>();
//     final BarChartStyle style = context.read<BarChartStyle>();
//     return Tooltip(
//       key: key,
//       //message: barSelected.toString(),
//       message: 'hi',
//       child: CanvasTouchDetector(
//         builder: (BuildContext context) {
//           return CustomPaint(
//             painter: SingleGroupDataPainter(
//               context: context,
//               dataModel: dataModel,
//               dataIndex: widget.groupIndex,
//               style: style,
//               xSectionLength: widget.size.width,
//               barAnimationFraction: barAnimationFraction,
//               onBarSelected: (data, details) {
//                 widget.onBarSelected(widget.groupIndex, data, details);
//                 print('called');
//                 final dynamic tooltip = key.currentState;
//                 tooltip.ensureTooltipVisible();
//               },
//               groupSelected: widget.isSelected ? true : false,
//               barSelected: widget.barSelected,
//             ),
//             size: widget.size,
//           );
//         },
//       ),
//     );
//   }
// }

@immutable
class SingleGroupDataPainter extends CustomPainter {
  final BuildContext context;
  final double xSectionLength;
  final double barWidth;
  final double barAnimationFraction;
  final int dataIndex;
  final ModularBarChartData dataModel;
  final BarChartStyle style;
  final Function(BarChartDataDouble, TapDownDetails) onBarSelected;
  final bool groupSelected;
  final BarChartDataDouble barSelected;

  SingleGroupDataPainter({
    @required this.context,
    @required this.dataIndex,
    @required this.dataModel,
    @required this.xSectionLength,
    @required this.barWidth,
    this.style = const BarChartStyle(),
    this.barAnimationFraction = 1,
    this.onBarSelected,
    this.groupSelected,
    this.barSelected,
  });

  @override
  void paint(Canvas originCanvas, Size size) {
    var canvas = TouchyCanvas(context, originCanvas);
    final double yUnitPerPixel = (dataModel.yValueRange[2] - dataModel.yValueRange[0]) / size.height;
    final BarChartType type = dataModel.type;
    if (type == BarChartType.Ungrouped) {
      drawUngroupedData(
        originCanvas: originCanvas,
        canvas: canvas,
        yUnitPerPixel: yUnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.Grouped) {
      drawGroupedData(
        originCanvas: originCanvas,
        canvas: canvas,
        yUnitPerPixel: yUnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    } else if (type == BarChartType.GroupedStacked) {
      drawGroupedStackedData(
        originCanvas: originCanvas,
        canvas: canvas,
        yUnitPerPixel: yUnitPerPixel,
        bottomLeft: Offset(0, size.height)
      );
    }
  }

  @override
  bool shouldRepaint(covariant SingleGroupDataPainter oldDelegate) {
    return oldDelegate.barAnimationFraction != barAnimationFraction
    || oldDelegate.groupSelected != groupSelected
    || oldDelegate.barSelected != barSelected;
  }

  void drawUngroupedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required double yUnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    final BarChartDataDouble bar = dataModel.bars[dataIndex];
    //Draw data as bars on grid
    paint..color = style.barStyle.color;
    double x1FromBottomLeft = style.groupMargin;
    double x2FromBottomLeft = x1FromBottomLeft + barWidth;
    double y1FromBottomLeft = (bar.data - dataModel.yValueRange[0]) / yUnitPerPixel;

    if (bar == barSelected) {
      print('I am selected $bar');
      double x1 = x1FromBottomLeft - 2;
      double x2 = x2FromBottomLeft + 2;
      double y = y1FromBottomLeft + 2;
      // final Rect rect = Rect.fromPoints(
      //     bottomLeft.translate(x1, -y * barAnimationFraction),
      //     bottomLeft.translate(x2, 0)
      // );
      // final Color color = paint.color.withOpacity(0.5);
      // paint..color = color;
      // originCanvas.drawRect(rect, paint);
      drawHighlight(
        canvas: originCanvas,
        bottomLeft: bottomLeft,
        x1: x1,
        x2: x2,
        y1: y,
      );
    }

    drawBar(
      canvas: canvas,
      data: bar,
      bottomLeft: bottomLeft,
      x1: x1FromBottomLeft,
      x2: x2FromBottomLeft,
      y1: y1FromBottomLeft,
      style: style.barStyle,
      paint: paint,
    );

    if (barAnimationFraction == 1) {
      drawValueOnBar(
        canvas: originCanvas,
        value: bar.data.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        y1: y1FromBottomLeft,
      );
    }
  }

  void drawGroupedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required double yUnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    final List<BarChartDataDouble> data = dataModel.groupedBars[dataIndex].dataList;
    DataForBarToBeDrawnLast savedBar;
    //Draw data as bars on grid
    for (int i = 0; i < data.length; i++) {
      // Grouped Data must use defined Color for its group
      paint..color = dataModel.subGroupColors[data[i].group];
      double inGroupMargin = i == 0
          ? 0
          : style.barStyle.barInGroupMargin;
      double x1FromBottomLeft = i * barWidth + style.groupMargin + inGroupMargin * i;
      double x2FromBottomLeft = x1FromBottomLeft + barWidth;
      double y1FromBottomLeft = (data[i].data - dataModel.yValueRange[0]) / yUnitPerPixel;

      if (groupSelected && data[i] == barSelected) {
        print('I am selected ${data[i]}');
        savedBar = DataForBarToBeDrawnLast(
          data: data[i],
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          paint: Paint()..color = paint.color,
        );
      }

      drawBar(
        canvas: canvas,
        data: data[i],
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        x2: x2FromBottomLeft,
        y1: y1FromBottomLeft,
        style: style.barStyle,
        paint: paint,
      );

      if (barAnimationFraction == 1) {
        drawValueOnBar(
          canvas: originCanvas,
          value: data[i].data.toStringAsFixed(0),
          bottomLeft: bottomLeft,
          x1: x1FromBottomLeft,
          y1: y1FromBottomLeft,
        );
      }
    }

    if (savedBar != null) {
      drawHighlight(
        canvas: originCanvas,
        bottomLeft: bottomLeft,
        x1: savedBar.x1 - 2,
        x2: savedBar.x2 + 2,
        y1: savedBar.y1 + 2,
      );
      drawBar(
        canvas: canvas,
        data: savedBar.data,
        bottomLeft: bottomLeft,
        x1: savedBar.x1,
        x2: savedBar.x2,
        y1: savedBar.y1,
        style: style.barStyle,
        paint: savedBar.paint,
      );
    }
  }

  void drawGroupedStackedData({
    @required Canvas originCanvas,
    @required TouchyCanvas canvas,
    @required double yUnitPerPixel,
    @required Offset bottomLeft
  }) {
    //This is the bar paint
    Paint paint = Paint();
    //Draw data as bars on grid
    final List<BarChartDataDouble> data = dataModel.groupedBars[dataIndex].dataList;
    DataForBarToBeDrawnLast savedBar;
    bool lastBarIsHighlighted = false;
    double totalHeight = 0, previousYValue = 0, lastBarX1, lastBarY1, valueOnBarDistanceUp = 0;
    data.forEach((data) { totalHeight += data.data; });
    for (int i = data.length - 1; i >= 0; i--) {
      // Grouped Data must use grouped Color
      paint..color = dataModel.subGroupColors[data[i].group];
      double x1FromBottomLeft = style.groupMargin;
      double x2FromBottomLeft = x1FromBottomLeft + barWidth;
      double y1FromBottomLeft = (totalHeight - dataModel.yValueRange[0] - previousYValue) / yUnitPerPixel;
      if (i == data.length - 1) {
        lastBarX1 = x1FromBottomLeft;
        lastBarY1 = y1FromBottomLeft;
      }

      if (groupSelected && data[i] == barSelected) {
        print('I am selected ${data[i]}');
        double y2FromBottomLeft = (y1FromBottomLeft - data[i].data / yUnitPerPixel);
        savedBar = DataForBarToBeDrawnLast(
          data: data[i],
          x1: x1FromBottomLeft,
          x2: x2FromBottomLeft,
          y1: y1FromBottomLeft,
          y2: y2FromBottomLeft,
          paint: Paint()..color = paint.color,
        );
      }

      drawBar(
        canvas: canvas,
        data: data[i],
        bottomLeft: bottomLeft,
        x1: x1FromBottomLeft,
        x2: x2FromBottomLeft,
        y1: y1FromBottomLeft,
        style: style.barStyle,
        paint: paint,
        last: false,
      );

      previousYValue += data[i].data;

      if (savedBar != null) {
        drawHighlight(
          canvas: originCanvas,
          bottomLeft: bottomLeft,
          x1: savedBar.x1 - 2,
          x2: savedBar.x2 + 2,
          y1: savedBar.y1 + 2,
          y2: savedBar.y2 - 2,
          isStacked: true,
        );
        drawBar(
          canvas: canvas,
          data: savedBar.data,
          bottomLeft: bottomLeft,
          x1: savedBar.x1,
          x2: savedBar.x2,
          y1: savedBar.y1,
          y2: savedBar.y2,
          style: style.barStyle,
          paint: savedBar.paint,
        );
      }
    }

    if (barAnimationFraction == 1) {
      drawValueOnBar(
        canvas: originCanvas,
        value: totalHeight.toStringAsFixed(0),
        bottomLeft: bottomLeft,
        x1: lastBarX1,
        y1: lastBarY1,
      );
    }
  }

  void drawBar({
    @required TouchyCanvas canvas,
    @required BarChartDataDouble data,
    @required Offset bottomLeft,
    @required double x1,
    @required double x2,
    @required double y1,
    @required BarChartBarStyle style,
    @required Paint paint,
    double y2 = 0,
    bool last = true,
  }) {
    Rect rect = Rect.fromPoints(
      bottomLeft.translate(x1, -y1 * barAnimationFraction),
      //bottomLeft.translate(x1, -y1 * 1),
      bottomLeft.translate(x2, -y2)
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
      canvas.drawRect(
        rect,
        paint,
        onTapDown: (details) {
          onBarSelected(data, details);
        }
      );
    }
  }

  void drawValueOnBar({
    @required Canvas canvas,
    @required String value,
    @required Offset bottomLeft,
    @required double x1,
    @required double y1, 
    TextStyle textStyle = const TextStyle(color: Colors.white),
  }) {
    TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        // TODO style
        style: textStyle,
      ),
      ellipsis: '..',
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout(maxWidth: barWidth);
    valuePainter.paint(canvas, bottomLeft.translate(x1 + barWidth / 2 - valuePainter.width / 2, -y1 - valuePainter.height));
  }

  void drawHighlight({
    @required Canvas canvas,
    @required Offset bottomLeft,
    @required double x1,
    @required double x2,
    @required double y1,
    double y2 = 0,
    bool isStacked = false,
  }) {
    final Rect rect = Rect.fromPoints(
      bottomLeft.translate(x1, -y1 * barAnimationFraction),
      bottomLeft.translate(x2, -y2)
    );
    canvas.drawRect(rect, Paint()..color = Colors.lightBlueAccent);
  }
}

@immutable
class DataForBarToBeDrawnLast {
  final BarChartDataDouble data;
  final double x1;
  final double x2;
  final double y1;
  final double y2;
  final Paint paint;
  final bool isLastInStack;

  const DataForBarToBeDrawnLast({
    this.data,
    this.x1,
    this.x2,
    this.y1,
    this.y2 = 0,
    this.paint,
    this.isLastInStack = false,
  });
}