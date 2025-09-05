import 'package:flutter/material.dart';

class FloorplanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw rooms outline
    paint.color = Colors.grey[600]!;

    // Living room
    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width * 0.6, size.height * 0.4),
      paint,
    );

    // Kitchen
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.65,
        20,
        size.width * 0.3,
        size.height * 0.25,
      ),
      paint,
    );

    // Bedroom 1
    canvas.drawRect(
      Rect.fromLTWH(
        20,
        size.height * 0.45,
        size.width * 0.35,
        size.height * 0.5,
      ),
      paint,
    );

    // Bedroom 2
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.45,
        size.width * 0.25,
        size.height * 0.35,
      ),
      paint,
    );

    // Bathroom
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.3,
        size.width * 0.25,
        size.height * 0.25,
      ),
      paint,
    );

    // Draw doors
    paint.color = Colors.brown;
    paint.strokeWidth = 3.0;

    // Door lines (simplified)
    canvas.drawLine(
      Offset(size.width * 0.3, 20),
      Offset(size.width * 0.35, 20),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.65, size.height * 0.2),
      paint,
    );

    // Draw furniture (simplified rectangles)
    paint.color = Colors.green[400]!;
    paint.style = PaintingStyle.fill;

    // Sofa
    canvas.drawRect(
      Rect.fromLTWH(40, 40, size.width * 0.2, size.height * 0.1),
      paint,
    );

    // Bed
    canvas.drawRect(
      Rect.fromLTWH(
        30,
        size.height * 0.6,
        size.width * 0.15,
        size.height * 0.2,
      ),
      paint,
    );

    // Table
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.25), 20, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
