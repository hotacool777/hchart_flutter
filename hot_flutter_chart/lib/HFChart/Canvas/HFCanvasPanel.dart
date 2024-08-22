import 'package:flutter/cupertino.dart';

class HFCanvasPanel extends StatelessWidget {
  late final Function(Canvas canvas, Size size) drawRect;
  final Size size; // panel size

  HFCanvasPanel(this.drawRect, this.size);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomImagePainter(drawRect),
      child: Container(
        height: size.height,
      ),
    );
  }
}

class CustomImagePainter extends CustomPainter {
  late Function(Canvas canvas, Size size) drawRect;

  CustomImagePainter(this.drawRect);

  @override
  void paint(Canvas canvas, Size size) {
    drawRect(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      this != oldDelegate;
}
