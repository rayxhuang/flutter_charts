import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/stringSizeMixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

class ChartLegendHorizontal extends StatelessWidget with StringSize{
  final double width;

  ChartLegendHorizontal({ @required this.width, });

  @override
  Widget build(BuildContext context) {
    final ModularBarChartData data = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();
    final double height = StringSize.getHeightOfString(data.xSubGroups.first, style.legendStyle.legendTextStyle) + 4;

    // Calculate width for each legend
    double maxWidthOfOneLegend = double.negativeInfinity;
    data.xSubGroups.forEach((name) {
      double singleLegendWidth = StringSize.getWidthOfString(name, style.legendStyle.legendTextStyle);
      if ( singleLegendWidth >= maxWidthOfOneLegend) { maxWidthOfOneLegend = singleLegendWidth; }
    });
    double legendWidth;
    if (maxWidthOfOneLegend * data.xSubGroups.length <= width) {
      legendWidth = width / data.xSubGroups.length;
    } else {
      int numLegendOnScreen = width ~/ 50;
      legendWidth = width / numLegendOnScreen;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: data.xSubGroups.length,
        itemBuilder: (BuildContext context, int index) {
          final String groupName = data.xSubGroups[index];
          return SizedBox(
            width: legendWidth,
            height: height,
            child: Tooltip(
              message: groupName,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: data.subGroupColors[groupName], size: 8,),
                  SizedBox(width: 5,),
                  Expanded(
                    child: Text(
                      groupName,
                      style: style.legendStyle.legendTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Size size(TextStyle textStyle) => Size(width, StringSize.getHeightOfString('I', textStyle) + 4);

  static double getHeight(BarChartLabel label) => StringSize.getHeightOfString('I', label.textStyle) + 4;
}