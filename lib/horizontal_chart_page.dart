import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/modular_bar_chart.dart';

class HorizontalChartViewPage extends StatelessWidget {
  final ModularBarChart chart;

  const HorizontalChartViewPage({
    @required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('${chart.title}'),
      ),
      // ! 1. delete unused widget
      // ! 2. should create body widget, and the body widget should wrap the chart widget
      // ! 3. chart widget should be able to detect the different data structure to auto-select proper chart type
      body: RotatedBox(
        quarterTurns: 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SafeArea(child: chart),
          ),
        ),
      ),
    );
  }
}
