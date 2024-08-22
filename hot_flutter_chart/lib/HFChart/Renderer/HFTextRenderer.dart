import 'dart:ui';

import 'package:flutter/material.dart';

import '../Canvas/HFCanvasExtension.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFProvider.dart';
import '../Providers/HFTextProvider.dart';
import 'HFRenderer.dart';

class HFTextRenderer extends HFRenderer {
  HFTextRenderer(HFProvider provider) : super(provider);

  @override
  void draw(HFRect inRect, Canvas canvas) {
    super.draw(inRect, canvas);

    HFTextProvider provider = this.provider as HFTextProvider;
    var data = provider.textDataInRect(inRect);

    Paint paint = Paint()..style = PaintingStyle.stroke;

    for (var index = 0; index < data.length; index++) {
      HFTextModel element = data[index];
      if (element.text.isNotEmpty) {
        paint.color = element.textColor;
        int drawOrigin = 0;
        switch (element.location) {
          case HFAxisLocation.head:
            drawOrigin = 0;
            break;
          case HFAxisLocation.middle:
            drawOrigin = 1;
            break;
          case HFAxisLocation.trail:
            drawOrigin = 2;
            break;
        }
        TextStyle textStyle = TextStyle(
            color: Colors.white, backgroundColor: paint.color, fontSize: 12);
        canvas.drawText(
            paint,
            element.text,
            Offset(element.textFrame.origin().x.toDouble(),
                element.textFrame.origin().y.toDouble()),
            textStyle: textStyle,
            drawOrigin: drawOrigin);
      }
    }
  }
}
