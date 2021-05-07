import 'package:flutter/cupertino.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

@immutable
class ChartTitle extends StatelessWidget with StringSize{
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
      height: StringSize.getHeight(label),
      child: Center(
        child: Text(
          label.text,
          style: label.textStyle,
        ),
      ),
    );
  }

  Size size(BarChartLabel title) => Size(width, StringSize.getHeight(title));
}