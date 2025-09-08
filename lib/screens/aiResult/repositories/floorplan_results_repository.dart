import 'package:supabase_flutter/supabase_flutter.dart';

class FloorplanResultsRepository {
  final _client = Supabase.instance.client;
  final String table;

  FloorplanResultsRepository({this.table = 'ai_floorplan_results'});

  Future<bool> insertResult({
    required String userId,
    required String storagePath,
    required String imageUrl,
    String? analysisId,
    Map<String, dynamic>? extra,
  }) async {
    try {
      await _client.from(table).insert({
        'user_id': userId,
        'storage_path': storagePath,
        'image_url': imageUrl,
        'analysis_id': analysisId,
        'extra': extra,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
