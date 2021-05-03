import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/fancy_bar_chart.dart';

import 'bar_chart/bar_chart.dart';
import 'bar_chart/bar_chart_style.dart';
import 'bar_chart/bar_chart_unit_length.dart';
import 'modular_fancy_bar_chart/modular_fancy_bar_chart.dart';

// BarChartData data = BarChartDataNumber.double(data: sampleData);
// List<BarData> sampleData = [
//   BarData(x1: 0, x2: 0.5, y1: 8, style: BarChartBarStyle(color: Colors.red)),
//   BarData(x1: 0.8, x2: 1.2, y1: 4),
//   BarData(x1: 1.5, x2: 2.5, y1: 8, style: BarChartBarStyle(color: Colors.blue)),
//   BarData(x1: 3, x2: 4, y1: 3.4),
// ];

Map<String, double> sampleData2 =  {
  'A': 1,
  'C': 3,
  'B': 7,
  'D': 5.5,
  'G': 10.5,
  'F': 8,
};

Map<String, Map<String, double>> sampleData3 =  {
  'A': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeeeeeeeeeeeeee': 2,
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
  'D': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeeeeeeeeeeeeee': 2,
  },
  'E': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'G': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Y': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeeeeeeeeeeeeee': 188,
  },
  'H': {
    'a': 1000,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Z': {
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

class MyHomePage extends StatelessWidget {
//   MyHomePage({Key key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   bool toggle = false;
//   bool toggle2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // setState(() {
              //   toggle = !toggle;
              //   toggle2 = !toggle2;
              // });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5,),
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: ModularFancyBarChart(
                    rawData: ModularBarChartData.grouped(
                      rawData: sampleData3
                    ),
                    style: BarChartStyle(
                      title: BarChartLabel(
                        text: 'Boring Title',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      sortXAxis: true,
                      barWidth: 35,
                      groupMargin: 20,
                      barMargin: 5,
                      xAxisStyle: AxisStyle(
                        label: BarChartLabel(
                          text: 'x Axis',
                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        axisColor: Colors.teal,
                        tick: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      ),
                      yAxisStyle: AxisStyle(
                        numTicks: 5,
                        label: BarChartLabel(
                          text: 'Y Axis',
                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                        ),
                        //preferredEndValue: 20,
                        axisColor: Colors.teal,
                        tick: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      )
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5,),
            // Card(
            //   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
            //   margin: const EdgeInsets.all(5),
            //   child: Center(
            //     child: Container(
            //       padding: EdgeInsets.all(20),
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height / 3,
            //       child: ModularFancyBarChart(
            //         rawData: ModularBarChartData.groupedStacked(
            //             rawData: sampleData3
            //         ),
            //         style: BarChartStyle(
            //           title: BarChartLabel(
            //             text: 'Boring Title',
            //             textStyle: TextStyle(color: Colors.white),
            //           ),
            //           sortXAxis: true,
            //           barWidth: 35,
            //           groupMargin: 20,
            //           barMargin: 5,
            //           xAxisStyle: AxisStyle(
            //             label: BarChartLabel(
            //               text: 'x Axis',
            //               textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //             ),
            //             axisColor: Colors.teal,
            //             tick: TickStyle(
            //               tickLength: 5,
            //               tickColor: Colors.teal,
            //             ),
            //           ),
            //           yAxisStyle: AxisStyle(
            //             //preferredEndValue: 250,
            //             label: BarChartLabel(
            //               text: 'Y Axis',
            //               textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
            //             ),
            //             //preferredEndValue: 20,
            //             axisColor: Colors.teal,
            //             tick: TickStyle(
            //               tickLength: 5,
            //               tickColor: Colors.teal,
            //             ),
            //           )
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: St(
                    rawData: ModularBarChartData.groupedStacked(
                        rawData: sampleData3
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
      // body: BarChartSample1(),
    );
  }
}
