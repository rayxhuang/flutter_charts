// return MultiProvider(
//   providers: [
//     Provider<ModularBarChartData>(create: (_) => dataModel),
//     Provider<BarChartStyle>(create: (_) => style),
//     ChangeNotifierProvider<BarChartEvent>(create: (_) => BarChartEvent(dataModel: dataModel, style: style),),
//   ],
//   child: LayoutBuilder(builder: (context, constraint) {
//     ModularBarChartData dataModel = context.read<ModularBarChartData>();
//     BarChartStyle style = context.read<BarChartStyle>();
//     final Size parentSize = _getParentSize(constraint: constraint, context: context);
//
//     // Set max group name width
//     dataModel.setMaxGroupNameWidth(textStyle: style.xAxisStyle.tickStyle.labelTextStyle);
//
//     // Width information
//     final bool hasYAxisOnTheRight = type == BarChartType.GroupedSeparated;
//     final double leftAxisStaticWidth =
//       getVerticalAxisCombinedWidth(axisMaxValue: dataModel.y1ValueRange[1], style: style.y1AxisStyle, isMini: style.isMini);
//     final double rightAxisStaticWidth = hasYAxisOnTheRight
//         ? getVerticalAxisCombinedWidth(axisMaxValue: dataModel.y2ValueRange[1], style: style.y2AxisStyle, isMini: style.isMini)
//         : 0;
//     double canvasWidth = parentSize.width - leftAxisStaticWidth - rightAxisStaticWidth;
//     if (canvasWidth < 0) { canvasWidth = 0; }
//     // Adjust xSectionLength and bar width in case of user-set bar width is too small
//     final List<double> xSectionLength =
//       calculateXSectionLength(dataModel: dataModel, style: style, canvasWidth: canvasWidth);
//     final double barWidth = xSectionLength.length == 2
//         ? xSectionLength[1]
//         : style.barStyle.barWidth;
//
//     // Height information
//     final double titleStaticHeight = StringSize.getHeight(style.title);
//     // TODO
//     final double spacingStaticHeight = 0.5 * StringSize.getHeightOfString('I', style.y1AxisStyle.tickStyle.labelTextStyle);
//     // TODO
//     double a = 2 * StringSize.getHeightOfString('I', style.xAxisStyle.tickStyle.labelTextStyle);
//     final List<double> bottomAxisHeightInformation = getXRotatedHeight(
//       axisStyle: style.xAxisStyle,
//       nameMaxWidth: dataModel.maxGroupNameWidth + a - a,
//       nameMaxWidthWithSpace: dataModel.maxGroupNameWidthWithSpace,
//       xSectionLength: xSectionLength[0],
//     );
//     final double bottomAxisStaticHeight = bottomAxisHeightInformation[0] + style.xAxisStyle.tickStyle.tickLength + style.xAxisStyle.tickStyle.tickMargin;
//     final double bottomLabelStaticHeight = style.isMini ? 0 : StringSize.getHeight(style.xAxisStyle.label);
//     final double bottomLegendStaticHeight = style.legendStyle.visible && !style.isMini
//         ? StringSize.getHeightOfString('Title', style.legendStyle.legendTextStyle)
//         : 0;
//     //print(bottomLabelStaticHeight);
//     double canvasHeight = parentSize.height -
//         titleStaticHeight -
//         spacingStaticHeight -
//         bottomAxisStaticHeight -
//         bottomLabelStaticHeight -
//         bottomLegendStaticHeight;
//     if (canvasHeight < 0) { canvasHeight = 0; }
//     final Size canvasSize = Size(canvasWidth, canvasHeight);
//     // Adjust y Max to fit number on bar and populate data
//     _adjustVerticalAxisValueRange(canvasHeight: canvasHeight, hasYAxisOnTheRight: hasYAxisOnTheRight);
//     dataModel.populateDataWithMinimumValue();
//
//     // Canvas and bottom axis
//     Widget chartCanvasWithAxis;
//     Size chartCanvasWithAxisSize;
//     if (style.isMini) {
//       chartCanvasWithAxis = _buildMiniChart(canvasSize: canvasSize, dataModel: dataModel, style: style, barWidth: barWidth);
//       chartCanvasWithAxisSize = canvasSize;
//     } else {
//       final Size wrapperSize = Size(canvasWidth, canvasHeight + bottomAxisHeightInformation[0] + style.xAxisStyle.tickStyle.tickLength);
//       chartCanvasWithAxis = ChartCanvasWrapper(
//         size: wrapperSize,
//         labelInfo: bottomAxisHeightInformation,
//         canvasSize: canvasSize,
//         barWidth: barWidth,
//         displayMiniCanvas: barWidth == style.barStyle.barWidth ? true : false,
//         animation: style.animation,
//       );
//       chartCanvasWithAxisSize = wrapperSize;
//     }
//
//     // Left Axis
//     final ChartAxisVerticalWithLabel leftAxis = ChartAxisVerticalWithLabel(axisHeight: canvasHeight,);
//
//     // TODO Change the height of title in full mode
//     // Title
//     final ChartTitle chartTitle = ChartTitle(
//       width: parentSize.width,
//       hasRightAxis: hasYAxisOnTheRight,
//     );
//
//     // Bottom Label
//     final Widget bottomLabel = !style.isMini
//         ? ChartTitle(
//           width: canvasWidth,
//           isXAxisLabel: true,
//           hasRightAxis: hasYAxisOnTheRight,
//         )
//         : SizedBox();
//
//     // Bottom Legend
//     final Widget bottomLegend = style.legendStyle.visible && !style.isMini
//         ? ChartLegendHorizontal(width: canvasWidth)
//         : SizedBox();
//
//     // Right Axis
//     final Widget rightAxis = hasYAxisOnTheRight
//         ? ChartAxisVerticalWithLabel(
//           axisHeight: canvasHeight,
//           isRightAxis: true,
//         )
//         : SizedBox();
//
//     // TODO Too small to have a canvas?
//     return _buildChart(
//       parentSize: parentSize,
//       canvasSize: chartCanvasWithAxisSize,
//       title: chartTitle,
//       spacing: SizedBox(height: spacingStaticHeight,),
//       leftAxisWithLabel: leftAxis,
//       mainCanvasWithBottomAxis: chartCanvasWithAxis,
//       bottomLabel: bottomLabel,
//       bottomLegend: bottomLegend,
//       rightAxisWithLabel: rightAxis,
//       titleHeight: titleStaticHeight,
//       spacingHeight: spacingStaticHeight,
//       leftAxisWidth: leftAxisStaticWidth,
//       bottomLabelHeight: bottomLabelStaticHeight,
//     );
//   }),
// );
// List<double> getXRotatedHeight({
//   @required AxisStyle axisStyle,
//   @required double nameMaxWidth,
//   @required double nameMaxWidthWithSpace,
//   @required double xSectionLength,
// }) {
//   double rotatedAngle = 0;
//   if (nameMaxWidth > xSectionLength) {
//     final double ratio = 2;
//     //final double maxHeight = xSectionLength * ratio;
//     double maxHeight = 30, maxRotatedAngle = 0, spaceLeft = 0;
//     bool success = false;
//     // print('got it');
//     // print(xSectionLength);
//     // print(maxHeight);
//     double maxCombineGroup = 3, numGroupsToBeCombined = 1;
//     for (int i = 1; i < maxCombineGroup + 1; i++) {
//       double w = i * xSectionLength;
//       if (w >= nameMaxWidth) {
//         // print('success at $i, simple width: $w');
//         // print('text len: $nameMaxWidth');
//         success = true;
//         numGroupsToBeCombined = i.toDouble();
//         final double tickLength = axisStyle.tickStyle.tickLength + axisStyle.tickStyle.tickMargin;
//         maxHeight = StringSize.getHeightOfString('I', axisStyle.tickStyle.labelTextStyle) + tickLength;
//         break;
//       }
//       double diagonalLength = sqrt(pow(w, 2) + pow(maxHeight, 2));
//       if (diagonalLength >= nameMaxWidthWithSpace) {
//         // print('success at $i, dia len: $diagonalLength');
//         // print('text len: $nameMaxWidthWithSpace');
//         maxRotatedAngle = asin(maxHeight / diagonalLength);
//         success = true;
//         numGroupsToBeCombined = i.toDouble();
//         spaceLeft = diagonalLength - nameMaxWidthWithSpace;
//         //print('space left: $spaceLeft');
//         break;
//       }
//     }
//     if (!success) {
//       maxRotatedAngle = asin(maxHeight / sqrt(pow(maxCombineGroup * xSectionLength, 2) + pow(maxHeight, 2)));
//       numGroupsToBeCombined = maxCombineGroup;
//     }
//     // print('success? $success');
//     // print('max angle: $maxRotatedAngle');
//     // print('groups combined: $numGroupsToBeCombined');
//     final List<double> result = [maxHeight, maxRotatedAngle, numGroupsToBeCombined, spaceLeft];
//     //print(result);
//     return result;
//   } else {
//     final double tickLength = axisStyle.tickStyle.tickLength + axisStyle.tickStyle.tickMargin;
//     return [
//       StringSize.getHeightOfString('I', axisStyle.tickStyle.labelTextStyle) + tickLength,
//       0,
//       1
//     ];
//   }
// }