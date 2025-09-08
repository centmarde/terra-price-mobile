import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../aiResultsWidgets/floorplan_painter.dart';
import 'floorplan_render_service.dart';
import 'floorplan_export_service.dart';
import '../repositories/floorplan_results_repository.dart';

enum FloorplanPersistMode { rawBase64, rendered }

class FloorplanPersistResult {
  final bool success;
  final String? imageUrl;
  final String? storagePath;
  final Map<String, dynamic>? dbRow;
  final String? error;
  final String? stage;
  FloorplanPersistResult({
    required this.success,
    this.imageUrl,
    this.storagePath,
    this.dbRow,
    this.error,
    this.stage,
  });
}

class FloorplanPersistService {
  final FloorplanExportService exportService;
  final AIFloorplanResultsRepository resultsRepo;
  final Uuid _uuid = const Uuid();

  FloorplanPersistService({
    FloorplanExportService? exportService,
    AIFloorplanResultsRepository? resultsRepo,
  }) : exportService = exportService ?? FloorplanExportService(),
       resultsRepo = resultsRepo ?? AIFloorplanResultsRepository();

  Future<FloorplanPersistResult> persist({
    required String userId,
    required String? base64Data,
    List<String>? insights,
    String? analysisId,
    FloorplanPersistMode mode = FloorplanPersistMode.rawBase64,
  }) async {
    debugPrint(
      '[Persist] start user=$userId mode=$mode base64?=${base64Data != null}',
    );
    if (base64Data == null || base64Data.isEmpty) {
      return FloorplanPersistResult(
        success: false,
        stage: 'validation',
        error: 'No base64 data',
      );
    }

    try {
      Uint8List? bytes;
      String persistModeLabel;

      if (mode == FloorplanPersistMode.rawBase64) {
        persistModeLabel = 'rawBase64';
        bytes = FloorplanRenderService.decodeBase64ToBytes(base64Data);
        debugPrint('[Persist] raw decode length=${bytes?.length}');
      } else {
        persistModeLabel = 'rendered';
        final painter = await FloorplanPainter.fromBase64(base64Data);
        bytes = await FloorplanRenderService.renderPainterToPng(
          painter: painter,
          logicalSize: const ui.Size(600, 600),
          pixelRatio: 2.0,
        );
        debugPrint('[Persist] rendered length=${bytes?.length}');
      }

      if (bytes == null || bytes.isEmpty) {
        return FloorplanPersistResult(
          success: false,
          stage: 'convert',
          error: 'Failed to produce image bytes',
        );
      }

      // Put inside a user-specific folder for organization:
      final fileName = 'floorplans/$userId/floorplan_${_uuid.v4()}.png';
      final uploadResult = await exportService.uploadPngBytes(
        bytes,
        fileName: fileName,
        public: true,
      );

      if (!uploadResult.success || uploadResult.url == null) {
        return FloorplanPersistResult(
          success: false,
          stage: 'upload',
          error: uploadResult.error ?? 'Upload failed',
        );
      }

      final dbRow = await resultsRepo.insertResult(
        userId: userId,
        storagePath: uploadResult.path ?? fileName,
        imageUrl: uploadResult.url!,
        analysisId: analysisId,
        insights: insights,
        rawBase64Length: base64Data.length,
        persistMode: persistModeLabel,
      );

      if (dbRow == null) {
        return FloorplanPersistResult(
          success: false,
          stage: 'db',
          error: 'Insert returned null',
        );
      }

      return FloorplanPersistResult(
        success: true,
        imageUrl: uploadResult.url,
        storagePath: uploadResult.path ?? fileName,
        dbRow: dbRow,
      );
    } catch (e, st) {
      debugPrint('[Persist] exception: $e\n$st');
      return FloorplanPersistResult(
        success: false,
        stage: 'exception',
        error: e.toString(),
      );
    }
  }
}
