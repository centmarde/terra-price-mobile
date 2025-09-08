import 'dart:convert';
import 'package:http/http.dart' as http;
import 'roboflow_config.dart';
import 'roboflow_models.dart';

/// Low-level HTTP client for Roboflow API communication
class RoboflowClient {
  /// Tests if an image URL is accessible
  Future<bool> testImageUrlAccessibility(String imageUrl) async {
    try {
      final headResponse = await http.head(Uri.parse(imageUrl));
      print('🔍 Image URL accessibility test: ${headResponse.statusCode}');

      if (headResponse.statusCode != 200) {
        print('❌ Image URL is not accessible: ${headResponse.statusCode}');
        print('📄 Head response: ${headResponse.headers}');
        return false;
      }
      return true;
    } catch (e) {
      print('❌ Failed to test image URL accessibility: $e');
      return false;
    }
  }

  /// Sends a request to Roboflow API
  Future<Map<String, dynamic>?> sendRequest(String imageUrl) async {
    try {
      print('🚀 Starting Roboflow analysis for image: $imageUrl');

      // Test image URL accessibility first
      final isAccessible = await testImageUrlAccessibility(imageUrl);
      if (!isAccessible) {
        return null;
      }

      // Create request payload
      final request = RoboflowRequest(
        apiKey: RoboflowConfig.apiKey,
        inputs: {
          'image': {'type': 'url', 'value': imageUrl},
        },
      );

      print('📤 Request payload: ${jsonEncode(request.toJson())}');

      // Send HTTP request
      final response = await http.post(
        Uri.parse(RoboflowConfig.baseUrl),
        headers: RoboflowConfig.headers,
        body: jsonEncode(request.toJson()),
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

  /// Sends an image URL to Roboflow for analysis with detailed logging
  Future<RoboflowResult> analyzeImageWithResult(String imageUrl) async {
    print('🔍 Initiating Roboflow analysis for: $imageUrl');

    final startTime = DateTime.now();
    final result = await sendRequest(imageUrl);
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
}
