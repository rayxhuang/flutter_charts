import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_event.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

@immutable
class ChartTitle extends StatefulWidget with StringSize {
  final double width;
  final bool isXAxisLabel;
  final bool hasRightAxis;

  // TODO Separate out x label
  const ChartTitle({
    @required this.width,
    this.isXAxisLabel = false,
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

  Size size(BarChartLabel title) =>
      Size(widget.width, StringSize.getHeight(title));

  @override
  Widget build(BuildContext context) {
    final BarChartLabel label = widget.isXAxisLabel
        ? context.read<BarChartStyle>().xAxisStyle.label
        : context.read<BarChartStyle>().title;
    return SizedBox(
      width: widget.width,
      height: StringSize.getHeight(label),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showToolbar
            ? ChartToolBar(
                onPressed: _toggleToolBar,
                toggleAverageLine: _toggleAverageLine,
              )
            : ChartTitleBar(label: label, onPressed: _toggleToolBar),
      ),
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
          style: label.textStyle,
        ),
        Material(
          color: Colors.white10,
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(side: BorderSide(color: Colors.black12)),
          elevation: 16,
          child: IconButton(
            padding: EdgeInsets.symmetric(horizontal: 4),
            onPressed: onPressed,
            icon: const Icon(
              CupertinoIcons.chevron_down,
              size: 12,
              color: Colors.white70,
            ),
          ),
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
  }) : super(key: key);

  final VoidCallback onPressed;
  final Function(BarChartEvent) toggleAverageLine;

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
                event.leftDisplayText
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChartToolBarButton(
                    icon: CupertinoIcons.minus,
                    onPressed: () => toggleAverageLine(event),
                  ),
                  ChartToolBarButton(
                    icon: CupertinoIcons.chevron_up,
                    onPressed: onPressed,
                  ),
                  ChartToolBarButton(
                    icon: CupertinoIcons.chevron_up,
                    onPressed: onPressed,
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
  }) : super(key: key);

  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white10,
      clipBehavior: Clip.hardEdge,
      shape: CircleBorder(side: BorderSide(color: Colors.black12)),
      elevation: 16,
      child: IconButton(
        padding: EdgeInsets.symmetric(horizontal: 0),
        onPressed: onPressed,
        iconSize: 12,
        icon: Icon(
          icon,
          color: Colors.white70,
        ),
      ),
    );
  }
}
