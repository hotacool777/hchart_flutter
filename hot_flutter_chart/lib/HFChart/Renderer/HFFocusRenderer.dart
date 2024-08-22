import 'package:flutter/material.dart';

import '../Canvas/HFCanvasExtension.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFFocusProvider.dart';
import '../Providers/HFProvider.dart';
import 'HFRenderer.dart';

const double HF_Focus_Alert_width = 145;

class HFFocusRenderer extends HFRenderer {
  HFFocusRenderer(HFProvider provider) : super(provider);

  @override
  void draw(HFRect inRect, Canvas canvas) {
//print('HFFocusRenderer: $inRect');
    // TODO: implement draw
    super.draw(inRect, canvas);

    HFFocusProvider provider = this.provider as HFFocusProvider;
    var data = provider.focusDataInRect(inRect);

    Paint paint = Paint()..style = PaintingStyle.stroke;

    for (var index = 0; index < data.length; index++) {
      HFFocusModel element = data[index];
      paint.color = element.lineColor;
      // cross
      if (element.point.isValid()) {
        var nowPoint = element.point;
        paint.color = element.lineColor;
        paint.strokeWidth = element.lineBolder;
        canvas.drawCross(
            paint,
            Size(inRect.width.toDouble(), inRect.height.toDouble()),
            Offset(element.point.x.toDouble(), element.point.y.toDouble()));

        // text
        TextStyle textStyle = TextStyle(
            color: Colors.white, backgroundColor: paint.color, fontSize: 10);
        var text = element.text;
        if (text.isNotEmpty) {
          canvas.drawText(paint, " $text ", Offset(0, nowPoint.y - 6),
              textStyle: textStyle);
        }
        text = element.extText;
        if (text.isNotEmpty) {
          canvas.drawText(paint, " $text ",
              Offset(nowPoint.x.toDouble(), inRect.height - 12),
              textStyle: textStyle, drawOrigin: 2);
        }

        // alert
        if (element.alertText.isNotEmpty) {
          // 默认显示左上角
          Offset topLeft =
              Offset(inRect.width.toDouble(), inRect.top.toDouble());
          if (nowPoint.x.toDouble() > inRect.width.toDouble() / 2) {
            // 超过width一半显示在右上
            topLeft = Offset(inRect.left.toDouble(), inRect.top.toDouble());
          }
          paintAlert(
              canvas,
              topLeft,
              Size(inRect.width.toDouble(), inRect.height.toDouble()),
              paint,
              element.alertText);
        }
      }
    }
  }

  // 信息提示框
  paintAlert(Canvas canvas, Offset offset, Size size, Paint paint,
      List<String> model) {
    var nowPoint = offset;
    Offset nowP = nowPoint;
    // TODO: 去除size硬编码
    double space = 8;
    Size rectSize = Size(145 + space, 84 + space);
    Offset point = Offset(
        nowP.dx >= size.width - rectSize.width
            ? nowP.dx - rectSize.width - space
            : nowP.dx,
        nowP.dy >= size.height - rectSize.height
            ? nowP.dy - rectSize.height - space
            : nowP.dy);
    Rect rect = Rect.fromLTWH(point.dx + space, point.dy + space,
        rectSize.width - space, rectSize.height - space);
    RRect outer = RRect.fromRectAndRadius(rect, const Radius.circular(8.0));
    // paint.color = Colors.white.withAlpha(200);
    // 背景色
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(outer, paint);
    // 画边框
    paint.color = Colors.red;
    paint.style = PaintingStyle.stroke;
    canvas.drawRRect(outer, paint);

    List<String> titles = ['', '最高: ', '最低: ', '开盘: ', '收盘: '];
    List<String> values = [
      HF_NULL_VALUE,
      HF_NULL_VALUE,
      HF_NULL_VALUE,
      HF_NULL_VALUE,
      HF_NULL_VALUE,
    ];
    if (model.length >= 4) {
      values = model;
    }
    Offset s = Offset(point.dx + space * 2, point.dy + space * 2);
    int index = 0;
    for (var element in titles) {
      paint.color = Colors.red;
      int width = canvas.drawText(paint, element, s);
      s = Offset(s.dx + width, s.dy);
      paint.color = Colors.black;
      canvas.drawText(paint, values[index], s);
      s = Offset(point.dx + space * 2, s.dy + 12);
      index++;
    }
  }
}
