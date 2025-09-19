import 'package:supabase_flutter/supabase_flutter.dart';

class AIResultsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> fetchLatestAIResultImage(String uploadId) async {
    try {
      final response = await _supabase
          .from('mobile_uploads')
          .select()
          .eq('id', uploadId)
          .single();

      if (response != null) {
        // Get the file_path which contains the full URL to the AI-generated image
        final filePath = response['file_path'] as String?;
        if (filePath != null) {
          print('✅ Found AI-generated image URL: $filePath');
          return filePath;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching AI result image: $e');
      return null;
    }
  }
}
