part of document_verification.widgets;

class DocumentPainter extends CustomPainter {
  DocumentPainter(this.color);

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

class SelfiePainter extends CustomPainter {
  SelfiePainter(this.color);

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(
            RRect.fromLTRBR(
              0,
              0,
              size.width,
              size.height,
              const Radius.circular(0),
            ),
          ),
        Path()
          ..addOval(
            Rect.fromLTRB(
              48,
              48,
              size.width - 48,
              size.height - (size.height / 5) * 2.2,
            ),
          )
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
