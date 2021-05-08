import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

import '../chart_single_group_canvas.dart';

class MainCanvas extends StatefulWidget {
  final Size canvasSize;
  final double xSectionLength;
  final double barWidth;
  final BarChartAnimation animation;
  final ScrollController scrollController;

  const MainCanvas({
    @required this.canvasSize,
    @required this.xSectionLength,
    @required this.barWidth,
    @required this.animation,
    @required this.scrollController,
  });

  @override
  _MainCanvasState createState() => _MainCanvasState();
}

class _MainCanvasState extends State<MainCanvas> with SingleTickerProviderStateMixin, StringSize{
  // Interaction and animation
  int indexSelected, previousIndex;
  BarChartDataDouble barSelected;
  TapDownDetails tapDownDetails;
  List<OverlayEntry> barDetailOverlay;
  List<bool> needsRemoval;
  Animation<double> dataAnimation;
  AnimationController _dataAnimationController;

  @override
  void initState() {
    super.initState();
    barDetailOverlay = [];
    needsRemoval = [];
    previousIndex = 0;

    // Animation
    final Tween<double> _tween = Tween(begin: widget.animation.animateData ? 0 : 1, end: 1);
    _dataAnimationController = AnimationController(
      vsync: this,
      duration: widget.animation.dataAnimationDuration,
    );
    dataAnimation = _tween.animate(_dataAnimationController);
    _dataAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Size canvasSize = widget.canvasSize;
    final ModularBarChartData dataModel = context.read<ModularBarChartData>();
    return SizedBox.fromSize(
      size: canvasSize,
      child: ListView.builder(
        controller: widget.scrollController,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        itemCount: dataModel.xGroups.length,
        itemBuilder: (context, index) {
          return SingleGroupedCanvas(
            groupIndex: index,
            isSelected: index == indexSelected ? true : false,
            barSelected: barSelected,
            size: Size(widget.xSectionLength, canvasSize.height),
            barWidth: widget.barWidth,
            dataAnimation: dataAnimation,
            onBarSelected: (index, bar, details) {
              setState(() {
                _createOverlay(context: context, dataModel: dataModel, index: index, bar: bar, details: details);
              });
            },
          );
        },
      ),
    );
  }

  void _createOverlay({
    @required BuildContext context,
    @required ModularBarChartData dataModel,
    @required int index,
    @required BarChartDataDouble bar,
    @required TapDownDetails details,
  }) {
    OverlayState overlayState = Overlay.of(context);
    // Remove all the previous overlays
    for (int i = previousIndex; i < barDetailOverlay.length; i++) {
      if (needsRemoval[i]) {
        barDetailOverlay[i].remove();
        needsRemoval[i] = false;
      }
      previousIndex = i;
    }
    indexSelected = index;
    barSelected = bar;
    tapDownDetails = details;
    final currentBarDetailOverlay = OverlayEntry(
      builder: (context) {
        final String separatedGroupName = dataModel.type == BarChartType.GroupedSeparated
            ? bar.separatedGroupName
            : bar.group;
        final String detailString = (dataModel.type == BarChartType.Ungrouped)
            ? '${bar.group}: ${bar.data.toStringAsFixed(2)}'
            : '$separatedGroupName\n${dataModel.xGroups[index]}: ${bar.data.toStringAsFixed(2)}';
        final TextStyle detailTextStyle = const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        );
        final double width = StringSize.getWidthOfString(detailString, detailTextStyle) + 16;
        final double height = StringSize.getHeightOfString(detailString, detailTextStyle) + 10;
        return _buildOverlayWidget(
          tapDownDetails: details,
          height: height,
          width: width,
          detailString: detailString,
          detailTextStyle: detailTextStyle,
        );
      }
    );
    overlayState.insert(currentBarDetailOverlay);
    barDetailOverlay.add(currentBarDetailOverlay);
    needsRemoval.add(true);
    registerRemoval(barDetailOverlay.length - 1);
  }

  Widget _buildOverlayWidget({
    TapDownDetails tapDownDetails,
    double height,
    double width,
    String detailString,
    TextStyle detailTextStyle,
  }) {
    return Positioned(
      top: tapDownDetails.globalPosition.dy - height - 5,
      left: tapDownDetails.globalPosition.dx - width / 2,
      child: FittedBox(
        child: Material(
          type: MaterialType.canvas,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 8,
            ),
            child: Text(
              detailString,
              style: detailTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  void registerRemoval(int i) async {
    await Future.delayed(const Duration(seconds: 2)).then((_) => {
      if (needsRemoval[i]) {
        barDetailOverlay[i].remove(),
        needsRemoval[i] = false
      }
    });
  }
}
