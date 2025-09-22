import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching upload history from mobile_uploads table
class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches all mobile upload records for the current user
  Future<List<Map<String, dynamic>>> getMobileUploads() async {
    try {
      final response = await _supabase
          .from('mobile_uploads')
          .select('file_name, status, created_at')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch upload history: $e');
    }
  }
}
