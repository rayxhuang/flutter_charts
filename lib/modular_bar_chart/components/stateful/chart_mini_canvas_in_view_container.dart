import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class InViewContainer extends StatefulWidget {
  final LinkedScrollControllerGroup controllerGroup;
  final Size containerSize;
  final Size inViewContainerSize;
  final double canvasWidth;
  final double xLength;
  final double inViewContainerMovingDistance;

  const InViewContainer({
    @required this.controllerGroup,
    @required this.containerSize,
    @required this.inViewContainerSize,
    @required this.xLength,
    @required this.canvasWidth,
    @required this.inViewContainerMovingDistance
  });

  @override
  _InViewContainerState createState() => _InViewContainerState();
}

class _InViewContainerState extends State<InViewContainer> {
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
    final double inViewContainerOffset = (1 - scrollOffset / (widget.xLength - widget.canvasWidth));
    final Widget inViewContainerOnMiniCanvas = Container(
      width: widget.inViewContainerSize.width,
      height: widget.inViewContainerSize.height,
      color: Colors.white12,
    );
    return SizedBox.fromSize(
      size: widget.containerSize,
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
