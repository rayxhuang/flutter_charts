import 'dart:math';
import 'dart:ui';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

import 'components/chart_axis.dart';
import 'components/chart_canvas.dart';
import 'components/chart_legend.dart';
import 'components/chart_title.dart';

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
  // Data processing variables
  List<String> xGroups = [], xSubGroups = [];
  List<double> y1Values = [], y2Values = [], yValueRange = [0, 0, 0];
  Map<String, Color> subGroupColors = {};
  List<BarChartDataDouble> _bars = [];
  List<BarChartDataDoubleGrouped> _groupedBars = [];

  // Variables for scrolling and animation
  LinkedScrollControllerGroup _linkedScrollControllerGroup;
  ScrollController _scrollController1, _scrollController2;
  double scrollOffset = 0;
  AnimationController _axisAnimationController, _dataAnimationController;
  double axisAnimationValue = 0, dataAnimationValue = 0;

  // Size data
  Size parentSize;
  Size leftAxisSize  = Size.zero, titleSize = Size.zero, canvasSize = Size.zero, bottomAxisSize = Size.zero,
      bottomLabelSize = Size.zero, bottomLegendSize = Size.zero, rightAxisSize = Size.zero, rightLegendSize = Size.zero;
  double leftAxisStaticWidth, canvasWidth;
  double titleStaticHeight, bottomAxisStaticHeight, bottomLabelStaticHeight, bottomLegendStaticHeight, canvasHeight;

  // Components
  ChartTitle chartTitle, bottomLabel;
  ChartCanvas chartCanvas;
  Container miniCanvas;
  ChartAxisHorizontal topAxis, bottomAxis;
  ChartAxisVerticalWithLabel leftAxis;
  SizedBox bottomLegend;
  ChartLegendVertical rightLegend;

  @override
  void initState() {
    super.initState();
    analyseData();
    adjustAxisValueRange();
    populateDataWithMinimumValue();

    // Scrolling actions
    _linkedScrollControllerGroup = LinkedScrollControllerGroup();
    _scrollController1 = _linkedScrollControllerGroup.addAndGet();
    _scrollController2 = _linkedScrollControllerGroup.addAndGet();
    _linkedScrollControllerGroup.addOffsetChangedListener(() { setState(() {
      scrollOffset = _linkedScrollControllerGroup.offset;
    }); });
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
        double localMaximum = double.negativeInfinity;
        data.rawData.forEach((key, map) {
          xSubGroups.addAll(map.keys.toList());
          //final List<BarChartDataDouble> dataInGroup = [];
          double sum = 0;
          map.forEach((subgroup, value) {
            xSubGroups.add(subgroup);
            y1Values.add(value.toDouble());
            sum += value.toDouble();
          });
          if (sum >= localMaximum) { localMaximum = sum; }
        });
        xSubGroups = xSubGroups.toSet().toList();
        // TODO Allow subgroup comparator
        xSubGroups.sort();
        yValueRange[0] = y1Values.reduce(min);
        // If data type is stacked, use local maximum
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
    String max = yValueRange[1].toStringAsExponential();
    int exp = int.tryParse(max.substring(max.indexOf('e+') + 2));
    //int unit1 = pow(10, exp);
    exp = pow(10, exp - 1);
    double value = ((yValueRange[1] * 1.1 / exp).ceil() * exp).toDouble();
    //print(value);
    // int i = yValueRange[1] ~/ exp;
    // double remainder = yValueRange[1] / exp;
    // int remainderInt = remainder.round();
    // double result  = (exp * (i + (remainderInt == remainder.floor() ? 1 : 2))).toDouble();
    widget.style.yAxisStyle.preferredEndValue >= yValueRange[1]
        ? yValueRange[1] = widget.style.yAxisStyle.preferredEndValue
        : yValueRange[1] = value;
        //: yValueRange[1] = yValueRange[1];

  }

  void populateDataWithMinimumValue() {
    if (widget.rawData.type == BarChartType.Grouped || widget.rawData.type == BarChartType.GroupedStacked) {
      // populate with data with min value
      widget.rawData.rawData.forEach((key, map) {
        final List<BarChartDataDouble> dataInGroup = [];
        final List<String> keys = map.keys.toList();
        for (String key in xSubGroups) {
          if (keys.contains(key)) {
            dataInGroup.add(BarChartDataDouble(group: key, data: map[key].toDouble()));
          } else {
            dataInGroup.add(BarChartDataDouble(group: key, data: yValueRange[0]));
          }
        }
        _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
      });
    }
  }

  void getStaticSizeData() {
    leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(widget.style.yAxisStyle.label.text, yValueRange[1], widget.style.yAxisStyle);
    //print('Static: leftAxis has ${leftAxisStaticWidth.toStringAsFixed(1)} width');
    titleStaticHeight = ChartTitle.getHeight(widget.style.title);
    //print('Static: title has ${titleStaticHeight.toStringAsFixed(1)} height');
    bottomAxisStaticHeight = ChartAxisHorizontal.getHeight(widget.style.xAxisStyle);
    //print('Static: bottomAxis has ${bottomAxisStaticHeight.toStringAsFixed(1)} height');
    bottomLabelStaticHeight = ChartTitle.getHeight(widget.style.xAxisStyle.label);
    //print('Static: bottomLabel has ${bottomLabelStaticHeight.toStringAsFixed(1)} height');
    bottomLegendStaticHeight = ChartLegendHorizontal.getHeight(BarChartLabel(text: 'Title', textStyle: widget.style.legendTextStyle));
    //print('Static: bottomLegend has ${bottomLegendStaticHeight.toStringAsFixed(1)} height');

    canvasWidth = parentSize.width - leftAxisStaticWidth;
    if (canvasWidth < 0) { canvasWidth = 0; }
    canvasHeight = parentSize.height - titleStaticHeight - bottomAxisStaticHeight - bottomLabelStaticHeight - bottomLegendStaticHeight;
    if (canvasHeight < 0) { canvasHeight = 0; }
    canvasSize = Size(canvasWidth, canvasHeight);
    //print(canvasSize);
  }

  void constructComponents() {
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

    // Canvas
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

    // MiniCanvas
    miniCanvas = Container(
      width: canvasWidth * 0.2,
      height: canvasHeight * 0.2 + 3,
      color: Colors.black12,
      child: Stack(
        children: [
          //Container(color: Colors.black12,),
          Align(
            alignment: Alignment((-1 + (scrollOffset != 0 ? (scrollOffset * 2 / (bottomAxis.length - canvasWidth)) : 0).toDouble()), 0),
            child: Container(
              width: (canvasWidth / bottomAxis.length) * canvasWidth * 0.2,
              height: canvasHeight * 0.2 + 3,
              color: Colors.white12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: ChartCanvas.mini(
              type: widget.rawData.type,
              canvasSize: Size(canvasWidth * 0.2, canvasHeight * 0.2),
              length: canvasWidth * 0.2,
              xGroups: xGroups,
              subGroups: xSubGroups,
              subGroupColors: subGroupColors,
              valueRange: yValueRange,
              xSectionLength: bottomAxis.xSectionLength * (canvasWidth * 0.2 / bottomAxis.length),
              groupedBars: _groupedBars,
              style: widget.style,
            ),
          ),
        ],
      ),
    );

    // rightAxis = ChartAxisVertical(parentSize: parentSize, yValueRange: yValueRange, axisStyle: widget.style.yAxisStyle);
    // rightAxisSize = rightAxis.size;
    // rightLegend = ChartLegendVertical(parentSize: parentSize);
    // rightLegendSize = rightLegend.size;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraint) {
          //print('Biggest: ${constraint.biggest.toString()}');
          double height, width;
          height = constraint.maxHeight < double.infinity ? constraint.maxHeight : MediaQuery.of(context).size.height;
          width = constraint.maxWidth < double.infinity ? constraint.maxWidth : MediaQuery.of(context).size.width;

          parentSize = Size(width, height);
          //print(parentSize);
          getStaticSizeData();
          constructComponents();
          // TODO Too small to have a canvas?
          return (
            SizedBox(
              // width: constraint.maxWidth,
              // height: constraint.maxHeight,
              width: width,
              height: height,
              child: Padding(
                // TODO padding
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
                      left: leftAxisSize.width + canvasWidth - canvasWidth * 0.2,
                      child: miniCanvas,
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _axisAnimationController.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }
}

class St extends StatelessWidget {
  final AbstractModularBarChartData rawData;
  final BarChartStyle style;

  St({
    @required this.rawData,
    this.style = const BarChartStyle(),
  }) : assert(rawData != null);

  @override
  Widget build(BuildContext context) {
    // Data processing variables
    List<String> xGroups = [], xSubGroups = [];
    List<double> y1Values = [], y2Values = [], yValueRange = [0, 0, 0];
    Map<String, Color> subGroupColors = {};
    List<BarChartDataDouble> _bars = [];
    List<BarChartDataDoubleGrouped> _groupedBars = [];

    // Size data
    Size parentSize;
    Size leftAxisSize  = Size.zero, titleSize = Size.zero, canvasSize = Size.zero, bottomAxisSize = Size.zero,
        bottomLabelSize = Size.zero, bottomLegendSize = Size.zero, rightAxisSize = Size.zero, rightLegendSize = Size.zero;
    double leftAxisStaticWidth, canvasWidth;
    double titleStaticHeight, bottomAxisStaticHeight, bottomLabelStaticHeight, bottomLegendStaticHeight, canvasHeight;

    // Components
    ChartTitle chartTitle, bottomLabel;
    ChartCanvas chartCanvas;
    Container miniCanvas;
    ChartAxisHorizontal topAxis, bottomAxis;
    ChartAxisVerticalWithLabel leftAxis;
    SizedBox bottomLegend;
    ChartLegendVertical rightLegend;

    final AbstractModularBarChartData data = rawData;
    final BarChartType type = data.type;
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
        double localMaximum = double.negativeInfinity;
        data.rawData.forEach((key, map) {
          xSubGroups.addAll(map.keys.toList());
          //final List<BarChartDataDouble> dataInGroup = [];
          double sum = 0;
          map.forEach((subgroup, value) {
            xSubGroups.add(subgroup);
            y1Values.add(value.toDouble());
            sum += value.toDouble();
          });
          if (sum >= localMaximum) { localMaximum = sum; }
        });
        xSubGroups = xSubGroups.toSet().toList();
        // TODO Allow subgroup comparator
        xSubGroups.sort();
        yValueRange[0] = y1Values.reduce(min);
        // If data type is stacked, use local maximum
        yValueRange[1] = type == BarChartType.Grouped
            ? y1Values.reduce(max)
            : localMaximum;
        break;
    }
    // Generate color for subgroups
    if (type != BarChartType.Ungrouped) {
      for (String subGroup in xSubGroups) { subGroupColors[subGroup] = Colors.primaries[Random().nextInt(Colors.primaries.length)]; }
    }



    style.yAxisStyle.preferredStartValue <= yValueRange[0]
        ? yValueRange[0] = style.yAxisStyle.preferredStartValue
        : yValueRange[0] = yValueRange[0];
    String maxS = yValueRange[1].toStringAsExponential();
    int exp = int.tryParse(maxS.substring(maxS.indexOf('e+') + 2));
    //int unit1 = pow(10, exp);
    exp = pow(10, exp - 1);
    double value = ((yValueRange[1] * 1.1 / exp).ceil() * exp).toDouble();
    style.yAxisStyle.preferredEndValue >= yValueRange[1]
        ? yValueRange[1] = style.yAxisStyle.preferredEndValue
        : yValueRange[1] = value;



    if (rawData.type == BarChartType.Grouped || rawData.type == BarChartType.GroupedStacked) {
      // populate with data with min value
      rawData.rawData.forEach((key, map) {
        final List<BarChartDataDouble> dataInGroup = [];
        final List<String> keys = map.keys.toList();
        for (String key in xSubGroups) {
          if (keys.contains(key)) {
            dataInGroup.add(BarChartDataDouble(group: key, data: map[key].toDouble()));
          } else {
            dataInGroup.add(BarChartDataDouble(group: key, data: yValueRange[0]));
          }
        }
        _groupedBars.add(BarChartDataDoubleGrouped(mainGroup: key, dataList: dataInGroup));
      });
    }



    print('do some work');
    return LayoutBuilder(
      builder: (context, constraint) {
        double height, width;
        height = constraint.maxHeight < double.infinity ? constraint.maxHeight : MediaQuery.of(context).size.height;
        width = constraint.maxWidth < double.infinity ? constraint.maxWidth : MediaQuery.of(context).size.width;
        parentSize = Size(width, height);

        leftAxisStaticWidth = ChartAxisVerticalWithLabel.getWidth(style.yAxisStyle.label.text, yValueRange[1], style.yAxisStyle);
        titleStaticHeight = ChartTitle.getHeight(style.title);
        bottomAxisStaticHeight = ChartAxisHorizontal.getHeight(style.xAxisStyle);
        bottomLabelStaticHeight = ChartTitle.getHeight(style.xAxisStyle.label);
        bottomLegendStaticHeight = ChartLegendHorizontal.getHeight(BarChartLabel(text: 'Title', textStyle: style.legendTextStyle));

        canvasWidth = parentSize.width - leftAxisStaticWidth;
        if (canvasWidth < 0) { canvasWidth = 0; }
        canvasHeight = parentSize.height - titleStaticHeight - bottomAxisStaticHeight - bottomLabelStaticHeight - bottomLegendStaticHeight;
        if (canvasHeight < 0) { canvasHeight = 0; }
        canvasSize = Size(canvasWidth, canvasHeight);





        // Left Axis
        leftAxis = ChartAxisVerticalWithLabel(
          axisHeight: canvasHeight,
          yValueRange: yValueRange,
          axisStyle: style.yAxisStyle,
        );
        leftAxisSize = leftAxis.size;

        // Title
        chartTitle = ChartTitle(title: style.title, width: parentSize.width,);
        titleSize = chartTitle.size;

        // Bottom Axis
        int numInGroups = xSubGroups.length;
        if (numInGroups <= 1) { numInGroups = 1; }
        if (rawData.type == BarChartType.GroupedStacked) { numInGroups = 1; }
        bottomAxis = ChartAxisHorizontal(
          axisLength: canvasWidth,
          xGroups: xGroups,
          barWidth: style.barWidth,
          numBarsInGroup: numInGroups,
          style: style,
          scrollController: null,
        );
        bottomAxisSize = bottomAxis.size;

        // Bottom Label
        bottomLabel = ChartTitle(
          title: style.xAxisStyle.label,
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
                  textStyle: style.legendTextStyle,
                ),
                color: subGroupColors[xSubGroups[index]],
              );
            },
          ),
        );
        bottomLegendSize = Size(canvasWidth, bottomLegendStaticHeight);

        // Canvas
        switch (rawData.type) {
          case BarChartType.Ungrouped:
            chartCanvas = ChartCanvas.ungrouped(
              canvasSize: canvasSize,
              length: bottomAxis.length,
              scrollController: null,
              xGroups: xGroups,
              valueRange: yValueRange,
              xSectionLength: bottomAxis.xSectionLength,
              bars: _bars,
              style: style,
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
              isStacked: rawData.type == BarChartType.GroupedStacked ? true : false,
              canvasSize: canvasSize,
              length: bottomAxis.length,
              scrollController: null,
              xGroups: xGroups,
              subGroups: xSubGroups,
              subGroupColors: subGroupColors,
              valueRange: yValueRange,
              xSectionLength: bottomAxis.xSectionLength,
              groupedBars: _groupedBars,
              style: style,
            );
            break;
        }

        // MiniCanvas
        miniCanvas = Container(
          width: canvasWidth * 0.2,
          height: canvasHeight * 0.2 + 3,
          color: Colors.black12,
          child: Stack(
            children: [
              //Container(color: Colors.black12,),
              Align(
                alignment: Alignment(-1, 0),
                child: Container(
                  width: (canvasWidth / bottomAxis.length) * canvasWidth * 0.2,
                  height: canvasHeight * 0.2 + 3,
                  color: Colors.white12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: ChartCanvas.mini(
                  type: rawData.type,
                  canvasSize: Size(canvasWidth * 0.2, canvasHeight * 0.2),
                  length: canvasWidth * 0.2,
                  xGroups: xGroups,
                  subGroups: xSubGroups,
                  subGroupColors: subGroupColors,
                  valueRange: yValueRange,
                  xSectionLength: bottomAxis.xSectionLength * (canvasWidth * 0.2 / bottomAxis.length),
                  groupedBars: _groupedBars,
                  style: style,
                ),
              ),
            ],
          ),
        );








        // TODO Too small to have a canvas?
        return (
            SizedBox(
              // width: constraint.maxWidth,
              // height: constraint.maxHeight,
              width: width,
              height: height,
              child: Padding(
                // TODO padding
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
                        left: leftAxisSize.width + canvasWidth - canvasWidth * 0.2,
                        child: miniCanvas,
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
                        top: titleSize.height + canvasSize.height - style.xAxisStyle.strokeWidth / 2,
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

        return ModularFancyBarChart(rawData: rawData);
    });
  }
}
