part of document_selfie_verification.widgets;

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
              40,
              size.width - 48,
              size.height - (size.height / 2.5),
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

class CicularButtonPainter extends CustomPainter {
  CicularButtonPainter(this.color);

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;

    Path path = Path.combine(
      PathOperation.difference,
      Path()
        ..addOval(
          const Rect.fromLTRB(
            0,
            0,
            64,
            64,
          ),
        ),
      Path()
        ..addOval(
          const Rect.fromLTRB(
            5,
            5,
            50 + 10,
            50 + 10,
          ),
        )
        ..close(),
    );
    canvas
      ..drawPath(path, paint)
      ..drawPath(
          Path()
            ..addOval(
              const Rect.fromLTRB(
                10,
                10,
                40 + 15,
                40 + 15,
              ),
            ),
          paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
