import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/modular_bar_chart/mixin/string_size_mixin.dart';
import 'package:provider/provider.dart';

import 'package:flutter_charts/modular_bar_chart/data/bar_chart_data.dart';
import 'package:flutter_charts/modular_bar_chart/data/bar_chart_style.dart';

@immutable
class ChartTitle extends StatefulWidget with StringSize {
  final double width;
  final bool isXAxisLabel;

  const ChartTitle({
    @required this.width,
    this.isXAxisLabel = false,
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

  void _toggleToolBar() {
    setState(() { showToolbar = !showToolbar; });
  }

  void _toggleAverageLine() {

  }

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

// @immutable
// class ChartTitle extends StatelessWidget with StringSize{
//   final double width;
//   final bool isXAxisLabel;
//
//   const ChartTitle({
//     @required this.width,
//     this.isXAxisLabel = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final BarChartLabel label = isXAxisLabel
//         ? context.read<BarChartStyle>().xAxisStyle.label
//         : context.read<BarChartStyle>().title;
//     return SizedBox(
//       width: width,
//       height: StringSize.getHeight(label),
//       child: Center(
//         child: Row(
//           children: [
//             Spacer(),
//             Text(
//               label.text,
//               style: label.textStyle,
//             ),
//             SizedBox(
//               width: 12,
//               child: IconButton(
//                 onPressed: () {
//
//                 },
//                 padding: EdgeInsets.all(0),
//                 icon: Icon(
//                   Icons.arrow_drop_down_circle_outlined,
//                   size: 12,
//                 ),
//               ),
//             ),
//             Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Size size(BarChartLabel title) => Size(width, StringSize.getHeight(title));
// }

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
              //CupertinoIcons.chevron_down,
              CupertinoIcons.slider_horizontal_3,
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

class ChartToolBar extends StatelessWidget {
  const ChartToolBar({
    Key key,
    @required this.onPressed,
    @required this.toggleAverageLine,
  }) : super(key: key);

  final VoidCallback onPressed;
  final VoidCallback toggleAverageLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.white10,
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(side: BorderSide(color: Colors.black12)),
          elevation: 16,
          child: IconButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            onPressed: toggleAverageLine,
            iconSize: 12,
            icon: const Icon(
              CupertinoIcons.minus,
              color: Colors.white70,
            ),
          ),
        ),
        Material(
          color: Colors.white10,
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(side: BorderSide(color: Colors.black12)),
          elevation: 16,
          child: IconButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            onPressed: onPressed,
            iconSize: 12,
            icon: const Icon(
              CupertinoIcons.chevron_down,
              color: Colors.white70,
            ),
          ),
        ),
        Material(
          color: Colors.white10,
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(side: BorderSide(color: Colors.black12)),
          elevation: 16,
          child: IconButton(
            padding: EdgeInsets.symmetric(horizontal: 0),
            onPressed: onPressed,
            iconSize: 12,
            icon: const Icon(
              CupertinoIcons.chevron_down,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
