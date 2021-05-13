import 'package:flutter/material.dart';
import 'package:flutter_charts/horizontal_chart_page.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/data/sample_data.dart';
import 'package:flutter_charts/modular_bar_chart/modular_bar_chart.dart';

// ! use expression body
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      ),
      // ! use another widget on body, it can easily extract body widget to fit other pages
      body: const MyHomePageBody(),
    );
  }
}

class MyHomePageBody extends StatelessWidget {
  const MyHomePageBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ! use const value to fit factory pattern, reduce massive code
    final ModularBarChart chartUngrouped = ModularBarChart.ungrouped(data: sampleData2);
    final ModularBarChart chartGroupedSeparated = ModularBarChart.groupedSeparated(data: sampleData6);
    final ModularBarChart chartGrouped = ModularBarChart.grouped(data: sampleData3);
    final ModularBarChart chartGroupedStacked = ModularBarChart.groupedStacked(data: sampleData3);
    final ModularBarChart chartGroupedTest = ModularBarChart.grouped(data: sampleData7);
    return Align(
      alignment: Alignment.topCenter,
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          // ! extract it into MiniChart
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                // ! add ',' to restructure nicely
                MaterialPageRoute(
                  builder: (context) => HorizontalChartViewPage(
                    // ! should not pass the whole widget, but only data and configuration
                    chart: chartUngrouped.copyWith(
                      style: chartUngrouped.style.copyWith(
                        clickable: true,
                        isMini: false,
                        animation: BarChartAnimation(
                          animateData: true,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(5),
                child: chartUngrouped,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                // ! add ',' to restructure nicely
                MaterialPageRoute(
                  builder: (context) => HorizontalChartViewPage(
                    chart: chartGroupedSeparated.copyWith(
                      style: chartGroupedSeparated.style.copyWith(
                        clickable: true,
                        isMini: false,
                        animation: BarChartAnimation(
                          animateData: true,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(5),
                child: SafeArea(child: chartGroupedSeparated),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HorizontalChartViewPage(
                        chart: chartGrouped.copyWith(
                            colorMap: chartGrouped.dataModel.subGroupColors,
                            style: chartGrouped.style.copyWith(
                                clickable: true,
                                isMini: false,
                                animation: BarChartAnimation(
                                  animateData: true,
                                ))))),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(5),
                child: chartGrouped,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HorizontalChartViewPage(
                        chart: chartGroupedStacked.copyWith(
                            colorMap: chartGroupedStacked.dataModel.subGroupColors,
                            style: chartGroupedStacked.style.copyWith(
                                clickable: true,
                                isMini: false,
                                animation: BarChartAnimation(
                                  animateData: true,
                                ))))),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(5),
                child: chartGroupedStacked,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HorizontalChartViewPage(
                        chart: chartGroupedTest.copyWith(
                            colorMap: chartGroupedTest.dataModel.subGroupColors,
                            style: chartGroupedTest.style.copyWith(
                                clickable: true,
                                isMini: false,
                                animation: BarChartAnimation(
                                  animateData: true,
                                ))))),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.all(5),
                child: chartGroupedTest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniChart extends StatelessWidget {
  const MiniChart({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
