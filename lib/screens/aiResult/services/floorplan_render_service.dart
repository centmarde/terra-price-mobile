import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../aiResultsWidgets/floorplan_painter.dart';

class FloorplanRenderService {
  /// Render a FloorplanPainter to PNG bytes (headless/off-screen).
  static Future<Uint8List?> renderPainterToPng({
    required FloorplanPainter painter,
    Size logicalSize = const Size(600, 600),
    double pixelRatio = 3.0,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, logicalSize.width, logicalSize.height),
      );

      painter.paint(canvas, logicalSize);
      final picture = recorder.endRecording();

      final image = await picture.toImage(
        (logicalSize.width * pixelRatio).toInt(),
        (logicalSize.height * pixelRatio).toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('FloorplanRenderService.renderPainterToPng error: $e');
      return null;
    }
  }

  /// Decode a base64 image (Roboflow output) directly to PNG bytes.
  /// Strips potential data URI prefix.
  static Uint8List? decodeBase64ToBytes(String? base64Data) {
    if (base64Data == null || base64Data.isEmpty) return null;
    try {
      final cleaned = base64Data.contains(',')
          ? base64Data.split(',').last
          : base64Data;
      return base64Decode(cleaned);
    } catch (e) {
      debugPrint('FloorplanRenderService.decodeBase64ToBytes error: $e');
      return null;
    }
  }
}
