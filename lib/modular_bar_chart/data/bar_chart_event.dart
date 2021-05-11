import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

class BarChartEvent extends ChangeNotifier {
  final ModularBarChartData dataModel;
  final BarChartStyle style;

  BarChartEvent({
    @required this.dataModel,
    @required this.style,
  });

  bool showAverageLine = false;
  bool showValueOnBar = false;
  bool showGridLine = false;
  String leftDisplayText = '';
  String rightDisplayText = '';

  void toggleAverageLine({@required bool hasRightAxis}) {
    showAverageLine = !showAverageLine;
    if (showAverageLine) {
      leftDisplayText = 'Avg: ${dataModel.y1Average.toStringAsFixed(2)}';
      if (hasRightAxis) {
        rightDisplayText = 'Avg: ${dataModel.y2Average.toStringAsFixed(2)}';
      }
    } else {
      leftDisplayText = '';
      rightDisplayText = '';
    }
    notifyListeners();
  }

  void toggleValueOnBar() {
    showValueOnBar = !showValueOnBar;
    notifyListeners();
  }

  void toggleGridLine() {
    showGridLine = !showGridLine;
    notifyListeners();
  }
}