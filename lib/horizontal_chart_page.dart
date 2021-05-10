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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.of(context).pop();
        },),
        title: Text('${chart.title}'),
      ),
      body: RotatedBox(
        quarterTurns: 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: chart,
          ),
        ),
      ),
    );
  }
}
