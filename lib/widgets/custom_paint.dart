part of document_selfie_verification.widgets;

class DocumentPainter extends CustomPainter {
  DocumentPainter(this.color);

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;

    Paint cornersCombine = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    double cornerValue = 50;

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
          ..addRRect(
            RRect.fromLTRBR(
              64,
              32,
              size.width - 32,
              size.height - 32,
              const Radius.circular(10),
            ),
          )
          ..close(),
      ),
      paint,
    );

    Path baseCorners = Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(
          RRect.fromLTRBR(
            124,
            44,
            size.width - 96,
            size.height - 44,
            const Radius.circular(10),
          ),
        ),
      Path()
        ..addRRect(
          RRect.fromLTRBR(
            124 + 4,
            44 + 4,
            size.width - (96 + 4),
            size.height - (44 + 4),
            const Radius.circular(10),
          ),
        )
        ..close(),
    );

    Path removeVerticalLines = Path.combine(
      PathOperation.difference,
      baseCorners,
      Path()
        ..addRRect(
          RRect.fromLTRBR(
            124 + cornerValue,
            44,
            size.width - (96 + cornerValue),
            size.height - 44,
            const Radius.circular(0),
          ),
        )
        ..close(),
    );

    Path removeHorizontalLines = Path.combine(
      PathOperation.difference,
      removeVerticalLines,
      Path()
        ..addRRect(
          RRect.fromLTRBR(
            124,
            44 + cornerValue,
            size.width - 96,
            size.height - (44 + cornerValue),
            const Radius.circular(0),
          ),
        )
        ..close(),
    );

    canvas.drawPath(removeHorizontalLines, cornersCombine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SelfiePainter extends CustomPainter {
  SelfiePainter(this.color);

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
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
    Paint paint = Paint()..color = color;

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
        paint,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
