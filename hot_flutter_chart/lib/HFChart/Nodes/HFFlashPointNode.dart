import 'package:flutter/material.dart';

import '../Model/HFGraphicFoundation.dart';
import 'HFChartNode.dart';

class HFFlashPointNode extends HFChartNode {
  HFPoint flashPoint = HFPoint.INVALID_POINT;

  AnimationController? controller;
  double opacity = 1;

  HFFlashPointNode(Canvas canvas) : super(canvas);

  @override
  void setNeedsDisplay() {
    super.setNeedsDisplay();
    // 画闪烁点。依赖lineDrawingData，需放到lineRenderer后。
    if (flashPoint.isValid() && !flashPoint.isZero()) {
      Offset point = Offset(flashPoint.x.toDouble(), flashPoint.y.toDouble());
      startAnimation();
      Paint realTimePaint = Paint()
            ..strokeWidth = 1.0
            ..isAntiAlias = true,
          pointPaint = Paint();
      Gradient pointGradient = RadialGradient(
          colors: [Colors.white.withOpacity(opacity), Colors.transparent]);
      pointPaint.shader = pointGradient
          .createShader(Rect.fromCircle(center: point, radius: 14.0));
      canvas.drawCircle(point, 14.0, pointPaint);
      canvas.drawCircle(point, 2.0, realTimePaint..color = Colors.white);
    } else {
      stopAnimation();
    }
  }

  startAnimation() {
    if (controller?.isAnimating != true) controller?.repeat(reverse: true);
  }

  stopAnimation() {
    if (controller?.isAnimating == true) controller?.stop();
  }
}
