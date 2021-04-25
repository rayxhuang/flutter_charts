import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bar extends StatefulWidget {
  final bool useAnimation;
  final double height;
  final double width;
  final Color backgroundColor;

  Bar(
    {
      this.height = 300,
      this.width = 30,
      this.useAnimation = false,
      this.backgroundColor = Colors.blue,
    }
  );

  @override
  _BarState createState() => _BarState();
}

class _BarState extends State<Bar> {
  double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.width;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
      ),
      height: widget.useAnimation ? widget.height : 0,
      width: _width,
      clipBehavior: Clip.hardEdge,
      duration: const Duration(milliseconds: 1000),
      child: Material(
        color: widget.backgroundColor,
        child: InkWell(
          onTap: () {
            print('Pressed');
          },
        ),
      ),
    );
  }
}

class Bar2 extends AnimatedContainer {

}
