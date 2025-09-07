import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RoboflowFetch {
  static const String _baseUrl =
      'https://serverless.roboflow.com/infer/workflows/test-cmoub/terra-price';
  static const String _apiKey = 'Zub42A5wGM8poDgcI18Q';

  /// Sends an image URL to Roboflow for analysis
  /// [imageUrl] - The URL of the image to be analyzed
  /// Returns the response from Roboflow API
  static Future<Map<String, dynamic>?> analyzeImage(String imageUrl) async {
    try {
      developer.log('🚀 Starting Roboflow analysis for image: $imageUrl');

      final Map<String, dynamic> requestBody = {
        'api_key': _apiKey,
        'inputs': {
          'image': {'type': 'url', 'value': imageUrl},
        },
      };

      developer.log('📤 Request payload: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📊 Response status code: ${response.statusCode}');
      developer.log('📄 Response headers: ${response.headers}');
      developer.log('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        developer.log('✅ Roboflow analysis successful!');
        developer.log('🎯 Analysis results: ${jsonEncode(responseData)}');

        // Save the complete response for inspection
        await _saveResponseToFile(
          responseData,
          'roboflow_response_${DateTime.now().millisecondsSinceEpoch}.json',
        );

        return responseData;
      } else {
        developer.log(
          '❌ Roboflow analysis failed with status: ${response.statusCode}',
        );
        developer.log('❌ Error response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      developer.log('💥 Exception occurred during Roboflow analysis: $e');
      developer.log('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Saves the Roboflow response to a file for debugging
  static Future<void> _saveResponseToFile(
    Map<String, dynamic> responseData,
    String fileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      // Pretty print the JSON for better readability
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(responseData);

      await file.writeAsString(prettyJson);
      developer.log('💾 Saved Roboflow response to: ${file.path}');

      // Also print the first few hundred characters for immediate viewing
      final preview = prettyJson.length > 500
          ? '${prettyJson.substring(0, 500)}...'
          : prettyJson;
      developer.log('📋 Response preview:\n$preview');
    } catch (e) {
      developer.log('❌ Failed to save response to file: $e');
    }
  }

  /// Sends an image URL to Roboflow for analysis with detailed logging
  /// This is a wrapper method that provides more detailed logging
  static Future<RoboflowResult> analyzeImageWithResult(String imageUrl) async {
    developer.log('🔍 Initiating detailed Roboflow analysis...');

    final startTime = DateTime.now();
    final result = await analyzeImage(imageUrl);
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    developer.log('⏱️ Analysis completed in ${duration.inMilliseconds}ms');

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
