import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';

import 'bar_chart/bar_chart_style.dart';
import 'modular_fancy_bar_chart/components/stateful/op.dart';
import 'modular_fancy_bar_chart/modular_fancy_bar_chart.dart';

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
    'eeee': 2,
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
    'eeee': 2,
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
    'eeee': 23,
  },
  'H': {
    'a': 10,
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

// Map<String, Map<String, double>> sampleData4 =  {
//   'A': {
//     'a': 2,
//     'b': 2,
//     'd': 1,
//     'eeee': 2,
//   },
//   'B': {
//     'a': 1,
//     'b': 0.5,
//     'c': 2,
//     'd': 1,
//   },
//   'C': {
//     'a': 1,
//     'b': 2,
//     'c': 1,
//     'd': 1
//   },
//   'D': {
//     'a': 2,
//     'b': 2,
//     'c': 1,
//     'd': 1,
//     'eeee': 2,
//   },
// };

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {},
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                child: ModularBarChart(
                  data: sampleData3,
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
            SizedBox(height: 20,),
            Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                child: ModularBarChart(
                  data: sampleData3,
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
          ],
        ),
      ),
    );
  }
}
