import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching upload history from mobile_uploads table
class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches all mobile upload records with analysis data for the current user
  Future<List<Map<String, dynamic>>> getMobileUploads() async {
    try {
      // Get current user ID for filtering
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

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
            analyzed_at,
            comments,
            user_id,
            total_detections
          ''')
          .eq('user_id', userId) // Filter by current user
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(response);

      print(
        '📋 Fetched ${results.length} mobile upload records for user: $userId',
      );

      return results;
    } catch (e) {
      print('❌ Error fetching mobile uploads: $e');
      throw Exception('Failed to fetch upload history: $e');
    }
  }
}
