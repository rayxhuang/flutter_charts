import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/axis.dart';
import 'package:flutter_charts/bar_chart/bar_chart_bar.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'bar_chart/bar_chart.dart';

BarChartData data = BarChartDataNumber.Double(data: sampleData);
Map<double, double> sampleData = {
  0.5: 8,
  0.6:4,
  3.2:1
};

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
            ),
            const SizedBox(height: 5,),
            // BarChart(
            //   barChartData: BarChartDataNumber.Double(),
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height / 3,
            //   margin: EdgeInsets.all(5),
            //   contentPadding: EdgeInsets.all(5),
            //   axisX: AxisWithNum.X(
            //     style: AxisStyle(
            //       color: Colors.pink,
            //     ),
            //   ),
            //   axisY: AxisWithNum.Y(
            //     startValue: -10,
            //     endValue: 0,
            //     style: AxisStyle(
            //       startMarginX: 40,
            //       endMarginX: 40,
            //       startMarginY: 30,
            //       numTicks: 5,
            //       tick: Tick(
            //         tickLength: -5,
            //         tickDecimal: 1,
            //         tickMargin: 5
            //       ),
            //     ),
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
