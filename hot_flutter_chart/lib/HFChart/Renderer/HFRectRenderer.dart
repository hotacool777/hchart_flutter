import 'dart:ui';

import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFProvider.dart';
import '../Providers/HFRectProvider.dart';
import 'HFRenderer.dart';

class HFRectRenderer extends HFRenderer {
  HFRectRenderer(HFProvider provider) : super(provider);

  @override
  void draw(HFRect inRect, Canvas canvas) {
    super.draw(inRect, canvas);

    HFRectProvider provider = this.provider as HFRectProvider;
    var data = provider.rectDataInRect(inRect);

    Paint paint = Paint()..style = PaintingStyle.stroke;

    for (var index = 0; index < data.length; index++) {
      HFRectModel element = data[index];
      paint.color = element.lineColor;
      if (element.isSolid) {
        paint.style = PaintingStyle.fill;
      } else {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = element.lineBolder;
      }
      // 柱体
      canvas.drawRect(element.candleRect.rect(), paint);
      // 上下影线
      paint.strokeWidth = 1; // 设置线宽
      canvas.drawLine(
          Offset(element.lineUp.start.x.toDouble(),
              element.lineUp.start.y.toDouble()),
          Offset(
              element.lineUp.end.x.toDouble(), element.lineUp.end.y.toDouble()),
          paint);

      canvas.drawLine(
          Offset(element.lineDown.start.x.toDouble(),
              element.lineDown.start.y.toDouble()),
          Offset(element.lineDown.end.x.toDouble(),
              element.lineDown.end.y.toDouble()),
          paint);
    }
  }
}
