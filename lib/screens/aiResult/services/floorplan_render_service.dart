import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

import '../aiResultsWidgets/floorplan_painter.dart';

class FloorplanRenderService {
  static Future<Uint8List?> renderPainterToPng({
    required FloorplanPainter painter,
    ui.Size logicalSize = const ui.Size(600, 600),
    double pixelRatio = 3.0,
    bool errorOnNull = false,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
        recorder,
        ui.Rect.fromLTWH(0, 0, logicalSize.width, logicalSize.height),
      );

      painter.paint(canvas, logicalSize);

      final picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(
        (logicalSize.width * pixelRatio).toInt(),
        (logicalSize.height * pixelRatio).toInt(),
      );

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (errorOnNull) throw StateError('Failed to encode image to PNG');
        return null;
      }
      return byteData.buffer.asUint8List();
    } catch (e, st) {
      debugPrint('FloorplanRenderService.renderPainterToPng error: $e\n$st');
      if (errorOnNull) rethrow;
      return null;
    }
  }

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

  static Future<Uint8List?> renderFromBase64({
    required String? base64Data,
    ui.Size logicalSize = const ui.Size(600, 600),
    double pixelRatio = 2.0,
  }) async {
    final painter = await FloorplanPainter.fromBase64(base64Data);
    return renderPainterToPng(
      painter: painter,
      logicalSize: logicalSize,
      pixelRatio: pixelRatio,
    );
  }

  static Future<Uint8List?> addTextOverlay({
    required Uint8List pngBytes,
    required String text,
    ui.Color color = const ui.Color(0xAAFFFFFF),
    double fontSize = 22,
    ui.Offset position = const ui.Offset(16, 32),
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      final baseImage = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
        recorder,
        ui.Rect.fromLTWH(
          0,
          0,
          baseImage.width.toDouble(),
          baseImage.height.toDouble(),
        ),
      );

      // Draw original
      canvas.drawImage(baseImage, ui.Offset.zero, ui.Paint());

      // Build paragraph (text)
      final paragraphBuilder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: ui.TextAlign.left,
                fontSize: fontSize,
                fontWeight: ui.FontWeight.w600,
              ),
            )
            ..pushStyle(
              ui.TextStyle(
                color: color,
                shadows: const [
                  ui.Shadow(
                    color: ui.Color(0x88000000),
                    offset: ui.Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            )
            ..addText(text);

      final paragraph = paragraphBuilder.build()
        ..layout(
          ui.ParagraphConstraints(
            width: baseImage.width.toDouble() - position.dx - 8,
          ),
        );

      canvas.drawParagraph(paragraph, position);

      final picture = recorder.endRecording();
      final ui.Image outImage = await picture.toImage(
        baseImage.width,
        baseImage.height,
      );

      final outData = await outImage.toByteData(format: ui.ImageByteFormat.png);
      return outData?.buffer.asUint8List();
    } catch (e, st) {
      debugPrint('FloorplanRenderService.addTextOverlay error: $e\n$st');
      return null;
    }
  }
}
