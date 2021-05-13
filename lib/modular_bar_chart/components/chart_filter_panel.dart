import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({
    Key key,
    @required this.displayInfo,
  }) : super(key: key);

  final DisplayInfo displayInfo;

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  RangeValues y1Range, y2Range;
  Map<String, bool> selectedXGroups, selectedXSubGroups;

  @override
  void initState() {
    super.initState();
    y1Range = widget.displayInfo.y1RangeFilter;
    y2Range = widget.displayInfo.y2RangeFilter;
    selectedXGroups = widget.displayInfo.selectedXGroups;
    selectedXSubGroups = widget.displayInfo.selectedXSubGroups;
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final SizedBox space = const SizedBox(height: 4,);
    return SizedBox(
      width: displayInfo.parentSize.width,
      height: displayInfo.parentSize.height - displayInfo.spacingHeight - kMinInteractiveDimensionCupertino,
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
              space,
              SliderTheme(
                data: SliderThemeData(
                  rangeThumbShape: RoundRangeSliderThumbShape(
                    enabledThumbRadius: 4
                  ),
                  overlayShape: RoundSliderThumbShape(
                    enabledThumbRadius: 4
                  )
                ),
                child: RangeSlider(
                  min: displayInfo.originalY1Min,
                  max: displayInfo.originalY1Max,
                  values: y1Range,
                  onChanged: (values){ setState(() {
                    y1Range = values;
                  }); },
                ),
              ),
              space,
              SizedBox(
                height: 17,
                child: Row(
                  children: [
                    Text(
                      'Start: ${y1Range.start.toStringAsFixed(2)}'
                    ),
                    Spacer(),
                    Text(
                      'End: ${y1Range.end.toStringAsFixed(2)}'
                    )
                  ],
                ),
              ),
              space,
              displayInfo.originalDataModel.type == BarChartType.GroupedSeparated
                  ? Text('Y2 Value Range')
                  : SizedBox(),
              displayInfo.originalDataModel.type == BarChartType.GroupedSeparated
                  ? space
                  : SizedBox(),
              displayInfo.originalDataModel.type == BarChartType.GroupedSeparated
                  ? SliderTheme(
                    data: SliderThemeData(
                      rangeThumbShape: RoundRangeSliderThumbShape(
                        enabledThumbRadius: 4
                      ),
                      overlayShape: RoundSliderThumbShape(
                        enabledThumbRadius: 4
                      )
                    ),
                    child: RangeSlider(
                      min: displayInfo.originalY2Min,
                      max: displayInfo.originalY2Max,
                      values: y2Range,
                      onChanged: (values){ setState(() {
                        y2Range = values;
                      }); },
                    ),
                  )
                  : SizedBox(),
              displayInfo.originalDataModel.type == BarChartType.GroupedSeparated
                  ? space
                  : SizedBox(),
              displayInfo.originalDataModel.type == BarChartType.GroupedSeparated
                  ? SizedBox(
                    height: 17,
                    child: Row(
                      children: [
                        Text(
                          'Start: ${y2Range.start.toStringAsFixed(2)}'
                        ),
                        Spacer(),
                        Text(
                          'End: ${y2Range.end.toStringAsFixed(2)}'
                        )
                      ],
                    ),
                  )
                  : space,
              displayInfo.originalDataModel.type == BarChartType.GroupedSeparated
                  ? space
                  : SizedBox(),
              Text('Groups'),
              Expanded(
                flex: 2,
                child: GridView.count(
                  physics: ClampingScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 2.5,
                  children: List.generate(displayInfo.originalDataModel.xGroups.length,
                    (index) {
                      final String groupName = displayInfo.originalDataModel.xGroups[index];
                      return GroupCheckBoxTitle(
                        groupName: groupName,
                        isSelected: selectedXGroups[groupName],
                        onPressed: (isSelected) {
                          setState(() {
                            selectedXGroups[groupName] = isSelected;
                          });
                        }
                      );
                    }
                  ),
                ),
              ),
              displayInfo.originalDataModel.xSubGroups.isNotEmpty && displayInfo.originalDataModel.type != BarChartType.GroupedSeparated
                  ? Text('Sub groups')
                  : SizedBox(),
              displayInfo.originalDataModel.xSubGroups.isNotEmpty && displayInfo.originalDataModel.type != BarChartType.GroupedSeparated
                  ? Expanded(
                    child: GridView.count(
                      physics: ClampingScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 2.5,
                      children: List.generate(displayInfo.originalDataModel.xSubGroups.length,
                        (index) {
                          final String groupName = displayInfo.originalDataModel.xSubGroups[index];
                          return GroupCheckBoxTitle(
                              groupName: groupName,
                              isSelected: selectedXSubGroups[groupName],
                              onPressed: (isSelected) {
                                setState(() {
                                  selectedXSubGroups[groupName] = isSelected;
                                });
                              }
                          );
                        }
                      ),
                    ),
                  )
                  : SizedBox(),
              space,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: 'Apply',
                    child: IconButton(
                      onPressed: () {
                        displayInfo.toggleFilterPanel();
                        displayInfo.setFilter(
                          y1Filter: y1Range,
                          y2Filter: y2Range,
                          xGroupFilter: selectedXGroups,
                          xSubGroupFilter: selectedXSubGroups,
                        );
                      },
                      icon: Icon(CupertinoIcons.checkmark),
                    ),
                  ),
                  Tooltip(
                    message: 'Reset all filters',
                    child: IconButton(
                      onPressed: () {
                        displayInfo.toggleFilterPanel();
                        displayInfo.setFilter(
                          y1Filter: RangeValues(displayInfo.originalY1Min, displayInfo.originalY1Max),
                          y2Filter: RangeValues(displayInfo.originalY2Min, displayInfo.originalY2Max),
                          xGroupFilter: new Map<String, bool>.from(displayInfo.originalSelectedXGroups),
                          xSubGroupFilter: new Map<String, bool>.from(displayInfo.originalSelectedXSubGroups),
                        );
                      },
                      icon: Icon(CupertinoIcons.clear),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}

@immutable
class GroupCheckBoxTitle extends StatelessWidget {
  const GroupCheckBoxTitle({
    Key key,
    @required this.groupName,
    @required this.isSelected,
    @required this.onPressed,
  }) : super(key: key);

  final String groupName;
  final bool isSelected;
  final Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: onPressed,
          activeColor: Colors.black12,
        ),
        Text(groupName),
      ],
    );
  }
}

