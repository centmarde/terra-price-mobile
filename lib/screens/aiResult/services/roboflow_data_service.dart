import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class RoboflowDataService {
  static const String _sampleDataPath = 'lib/assets/rboflow_sample.json';

  /// Logs JSON data with pretty formatting
  static void _logJsonData(String label, Map<String, dynamic> data) {
    developer.log('🔍 $label JSON RESPONSE:');
    developer.log('=' * 50);

    // Log the full JSON with pretty formatting
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(data);
    developer.log(prettyJson);

    developer.log('=' * 50);
    developer.log('📊 JSON Structure Summary:');
    developer.log('- Keys: ${data.keys.toList()}');

    // Log specific Roboflow fields
    if (data.containsKey('label_vis_model_output')) {
      developer.log(
        '🏷️ Has label_vis_model_output: ${data['label_vis_model_output']?.toString().substring(0, 100)}...',
      );
    }
    if (data.containsKey('bbox_vis_model_output')) {
      developer.log(
        '📦 Has bbox_vis_model_output: ${data['bbox_vis_model_output']?.toString().substring(0, 100)}...',
      );
    }
    if (data.containsKey('predictions')) {
      final predictions = data['predictions'];
      developer.log(
        '🎯 Predictions count: ${predictions is List ? predictions.length : 'N/A'}',
      );
    }
    if (data.containsKey('time')) {
      developer.log('⏱️ Processing time: ${data['time']}');
    }
    developer.log('=' * 50);
  }

  /// Loads the sample Roboflow data from the JSON file
  static Future<Map<String, dynamic>?> loadSampleData() async {
    try {
      developer.log('📁 Loading Roboflow sample data from: $_sampleDataPath');

      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(_sampleDataPath);
      final List<dynamic> jsonData = jsonDecode(jsonString);

      if (jsonData.isNotEmpty && jsonData[0] is Map<String, dynamic>) {
        final Map<String, dynamic> roboflowResponse =
            jsonData[0] as Map<String, dynamic>;

        developer.log('✅ Successfully loaded Roboflow sample data');

        // Log the detailed JSON response
        _logJsonData('SAMPLE ROBOFLOW DATA', roboflowResponse);

        return roboflowResponse;
      } else {
        developer.log('⚠️ Invalid data format in sample JSON');
        return null;
      }
    } catch (e) {
      developer.log('❌ Error loading sample Roboflow data: $e');
      return null;
    }
  }

  /// Loads Roboflow data from a real API response
  /// This method would be used when integrating with the actual Roboflow API
  static Future<Map<String, dynamic>?> loadFromApiResponse(
    String jsonResponse,
  ) async {
    try {
      developer.log('📡 Processing Roboflow API response...');

      final Map<String, dynamic> responseData = jsonDecode(jsonResponse);

      developer.log('✅ Successfully processed API response');

      // Log the detailed JSON response from real API
      _logJsonData('LIVE ROBOFLOW API', responseData);

      return responseData;
    } catch (e) {
      developer.log('❌ Error processing API response: $e');
      return null;
    }
  }
}
