import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/axis.dart';
import 'package:flutter_charts/bar_chart/bar_chart_bar.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'bar_chart/bar_chart.dart';

BarChartData data = BarChartDataNumber.Double(data: sampleData);
List<BarData> sampleData = [
  BarData(x1: 0, x2: 0.5, y: 8),
  BarData(x1: 0.5, x2: 1.2, y: 4),
  BarData(x1: 3, x2: 4, y: 3.4),
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool animate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5,),
            BarChart(
              barChartData: BarChartDataNumber.Double(
                data: sampleData,
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              margin: EdgeInsets.all(5),
              actualDataGridAreaOffsetFromBottomLeft: Offset(20, 20),
              actualDataGridAreaOffsetFromTopRight: Offset(5, 5),
              xAxisStyle: AxisStyle(
                preferredStart: 0,
                preferredEnd: 5,
              ),
              yAxisStyle: AxisStyle(
                preferredStart: 0,
                preferredEnd: 10,
              ),
            ),
            const SizedBox(height: 5,),
            // BarChart(
            //   barChartData: BarChartDataNumber.Double(
            //     data: sampleData,
            //   ),
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height / 3,
            //   margin: EdgeInsets.all(5),
            //   actualDataGridAreaOffsetFromBottomLeft: Offset(20, 20),
            //   actualDataGridAreaOffsetFromTopRight: Offset(5, 5),
            //   xAxisStyle: AxisStyle(
            //     shift: 50
            //   ),
            //   yAxisStyle: AxisStyle(
            //     shift: 50
            //   ),
            // ),
            const SizedBox(height: 5,),
          ]
        ),
      ),
      // body: BarChartSample1(),
    );
  }
}
