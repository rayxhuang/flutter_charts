import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
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

class _FilterPanelState extends State<FilterPanel> with StringSize {
  RangeValues y1Range, y2Range;
  Map<String, bool> selectedXGroups, selectedXSubGroups;
  final SizedBox _kSpaceHeight4 = const SizedBox(height: 4,);
  final SliderThemeData _kSliderThemeData = const SliderThemeData(
    rangeThumbShape: RoundRangeSliderThumbShape(
      enabledThumbRadius: 4
    ),
    overlayShape: RoundSliderThumbShape(
      enabledThumbRadius: 4
    )
  );
  
  @override
  void initState() {
    super.initState();
    y1Range = widget.displayInfo.y1RangeFilter;
    y2Range = widget.displayInfo.y2RangeFilter;
    selectedXGroups = widget.displayInfo.selectedXGroups;
    selectedXSubGroups = widget.displayInfo.selectedXSubGroups;
  }

  Widget _buildRangeSlider({
    @required double min,
    @required double max,
    @required String title,
    bool isY1 = true,
  }) {
    return Column(
      children: [
        Text(title),
        _kSpaceHeight4,
        SliderTheme(
          data: _kSliderThemeData,
          child: RangeSlider(
            min: min,
            max: max,
            values: isY1 ? y1Range : y2Range,
            onChanged: (values) => setState(() {
              isY1
                  ? y1Range = values
                  : y2Range = values;
            }),
          ),
        ),
        _kSpaceHeight4,
        _buildRangeSliderValueText(rangeValues: isY1 ? y1Range : y2Range),
        _kSpaceHeight4,
      ],
    );
  }

  Widget _buildRangeSliderValueText({
    @required RangeValues rangeValues,
  }){
    return SizedBox(
      height: 17,
      child: Row(
        children: [
          Text(
            'Start: ${rangeValues.start.toStringAsFixed(2)}'
          ),
          Spacer(),
          Text(
            'End: ${rangeValues.end.toStringAsFixed(2)}'
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelectionPanel({
    @required List<String> xGroups,
    @required String title,
    @required int crossAxisCount,
    @required double aspectRatio,
    bool isMainGroup = true,
    int flex = 1
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(title),
          _kSpaceHeight4,
          Expanded(
            child: GridView.count(
              physics: ClampingScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              children: List.generate(xGroups.length,
                (index) {
                  final String groupName = xGroups[index];
                  return GroupCheckBoxTitle(
                    groupName: groupName,
                    isSelected: isMainGroup ? selectedXGroups[groupName] : selectedXSubGroups[groupName],
                    onPressed: (isSelected) {
                      setState(() {
                        isMainGroup
                            ? selectedXGroups[groupName] = isSelected
                            : selectedXSubGroups[groupName] = isSelected;
                      });
                    }
                  );
                }
              ),
            ),
          ),
          _kSpaceHeight4,
        ],
      ),
    );
  }

  Widget _buildApplyAndClearButtons({
    @required DisplayInfo displayInfo,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          message: 'Apply',
          child: IconButton(
            onPressed: () {
              displayInfo.setFilter(
                y1Filter: y1Range,
                y2Filter: y2Range,
                xGroupFilter: selectedXGroups,
                xSubGroupFilter: selectedXSubGroups,
              );
            },
            icon: const Icon(CupertinoIcons.checkmark),
          ),
        ),
        Tooltip(
          message: 'Reset all filters',
          child: IconButton(
            onPressed: () {
              displayInfo.setFilter(
                y1Filter: RangeValues(displayInfo.originalY1Min, displayInfo.originalY1Max),
                y2Filter: RangeValues(displayInfo.originalY2Min, displayInfo.originalY2Max),
                xGroupFilter: new Map<String, bool>.from(displayInfo.originalSelectedXGroups),
                xSubGroupFilter: new Map<String, bool>.from(displayInfo.originalSelectedXSubGroups),
              );
            },
            icon: const Icon(CupertinoIcons.clear),
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount({
    @required DisplayInfo displayInfo,
    bool isMainGroup = true
  }) {
    final double longestGroupName = isMainGroup
        ? StringSize.getWidthOfString(displayInfo.longestGroupName, TextStyle())
        : StringSize.getWidthOfString(displayInfo.longestSubGroupName, TextStyle());
    // 48 is the default size of checkbox
    final double maxWidthForTile = longestGroupName + 48;
    // print(displayInfo.longestGroupName);
    // print(displayInfo.longestSubGroupName);
    // print(displayInfo.parentSize.width);
    // print(maxWidthForTile);
    // 24 is padding
    int crossAxisCount = (displayInfo.parentSize.width - 24) ~/ maxWidthForTile;
    //print(crossAxisCount);
    if (crossAxisCount == 0) {
      crossAxisCount = 1;
    }
    return crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final int xGroupCrossAxisCount = _getCrossAxisCount(displayInfo: displayInfo);
    final double xGroupWidthPerTile = (displayInfo.parentSize.width - 24) / xGroupCrossAxisCount;
    final double xGroupAspectRatio = xGroupWidthPerTile < displayInfo.parentSize.width
        ? xGroupWidthPerTile / 21
        : displayInfo.parentSize.width / 21;

    int xSubGroupCrossAxisCount;
    double xSubGroupWidthPerTile, xSubGroupAspectRatio;
    if (displayInfo.hasXSubGroups) {
      xSubGroupCrossAxisCount = _getCrossAxisCount(displayInfo: displayInfo, isMainGroup: false);
      xSubGroupWidthPerTile = (displayInfo.parentSize.width - 24) / xSubGroupCrossAxisCount;
      xSubGroupAspectRatio = xSubGroupWidthPerTile < displayInfo.parentSize.width
          ? xSubGroupWidthPerTile / 21
          : displayInfo.parentSize.width / 21;
    }
    return SizedBox(
      width: displayInfo.parentSize.width,
      height: displayInfo.filterPanelHeight,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRangeSlider(
                min: displayInfo.originalY1Min,
                max: displayInfo.originalY1Max,
                title: 'Y1 Value Range',
              ),
              displayInfo.hasYAxisOnTheRight
                  ? _buildRangeSlider(
                    min: displayInfo.originalY2Min,
                    max: displayInfo.originalY2Max,
                    title: 'Y2 Value Range',
                    isY1: false,
                  )
                  : SizedBox(),
              _buildGroupSelectionPanel(
                title: 'Groups',
                xGroups: displayInfo.originalDataModel.xGroups,
                crossAxisCount: xGroupCrossAxisCount,
                aspectRatio: xGroupAspectRatio,
                flex: 2
              ),
              displayInfo.hasXSubGroups
                  ? _buildGroupSelectionPanel(
                    title: 'Sub Groups',
                    xGroups: displayInfo.originalDataModel.xSubGroups,
                    crossAxisCount: xSubGroupCrossAxisCount,
                    aspectRatio: xSubGroupAspectRatio,
                    isMainGroup: false,
                  )
                  : SizedBox(),
              _kSpaceHeight4,
              _buildApplyAndClearButtons(displayInfo: displayInfo),
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
        Text(
          groupName,
          // TODO Fix overflow
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

