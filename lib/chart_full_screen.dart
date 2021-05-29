import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/create_chart_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/modular_bar_chart.dart';

import 'modular_bar_chart/data/bar_chart_data.dart';
import 'modular_bar_chart/data/bar_chart_style.dart';

class ChartFullViewScreen extends StatelessWidget with CreateChart {
  final Map<String, dynamic> rawData;
  final BarChartType chartType;
  final BarChartStyle style;
  final Map<String, Color> xSubGroupColorMap;

  const ChartFullViewScreen({
    @required this.rawData,
    @required this.chartType,
    @required this.style,
    this.xSubGroupColorMap = const {}
  });

  @override
  Widget build(BuildContext context) {
    final ModularBarChart _chart = createChart(
      rawData: rawData,
      chartType: chartType,
      style: style.copyWith(
        isMini: false,
        clickable: true,
        legendStyle: style.legendStyle.copyWith(
          visible: true,
        ),
        animation: style.animation.copyWith(
          animateData: true
        ),
      ),
      xSubGroupColorMap: xSubGroupColorMap,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.of(context).pop();
        },),
        title: Text('${_chart.title}'),
      ),
      body: RotatedBox(
        quarterTurns: 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SafeArea(
              child: _chart,
            ),
          ),
        ),
      ),
    );
  }
}
