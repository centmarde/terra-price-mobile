import 'package:flutter/material.dart';

import '../../aiResult/services/floorplan_render_service.dart';
import '../../aiResult/services/floorplan_export_service.dart';
import '../../aiResult/aiResultsWidgets/floorplan_painter.dart';

Future<void> persistRoboflowFloorplan(String? base64Image) async {
  if (base64Image == null) return;

  final painter = await FloorplanPainter.fromBase64(base64Image);

  final bytes = await FloorplanRenderService.renderPainterToPng(
    painter: painter,
    logicalSize: const Size(512, 512),
    pixelRatio: 2.0,
  );

  if (bytes == null) {
    print('Render to PNG failed.');
    return;
  }

  final exportService = FloorplanExportService();
  final result = await exportService.uploadPngBytes(bytes, public: true);

  if (result.success) {
    print('Saved floorplan: ${result.url}');
  } else {
    print('Failed storing floorplan: ${result.error}');
  }
}
