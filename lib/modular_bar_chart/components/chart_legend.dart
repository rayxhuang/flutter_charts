import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

class ChartLegendHorizontal extends StatelessWidget with StringSize{
  const ChartLegendHorizontal();

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final BarChartStyle style = displayInfo.style;
    final double width = displayInfo.canvasWidth;
    final double height = displayInfo.bottomLegendHeight;

    // Calculate width for each legend
    final double maxWidthOfOneLegend = StringSize.getWidthOfString(displayInfo.longestGroupName, style.legendStyle.legendTextStyle);
    double legendWidth;
    if (maxWidthOfOneLegend * dataModel.xSubGroups.length <= width) {
      legendWidth = width / dataModel.xSubGroups.length;
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
        itemCount: dataModel.xSubGroups.length,
        itemBuilder: (BuildContext context, int index) {
          return HorizontalLegendTile(
            index: index,
            width: legendWidth,
          );
        },
      ),
    );
  }
}

@immutable
class HorizontalLegendTile extends StatelessWidget {
  const HorizontalLegendTile({
    Key key,
    @required this.index,
    @required this.width,
  }) : super(key: key);

  final int index;
  final double width;

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final ModularBarChartData dataModel = displayInfo.dataModel;
    final String groupName = dataModel.xSubGroups[index];
    final Color color = dataModel.subGroupColors[groupName];
    return SizedBox(
      width: width,
      height: displayInfo.bottomLegendHeight,
      child: Tooltip(
        message: groupName,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: color, size: 8,),
            SizedBox(width: 5,),
            Expanded(
              child: Text(
                groupName,
                style: displayInfo.style.legendStyle.legendTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
