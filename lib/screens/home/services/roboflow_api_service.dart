import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../../aiResult/aiResultsWidgets/roboflow_data_parser.dart';
import 'image_upload_service.dart';

/// Service class to handle Roboflow API integration
/// Separated from HomeProvider to follow single responsibility principle
class RoboflowApiService {
  final ImageUploadService _uploadService = ImageUploadService();

  // Roboflow API configuration
  static const String _baseUrl =
      'https://serverless.roboflow.com/infer/workflows/test-cmoub/terra-price';
  static const String _apiKey = 'Zub42A5wGM8poDgcI18Q';

  /// Sends an image URL to Roboflow for analysis with detailed logging
  Future<RoboflowResult> _analyzeImageWithResult(String imageUrl) async {
    print('🔍 Initiating Roboflow analysis for: $imageUrl');

    final startTime = DateTime.now();
    final result = await _analyzeImage(imageUrl);
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    print('⏱️ Analysis completed in ${duration.inMilliseconds}ms');

    if (result != null) {
      return RoboflowResult(
        success: true,
        data: result,
        duration: duration,
        error: null,
      );
    } else {
      return RoboflowResult(
        success: false,
        data: null,
        duration: duration,
        error: 'Failed to analyze image',
      );
    }
  }

  /// Sends an image URL to Roboflow for analysis
  Future<Map<String, dynamic>?> _analyzeImage(String imageUrl) async {
    try {
      print('🚀 Starting Roboflow analysis for image: $imageUrl');

      // First, test if the image URL is accessible
      try {
        final headResponse = await http.head(Uri.parse(imageUrl));
        print('🔍 Image URL accessibility test: ${headResponse.statusCode}');
        if (headResponse.statusCode != 200) {
          print('❌ Image URL is not accessible: ${headResponse.statusCode}');
          print('📄 Head response: ${headResponse.headers}');
          return null;
        }
      } catch (e) {
        print('❌ Failed to test image URL accessibility: $e');
        return null;
      }

      final Map<String, dynamic> requestBody = {
        'api_key': _apiKey,
        'inputs': {
          'image': {'type': 'url', 'value': imageUrl},
        },
      };

      print('📤 Request payload: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📊 Response status code: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('✅ Roboflow analysis successful!');
        print('🎯 Analysis results: ${jsonEncode(responseData)}');

        return responseData;
      } else {
        print('❌ Roboflow analysis failed with status: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('💥 Exception occurred during Roboflow analysis: $e');
      print('📚 Stack trace: $stackTrace');
      return null;
    }
  }

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
      final result = await _analyzeImageWithResult(imageUrl);
      print('📊 Roboflow API response received: $result');

      // Clean up the temporary raw image from storage (we don't store raw images)
      try {
        await _uploadService.deleteAiResult(uploadedPaths.first);
        print('🗑️ Cleaned up temporary raw image from storage');
      } catch (e) {
        print('⚠️ Warning: Failed to clean up temporary image: $e');
      }

      if (result.success && result.data != null) {
        print('✅ Successfully received Roboflow analysis result');
        print('🗂️ Response data keys: ${result.data!.keys.toList()}');

        // Enhanced JSON logging for live API response
        print('🚀 LIVE ROBOFLOW API JSON RESPONSE:');
        print('=' * 60);
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(result.data!);
        print(prettyJson);
        print('=' * 60);

        // Parse and save visualization images to ai_results bucket
        final analysisId = 'analysis_${DateTime.now().millisecondsSinceEpoch}';
        List<String> aiResultsUrls = [];
        List<String> storedFilePaths = [];

        try {
          // Extract label visualization image
          final labelVisImageData =
              RoboflowDataParser.extractLabelVisualizationImage(result.data!);
          if (labelVisImageData != null) {
            try {
              final labelImageFile = await _saveBase64ToTempFile(
                labelVisImageData,
                'label_vis',
                analysisId,
              );
              if (labelImageFile != null) {
                final uploadedPaths = await _uploadService.uploadToAiResults([
                  labelImageFile,
                ], analysisId: '${analysisId}_label');
                if (uploadedPaths.isNotEmpty) {
                  final aiResultUrl = _uploadService.getAiResultImageUrl(
                    uploadedPaths.first,
                  );
                  if (aiResultUrl != null) {
                    aiResultsUrls.add(aiResultUrl);
                    storedFilePaths.add(uploadedPaths.first);
                    print('📸 Label visualization stored: $aiResultUrl');
                  }
                }
                // Clean up temp file
                await labelImageFile.delete();
              }
            } catch (e) {
              print('⚠️ Failed to save label visualization: $e');
            }
          }

          // Store metadata in mobile_uploads table for the processed images
          // This should happen even if only some images were saved successfully
          if (storedFilePaths.isNotEmpty) {
            try {
              await _uploadService.storeProcessedImageMetadata(
                storedFilePaths,
                analysisId,
                result.data!,
              );
              print(
                '📝 Stored metadata for ${storedFilePaths.length} processed images',
              );
            } catch (e) {
              print('❌ Failed to store metadata in mobile_uploads table: $e');
            }
          } else {
            print(
              '⚠️ No processed images were saved, skipping metadata storage',
            );
          }

          print(
            '✅ Stored ${aiResultsUrls.length} processed visualization images',
          );
        } catch (e) {
          print('⚠️ Warning: Failed to save processed images: $e');
          // Continue with the analysis even if image saving fails
        }

        return RoboflowAnalysisResult.success(
          result.data!,
          uploadedImageUrl: null, // No raw image stored, only processed images
          aiResultsUrls: aiResultsUrls,
        );
      } else {
        print('❌ Roboflow analysis failed or returned no data');
        print(
          '📄 Result details: success=${result.success}, data=${result.data}, error=${result.error}',
        );

        return RoboflowAnalysisResult.failure(
          result.error ?? 'Analysis failed - no data returned',
        );
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
          print('🔍 Starting Roboflow analysis for: $imageUrl');
          final result = await _analyzeImageWithResult(imageUrl);
          print('📊 Roboflow analysis result: $result');

          if (result.success && result.data != null) {
            // Log the full result JSON if successful
            print('🚀 LIVE ROBOFLOW API JSON RESPONSE:');
            print('=' * 60);
            const encoder = JsonEncoder.withIndent('  ');
            final prettyJson = encoder.convert(result.data!);
            print(prettyJson);
            print('=' * 60);

            results.add(
              RoboflowAnalysisResult.success(
                result.data!,
                uploadedImageUrl: imageUrl,
                aiResultsUrls: [], // No AI results URLs for this method
              ),
            );
          } else {
            results.add(
              RoboflowAnalysisResult.failure(
                result.error ?? 'Analysis failed for $filePath',
              ),
            );
          }
        } else {
          results.add(
            RoboflowAnalysisResult.failure(
              'Failed to generate URL for $filePath',
            ),
          );
        }
      } catch (e) {
        results.add(
          RoboflowAnalysisResult.failure('Exception analyzing $filePath: $e'),
        );
      }
    }

    return results;
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

/// Result class for Roboflow API analysis
class RoboflowAnalysisResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final String? uploadedImageUrl;
  final List<String>? aiResultsUrls;

  RoboflowAnalysisResult._({
    required this.success,
    this.data,
    this.error,
    this.uploadedImageUrl,
    this.aiResultsUrls,
  });

  /// Creates a successful result
  factory RoboflowAnalysisResult.success(
    Map<String, dynamic> data, {
    String? uploadedImageUrl,
    List<String>? aiResultsUrls,
  }) {
    return RoboflowAnalysisResult._(
      success: true,
      data: data,
      uploadedImageUrl: uploadedImageUrl,
      aiResultsUrls: aiResultsUrls,
    );
  }

  /// Creates a failed result
  factory RoboflowAnalysisResult.failure(String error) {
    return RoboflowAnalysisResult._(success: false, error: error);
  }

  @override
  String toString() {
    return 'RoboflowAnalysisResult(success: $success, error: $error, hasData: ${data != null})';
  }
}

/// Result class to encapsulate Roboflow API response
class RoboflowResult {
  final bool success;
  final Map<String, dynamic>? data;
  final Duration duration;
  final String? error;

  RoboflowResult({
    required this.success,
    this.data,
    required this.duration,
    this.error,
  });

  @override
  String toString() {
    return 'RoboflowResult(success: $success, duration: ${duration.inMilliseconds}ms, error: $error)';
  }
}
