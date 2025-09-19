import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'roboflow_client.dart';
import 'roboflow_models.dart';
import 'roboflow_class_extractor.dart';
import 'image_upload_service.dart';
import '../../aiResult/services/roboflow_data_parser.dart';

/// High-level service for analyzing images with Roboflow
class RoboflowAnalyzer {
  final RoboflowClient _client = RoboflowClient();
  final ImageUploadService _uploadService = ImageUploadService();

  /// Analyzes a single image with Roboflow API
  ///
  /// This method handles:
  /// 1. Temporarily uploading the raw image for Roboflow analysis
  /// 2. Calling the Roboflow API with the image URL
  /// 3. Extracting and storing only the processed visualization images
  /// 4. Cleaning up the temporary raw image
  /// 5. Storing metadata in mobile_uploads table
  ///
  /// Returns [RoboflowAnalysisResult] containing success status and data
  Future<RoboflowAnalysisResult> analyzeImage(File imageFile) async {
    try {
      print('🚀 Starting Roboflow analysis for image: ${imageFile.path}');

      // Upload the image to cloud storage first
      print('📤 Uploading image to cloud storage...');
      final uploadedPaths = await _uploadService.uploadImages([imageFile]);
      print('✅ Image upload completed. Uploaded paths: $uploadedPaths');

      if (uploadedPaths.isEmpty) {
        print('❌ No files were uploaded successfully');
        return RoboflowAnalysisResult.failure(
          'Failed to upload image to cloud storage',
        );
      }

      // Generate the public URL for the uploaded image
      final imageUrl = _uploadService.getImageUrl(uploadedPaths.first);
      if (imageUrl == null) {
        print(
          '❌ Failed to generate image URL from uploaded path: ${uploadedPaths.first}',
        );
        return RoboflowAnalysisResult.failure(
          'Failed to generate image URL for analysis',
        );
      }

      print('🌐 Generated image URL for Roboflow: $imageUrl');
      print('🔍 Calling Roboflow API and waiting for result...');

      // Call Roboflow API
      final result = await _client.analyzeImageWithResult(imageUrl);
      print('📊 Roboflow API response received: $result');

      // Clean up the temporary raw image from storage (we don't store raw images)
      try {
        await _uploadService.deleteAiResult(uploadedPaths.first);
        print('🗑️ Cleaned up temporary raw image from storage');
      } catch (e) {
        print('⚠️ Warning: Failed to clean up temporary image: $e');
      }

      if (result.success && result.data != null) {
        return await _processSuccessfulAnalysis(result, imageFile);
      } else {
        return _processFailedAnalysis(result);
      }
    } catch (e) {
      print('💥 Exception in Roboflow analysis: $e');
      return RoboflowAnalysisResult.failure('Analysis failed: ${e.toString()}');
    }
  }

  /// Analyzes multiple images with Roboflow API
  /// Returns a list of analysis results for each image
  Future<List<RoboflowAnalysisResult>> analyzeMultipleImages(
    List<File> imageFiles,
  ) async {
    final results = <RoboflowAnalysisResult>[];

    for (final imageFile in imageFiles) {
      final result = await analyzeImage(imageFile);
      results.add(result);
    }

    return results;
  }

  /// Analyzes images that are already uploaded to cloud storage
  /// [uploadedFilePaths] - List of file paths in cloud storage
  Future<List<RoboflowAnalysisResult>> analyzeUploadedImages(
    List<String> uploadedFilePaths,
  ) async {
    final results = <RoboflowAnalysisResult>[];

    for (String filePath in uploadedFilePaths) {
      try {
        final imageUrl = _uploadService.getImageUrl(filePath);
        if (imageUrl != null) {
          final result = await _client.analyzeImageWithResult(imageUrl);
          if (result.success && result.data != null) {
            final analysisResult = await _processSuccessfulAnalysis(
              result,
              null,
            );
            results.add(analysisResult);
          } else {
            results.add(_processFailedAnalysis(result));
          }
        } else {
          results.add(
            RoboflowAnalysisResult.failure(
              'Failed to get image URL for $filePath',
            ),
          );
        }
      } catch (e) {
        results.add(
          RoboflowAnalysisResult.failure('Analysis failed for $filePath: $e'),
        );
      }
    }

    return results;
  }

  /// Processes successful analysis results
  Future<RoboflowAnalysisResult> _processSuccessfulAnalysis(
    RoboflowResult result,
    File? originalImageFile,
  ) async {
    print('✅ Successfully received Roboflow analysis result');
    print('🗂️ Response data keys: ${result.data!.keys.toList()}');

    // Enhanced JSON logging for live API response
    print('🚀 LIVE ROBOFLOW API JSON RESPONSE:');
    print('=' * 60);
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(result.data!);
    print(prettyJson);
    print('=' * 60);

    // Extract and log class counts from predictions
    final classCounts = RoboflowClassExtractor.extractClassCounts(result.data!);
    final classSummary = RoboflowClassExtractor.getClassSummary(classCounts);

    print('📊 CLASS ANALYSIS RESULTS:');
    print('=' * 40);
    print('🏷️ Total unique classes: ${classSummary.totalClasses}');
    print('🎯 Total detections: ${classSummary.totalDetections}');
    if (classSummary.totalClasses > 0) {
      print(
        '🥇 Most common: ${classSummary.mostCommonClass} (${classSummary.mostCommonCount})',
      );
      print('📋 All classes: ${classCounts.classCounts}');
    }
    print('=' * 40);

    // Parse and save visualization images to ai_results bucket
    final analysisId = 'analysis_${DateTime.now().millisecondsSinceEpoch}';
    List<String> aiResultsUrls = [];

    try {
      final visualizations = await _extractAndStoreVisualizations(
        result.data!,
        analysisId,
        originalImageFile,
      );
      aiResultsUrls = visualizations['urls'] ?? [];
    } catch (e) {
      print('⚠️ Warning: Failed to process visualizations: $e');
    }

    return RoboflowAnalysisResult.success(
      result.data!,
      aiResultsUrls: aiResultsUrls,
      classCounts: classCounts,
      classSummary: classSummary,
    );
  }

  /// Processes failed analysis results
  RoboflowAnalysisResult _processFailedAnalysis(RoboflowResult result) {
    print('❌ Roboflow analysis failed or returned no data');
    print('📄 Result details: $result');

    return RoboflowAnalysisResult.failure(
      result.error ?? 'Analysis failed - no data returned',
    );
  }

  /// Extracts and stores visualization images from Roboflow response
  Future<Map<String, List<String>>> _extractAndStoreVisualizations(
    Map<String, dynamic> roboflowData,
    String analysisId,
    File? originalImageFile,
  ) async {
    List<String> aiResultsUrls = [];
    List<String> uploadedPaths = [];

    // Process visualization images using RoboflowDataParser
    final labelVisualization =
        RoboflowDataParser.extractLabelVisualizationImage(roboflowData);
    final bboxVisualization = RoboflowDataParser.extractBboxVisualizationImage(
      roboflowData,
    );

    final visualizations = <String>[];
    if (labelVisualization != null) {
      visualizations.add(labelVisualization);
    }
    if (bboxVisualization != null) {
      visualizations.add(bboxVisualization);
    }

    if (visualizations.isNotEmpty) {
      print(
        '🖼️ Found ${visualizations.length} visualization images to process',
      );

      List<File> tempFiles = [];
      for (int i = 0; i < visualizations.length; i++) {
        final base64Data = visualizations[i];
        final tempFile = await _saveBase64ToTempFile(
          base64Data,
          'visualization',
          analysisId,
        );

        if (tempFile != null) {
          tempFiles.add(tempFile);
          print('✅ Created temp file for visualization $i: ${tempFile.path}');
        }
      }

      if (tempFiles.isNotEmpty) {
        // Upload visualization images to ai_results bucket
        uploadedPaths = await _uploadService.uploadToAiResults(
          tempFiles,
          analysisId: analysisId,
        );

        // Generate public URLs for the uploaded visualizations
        for (String filePath in uploadedPaths) {
          final url = _uploadService.getAiResultImageUrl(filePath);
          if (url != null) {
            aiResultsUrls.add(url);
          }
        }

        // Clean up temporary files
        for (File tempFile in tempFiles) {
          try {
            await tempFile.delete();
          } catch (e) {
            print('⚠️ Warning: Failed to delete temp file: $e');
          }
        }

        // Store metadata for processed images
        await _uploadService.storeProcessedImageMetadata(
          uploadedPaths,
          analysisId,
          roboflowData,
          originalImageFile: originalImageFile,
        );

        print('🎯 Stored ${aiResultsUrls.length} visualization URLs');
      }
    } else {
      print('⚠️ No visualization images found in Roboflow response');
    }

    return {'urls': aiResultsUrls, 'paths': uploadedPaths};
  }

  /// Helper method to save base64 image data to a temporary file
  Future<File?> _saveBase64ToTempFile(
    String base64Data,
    String prefix,
    String analysisId,
  ) async {
    try {
      // Remove data URL prefix if present (e.g., "data:image/png;base64,")
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }

      // Decode base64 to bytes
      final Uint8List bytes = base64Decode(cleanBase64);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${prefix}_${analysisId}_$timestamp.png';
      final tempFile = File(path.join(tempDir.path, fileName));

      // Write bytes to file
      await tempFile.writeAsBytes(bytes);

      print('💾 Saved ${bytes.length} bytes to temp file: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      print('❌ Error saving base64 to temp file: $e');
      return null;
    }
  }
}
