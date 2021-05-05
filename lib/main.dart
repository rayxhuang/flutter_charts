import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';

import 'modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
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
    'eeee': 7,
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
  '2': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'B1': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'C4': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'D5': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'E2': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'G7': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Yd': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'Ha': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Zj': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Ax': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'Bu': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Ck': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Ds': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'Em': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Gx': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Yk': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'Hs': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Zf': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Ai': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'Bz': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Cd': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Dg': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'Ek': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Gw': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Yde': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'Hj': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Zz': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'A1': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'C1': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'D1': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'E1': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'G1': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Y1': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'H1': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Z1': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  '21': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'B11': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'C41': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'D51': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'E21': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'G71': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Yd1': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'Ha1': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Zj1': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Ax1': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'Bu12': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Ck12': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Ds12': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'E12m': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'G12x': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Y12k': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'H12s': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Z12f': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'A12i': {
    'a': 2,
    'b': 4,
    'd': 1,
    'eeee': 2,
  },
  'B12z': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'C12d': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'D12g': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 2,
  },
  'E12k': {
    'a': 1,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'G12w': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
  'Yd12e': {
    'a': 2,
    'b': 4,
    'c': 6,
    'd': 1,
    'eeee': 7,
  },
  'H12j': {
    'a': 10,
    'b': 3.5,
    'c': 8.5,
    'd': 6.9,
  },
  'Z12z': {
    'a': 7,
    'b': 2,
    'c': 5,
    'd': 12
  },
};

Map<String, Map<String, double>> sampleData4 =  {
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
    'eeee': 7,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
                margin: const EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: ModularBarChart.ungrouped(
                    data: sampleData2,
                    style: BarChartStyle(
                      title: BarChartLabel(
                        text: 'Boring Title',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      sortXAxis: true,
                      groupMargin: 20,
                      xAxisStyle: AxisStyle(
                        label: BarChartLabel(
                          text: 'x Axis',
                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        axisColor: Colors.teal,
                        tickStyle: TickStyle(
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
                        tickStyle: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      ),
                      barStyle: BarChartBarStyle(
                        barWidth: 35,
                        barInGroupMargin: 5,
                      ),
                      legendStyle: BarChartLegendStyle(visible: false),
                      animation: BarChartAnimation(
                        animateData: false,
                      ),
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
                  child: ModularBarChart.grouped(
                    data: sampleData3,
                    style: BarChartStyle(
                      title: BarChartLabel(
                        text: 'Boring Title',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      sortXAxis: true,
                      groupMargin: 10,
                      xAxisStyle: AxisStyle(
                        label: BarChartLabel(
                          text: 'x Axis',
                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        axisColor: Colors.teal,
                        tickStyle: TickStyle(
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
                        tickStyle: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      ),
                      barStyle: BarChartBarStyle(
                        barWidth: 10,
                        barInGroupMargin: 0,
                      ),
                      animation: BarChartAnimation(
                        animateData: true,
                        dataAnimationDuration: const Duration(milliseconds: 300),
                      ),
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
                  child: ModularBarChart.groupedStacked(
                    data: sampleData3,
                    style: BarChartStyle(
                      title: BarChartLabel(
                        text: 'Boring Title',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      sortXAxis: true,
                      groupMargin: 20,
                      xAxisStyle: AxisStyle(
                        label: BarChartLabel(
                          text: 'x Axis',
                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        axisColor: Colors.teal,
                        tickStyle: TickStyle(
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
                        tickStyle: TickStyle(
                          tickLength: 5,
                          tickColor: Colors.teal,
                        ),
                      ),
                      barStyle: BarChartBarStyle(
                        barWidth: 35,
                        barInGroupMargin: 5,
                        isStacked: true,
                      ),
                      animation: BarChartAnimation(
                        animateData: false,
                        //dataAnimationDuration: const Duration(seconds: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
