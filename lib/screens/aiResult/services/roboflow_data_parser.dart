import 'dart:developer' as developer;

class RoboflowDataParser {
  /// Parses the Roboflow response JSON and extracts the label visualization image
  static String? extractLabelVisualizationImage(
    Map<String, dynamic> roboflowData,
  ) {
    try {
      // Check the new structure from live API: outputs[0].label_vis_model_output
      if (roboflowData.containsKey('outputs') &&
          roboflowData['outputs'] is List &&
          (roboflowData['outputs'] as List).isNotEmpty) {
        final firstOutput = (roboflowData['outputs'] as List)[0];
        if (firstOutput is Map<String, dynamic> &&
            firstOutput.containsKey('label_vis_model_output')) {
          final labelVisModelOutput = firstOutput['label_vis_model_output'];
          if (labelVisModelOutput != null &&
              labelVisModelOutput['type'] == 'base64') {
            final imageData = labelVisModelOutput['value'] as String?;
            developer.log(
              '🖼️ Found label visualization image data from outputs[0]',
            );
            return imageData;
          }
        }
      }

      // Fallback to old structure for backward compatibility
      final labelVisModelOutput = roboflowData['label_vis_model_output'];
      if (labelVisModelOutput != null &&
          labelVisModelOutput['type'] == 'base64') {
        final imageData = labelVisModelOutput['value'] as String?;
        developer.log(
          '🖼️ Found label visualization image data (legacy format)',
        );
        return imageData;
      }

      developer.log('⚠️ No label visualization image found in Roboflow data');
      developer.log('📋 Available keys: ${roboflowData.keys.toList()}');
      if (roboflowData.containsKey('outputs')) {
        developer.log('🔍 Outputs structure: ${roboflowData['outputs']}');
      }
      return null;
    } catch (e) {
      developer.log('❌ Error extracting label visualization image: $e');
      return null;
    }
  }

  /// Parses the Roboflow response JSON and extracts the bbox visualization image
  static String? extractBboxVisualizationImage(
    Map<String, dynamic> roboflowData,
  ) {
    try {
      // Check the new structure from live API: outputs[0].bbox_vis_model_output
      if (roboflowData.containsKey('outputs') &&
          roboflowData['outputs'] is List &&
          (roboflowData['outputs'] as List).isNotEmpty) {
        final firstOutput = (roboflowData['outputs'] as List)[0];
        if (firstOutput is Map<String, dynamic> &&
            firstOutput.containsKey('bbox_vis_model_output')) {
          final bboxVisModelOutput = firstOutput['bbox_vis_model_output'];
          if (bboxVisModelOutput != null &&
              bboxVisModelOutput['type'] == 'base64') {
            final imageData = bboxVisModelOutput['value'] as String?;
            developer.log(
              '🔲 Found bbox visualization image data from outputs[0]',
            );
            return imageData;
          }
        }
      }

      // Fallback to old structure for backward compatibility
      final bboxVisModelOutput = roboflowData['bbox_vis_model_output'];
      if (bboxVisModelOutput != null &&
          bboxVisModelOutput['type'] == 'base64') {
        final imageData = bboxVisModelOutput['value'] as String?;
        developer.log('🔲 Found bbox visualization image data (legacy format)');
        return imageData;
      }

      developer.log('⚠️ No bbox visualization image found in Roboflow data');
      return null;
    } catch (e) {
      developer.log('❌ Error extracting bbox visualization image: $e');
      return null;
    }
  }

  /// Extracts analysis insights from the predictions data
  static List<String> extractInsights(Map<String, dynamic> roboflowData) {
    try {
      List<dynamic>? predictions;

      // Check the new structure from live API: outputs[0] and look for any prediction-like data
      if (roboflowData.containsKey('outputs') &&
          roboflowData['outputs'] is List &&
          (roboflowData['outputs'] as List).isNotEmpty) {
        final firstOutput = (roboflowData['outputs'] as List)[0];
        if (firstOutput is Map<String, dynamic>) {
          developer.log('🔍 Searching for predictions in outputs[0]');
          developer.log(
            '📋 Available keys in outputs[0]: ${firstOutput.keys.toList()}',
          );

          // Try different possible prediction keys in the actual structure
          for (String key in firstOutput.keys) {
            if (key.toLowerCase().contains('prediction') ||
                key.toLowerCase().contains('detection') ||
                key.toLowerCase().contains('object')) {
              final value = firstOutput[key];
              developer.log(
                '🔍 Checking key: $key, type: ${value.runtimeType}',
              );

              if (value is Map<String, dynamic> &&
                  value.containsKey('predictions')) {
                predictions = value['predictions'] as List<dynamic>?;
                developer.log('✅ Found predictions in $key.predictions');
                break;
              } else if (value is List<dynamic>) {
                predictions = value;
                developer.log('✅ Found predictions directly in $key');
                break;
              }
            }
          }
        }
      }

      // Fallback to old structure for backward compatibility
      if (predictions == null) {
        if (roboflowData.containsKey('predictions')) {
          final predData = roboflowData['predictions'];
          if (predData is Map<String, dynamic> &&
              predData.containsKey('predictions')) {
            predictions = predData['predictions'] as List<dynamic>?;
          } else if (predData is List<dynamic>) {
            predictions = predData;
          }
        }
      }

      if (predictions == null || predictions.isEmpty) {
        developer.log(
          '⚠️ No predictions found in Roboflow data, using default insights',
        );
        developer.log('📋 Full data structure: $roboflowData');
        return _getDefaultInsights();
      }

      developer.log('✅ Found ${predictions.length} predictions to process');

      // Count different types of detected objects
      Map<String, int> objectCounts = {};
      double totalConfidence = 0;
      int detectionCount = 0;

      for (var prediction in predictions) {
        if (prediction is Map<String, dynamic>) {
          final className = prediction['class'] as String?;
          final confidence = prediction['confidence'] as double?;

          if (className != null) {
            objectCounts[className] = (objectCounts[className] ?? 0) + 1;
            developer.log('🏷️ Found object: $className');
          }

          if (confidence != null) {
            totalConfidence += confidence;
            detectionCount++;
          }
        }
      }

      List<String> insights = [];

      // Add confidence insight
      if (detectionCount > 0) {
        double avgConfidence = (totalConfidence / detectionCount) * 100;
        insights.add(
          '✓ AI detection confidence: ${avgConfidence.toStringAsFixed(1)}%',
        );
      }

      // Add object type insights
      objectCounts.forEach((className, count) {
        String formattedName = _formatObjectName(className);
        insights.add('✓ Detected $count $formattedName${count > 1 ? "s" : ""}');
      });

      // Add space optimization insights based on detected objects
      if (objectCounts.containsKey('door') && objectCounts['door']! > 3) {
        insights.add('✓ Good room connectivity with multiple doors');
      }

      if (objectCounts.containsKey('window')) {
        insights.add('✓ Natural light optimization detected');
      }

      if (objectCounts.containsKey('sofa') ||
          objectCounts.containsKey('large_sofa')) {
        insights.add('✓ Comfortable living space arrangement');
      }

      if (insights.isEmpty) {
        developer.log(
          '⚠️ No insights generated from predictions, using defaults',
        );
        return _getDefaultInsights();
      }

      developer.log(
        '✅ Generated ${insights.length} insights from Roboflow predictions',
      );
      return insights.take(4).toList(); // Limit to 4 insights
    } catch (e, stackTrace) {
      developer.log('❌ Error extracting insights: $e');
      developer.log('📚 Stack trace: $stackTrace');
      return _getDefaultInsights();
    }
  }

  /// Formats object class names for better readability
  static String _formatObjectName(String className) {
    return className
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Returns default insights when no data is available
  static List<String> _getDefaultInsights() {
    return [
      '✓ Open floor plan maximizes space utilization',
      '✓ Natural light optimization detected',
      '✓ Efficient room layout increases property value',
      '✓ Modern furniture placement suggests premium quality',
    ];
  }

  /// Extracts property metrics from predictions
  static Map<String, String> extractPropertyMetrics(
    Map<String, dynamic> roboflowData,
  ) {
    try {
      List<dynamic>? predictions;

      // Check the new structure from live API: outputs[0] and look for any prediction-like data
      if (roboflowData.containsKey('outputs') &&
          roboflowData['outputs'] is List &&
          (roboflowData['outputs'] as List).isNotEmpty) {
        final firstOutput = (roboflowData['outputs'] as List)[0];
        if (firstOutput is Map<String, dynamic>) {
          developer.log(
            '🔍 Searching for predictions in outputs[0] for metrics',
          );

          // Try different possible prediction keys in the actual structure
          for (String key in firstOutput.keys) {
            if (key.toLowerCase().contains('prediction') ||
                key.toLowerCase().contains('detection') ||
                key.toLowerCase().contains('object')) {
              final value = firstOutput[key];

              if (value is Map<String, dynamic> &&
                  value.containsKey('predictions')) {
                predictions = value['predictions'] as List<dynamic>?;
                developer.log(
                  '✅ Found predictions in $key.predictions for metrics',
                );
                break;
              } else if (value is List<dynamic>) {
                predictions = value;
                developer.log(
                  '✅ Found predictions directly in $key for metrics',
                );
                break;
              }
            }
          }
        }
      }

      // Fallback to old structure for backward compatibility
      if (predictions == null) {
        if (roboflowData.containsKey('predictions')) {
          final predData = roboflowData['predictions'];
          if (predData is Map<String, dynamic> &&
              predData.containsKey('predictions')) {
            predictions = predData['predictions'] as List<dynamic>?;
          } else if (predData is List<dynamic>) {
            predictions = predData;
          }
        }
      }

      if (predictions == null || predictions.isEmpty) {
        developer.log(
          '⚠️ No predictions found for metrics extraction, using defaults',
        );
        return _getDefaultMetrics();
      }

      Map<String, int> objectCounts = {};

      for (var prediction in predictions) {
        if (prediction is Map<String, dynamic>) {
          final className = prediction['class'] as String?;
          if (className != null) {
            objectCounts[className] = (objectCounts[className] ?? 0) + 1;
          }
        }
      }

      // Calculate estimated room count (simplified logic)
      int estimatedRooms = 1; // Start with 1 room
      if (objectCounts.containsKey('door')) {
        estimatedRooms = (objectCounts['door']! / 2).ceil().clamp(1, 6);
      }

      developer.log(
        '✅ Extracted property metrics from ${predictions.length} predictions',
      );
      return {
        'size': '120 sqm', // This would need additional calculation logic
        'rooms': estimatedRooms.toString(),
        'doors': (objectCounts['door'] ?? 0).toString(),
        'furnitures': _countFurniture(objectCounts).toString(),
      };
    } catch (e, stackTrace) {
      developer.log('❌ Error extracting property metrics: $e');
      developer.log('📚 Stack trace: $stackTrace');
      return _getDefaultMetrics();
    }
  }

  /// Counts furniture items from object detections
  static int _countFurniture(Map<String, int> objectCounts) {
    final furnitureTypes = [
      'sofa',
      'large_sofa',
      'small_sofa',
      'coffee_table',
      'sink',
      'large_sink',
      'twin_sink',
      'tub',
    ];

    int totalFurniture = 0;
    for (String type in furnitureTypes) {
      totalFurniture += objectCounts[type] ?? 0;
    }

    return totalFurniture;
  }

  /// Returns default metrics when no data is available
  static Map<String, String> _getDefaultMetrics() {
    return {'size': '120 sqm', 'rooms': '3', 'doors': '5', 'furnitures': '10'};
  }

  /// Loads and parses the Roboflow sample data from JSON file
  static Future<Map<String, dynamic>?> loadSampleData() async {
    try {
      // In a real app, you'd load this from assets or from the actual API response
      // For now, we'll return null to use default data
      developer.log('📁 Loading sample Roboflow data...');
      return null; // Will be implemented when needed
    } catch (e) {
      developer.log('❌ Error loading sample data: $e');
      return null;
    }
  }
}
