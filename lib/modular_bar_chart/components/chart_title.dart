import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_event.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';

class ChartTitle extends StatefulWidget with StringSize {
  final double width;
  final bool hasRightAxis;

  const ChartTitle({
    @required this.width,
    this.hasRightAxis = false,
  });

  @override
  _ChartTitleState createState() => _ChartTitleState();
}

class _ChartTitleState extends State<ChartTitle> {
  bool showToolbar;

  @override
  void initState() {
    super.initState();
    showToolbar = false;
  }

  void _toggleToolBar() => setState(() { showToolbar = !showToolbar; });

  void _toggleAverageLine(BarChartEvent event) => event.toggleAverageLine(hasRightAxis: widget.hasRightAxis);

  void _toggleValueOnBar(BarChartEvent event) => event.toggleValueOnBar();

  void _toggleGridLine(BarChartEvent event) => event.toggleGridLine();

  Widget _buildMiniTitle(BarChartLabel label) {
    return SizedBox(
      width: widget.width,
      height: StringSize.getHeight(label),
      child: Center(
        child: Text(
          label.text,
          style: label.textStyle,
        ),
      ),
    );
  }

  Widget _buildInteractiveTitleBar(BarChartLabel label) {
    return SizedBox(
      width: widget.width,
      height: kMinInteractiveDimensionCupertino,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showToolbar
            ? ChartToolBar(
              onPressed: _toggleToolBar,
              toggleAverageLine: _toggleAverageLine,
              toggleValueOnBar: _toggleValueOnBar,
              toggleGridLine: _toggleGridLine,
            )
            : ChartTitleBar(
              label: label,
              onPressed: _toggleToolBar,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final BarChartLabel label = displayInfo.style.title;
    if (displayInfo.style.isMini) {
      return _buildMiniTitle(label);
    } else {
      return _buildInteractiveTitleBar(label);
    }
  }
}

@immutable
class ChartTitleBar extends StatelessWidget {
  const ChartTitleBar({
    @required this.label,
    @required this.onPressed
  });

  final BarChartLabel label;
  final VoidCallback onPressed;

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
          onPressed: onPressed,
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
    @required this.onPressed,
    @required this.toggleAverageLine,
    @required this.toggleValueOnBar,
    @required this.toggleGridLine,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Function(BarChartEvent) toggleAverageLine;
  final Function(BarChartEvent) toggleValueOnBar;
  final Function(BarChartEvent) toggleGridLine;

  @override
  Widget build(BuildContext context) {
    return Consumer<BarChartEvent>(
      builder: (context, event, child) {
        final double maxLengthOfDisplayText = [
          StringSize.getWidthOfString(event.leftDisplayText, TextStyle()),
          StringSize.getWidthOfString(event.rightDisplayText, TextStyle())
        ].reduce(max);
        return Row(
          children: [
            SizedBox(
              width: maxLengthOfDisplayText,
              child: Text(
                event.leftDisplayText,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChartToolBarButton(
                    icon: CupertinoIcons.minus,
                    onPressed: () => toggleAverageLine(event),
                    message: 'Show average line',
                  ),
                  ChartToolBarButton(
                    icon: CupertinoIcons.textformat_123,
                    onPressed: () => toggleValueOnBar(event),
                    message: 'Show value on bar',
                  ),
                  ChartToolBarButton(
                    icon: CupertinoIcons.line_horizontal_3,
                    onPressed: () => toggleGridLine(event),
                    message: 'Show grid line',
                  ),
                  ChartToolBarButton(
                    icon: CupertinoIcons.chevron_compact_up,
                    onPressed: onPressed,
                    message: 'Go back',
                  ),
                ],
              ),
            ),
            SizedBox(
              width: maxLengthOfDisplayText,
              child: Text(
                event.rightDisplayText
              ),
            ),
          ],
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
