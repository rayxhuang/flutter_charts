import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

import 'components/chart_axis.dart';
import 'components/chart_canvas.dart';
import 'components/chart_legend.dart';

enum BarChartType {Ungrouped, Grouped, GroupedStacked, GroupedSeparated, Grouped3D}

abstract class AbstractModularBarChartData {
  final Map<String, dynamic> rawData;
  final BarChartType type;

  const AbstractModularBarChartData._({
    this.rawData,
    this.type,
  });
}

class ModularBarChartData extends AbstractModularBarChartData{
  const ModularBarChartData.ungrouped({
    @required Map<String, double> rawData,
  }) : super._(
    rawData: rawData ?? const {},
    type: BarChartType.Ungrouped,
  );

  const ModularBarChartData.grouped({
    @required Map<String, Map<String, double>> rawData,
  }) : super._(
    rawData: rawData ?? const {},
    type: BarChartType.Grouped,
  );

  const ModularBarChartData.groupedStacked({
    @required Map<String, Map<String, double>> rawData,
  }) : super._(
    rawData: rawData ?? const {},
    type: BarChartType.GroupedStacked,
  );
}

class ModularFancyBarChart extends StatefulWidget {
  final AbstractModularBarChartData rawData;
  final BarChartStyle style;

  ModularFancyBarChart({
    @required this.rawData,
    this.style = const BarChartStyle(),
  }) : assert(rawData != null);

  @override
  _ModularFancyBarChartState createState() => _ModularFancyBarChartState();
}

class _ModularFancyBarChartState extends State<ModularFancyBarChart> with TickerProviderStateMixin{
  List<String> xGroups = [], xSubGroups = [];
  List<double> y1Values = [], y2Values = [], yValueRange = [0, 0, 0];
  Map<String, Color> subGroupColors = {};

  List<BarChartDataDouble> _bars = [];
  List<BarChartDataDoubleGrouped> _groupedBars = [];

  // Var for scrolling and animation
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2, _scrollController3;
  double scrollOffset = 0;
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  Size leftAxisSize  = Size.zero, titleSize = Size.zero, canvasSize = Size.zero, bottomAxisSize = Size.zero,
      bottomLabelSize = Size.zero, bottomLegendSize = Size.zero, rightAxisSize = Size.zero, rightLegendSize = Size.zero;

  Size parentSize;
  ChartTitle chartTitle, bottomLabel;
  ChartCanvas chartCanvas, chartCanvas2;
  ChartAxisHorizontal topAxis, bottomAxis;
  ChartAxisVerticalWithLabel leftAxis;
  SizedBox bottomLegend;
  ChartLegendVertical rightLegend;

  @override
  void initState() {
    super.initState();
    analyseData();
    adjustAxisValueRange();

    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();
    _linkedScrollControllerGroup.addOffsetChangedListener(() { setState(() {
      scrollOffset = _linkedScrollControllerGroup.offset;
    }); });
    //_scrollController3 = _linkedScrollControllerGroup.addAndGet();
  }

  void analyseData() {
    final AbstractModularBarChartData data = widget.rawData;
    final BarChartType type = data.type;
    final BarChartStyle style = widget.style;
    xGroups = data.rawData.keys.toList();
    if (style.sortXAxis) {
      style.groupComparator == null
          ? xGroups.sort()
          : xGroups.sort(style.groupComparator);
    }
    switch (type) {
      case BarChartType.Ungrouped:
        for (String key in xGroups) {
          y1Values.add(data.rawData[key]);
          _bars.add(BarChartDataDouble(group: key, data: data.rawData[key]));
        }
        yValueRange[0] = y1Values.reduce(min);
        yValueRange[1] = y1Values.reduce(max);
        break;
      case BarChartType.GroupedSeparated:
      // TODO: Handle this case.
        break;
      case BarChartType.Grouped3D:
      // TODO: Handle this case.
        break;
      default:
        // default is shared by Grouped and GroupedStacked
        // TODO Fix missing middle group shift
        double localMaximum = double.negativeInfinity;
        data.rawData.forEach((key, map) {
          xSubGroups.addAll(map.keys.toList());
          final List<BarChartDataDouble> dataInGroup = [];
          double sum = 0;
          map.forEach((subgroup, value) {
            xSubGroups.add(subgroup);
            dataInGroup.add(BarChartDataDouble(group: subgroup, data: value.toDouble()));
            y1Values.add(value.toDouble());
            sum += value.toDouble();
          });
          if (sum >= localMaximum) { localMaximum = sum; }
          _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
        });
        xSubGroups = xSubGroups.toSet().toList();
        yValueRange[0] = y1Values.reduce(min);
        yValueRange[1] = type == BarChartType.Grouped
            ? y1Values.reduce(max)
            : localMaximum;
        break;
    }
    // Generate color for subgroups
    if (type != BarChartType.Ungrouped) {
      for (String subGroup in xSubGroups) { subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)]; }
    }
  }

  void adjustAxisValueRange() {
    widget.style.yAxisStyle.preferredStartValue <= yValueRange[0]
        ? yValueRange[0] = widget.style.yAxisStyle.preferredStartValue
        : yValueRange[0] = yValueRange[0];

    // if (type != BarChartType.GroupedStacked) {
    //   yStyle.preferredEndValue >= yValueRange[1]
    //       ? yMax = yStyle.preferredEndValue
    //       : yMax = yValueRange[1];
    // } else {
    //   widget.style.yAxisStyle.preferredEndValue >= yValueRange[2]
    //       ? yMax = widget.style.yAxisStyle.preferredEndValue
    //       : yMax = yValueRange[2];
    // }
    widget.style.yAxisStyle.preferredEndValue >= yValueRange[1]
        ? yValueRange[1] = widget.style.yAxisStyle.preferredEndValue
        : yValueRange[1] = yValueRange[1];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      //TODO FIX
      builder: (context, constraint) {
        // print(constraint.maxWidth);
        // print(constraint.maxHeight);
        // print(constraint.biggest);
        double height, width;
        //height = constraint.maxHeight < double.infinity ? constraint.maxHeight : MediaQuery.of(context).size.height;
        //width = constraint.maxWidth < double.infinity ? constraint.maxWidth : MediaQuery.of(context).size.width;
        if (constraint.maxHeight < double.infinity) {
          parentSize = Size(constraint.maxWidth, constraint.maxHeight);
          print(parentSize);

          double leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(widget.style.yAxisStyle.label.text, yValueRange[1], widget.style.yAxisStyle);
          print('Static: leftAxis has ${leftAxisStaticWidth.toStringAsFixed(1)} width');
          double titleStaticHeight = ChartTitle.getHeight(widget.style.title);
          print('Static: title has ${titleStaticHeight.toStringAsFixed(1)} height');
          double bottomAxisStaticHeight = ChartAxisHorizontal.getHeight(widget.style.xAxisStyle);
          print('Static: bottomAxis has ${bottomAxisStaticHeight.toStringAsFixed(1)} height');
          double bottomLabelStaticHeight = ChartTitle.getHeight(widget.style.xAxisStyle.label);
          print('Static: bottomLabel has ${bottomLabelStaticHeight.toStringAsFixed(1)} height');
          double bottomLegendStaticHeight = ChartLegendHorizontal.getHeight(BarChartLabel(text: 'Title', textStyle: widget.style.legendTextStyle));
          print('Static: bottomLegend has ${bottomLegendStaticHeight.toStringAsFixed(1)} height');

          double canvasWidth = parentSize.width - leftAxisStaticWidth;
          double canvasHeight = parentSize.height - titleStaticHeight - bottomAxisStaticHeight - bottomLabelStaticHeight - bottomLegendStaticHeight;
          canvasSize = Size(canvasWidth, canvasHeight);
          print(canvasSize);

          // Left Axis
          leftAxis = ChartAxisVerticalWithLabel(
            axisHeight: canvasHeight,
            yValueRange: yValueRange,
            axisStyle: widget.style.yAxisStyle,
          );
          leftAxisSize = leftAxis.size;

          // Title
          chartTitle = ChartTitle(title: widget.style.title, width: parentSize.width,);
          titleSize = chartTitle.size;

          // Bottom Axis
          int numInGroups = xSubGroups.length;
          if (numInGroups <= 1) { numInGroups = 1; }
          if (widget.rawData.type == BarChartType.GroupedStacked) { numInGroups = 1; }
          bottomAxis = ChartAxisHorizontal(
            axisLength: canvasWidth,
            xGroups: xGroups,
            barWidth: widget.style.barWidth,
            numBarsInGroup: numInGroups,
            style: widget.style,
            scrollController: _scrollController2,
          );
          bottomAxisSize = bottomAxis.size;
          // Bottom Label
          bottomLabel = ChartTitle(
            title: widget.style.xAxisStyle.label,
            width: canvasWidth,
          );
          bottomLabelSize = bottomLabel.size;
          // Bottom Legend
          bottomLegend = SizedBox(
            width: canvasWidth,
            height: bottomLegendStaticHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(),
              itemCount: xSubGroups.length,
              itemBuilder: (BuildContext context, int index) {
                return ChartLegendHorizontal(
                  // TODO width
                  width: canvasWidth / 6,
                  label: BarChartLabel(
                    text: xSubGroups[index],
                    textStyle: widget.style.legendTextStyle,
                  ),
                  color: subGroupColors[xSubGroups[index]],
                );
              },
            ),
          );
          bottomLegendSize = Size(canvasWidth, bottomLegendStaticHeight);

          switch (widget.rawData.type) {
            case BarChartType.Ungrouped:
              chartCanvas = ChartCanvas.ungrouped(
                canvasSize: canvasSize,
                length: bottomAxis.length,
                scrollController: _scrollController1,
                xGroups: xGroups,
                valueRange: yValueRange,
                xSectionLength: bottomAxis.xSectionLength,
                bars: _bars,
                style: widget.style,
              );
              break;
            case BarChartType.GroupedSeparated:
            // TODO: Handle this case.
              break;
            case BarChartType.Grouped3D:
            // TODO: Handle this case.
              break;
            default:
              chartCanvas = ChartCanvas.grouped(
                isStacked: widget.rawData.type == BarChartType.GroupedStacked ? true : false,
                canvasSize: canvasSize,
                length: bottomAxis.length,
                scrollController: _scrollController1,
                xGroups: xGroups,
                subGroups: xSubGroups,
                subGroupColors: subGroupColors,
                valueRange: yValueRange,
                xSectionLength: bottomAxis.xSectionLength,
                groupedBars: _groupedBars,
                style: widget.style,
              );
              break;
          }

          chartCanvas2 = ChartCanvas.mini(
            isStacked: widget.rawData.type == BarChartType.GroupedStacked ? true : false,
            canvasSize: Size(50, 30),
            length: 50,
            xGroups: xGroups,
            subGroups: xSubGroups,
            subGroupColors: subGroupColors,
            valueRange: yValueRange,
            xSectionLength: bottomAxis.xSectionLength * (50 / bottomAxis.length),
            groupedBars: _groupedBars,
            style: widget.style,
            offset1: scrollOffset * ((50 / bottomAxis.length * canvasWidth)/(bottomAxis.length - canvasWidth)),
            offset2: scrollOffset * ((50 / bottomAxis.length * canvasWidth)/(bottomAxis.length - canvasWidth)) + (canvasWidth / bottomAxis.length * 50),
          );
          print(scrollOffset * ((50 / bottomAxis.length * canvasWidth)/(bottomAxis.length - canvasWidth)));
          print(scrollOffset * ((50 / bottomAxis.length * canvasWidth)/(bottomAxis.length - canvasWidth)) + (canvasWidth / bottomAxis.length * 50));

          // rightAxis = ChartAxisVertical(parentSize: parentSize, yValueRange: yValueRange, axisStyle: widget.style.yAxisStyle);
          // rightAxisSize = rightAxis.size;
          // rightLegend = ChartLegendVertical(parentSize: parentSize);
          // rightLegendSize = rightLegend.size;

          return (
            SizedBox(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              child: Padding(
                // TODO
                padding: EdgeInsets.all(0),
                child: Stack(
                  children: [
                    // Canvas
                    Positioned(
                      top: titleSize.height,
                      left: leftAxisSize.width,
                      child: chartCanvas,
                    ),

                    // mini Canvas
                    Positioned(
                      top: titleSize.height,
                      left: leftAxisSize.width + canvasWidth - 50,
                      child: chartCanvas2,
                    ),

                    // Left Axis
                    Positioned(
                      top: titleSize.height,
                      child: leftAxis,
                    ),

                    // Positioned(
                    //   top: titleSize.height,
                    //   left: leftAxisSize.width + 10,
                    //   child: Container(
                    //     height: 4,
                    //     width: canvasWidth - 20,
                    //     child: LinearProgressIndicator(
                    //       color: Colors.grey,
                    //       backgroundColor: Colors.grey,
                    //       value: (scrollOffset + canvasWidth) / bottomAxis.length,
                    //     ),
                    //   ),
                    // ),

                    // Positioned(
                    //   top: titleSize.height + 8,
                    //   left: leftAxisSize.width,
                    //   child: Container(
                    //     height: 4,
                    //     width: canvasWidth,
                    //     child: SliderTheme(
                    //       data: SliderThemeData(
                    //         thumbColor: Colors.blue,
                    //         activeTrackColor: Colors.grey,
                    //         inactiveTrackColor: Colors.grey,
                    //         overlayColor: Colors.transparent,
                    //         trackHeight: 4,
                    //         trackShape: RectangularSliderTrackShape(),
                    //         thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                    //       ),
                    //       child: Slider(
                    //         onChanged: (double value) { setState(() {
                    //           _linkedScrollControllerGroup.jumpTo(value * (bottomAxis.length - canvasWidth));
                    //         }); },
                    //         value: (scrollOffset) / (bottomAxis.length - canvasWidth),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Title
                    Positioned(
                      top: 0,
                      left: 0,
                      child: chartTitle,
                    ),
                    // Bottom Axis
                    Positioned(
                      top: titleSize.height + canvasSize.height - widget.style.xAxisStyle.strokeWidth / 2,
                      left: leftAxisSize.width,
                      child: bottomAxis,
                    ),
                    // Bottom Label
                    Positioned(
                      top: titleSize.height + canvasSize.height + bottomAxisSize.height,
                      left: leftAxisSize.width,
                      child: bottomLabel,
                    ),
                    // Bottom Legends
                    Positioned(
                      top: titleSize.height + canvasSize.height + bottomAxisSize.height + bottomLabelSize.height,
                      left: leftAxisSize.width,
                      child: bottomLegend,
                    ),

                    // // Right Axis
                    // Positioned(
                    //   top: titleSize.height,
                    //   left: leftAxisSize.width + canvasSize.width,
                    //   child: rightAxis ?? SizedBox(),
                    // ),
                    // // Right Legends
                    // Positioned(
                    //   top: titleSize.height,
                    //   left: leftAxisSize.width + canvasSize.width + rightAxisSize.width,
                    //   child: rightLegend ?? SizedBox(),
                    // ),
                  ]
                ),
              ),
            )
          );
        }
        return (
          Container()
          // SizedBox(
          //   // width: widget.width,
          //   // height: widget.height,
          //   width: constraint.maxWidth,
          //   height: constraint.maxHeight,
          //   child: Padding(
          //     // TODO
          //     padding: EdgeInsets.all(0),
          //     child: Stack(
          //       children: [
          //         // Left Label
          //         Positioned(
          //           top: titleSize.height,
          //           child: leftLabel,
          //         ),
          //         // Left Axis
          //         Positioned(
          //           left: leftLabelSize.width,
          //           top: titleSize.height,
          //           child: leftAxis,
          //         ),
          //
          //         // Title
          //         Positioned(
          //           top: 0,
          //           left: 0,
          //           child: chartTitle,
          //         ),
          //         // Canvas
          //         Positioned(
          //           top: titleSize.height,
          //           left: leftAxisSize.width + leftLabelSize.width,
          //           child: chartCanvas,
          //         ),
          //         // Bottom Axis
          //         Positioned(
          //           top: titleSize.height + canvasSize.height - widget.style.yAxisStyle.strokeWidth / 2,
          //           left: leftAxisSize.width + leftLabelSize.width,
          //           child: bottomAxis,
          //         ),
          //         // Bottom Legends
          //         Positioned(
          //           top: titleSize.height + canvasSize.height + bottomAxisSize.height,
          //           left: leftAxisSize.width + leftLabelSize.width,
          //           child: bottomLegend,
          //         ),
          //
          //         // Right Axis
          //         Positioned(
          //           top: titleSize.height,
          //           left: leftAxisSize.width + leftLabelSize.width + canvasSize.width,
          //           child: rightAxis,
          //         ),
          //         // Right Legends
          //         Positioned(
          //           top: titleSize.height,
          //           left: leftAxisSize.width + leftLabelSize.width + canvasSize.width + rightAxisSize.width,
          //           child: rightLegend,
          //         ),
          //       ]
          //     ),
          //   ),
          // )
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    //_scrollController3.dispose();
    _axisAnimationController.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }
}

@immutable
class ChartTitle extends StatelessWidget {
  final BarChartLabel title;
  final double width;

  ChartTitle({
    @required this.title,
    @required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      width: width,
      height: size.height,
      child: Center(
        child: Text(
          title.text,
          style: title.textStyle,
        ),
      ),
    );
  }

  Size get size => Size(width, getHeight(title));

  static double getHeight(BarChartLabel title) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: title.text, style: title.textStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return title.text == '' ? 0 : painter.height;
  }
}