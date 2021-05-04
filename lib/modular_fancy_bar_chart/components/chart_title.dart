import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_data.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/bar_chart_style.dart';
import 'package:flutter_charts/modular_fancy_bar_chart/bar_chart_data_class/textSizeInfo.dart';

@immutable
class ChartTitle extends StatelessWidget {
  final double width;
  final bool isXAxisLabel;

  const ChartTitle({
    @required this.width,
    this.isXAxisLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final BarChartLabel label = isXAxisLabel
        ? context.read<BarChartStyle>().xAxisStyle.label
        : context.read<BarChartStyle>().title;
    return SizedBox(
      width: width,
      height: size(label).height,
      child: Center(
        child: Text(
          label.text,
          style: label.textStyle,
        ),
      ),
    );
  }

  Size size(BarChartLabel title) => Size(width, getHeight(title));

  static double getHeight(BarChartLabel title) => getSizeOfString(title.text, title.textStyle, isHeight: true);
}