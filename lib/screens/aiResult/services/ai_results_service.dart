import 'package:supabase_flutter/supabase_flutter.dart';

class AIResultsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches the latest AI result image for the current user
  Future<String?> fetchLatestAIResultImage([String? uploadId]) async {
    try {
      if (uploadId != null) {
        // Fetch specific upload by ID
        final response = await _supabase
            .from('mobile_uploads')
            .select()
            .eq('id', uploadId)
            .single();

        // Get the file_path which contains the full URL to the AI-generated image
        final filePath = response['file_path'] as String?;
        if (filePath != null) {
          print(
            '✅ Found AI-generated image URL for upload $uploadId: $filePath',
          );
          return filePath;
        }
      } else {
        // Fetch the latest upload for current user if no specific ID provided
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          final response = await _supabase
              .from('mobile_uploads')
              .select()
              .eq('user_id', userId)
              .inFilter('status', ['processed', 'approved'])
              .order('analyzed_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (response != null) {
            final filePath = response['file_path'] as String?;
            if (filePath != null) {
              print('✅ Found latest AI-generated image URL: $filePath');
              return filePath;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching AI result image: $e');
      return null;
    }
  }
}
