import 'package:flutter/material.dart';

import '../Canvas/HFCanvasExtension.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFAxisProvider.dart';
import '../Providers/HFProvider.dart';
import 'HFRenderer.dart';

class HFAxisRenderer extends HFRenderer {
  HFAxisType axisType = HFAxisType.x;
  num axisCnt = 0;

  HFAxisRenderer(HFProvider provider) : super(provider);

  @override
  void draw(HFRect inRect, Canvas canvas) {
    super.draw(inRect, canvas);

    HFAxisProvider provider = this.provider as HFAxisProvider;
    var data = [];
    if (axisType == HFAxisType.x) {
      data = provider.xAxisDataInRect(inRect);
    } else {
      data = provider.yAxisDataInRect(inRect);
    }

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    for (var index = 0; index < data.length; index++) {
      HFAxisModel element = data[index];
      paint.color = element.lineColor;
      paint.strokeWidth = element.lineBolder;

      if (index == 0 || index == data.length - 1) {
        // 首尾实线
        canvas.drawLine(
            Offset(element.line.start.x.toDouble(),
                element.line.start.y.toDouble()),
            Offset(
                element.line.end.x.toDouble(), element.line.end.y.toDouble()),
            paint);
      } else {
        paint.color = element.lineColor;
        if (element.dash.isNotEmpty) {
          canvas.drawDash(
              paint,
              Offset(element.line.start.x.toDouble(),
                  element.line.start.y.toDouble()),
              Offset(element.line.end.x.toDouble(),
                  element.line.end.y.toDouble()));
        } else {
          canvas.drawLine(
              Offset(element.line.start.x.toDouble(),
                  element.line.start.y.toDouble()),
              Offset(
                  element.line.end.x.toDouble(), element.line.end.y.toDouble()),
              paint);
        }
      }
      // print('line: ${element.lineColor}');
      if (element.text.isNotEmpty) {
        paint.color = element.textColor;
        TextStyle textStyle = TextStyle(
            color: Colors.white, backgroundColor: paint.color, fontSize: 10);
        canvas.drawText(
            paint,
            element.text,
            Offset(element.textFrame.origin().x.toDouble(),
                element.textFrame.origin().y.toDouble()),
            textStyle: textStyle);
      }

      if (element.extText.isNotEmpty) {
        paint.color = element.extTextColor;
        TextStyle textStyle = TextStyle(
            color: Colors.white, backgroundColor: paint.color, fontSize: 10);
        canvas.drawText(
            paint,
            element.extText,
            Offset(element.extTextFrame.origin().x.toDouble(),
                element.extTextFrame.origin().y.toDouble()),
            textStyle: textStyle,
            drawOrigin: 2);
      }
    }
  }
}
