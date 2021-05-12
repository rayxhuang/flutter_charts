import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({Key key, this.yMin, this.yMax}) : super(key: key);

  final double yMin;
  final double yMax;

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  RangeValues values1;

  @override
  void initState() {
    super.initState();
    values1 = RangeValues(widget.yMin, widget.yMax);
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    return SizedBox(
      width: displayInfo.parentSize.width,
      height: displayInfo.parentSize.height - kMinInteractiveDimensionCupertino,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Y1 Value Range'),
              SliderTheme(
                data: SliderThemeData(
                  rangeThumbShape: RoundRangeSliderThumbShape(
                    enabledThumbRadius: 2
                  ),
                  overlayShape: RoundSliderThumbShape(
                    enabledThumbRadius: 4
                  )
                ),
                child: RangeSlider(
                  min: displayInfo.y1Min,
                  max: displayInfo.y1Max,
                  values: values1,
                  onChanged: (values){ setState(() {
                    values1 = values;
                  }); },
                ),
              ),
              SizedBox(
                height: 17,
                child: Row(
                  children: [
                    Text(
                      'Start: ${values1.start.toStringAsFixed(2)}'
                    ),
                    Spacer(),
                    Text(
                      'End: ${values1.end.toStringAsFixed(2)}'
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  displayInfo.toggleFilterPanel();
                  displayInfo.setY1RangeFilter(values1);
                },
                icon: Icon(CupertinoIcons.checkmark),
              ),
            ],
          ),
        )
      ),
    );
  }
}
