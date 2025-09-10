import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'roboflow_class_extractor.dart';
import '../../aiResult/services/services.dart';

class ImageUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Temporarily uploads raw images for Roboflow analysis
  /// These images will be deleted after analysis and only processed images will be stored
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

      // Upload to Supabase Storage in ai_results bucket (temporary storage for analysis)
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

      uploadedFilePaths.add(filePath);
    }

    return uploadedFilePaths;
  }

  Future<void> updateUploadStatus(String filePath, String status) async {
    try {
      // Convert filePath to full URL format that's stored in the database
      print('testing');
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  /// Store metadata for processed images from Roboflow analysis
  /// Only stores metadata for the last processed image to avoid duplicates
  /// Now includes Groq AI analysis response
  Future<void> storeProcessedImageMetadata(
    List<String> processedFilePaths,
    String analysisId,
    Map<String, dynamic> roboflowData, {
    File? originalImageFile,
    String? aiResponse,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (processedFilePaths.isEmpty) {
      print('⚠️ No processed file paths to store');
      return;
    }

    try {
      // Extract individual object counts for database columns
      final objectCounts = RoboflowClassExtractor.extractIndividualCounts(
        roboflowData,
      );

      // Store only the last processed image to avoid duplicates
      final lastFilePath = processedFilePaths.last;
      final fileName = lastFilePath.split('/').last;
      final fullUrl =
          'https://gqxhltrjxuiuyveiqtsf.supabase.co/storage/v1/object/public/ai_results/$lastFilePath';

      // Use provided AI response or analyze with Groq AI if original image file is provided
      String? finalAiResponse = aiResponse;
      if (finalAiResponse == null && originalImageFile != null) {
        try {
          print('🤖 Starting Groq AI analysis for floor plan...');
          final groqResponse = await GroqAIService.analyzeFloorPlanFromFile(
            imageFile: originalImageFile,
            customPrompt:
                'Please analyze this floor plan and provide a detailed construction cost estimate with breakdown.',
          );

          // Extract the AI response content
          if (groqResponse.choices.isNotEmpty) {
            finalAiResponse = groqResponse.choices.first.message.content;
            print('✅ Groq AI analysis completed successfully');
            print(
              '📝 AI Response length: ${finalAiResponse.length} characters',
            );
          } else {
            print('⚠️ Groq AI returned empty response');
            finalAiResponse =
                'No analysis available - empty response from AI service';
          }
        } catch (e) {
          print('❌ Groq AI analysis failed: $e');
          finalAiResponse = 'AI analysis failed: ${e.toString()}';
        }
      }

      // Set default response if none provided
      if (finalAiResponse == null) {
        print(
          '⚠️ No AI response provided and no original image file for analysis',
        );
        finalAiResponse =
            'No AI analysis available - neither response nor original image provided';
      }

      // Prepare the insert data with object counts and AI response
      final insertData = {
        'user_id': userId,
        'file_name': fileName,
        'file_path': fullUrl,
        'file_size': 0, // Size not available for processed images
        'status': 'processed',
        'roboflow_data': roboflowData, // jsonB Store the full analysis data
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'analyzed_at': DateTime.now().toIso8601String(),
        // Add object counts
        'doors': objectCounts['doors'],
        'rooms': objectCounts['rooms'],
        'window': objectCounts['window'],
        'sofa': objectCounts['sofa'],
        'large_sofa': objectCounts['large_sofa'],
        'sink': objectCounts['sink'],
        'large_sink': objectCounts['large_sink'],
        'twin_sink': objectCounts['twin_sink'],
        'tub': objectCounts['tub'],
        'coffee_table': objectCounts['coffee_table'],
        'total_detections': objectCounts['total_detections'],
        'confidence_score': objectCounts['confidence_score'],
        'ai_response': finalAiResponse, // Store AI response from Groq AI
      };

      // Insert metadata record for the last processed image
      await _supabase.from('mobile_uploads').insert(insertData);

      print('📝 Stored metadata for last processed image: $fileName');
      print('🔢 Object counts: $objectCounts');
      print(
        '🔗 Total processed images: ${processedFilePaths.length}, stored: 1 (last)',
      );
    } catch (e) {
      print('❌ Failed to store processed image metadata: $e');
      throw e;
    }
  }

  String? getImageUrl(String filePath) {
    try {
      return _supabase.storage.from('ai_results').getPublicUrl(filePath);
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
    // Delete from storage (ai_results bucket where files are actually stored)
    await _supabase.storage.from('ai_results').remove([filePath]);

    // Delete from database (mobile_uploads table where metadata is stored)
    await _supabase
        .from('mobile_uploads')
        .delete()
        .eq(
          'file_path',
          'https://gqxhltrjxuiuyveiqtsf.supabase.co/storage/v1/object/public/ai_results/$filePath',
        );
  }

  /// Delete AI result upload (only from storage bucket, no table)
  Future<void> deleteAiResult(String filePath) async {
    // Delete from storage bucket only (no ai_results table exists)
    await _supabase.storage.from('ai_results').remove([filePath]);
  }
}
