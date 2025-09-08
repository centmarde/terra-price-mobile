import 'package:flutter/foundation.dart';
import '../services/floorplan_persist_service.dart';

/// Controller that persists a floorplan visualization only once per unique image.
class FloorplanPersistController extends ChangeNotifier {
  final FloorplanPersistService _service;
  bool saving = false;
  String? error;
  String? stage;
  String? imageUrl;
  Map<String, dynamic>? dbRow;

  bool _attempted = false;
  int? _lastSignature; // hash of base64 (or external signature)

  bool get hasPersisted => imageUrl != null;
  bool get attempted => _attempted;
  int? get lastSignature => _lastSignature;

  FloorplanPersistController({FloorplanPersistService? service})
    : _service = service ?? FloorplanPersistService();

  /// Provide a signature (e.g., base64.hashCode) before calling persistOnce.
  /// If it differs from the stored signature, controller resets automatically.
  void markNewImageSignature(int signature) {
    if (_lastSignature != signature) {
      reset();
      _lastSignature = signature;
    }
  }

  Future<void> persistOnce({
    required String userId,
    required String? base64Data,
    List<String>? insights,
    String? analysisId,
    FloorplanPersistMode mode = FloorplanPersistMode.rawBase64,
  }) async {
    if (_attempted || hasPersisted || saving) return;
    _attempted = true;
    saving = true;
    error = null;
    stage = null;
    notifyListeners();

    final result = await _service.persist(
      userId: userId,
      base64Data: base64Data,
      insights: insights,
      analysisId: analysisId,
      mode: mode,
    );

    if (result.success) {
      imageUrl = result.imageUrl;
      dbRow = result.dbRow;
    } else {
      error = result.error;
      stage = result.stage;
    }

    saving = false;
    notifyListeners();
  }

  void reset() {
    saving = false;
    error = null;
    stage = null;
    imageUrl = null;
    dbRow = null;
    _attempted = false;
  }
}
