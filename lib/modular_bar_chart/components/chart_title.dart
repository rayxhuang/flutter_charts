import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/components/chart_filter_panel.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

@immutable
class ChartTitle extends StatelessWidget with StringSize {
  const ChartTitle();

  void _toggleToolBar(DisplayInfo displayInfo) => displayInfo.toggleToolBar();

  void _toggleAverageLine(DisplayInfo displayInfo) => displayInfo.toggleAverageLine();

  void _toggleValueOnBar(DisplayInfo displayInfo) => displayInfo.toggleValueOnBar();

  void _toggleGridLine(DisplayInfo displayInfo) => displayInfo.toggleGridLine();

  void _toggleFilterPanel(DisplayInfo displayInfo) => displayInfo.toggleFilterPanel();

  Widget _buildMiniTitle(BarChartLabel label, double width) {
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

  Widget _buildInteractiveTitleBar(BarChartLabel label, double width, bool showToolBar) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showToolBar
            ? ChartToolBar(
              toggleToolBar: _toggleToolBar,
              toggleAverageLine: _toggleAverageLine,
              toggleValueOnBar: _toggleValueOnBar,
              toggleGridLine: _toggleGridLine,
              toggleFilterPanel: _toggleFilterPanel,
              w: width,
            )
            : SizedBox(
              width: width,
              height: kMinInteractiveDimensionCupertino,
              child: ChartTitleBar(
                label: label,
                onPressed: _toggleToolBar,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayInfo>(
      builder: (context, displayInfo, child) {
        final BarChartLabel label = displayInfo.style.title;
        if (displayInfo.style.isMini) {
          return _buildMiniTitle(label, displayInfo.parentSize.width);
        } else {
          return _buildInteractiveTitleBar(label,displayInfo.parentSize.width, displayInfo.showToolBar);
        }
      },
    );
  }
}

@immutable
class ChartTitleBar extends StatelessWidget {
  const ChartTitleBar({
    @required this.label,
    @required this.onPressed
  });

  final BarChartLabel label;
  final Function(DisplayInfo) onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      key: UniqueKey(),
      children: [
        Spacer(),
        Text(
          label.text,
          style: label.textStyle.copyWith(
            fontSize: 20,
          ),
        ),
        SizedBox(width: 4),
        ChartToolBarButton(
          icon: CupertinoIcons.chevron_down,
          onPressed: () => onPressed(context.read<DisplayInfo>()),
          message: 'Options',
        ),
        Spacer(),
      ],
    );
  }
}

@immutable
class ChartToolBar extends StatelessWidget {
  const ChartToolBar({
    Key key,
    @required this.toggleToolBar,
    @required this.toggleAverageLine,
    @required this.toggleValueOnBar,
    @required this.toggleGridLine,
    @required this.toggleFilterPanel,
    this.w
  }) : super(key: key);

  final Function(DisplayInfo) toggleToolBar;
  final Function(DisplayInfo) toggleAverageLine;
  final Function(DisplayInfo) toggleValueOnBar;
  final Function(DisplayInfo) toggleGridLine;
  final Function(DisplayInfo) toggleFilterPanel;
  final double w;

  Widget _buildLeftDisplayText(DisplayInfo displayInfo) {
    return Text(
      displayInfo.leftDisplayText,
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }

  Widget _buildRightDisplayText(DisplayInfo displayInfo) {
    return Text(
      displayInfo.rightDisplayText,
    );
  }

  Widget _buildAvgLineButton(DisplayInfo displayInfo) {
    return ChartToolBarButton(
      icon: CupertinoIcons.minus,
      onPressed: () => toggleAverageLine(displayInfo),
      message: 'Show average line',
    );
  }

  Widget _buildValueOnBarButton(DisplayInfo displayInfo) {
    return ChartToolBarButton(
      icon: CupertinoIcons.textformat_123,
      onPressed: () => toggleValueOnBar(displayInfo),
      message: 'Show value on bar',
    );
  }

  Widget _buildGridLineButton(DisplayInfo displayInfo) {
    return ChartToolBarButton(
      icon: CupertinoIcons.line_horizontal_3,
      onPressed: () => toggleGridLine(displayInfo),
      message: 'Show grid line',
    );
  }

  Widget _buildGoBackButton(DisplayInfo displayInfo) {
    return ChartToolBarButton(
      icon: CupertinoIcons.chevron_compact_up,
      onPressed: () => toggleToolBar(displayInfo),
      message: 'Go back',
    );
  }

  Widget _buildFilterButton(DisplayInfo displayInfo) {
    return ChartToolBarButton(
      icon: CupertinoIcons.slider_horizontal_3,
      onPressed: () => toggleFilterPanel(displayInfo),
      message: 'Filter data',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DisplayInfo>(
      builder: (context, displayInfo, child) {
        final double maxLengthOfDisplayText = [
          StringSize.getWidthOfString(displayInfo.leftDisplayText, TextStyle()),
          StringSize.getWidthOfString(displayInfo.rightDisplayText, TextStyle())
        ].reduce(max);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: !displayInfo.showFilterPanel
              ? SizedBox(
                height: kMinInteractiveDimensionCupertino,
                width: w,
                child: Row(
                  children: [
                    SizedBox(
                      width: maxLengthOfDisplayText,
                      child: _buildLeftDisplayText(displayInfo),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildValueOnBarButton(displayInfo),
                          _buildAvgLineButton(displayInfo),
                          _buildGridLineButton(displayInfo),
                          _buildFilterButton(displayInfo),
                          _buildGoBackButton(displayInfo),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: maxLengthOfDisplayText,
                      child: _buildRightDisplayText(displayInfo),
                    ),
                  ],
                ),
              )
              //: FilterPanel(),
              : Column(
                children: [
                  SizedBox(
                    height: kMinInteractiveDimensionCupertino,
                    width: w,
                    child: Row(
                      children: [
                        SizedBox(
                          width: maxLengthOfDisplayText,
                          child: _buildLeftDisplayText(displayInfo),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildValueOnBarButton(displayInfo),
                              _buildAvgLineButton(displayInfo),
                              _buildGridLineButton(displayInfo),
                              _buildFilterButton(displayInfo),
                              _buildGoBackButton(displayInfo),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: maxLengthOfDisplayText,
                          child: _buildRightDisplayText(displayInfo),
                        ),
                      ],
                    ),
                  ),
                  FilterPanel(yMin: displayInfo.y1Min, yMax: displayInfo.y1Max,),
                ],
              )
        );
      },
    );
  }
}

@immutable
class ChartToolBarButton extends StatelessWidget {
  const ChartToolBarButton({
    Key key,
    @required this.icon,
    @required this.onPressed,
    @required this.message,
  }) : super(key: key);

  final IconData icon;
  final Function onPressed;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Material(
        color: Colors.white10,
        clipBehavior: Clip.hardEdge,
        shape: CircleBorder(side: BorderSide(color: Colors.black12)),
        elevation: 16,
        child: Tooltip(
          message: message,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            iconSize: 24,
            icon: Icon(
              icon,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
