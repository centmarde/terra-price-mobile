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

  /// Upload images to ai_results bucket for analysis results
  Future<List<String>> uploadToAiResults(
    List<File> images, {
    String? analysisId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    List<String> uploadedFilePaths = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sessionId = analysisId ?? 'session_$timestamp';

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final fileExtension = path.extension(file.path).toLowerCase();
      final fileName = 'ai_result_${sessionId}_$i$fileExtension';
      final filePath = '$userId/$fileName';

      // Get file size
      final fileSize = await file.length();

      // Upload to Supabase Storage in ai_results bucket
      await _supabase.storage
          .from('ai_results')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: lookupMimeType(file.path),
            ),
          );

      // Insert record into ai_results table
      await _supabase.from('ai_results').insert({
        'user_id': userId,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'analysis_id': sessionId,
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

  /// Update status for AI results uploads
  Future<void> updateAiResultStatus(
    String filePath,
    String status, {
    Map<String, dynamic>? analysisData,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (analysisData != null) {
        updateData['analysis_data'] = analysisData;
      }

      await _supabase
          .from('ai_results')
          .update(updateData)
          .eq('file_path', filePath);
    } catch (e) {
      print('Failed to update AI result status: $e');
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

  /// Get public URL for images in ai_results bucket
  String? getAiResultImageUrl(String filePath) {
    try {
      return _supabase.storage.from('ai_results').getPublicUrl(filePath);
    } catch (e) {
      print('Failed to get AI result image URL: $e');
      return null;
    }
  }

  Future<void> deleteUpload(String filePath) async {
    // Delete from storage
    await _supabase.storage.from('mobile_uploads').remove([filePath]);

    // Delete from database
    await _supabase.from('mobile_uploads').delete().eq('file_path', filePath);
  }

  /// Delete AI result upload
  Future<void> deleteAiResult(String filePath) async {
    // Delete from storage
    await _supabase.storage.from('ai_results').remove([filePath]);

    // Delete from database
    await _supabase.from('ai_results').delete().eq('file_path', filePath);
  }
}
