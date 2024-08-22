import 'package:flutter/cupertino.dart';
import 'dart:math';

import '../Model/HFGraphicFoundation.dart';
import '../Utils/HFUtils.dart';

extension HFCanvasExtension on Canvas {
  /// 绘制文本。drawOrigin为绘制起点所在位置，0为左起，1为居中，2为右起。
  int drawText(Paint paint, String text, Offset from,
      {TextStyle? textStyle, int drawOrigin = 0}) {
    TextStyle ts = textStyle ?? TextStyle(color: paint.color, fontSize: 10);
    TextSpan span = TextSpan(text: text, style: ts);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset from_ = from;
    int textOffset = tp.size.width.toInt();
    switch (drawOrigin) {
      case 1:
        from_ = Offset(from_.dx - textOffset / 2, from_.dy);
        break;
      case 2:
        from_ = Offset(from_.dx - textOffset, from_.dy);
        break;
      default:
        break;
    }
    tp.paint(this, from_);
    return textOffset;
  }

  void drawLineWithOffset(Paint paint, Offset from, Offset to) {
    if (Point(from.dx, from.dy).distanceTo(Point(to.dx, to.dy)) > 1) {
      drawLine(from, to, paint);
    }
  }

  void drawDash(Paint paint, Offset from, Offset to,
      {int dashWidth = 5, int dashSpace = 5}) {
    // double max = (from.dx - to.dx) * (from.dx - to.dx) + (from.dy - to.dy) * (from.dy - to.dy);
    double max = Point(from.dx, from.dy).distanceTo(Point(to.dx, to.dy));

    double startX = from.dx;
    double startY = from.dy;
    int space = dashSpace + dashWidth;
    int num = max ~/ space;
    double h = (to.dy - from.dy).abs();
    double w = (to.dx - from.dx).abs();
    double sh = h / num;
    double sw = w / num;
    double d = dashWidth / space;
    double endx = startX + sw * d;
    double endy = startY + sh * d;

    double nowLength = 0;
    while (nowLength < max) {
      // double distance = Point(startX, startY).distanceTo(Point(sw, sh)) - dashSpace;
      drawLineWithOffset(paint, Offset(startX, startY), Offset(endx, endy));
      startX += sw;
      startY += sh;
      endx += sw;
      endy += sh;
      nowLength += space;
    }
  }

  void drawCross(
    Paint paint,
    Size size,
    Offset point,
  ) {
    drawDash(paint, Offset(0, point.dy), Offset(size.width, point.dy));
    drawDash(paint, Offset(point.dx, 0), Offset(point.dx, size.height));
  }

  /// 绘制连线
  void hf_drawPoints(Paint paint, List<HFPoint> points) {
    Path path = Path();
    bool isMove = false;
    for (var element in points) {
      if (element.y == HF_INVALID_VALUE) {
        isMove = false;
        // print('hf_drawPoints HF_INVALID_VALUE' + element.toString());
      } else {
        if (isMove) {
          path.lineTo(element.x.toDouble(), element.y.toDouble());
          // print('hf_drawPoints lineTo' + element.toString());
        }
        if (!isMove) {
          path.moveTo(element.x.toDouble(), element.y.toDouble());
          isMove = true;
          // print('hf_drawPoints ' + element.toString());
        }
      }
    }
    drawPath(path, paint);
  }

  /// 绘制带渐变阴影的连线
  void hf_drawShaderPoints(Paint paint, List<HFPoint> points, Rect chartRect) {
    // 绘制连线
    hf_drawPoints(paint, points);
    // 绘制阴影
    if (points.length < 2) {
      return;
    }
    final Paint mLineFillPaint = Paint();

    Shader mLineFillShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: kLineShadowColor,
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint.shader = mLineFillShader;

    Path mLineFillPath = Path();
    var p = points.first;
    mLineFillPath.moveTo(
        p.x.toDouble(), chartRect.height + chartRect.top); // 闭环起点
    for (var element in points) {
      if (element.y == HF_INVALID_VALUE) {
        // 遇到非法值直接退出不处理
        mLineFillPath.close();
        continue;
      } else {
        mLineFillPath.lineTo(element.x.toDouble(), element.y.toDouble());
      }
    }
    p = points.last;
    mLineFillPath.lineTo(
        p.x.toDouble(), chartRect.height + chartRect.top); // 闭环终点
    drawPath(mLineFillPath, mLineFillPaint);
    // mLineFillPath.reset();
  }
}
