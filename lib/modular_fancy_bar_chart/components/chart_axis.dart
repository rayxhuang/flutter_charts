import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/bar_chart/bar_chart_data.dart';
import 'package:flutter_charts/bar_chart/bar_chart_style.dart';

class ChartAxisHorizontal extends StatefulWidget {
  final List<String> xGroups;
  final int numBarsInGroup;
  final double barWidth;
  final BarChartStyle style;
  final double axisLength;
  final ScrollController scrollController;

  const ChartAxisHorizontal({
    @required this.xGroups,
    @required this.numBarsInGroup,
    @required this.barWidth,
    @required this.axisLength,
    @required this.scrollController,
    this.style = const BarChartStyle(),
  });

  @override
  _ChartAxisHorizontalState createState() => _ChartAxisHorizontalState();

  Size get size => Size(axisLength, getHeight(style.xAxisStyle));
  double get xSectionLength => numBarsInGroup * barWidth + style.groupMargin * 2 + style.barMargin * (numBarsInGroup - 1);
  double get length {
    double length = axisLength;
    final double lengthNeeded =  xSectionLength * xGroups.length;
    if (lengthNeeded >= length) { length = lengthNeeded; }
    return length;
  }
  double get height => getHeight(style.xAxisStyle);
  static double getHeight(AxisStyle xAxisStyle) {
    // TODO safe to use sample character?
    TextPainter painter = TextPainter(
      text: TextSpan(text: 'I', style: xAxisStyle.tick.labelTextStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return painter.height + xAxisStyle.tick.tickLength + xAxisStyle.tick.tickMargin;
  }
}

class _ChartAxisHorizontalState extends State<ChartAxisHorizontal> {
  double length = 0;

  @override
  void initState() {
    super.initState();
    length = widget.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      width: widget.axisLength,
      height: widget.height,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: widget.scrollController,
        child: CustomPaint(
          painter: HorizontalAxisPainter(
            xGroups: widget.xGroups,
            axisStyle: widget.style.xAxisStyle,
          ),
          size: Size(length, widget.height),
        ),
      ),
    );
  }
}

@immutable
class HorizontalAxisPainter extends CustomPainter {
  final List<String> xGroups;
  final AxisStyle axisStyle;

  const HorizontalAxisPainter({
    @required this.xGroups,
    this.axisStyle = const AxisStyle(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final xGroupNum = xGroups.length;
    final double length = size.width;
    final axisPaint = Paint();
    axisPaint..color = axisStyle.axisColor;
    axisPaint..strokeWidth = axisStyle.strokeWidth;
    axisPaint..strokeCap = axisStyle.strokeCap;

    final Offset start = Offset(0, axisStyle.strokeWidth / 2);
    final Offset end = Offset(length, axisStyle.strokeWidth / 2);
    //final Offset start = Offset(0, 0);
    //final Offset end = Offset(length, 0);
    canvas.drawLine(start, end, axisPaint);

    final TickStyle tick = axisStyle.tick;
    final Paint tickPaint = Paint()
      ..strokeWidth = axisStyle.strokeWidth
      ..strokeCap = axisStyle.strokeCap
      ..color = tick.tickColor;
    final TextStyle tickTextStyle = tick.labelTextStyle;
    final TextPainter _textPainter = TextPainter(
      text: TextSpan(),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();

    final double xSectionLength = length / xGroupNum;
    Offset p1, p2, p3;
    List<Offset> tickPositions = [];
    // This does not draw the start and ending tick
    // TODO fix scrolling effect on tick
    for (int i = 1; i < xGroupNum; i++) {
      p1 = start.translate(i * xSectionLength, tickPaint.strokeWidth / 2);
      p2 = p1.translate(0, tick.tickLength);
      p3 = p2.translate(0, tick.tickMargin);
      tickPositions.add(p3);
      //Draw the tick line
      canvas.drawLine(p1, p2, tickPaint);
    }
    for (int i = 0; i < xGroupNum; i++) {
      final String groupName = xGroups[i];
      _textPainter.text = TextSpan(text: '$groupName', style: tickTextStyle);
      _textPainter.layout(maxWidth: xSectionLength);
      //Draw the tick value text
      _textPainter.paint(canvas, Offset(
          i * xSectionLength + (xSectionLength - _textPainter.width) / 2,
          tick.tickLength + tick.tickMargin
      ));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

@immutable
class ChartAxisVerticalWithLabel extends StatelessWidget {
  // This widget force display the label and data
  final TextStyle textStyle;
  final double axisHeight;
  final List<double> yValueRange;
  final AxisStyle axisStyle;

  ChartAxisVerticalWithLabel({
    @required this.axisHeight,
    @required this.yValueRange,
    this.axisStyle = const AxisStyle(),
    this.textStyle
  });

  Size get size => Size(getWidth(axisStyle.label.text, yValueRange[1], axisStyle), axisHeight);

  static double getWidth(String axisLabel, double axisData, AxisStyle style) {
    return labelWidth(style.label) + axisWidth(axisData, style);
  }

  static double labelWidth(BarChartLabel label) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: label.text, style: label.textStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return label.text == '' ? 0 : 5 + painter.height;
  }

  static double axisWidth(double max, AxisStyle style) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: max.toStringAsFixed(style.tick.tickDecimal), style: style.tick.labelTextStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return painter.width + style.tick.tickMargin + style.tick.tickLength;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: axisHeight,
        width: size.width,
        child: Row(
          children: [
            RotatedBox(
              // TODO 1 or 3
              quarterTurns: 1,
              child: SizedBox(
                width: axisHeight,
                height: labelWidth(axisStyle.label),
                child: Center(
                  child: Text(
                    axisStyle.label.text,
                    style: axisStyle.label.textStyle,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: axisWidth(yValueRange[1], axisStyle),
              height: axisHeight,
              child: CustomPaint(
                  painter: VerticalAxisPainter(
                    valueRange: yValueRange,
                    axisStyle: axisStyle,
                  )
              ),
            ),
          ],
        )
    );
  }
}

@immutable
class VerticalAxisPainter extends CustomPainter {
  final List<double> valueRange;
  final AxisStyle axisStyle;
  final bool isLeft;

  const VerticalAxisPainter({
    @required this.valueRange,
    @required this.axisStyle,
    this.isLeft = true,
  }) : assert(valueRange != null);

  @override
  void paint(Canvas canvas, Size size) {
    final double length = size.height;
    final axisPaint = Paint();
    axisPaint..color = axisStyle.axisColor;
    axisPaint..strokeWidth = axisStyle.strokeWidth;
    axisPaint..strokeCap = axisStyle.strokeCap;

    final Offset start = Offset(size.width, 0);
    final Offset end = Offset(size.width, size.height);
    canvas.drawLine(start, end, axisPaint);
    //canvas.drawLine(end, end.translate(0, axisStyle.strokeWidth / 2), axisPaint..strokeCap = StrokeCap.square);

    final TickStyle tick = axisStyle.tick;
    final double lengthPerTick = length / (axisStyle.numTicks - 1);
    final double yMax = valueRange[1], yMin = valueRange[0];
    final double valuePerTick = (yMax - yMin) / (axisStyle.numTicks - 1);
    final Paint tickPaint = Paint()
      ..strokeWidth = axisStyle.strokeWidth
      ..strokeCap = axisStyle.strokeCap
      ..color = tick.tickColor;
    final TextStyle tickTextStyle = tick.labelTextStyle;
    final TextPainter _textPainter = TextPainter(
      text: TextSpan(),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();

    Offset p1, p2, p3, p4;
    if (!tick.onlyShowTicksAtTwoSides) {
      int _numTicksBetween = axisStyle.numTicks - 2;
      for (int i = 1; i < _numTicksBetween + 1; i++) {
        p1 = end.translate(0, -(i * lengthPerTick));    // p1 is the point on axis
        p2 = p1.translate(-tick.tickLength, 0);         // p2 is the point at the end of each tick
        p3 = p2.translate(-tick.tickMargin, 0);         // p3 is p2 + margin set by user

        //Draw the tick line
        canvas.drawLine(p1, p2, tickPaint);
        final String value = (yMin + i * valuePerTick).toStringAsFixed(tick.tickDecimal);
        _textPainter.text = TextSpan(text: '$value', style: tickTextStyle,);
        _textPainter.layout();
        //Draw the tick value text
        _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));
      }
    }

    //Draw start value
    p1 = end;
    p2 = p1.translate(-(tick.tickLength), 0);
    p3 = p2.translate(-tick.tickMargin, 0);
    canvas.drawLine(p1, p2, tickPaint);
    final String startText = yMin.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(text: '$startText', style: tickTextStyle,);
    _textPainter.layout();
    _textPainter.paint(canvas, p3.translate(-(_textPainter.width), -(_textPainter.height / 2)));

    //Draw end value
    p1 = start;
    p2 = p1.translate(-(tick.tickLength), 0);
    p3 = p2.translate(-tick.tickMargin, 0);
    canvas.drawLine(p1, p2, tickPaint);
    String endText;
    //If the user want last tick to show unit as text
    endText = yMax.toStringAsFixed(tick.tickDecimal);
    _textPainter.text = TextSpan(text: '$endText', style: tickTextStyle,);
    _textPainter.layout();
    p4 = p3.translate(-(_textPainter.width), -(_textPainter.height / 2));
    _textPainter.paint(canvas, p4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

@immutable
class ChartLabelHorizontal extends StatelessWidget {
  final String label;
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  const ChartLabelHorizontal({
    @required this.parentSize,
    this.heightInPercentage = 0.05,
    this.widthInPercentage = 0.7,
    this.label = '',
    this.textStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: parentSize.width * widthInPercentage,
      height: parentSize.height * heightInPercentage,
      child: Center(
        child: Text(
          label,
          style: textStyle,
        ),
      ),
    );
  }

  Size get size => Size(parentSize.width * widthInPercentage, parentSize.height * heightInPercentage);
}

@immutable
class ChartLabelVertical extends StatelessWidget {
  final String label;
  final TextStyle textStyle;
  final Size parentSize;
  final double widthInPercentage;
  final double heightInPercentage;

  const ChartLabelVertical({
    @required this.parentSize,
    this.widthInPercentage = 0.05,
    this.heightInPercentage = 0.7,
    this.label = '',
    this.textStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      // TODO 1 or 3
      quarterTurns: 1,
      child: FittedBox(
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
          width: parentSize.height * heightInPercentage,
          //height: parentSize.width * widthInPercentage,
          child: Center(
            child: Text(
              label,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }

  Size get size => Size(parentSize.width * widthInPercentage, parentSize.height * heightInPercentage);
}

@immutable
class VerticalAxisLabelPainter extends CustomPainter {
  final String axisLabel;
  final TextStyle labelTextStyle;

  const VerticalAxisLabelPainter({
    this.axisLabel = '',
    this.labelTextStyle = const TextStyle(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint labelPainter = Paint();
    labelPainter..color = labelTextStyle.color ?? Colors.black;
    final TextPainter _textPainter = TextPainter(
      text: TextSpan(text: axisLabel, style: labelTextStyle,),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
    final Offset offset = Offset(size.width / 2 - _textPainter.width / 2, 0);
    _textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}