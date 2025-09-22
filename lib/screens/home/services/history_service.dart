import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching upload history from mobile_uploads table
class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches all mobile upload records with analysis data for the current user
  Future<List<Map<String, dynamic>>> getMobileUploads() async {
    try {
      final response = await _supabase
          .from('mobile_uploads')
          .select('''
            file_name, 
            status, 
            created_at,
            doors,
            rooms,
            window,
            sofa,
            large_sofa,
            coffee_table,
            sink,
            large_sink,
            twin_sink,
            tub,
            confidence_score,
            ai_response,
            file_path,
            analyzed_at
          ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch upload history: $e');
    }
  }
}
