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
              16,
              150,
              size.width - 16,
              size.height / 2,
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