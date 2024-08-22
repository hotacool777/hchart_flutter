import 'dart:ui';

import '../Canvas/HFCanvasExtension.dart';
import '../Model/HFChartModel.dart';
import '../Model/HFGraphicFoundation.dart';
import '../Providers/HFLineProvider.dart';
import '../Providers/HFProvider.dart';
import 'HFRenderer.dart';

class HFLineRenderer extends HFRenderer {
  HFLineRenderer(HFProvider provider) : super(provider);

  @override
  void draw(HFRect inRect, Canvas canvas) {
    super.draw(inRect, canvas);
    HFLineProvider provider = this.provider as HFLineProvider;
    var data = provider.lineDataInRect(inRect);

    Paint paint = Paint()..style = PaintingStyle.stroke;
//print('HFLineRenderer' + data.toString());
    for (var index = 0; index < data.length; index++) {
      HFLineModel element = data[index];
      paint.color = element.lineColor;
      paint.strokeWidth = element.lineBolder;
      var points = element.points;
      // print('paints: ' + points.toString());
      if (points.isNotEmpty) {
        if (element.isDash) {
          // TODO: 暂时只支持两点绘制虚线
          canvas.drawDash(
              paint,
              Offset(points.first.x.toDouble(), points.first.y.toDouble()),
              Offset(points.last.x.toDouble(), points.last.y.toDouble()));
        } else {
          if (element.isGradient) {
            canvas.hf_drawShaderPoints(paint, points, inRect.rect());
          } else {
            canvas.hf_drawPoints(paint, points);
          }
        }
      }
    }
  }
}
