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
    'c': 6,
    'd': 1,
    'e': 2,
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
  bool toggle = false;
  bool toggle2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                toggle = !toggle;
                toggle2 = !toggle2;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5,),
            const SizedBox(height: 5,),
            // Card(
            //   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
            //   margin: const EdgeInsets.all(5),
            //   child: Center(
            //     child: FancyBarChart(
            //       rawData: sampleData3,
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height / 3,
            //       style: BarChartStyle(
            //         title: BarChartLabel(
            //           text: 'Random Bar Chart',
            //           textStyle: TextStyle(
            //             color: Colors.white,
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //           )
            //         ),
            //         sortXAxis: true,
            //         isStacked: toggle,
            //         gridAreaOffsetFromBottomLeft: const Offset(35, 35),
            //         gridAreaOffsetFromTopRight: const Offset(10, 10),
            //         groupMargin: 50,
            //         xAxisStyle: const AxisStyle(
            //           label: BarChartLabel(
            //               text: 'X Axis',
            //               textStyle: TextStyle(
            //                 color: Colors.white,
            //               )
            //           ),
            //           axisColor: Colors.teal,
            //           tick: TickStyle(
            //             tickDecimal: 0,
            //             tickLength: 5,
            //             tickColor: Colors.teal,
            //           ),
            //         ),
            //         yAxisStyle: const AxisStyle(
            //           label: BarChartLabel(
            //               text: 'Y Axis',
            //               textStyle: TextStyle(
            //                 color: Colors.white,
            //               )
            //           ),
            //           axisColor: Colors.teal,
            //           preferredStartValue: 0,
            //           numTicks: 8,
            //           tick: TickStyle(
            //             tickDecimal: 0,
            //             tickLength: 5,
            //             tickColor: Colors.teal,
            //           ),
            //         ),
            //         barStyle: const BarChartBarStyle(
            //           shape: BarChartBarShape.RoundedRectangle,
            //           topLeft: const Radius.circular(15),
            //           topRight: const Radius.circular(15),
            //         ),
            //         animation: BarChartAnimation(
            //           animateData: true,
            //           dataAnimationDuration: const Duration(milliseconds: 800),
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
                child: ModularFancyBarChart(
                  rawData: ModularBarChartData.ungrouped(
                    rawData: sampleData2
                  ),
                  style: BarChartStyle(
                    sortXAxis: true,
                    barWidth: 20,
                    groupMargin: 20,
                    xAxisStyle: AxisStyle(
                      axisColor: Colors.teal,
                      tick: TickStyle(
                        tickLength: 5,
                        tickColor: Colors.teal,
                      ),
                    ),
                    yAxisStyle: AxisStyle(
                      preferredEndValue: 20,
                      axisColor: Colors.teal,
                      tick: TickStyle(
                        tickLength: 5,
                        tickColor: Colors.teal,
                      ),
                    )
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: ModularFancyBarChart(
                  rawData: ModularBarChartData.grouped(
                    rawData: sampleData3
                  ),
                  style: BarChartStyle(
                      sortXAxis: true,
                      barWidth: 20,
                      groupMargin: 20,
                      barMargin: 5,
                      xAxisStyle: AxisStyle(
                        axisColor: Colors.teal,
                        tick: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      ),
                      yAxisStyle: AxisStyle(
                        preferredEndValue: 20,
                        axisColor: Colors.teal,
                        tick: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      )
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Center(
                child: Container(
                  height: 2000,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: ModularFancyBarChart(
                      rawData: ModularBarChartData.groupedStacked(
                          rawData: sampleData3
                      ),
                      style: BarChartStyle(
                          sortXAxis: true,
                          barWidth: 20,
                          groupMargin: 20,
                          barMargin: 5,
                          xAxisStyle: AxisStyle(
                            axisColor: Colors.teal,
                            tick: TickStyle(
                              tickLength: 5,
                              tickColor: Colors.teal,
                            ),
                          ),
                          yAxisStyle: AxisStyle(
                            preferredEndValue: 20,
                            axisColor: Colors.teal,
                            tick: TickStyle(
                              tickLength: 5,
                              tickColor: Colors.teal,
                            ),
                          )
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
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
