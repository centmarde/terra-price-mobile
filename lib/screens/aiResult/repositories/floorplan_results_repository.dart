import 'package:supabase_flutter/supabase_flutter.dart';

class AIFloorplanResultsRepository {
  final SupabaseClient _client;
  final String table;

  AIFloorplanResultsRepository({
    SupabaseClient? client,
    this.table = 'ai_floorplan_results',
  }) : _client = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> insertResult({
    required String userId,
    required String storagePath,
    required String imageUrl,
    String? analysisId,
    List<String>? insights,
    int? rawBase64Length,
    String persistMode = 'raw',
  }) async {
    final payload = {
      'user_id': userId,
      'storage_path': storagePath,
      'image_url': imageUrl,
      'analysis_id': analysisId,
      'insights': insights,
      'raw_base64_length': rawBase64Length,
      'persist_mode': persistMode,
    };

    try {
      return await _client.from(table).insert(payload).select().maybeSingle();
    } catch (_) {
      return null;
    }
  }
}
