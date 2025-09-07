import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class FloorplanPainter extends CustomPainter {
  final String? roboflowImageData; // Base64 image data from Roboflow
  final ui.Image? roboflowImage; // Decoded image from Roboflow

  FloorplanPainter({this.roboflowImageData, this.roboflowImage});

  @override
  void paint(Canvas canvas, Size size) {
    // If we have a Roboflow visualization image, draw it
    if (roboflowImage != null) {
      _paintRoboflowImage(canvas, size);
      return;
    }

    // Fallback to mock floorplan if no Roboflow image
    _paintMockFloorplan(canvas, size);
  }

  void _paintRoboflowImage(Canvas canvas, Size size) {
    if (roboflowImage == null) return;

    final paint = Paint()..filterQuality = FilterQuality.high;

    // Calculate scaling to fit the image within the available size
    final imageWidth = roboflowImage!.width.toDouble();
    final imageHeight = roboflowImage!.height.toDouble();

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledWidth = imageWidth * scale;
    final scaledHeight = imageHeight * scale;

    // Center the image
    final offsetX = (size.width - scaledWidth) / 2;
    final offsetY = (size.height - scaledHeight) / 2;

    final srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final destRect = Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledHeight);

    canvas.drawImageRect(roboflowImage!, srcRect, destRect, paint);
  }

  void _paintMockFloorplan(Canvas canvas, Size size) {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is FloorplanPainter) {
      return oldDelegate.roboflowImage != roboflowImage ||
          oldDelegate.roboflowImageData != roboflowImageData;
    }
    return true;
  }

  /// Creates a FloorplanPainter from base64 image data
  static Future<FloorplanPainter> fromBase64(String? base64Data) async {
    if (base64Data == null || base64Data.isEmpty) {
      return FloorplanPainter();
    }

    try {
      final bytes = base64Decode(base64Data);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      return FloorplanPainter(
        roboflowImageData: base64Data,
        roboflowImage: frame.image,
      );
    } catch (e) {
      // Return painter without image if decoding fails
      return FloorplanPainter();
    }
  }
}
