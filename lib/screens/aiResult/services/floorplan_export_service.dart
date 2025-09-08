import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FloorplanExportResult {
  final bool success;
  final String? url;
  final String? error;
  final String? path;

  FloorplanExportResult({
    required this.success,
    this.url,
    this.error,
    this.path,
  });
}

class FloorplanExportService {
  FloorplanExportService({String bucketName = 'ai_results'})
    : _storageBucket = Supabase.instance.client.storage.from(bucketName);

  final StorageFileApi _storageBucket;

  /// Upload raw PNG bytes to Supabase storage.
  Future<FloorplanExportResult> uploadPngBytes(
    Uint8List bytes, {
    String? fileName,
    bool public = true,
    String contentType = 'image/png',
  }) async {
    try {
      final name =
          fileName ??
          'floorplan_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.png';

      await _storageBucket.uploadBinary(
        name,
        bytes,
        fileOptions: FileOptions(contentType: contentType),
      );

      String? url;
      if (public) {
        url = _storageBucket.getPublicUrl(name);
      } else {
        url = await _storageBucket.createSignedUrl(name, 3600);
      }

      return FloorplanExportResult(success: true, url: url, path: name);
    } catch (e) {
      return FloorplanExportResult(success: false, error: e.toString());
    }
  }
}
