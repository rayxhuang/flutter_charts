import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_display_info.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class MiniCanvasInViewContainer extends StatefulWidget {
  final LinkedScrollControllerGroup controllerGroup;
  final Size inViewContainerSize;
  final double inViewContainerMovingDistance;

  const MiniCanvasInViewContainer({
    @required this.controllerGroup,
    @required this.inViewContainerSize,
    @required this.inViewContainerMovingDistance
  });

  @override
  _MiniCanvasInViewContainerState createState() => _MiniCanvasInViewContainerState();
}

class _MiniCanvasInViewContainerState extends State<MiniCanvasInViewContainer> {
  double scrollOffset;

  @override
  void initState() {
    super.initState();

    scrollOffset = 0;
    widget.controllerGroup.addOffsetChangedListener(() {
      setState(() { scrollOffset = widget.controllerGroup.offset; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final DisplayInfo displayInfo = context.read<DisplayInfo>();
    final Size containerSize = displayInfo.canvasWrapperSize;
    final double canvasWidth = displayInfo.canvasWidth;
    final double xLength = displayInfo.xTotalLength;
    final double inViewContainerOffset = (1 - scrollOffset / (xLength - canvasWidth));
    final Widget inViewContainerOnMiniCanvas = Container(
      width: widget.inViewContainerSize.width,
      height: widget.inViewContainerSize.height,
      color: Colors.white12,
    );
    return SizedBox.fromSize(
      size: containerSize,
      // TODO replace stack with align tomorrow
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: inViewContainerOffset * widget.inViewContainerMovingDistance,
            child: inViewContainerOnMiniCanvas,
          )
        ],
      ),
    );
  }
}
