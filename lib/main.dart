import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/axis.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'bar_chart/bar_chart.dart';

BarChartData data = BarChartDataNumber.Double(data: sampleData);
List<BarData> sampleData = [
  BarData(x1: 0, x2: 0.5, y: 8),
  BarData(x1: 0.8, x2: 1.2, y: 4),
  //BarData(x1: 3, x2: 4, y: 3.4),
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
              actualDataGridAreaOffsetFromTopRight: Offset(15, 5),
              xAxisStyle: const AxisStyle(
                preferredStart: 0,
                preferredEnd: 1.5,
                color: Colors.teal,
                numTicks: 16,
                tick: Tick(
                  labelTextSize: 10,
                  tickDecimal: 2,
                  tickLength: 5,
                  tickColor: Colors.teal,
                  unit: '',
                )
              ),
              yAxisStyle: AxisStyle(
                preferredStart: 0,
                preferredEnd: 10,
                color: Colors.teal,
                tick: Tick(
                  tickLength: 5,
                  tickColor: Colors.teal,
                )
              ),
            ),
            const SizedBox(height: 5,),
            const SizedBox(height: 5,),
          ]
        ),
      ),
      // body: BarChartSample1(),
    );
  }
}
