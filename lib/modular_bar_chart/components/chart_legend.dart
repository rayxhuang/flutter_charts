import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

@immutable
class ChartLegendHorizontal extends StatelessWidget with StringSize{
  final double width;

  ChartLegendHorizontal({@required this.width,});

  double _getLegendWidth({@required ModularBarChartData dataModel, @required double maxWidth}) {
    double legendWidth;
    if (maxWidth * dataModel.xSubGroups.length <= width) {
      legendWidth = width / dataModel.xSubGroups.length;
    } else {
      int numLegendOnScreen = width ~/ 50;
      legendWidth = width / numLegendOnScreen;
    }
    return legendWidth;
  }

  @override
  Widget build(BuildContext context) {
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    final BarChartStyle style = context.read<BarChartStyle>();
    final double height = StringSize.getHeightOfString(dataModel.xSubGroups.first, style.legendStyle.legendTextStyle) + 4;

    // Calculate width for each legend
    final double maxWidthOfOneLegend = StringSize.getWidthOfString(dataModel.longestGroupName, style.legendStyle.legendTextStyle);
    final double legendWidth = _getLegendWidth(dataModel: dataModel, maxWidth: maxWidthOfOneLegend);

    return SizedBox(
      width: width,
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: dataModel.xSubGroups.length,
        itemBuilder: (BuildContext context, int index) {
          final String groupName = dataModel.xSubGroups[index];
          return SizedBox(
            width: legendWidth,
            height: height,
            child: ChartLegendTile(groupName: groupName,),
          );
        },
      ),
    );
  }
}

@immutable
class ChartLegendTile extends StatelessWidget {
  final String groupName;

  const ChartLegendTile({@required this.groupName});

  @override
  Widget build(BuildContext context) {
    final Color color = context.read<ModularBarChartData>().subGroupColors[groupName];
    final TextStyle textStyle = context.read<BarChartStyle>().legendStyle.legendTextStyle;
    return Tooltip(
      message: groupName,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: color, size: 8,),
          SizedBox(width: 5,),
          Expanded(
            child: Text(
              groupName,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
