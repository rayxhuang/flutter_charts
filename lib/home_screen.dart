import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/create_chart_mixin.dart';

import 'chart_full_screen.dart';
import 'modular_bar_chart/data/bar_chart_data.dart';
import 'modular_bar_chart/data/bar_chart_style.dart';
import 'modular_bar_chart/data/sample_data.dart';
import 'modular_bar_chart/modular_bar_chart.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts'),
      ),
      body: const HomeScreenBody(),
    );
  }
}

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          MiniChartView(rawData: sampleData2, chartType: BarChartType.Ungrouped),
          MiniChartView(rawData: sampleData6, chartType: BarChartType.GroupedSeparated),
          MiniChartView(rawData: sampleData3, chartType: BarChartType.Grouped),
          MiniChartView(rawData: sampleData7, chartType: BarChartType.Grouped),
          MiniChartView(rawData: sampleData8, chartType: BarChartType.Grouped),
        ],
      ),
    );
  }
}

class MiniChartView extends StatelessWidget with CreateChart {
  const MiniChartView({
    Key key,
    @required this.rawData,
    @required this.chartType,
    this.style = BarChartStyle.standardMiniStyle,
  }) : super(key: key);

  final Map<String, dynamic> rawData;
  final BarChartType chartType;
  final BarChartStyle style;

  void _pushToFullViewScreen({
    @required BuildContext context,
    @required Map<String, Color> existingXSubGroupColorMap,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartFullViewScreen(
          rawData: rawData,
          chartType: chartType,
          style: style,
          xSubGroupColorMap: existingXSubGroupColorMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ModularBarChart _chart = createChart(
      rawData: rawData,
      chartType: chartType,
      style: style,
    );
    return GestureDetector(
      onTap: () => _pushToFullViewScreen(
        context: context,
        existingXSubGroupColorMap: _chart.dataModel.xSubGroupColorMap,
      ),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        margin: const EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(5),
          child: _chart,
        ),
      ),
    );
  }
}