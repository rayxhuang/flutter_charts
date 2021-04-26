import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/axis.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'bar_chart/bar_chart.dart';

BarChartData data = BarChartDataNumber.double(data: sampleData);
List<BarData> sampleData = [
  BarData(x1: 0, x2: 0.5, y: 8),
  BarData(x1: 0.8, x2: 1.2, y: 4),
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
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: BarChart(
                  barChartData: BarChartDataNumber.double(data: sampleData,),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  gridAreaOffsetFromBottomLeft: const Offset(20, 20),
                  gridAreaOffsetFromTopRight: const Offset(15, 5),
                  xAxisStyle: const AxisStyle(
                    preferredStartValue: 0,
                    preferredEndValue: 5,
                    axisColor: Colors.teal,
                    numTicks: 11,
                    tick: Tick(
                      tickDecimal: 1,
                      tickLength: 5,
                      tickColor: Colors.teal,
                      unit: '',
                    )
                  ),
                  yAxisStyle: const AxisStyle(
                    preferredStartValue: 0,
                    preferredEndValue: 10,
                    axisColor: Colors.teal,
                    tick: Tick(
                      tickLength: 5,
                      tickColor: Colors.teal,
                    )
                  ),
                  animation: const BarChartAnimation(
                    animateAxis: true,
                    animateData: true,
                  ),
                ),
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
