import 'package:flutter/material.dart';

class MyCustomPaint extends CustomPainter {
  MyCustomPaint(this.color);

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(RRect.fromLTRBR(
              0, 0, size.width, size.height, const Radius.circular(0))),
        Path()
          ..addRRect(
            RRect.fromLTRBR(
              64,
              32,
              size.width - 64,
              size.height - 32,
              const Radius.circular(10),
            ),
          )
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
