import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/fancy_bar_chart.dart';

import 'bar_chart/bar_chart.dart';
import 'bar_chart/bar_chart_style.dart';
import 'bar_chart/bar_chart_unit_length.dart';

BarChartData data = BarChartDataNumber.double(data: sampleData);
List<BarData> sampleData = [
  BarData(x1: 0, x2: 0.5, y1: 8, style: BarChartBarStyle(color: Colors.red)),
  BarData(x1: 0.8, x2: 1.2, y1: 4),
  BarData(x1: 1.5, x2: 2.5, y1: 8, style: BarChartBarStyle(color: Colors.blue)),
  BarData(x1: 3, x2: 4, y1: 3.4),
];

Map<String, dynamic> sampleData2 =  {
  'A': 2,
  'C': 3,
  'B': 7,
  'D': 5.5,
  'G': 10.5,
  'F': 8,
};

Map<String, dynamic> sampleData3 =  {
  'A': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
  },
  'B': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'C': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
};

void main() { runApp(MyApp()); }

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
            // Card(
            //   shape: const RoundedRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(20)),
            //   ),
            //   margin: const EdgeInsets.all(5),
            //   child: Center(
            //     child: BarChart(
            //       barChartData: BarChartDataNumber.double(
            //         data: sampleData,
            //         style: BarChartBarStyle(
            //           color: Colors.orange,
            //           shape: BarChartBarShape.RoundedRectangle,
            //           topLeft: const Radius.circular(15),
            //           topRight: const Radius.circular(15),
            //         ),
            //       ),
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height / 3,
            //       gridAreaOffsetFromBottomLeft: const Offset(35, 35),
            //       gridAreaOffsetFromTopRight: const Offset(15, 5),
            //       xAxisStyle: const AxisStyle(
            //         label: 'X Axis',
            //         preferredEndValue: 5,
            //         axisColor: Colors.teal,
            //         numTicks: 11,
            //         tick: Tick(
            //           tickDecimal: 1,
            //           tickLength: 5,
            //           tickColor: Colors.teal,
            //           unit: 'cm',
            //         )
            //       ),
            //       yAxisStyle: const AxisStyle(
            //         label: 'Y Axis',
            //         preferredEndValue: 10,
            //         axisColor: Colors.teal,
            //         tick: Tick(
            //           tickLength: 5,
            //           tickColor: Colors.teal,
            //         )
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 5,),
            // Card(
            //   shape: const RoundedRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(20)),
            //   ),
            //   margin: const EdgeInsets.all(5),
            //   child: Center(
            //     child: BarChartUnitLength(
            //       barChartData: BarChartDataDoubleWithUnitLength(
            //         data: [1,3,5,9,12,5,7,3,1,2,0,2,6,3,7.9,2,2.2,4,7,6,8,1,1,0,1.4,9],
            //         style: BarChartBarStyle(
            //           color: Colors.orange,
            //           shape: BarChartBarShape.RoundedRectangle,
            //           topLeft: const Radius.circular(15),
            //           topRight: const Radius.circular(15),
            //         ),
            //       ),
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height / 3,
            //       gridAreaOffsetFromBottomLeft: const Offset(35, 35),
            //       gridAreaOffsetFromTopRight: const Offset(15, 5),
            //       xAxisStyle: const AxisStyle(
            //         label: 'X Axis',
            //         preferredStartValue: 11,
            //         preferredEndValue: 30,
            //         axisColor: Colors.teal,
            //         numTicks: 6,
            //         tick: Tick(
            //           tickDecimal: 0,
            //           tickLength: 5,
            //           tickColor: Colors.teal,
            //         )
            //       ),
            //       yAxisStyle: const AxisStyle(
            //         label: 'Y Axis',
            //         preferredEndValue: 10,
            //         axisColor: Colors.teal,
            //         tick: Tick(
            //           tickLength: 5,
            //           tickColor: Colors.teal,
            //         )
            //       ),
            //       animation: const BarChartAnimation(
            //         dataAnimationDuration: Duration(milliseconds: 500),
            //         animateData: true,
            //       ),
            //     ),
            //   ),
            // ),
            // Card(
            //   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
            //   margin: const EdgeInsets.all(5),
            //   child: Center(
            //     child: FancyBarChart(
            //       rawData: sampleData2,
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height / 3,
            //       style: BarChartStyle(
            //         sortXAxis: true,
            //         gridAreaOffsetFromBottomLeft: const Offset(35, 35),
            //         gridAreaOffsetFromTopRight: const Offset(15, 5),
            //         xAxisStyle: const AxisStyle(
            //           label: 'X Axis',
            //           preferredEndValue: 30,
            //           axisColor: Colors.teal,
            //           tick: TickStyle(
            //             tickDecimal: 0,
            //             tickLength: 5,
            //             tickColor: Colors.teal,
            //           )
            //         ),
            //         yAxisStyle: const AxisStyle(
            //           label: 'Y Axis',
            //           axisColor: Colors.teal,
            //           preferredStartValue: 0,
            //           numTicks: 8,
            //           tick: TickStyle(
            //             tickDecimal: 0,
            //             tickLength: 5,
            //             tickColor: Colors.teal,
            //           )
            //         ),
            //         animation: BarChartAnimation(
            //           animateData: true,
            //           dataAnimationDuration: const Duration(milliseconds: 500),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 5,),
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: FancyBarChart(
                  rawData: sampleData3,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  style: BarChartStyle(
                    sortXAxis: true,
                    gridAreaOffsetFromBottomLeft: const Offset(35, 35),
                    gridAreaOffsetFromTopRight: const Offset(15, 5),
                    groupMargin: 50,
                    xAxisStyle: const AxisStyle(
                      label: 'X Axis',
                      axisColor: Colors.teal,
                      tick: TickStyle(
                        tickDecimal: 0,
                        tickLength: 5,
                        tickColor: Colors.teal,
                      ),
                    ),
                    yAxisStyle: const AxisStyle(
                      label: 'Y Axis',
                      axisColor: Colors.teal,
                      preferredStartValue: 0,
                      numTicks: 8,
                      tick: TickStyle(
                        tickDecimal: 0,
                        tickLength: 5,
                        tickColor: Colors.teal,
                      ),
                    ),
                    barStyle: const BarChartBarStyle(
                      shape: BarChartBarShape.RoundedRectangle,
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                    ),
                    animation: BarChartAnimation(
                      animateData: true,
                      dataAnimationDuration: const Duration(milliseconds: 500),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5,),
          ]
        ),
      ),
      // body: BarChartSample1(),
    );
  }
}
