import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class ImageUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<String>> uploadImages(List<File> images) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    List<String> uploadedFilePaths = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final fileExtension = path.extension(file.path).toLowerCase();
      final fileName =
          'image_${DateTime.now().millisecondsSinceEpoch}_$i$fileExtension';
      final filePath = '$userId/$fileName';

      // Get file size
      final fileSize = await file.length();

      // Upload to Supabase Storage
      await _supabase.storage
          .from('mobile_uploads')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: lookupMimeType(file.path),
            ),
          );

      // Insert record into mobile_uploads table
      await _supabase.from('mobile_uploads').insert({
        'user_id': userId,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'status': 'uploaded',
      });

      uploadedFilePaths.add(filePath);
    }

    return uploadedFilePaths;
  }

  Future<void> updateUploadStatus(String filePath, String status) async {
    try {
      await _supabase
          .from('mobile_uploads')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('file_path', filePath);
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  String? getImageUrl(String filePath) {
    try {
      return _supabase.storage.from('mobile_uploads').getPublicUrl(filePath);
    } catch (e) {
      print('Failed to get image URL: $e');
      return null;
    }
  }

  Future<void> deleteUpload(String filePath) async {
    // Delete from storage
    await _supabase.storage.from('mobile_uploads').remove([filePath]);

    // Delete from database
    await _supabase.from('mobile_uploads').delete().eq('file_path', filePath);
  }
}
