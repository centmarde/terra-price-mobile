import 'dart:developer' as developer;

/// Service class to extract and count classes from Roboflow API response
/// Handles both predictions and model_2_predictions sections
class RoboflowClassExtractor {
  /// Extracts classes from Roboflow response and returns counts
  /// Combines classes from both 'predictions' and 'model_2_predictions' sections
  static RoboflowClassCounts extractClassCounts(
    Map<String, dynamic> roboflowData,
  ) {
    developer.log('🔍 Starting class extraction from Roboflow data');

    final Map<String, int> classCounts = {};
    final Map<String, List<RoboflowDetection>> classDetections = {};
    int totalDetections = 0;

    try {
      // Check if outputs array exists
      if (roboflowData.containsKey('outputs') &&
          roboflowData['outputs'] is List &&
          (roboflowData['outputs'] as List).isNotEmpty) {
        final outputs = roboflowData['outputs'] as List;
        final firstOutput = outputs[0] as Map<String, dynamic>;

        // Extract from 'predictions' section
        if (firstOutput.containsKey('predictions')) {
          final predictionsSection = firstOutput['predictions'];
          if (predictionsSection is Map<String, dynamic> &&
              predictionsSection.containsKey('predictions')) {
            final predictions = predictionsSection['predictions'] as List;
            developer.log(
              '📊 Found ${predictions.length} predictions in main predictions section',
            );

            for (var prediction in predictions) {
              if (prediction is Map<String, dynamic>) {
                _processPrediction(
                  prediction,
                  classCounts,
                  classDetections,
                  'main_predictions',
                );
                totalDetections++;
              }
            }
          }
        }

        // Extract from 'model_2_predictions' section
        if (firstOutput.containsKey('model_2_predictions')) {
          final model2Section = firstOutput['model_2_predictions'];
          if (model2Section is Map<String, dynamic> &&
              model2Section.containsKey('predictions')) {
            final model2Predictions = model2Section['predictions'] as List;
            developer.log(
              '📊 Found ${model2Predictions.length} predictions in model_2_predictions section',
            );

            for (var prediction in model2Predictions) {
              if (prediction is Map<String, dynamic>) {
                _processPrediction(
                  prediction,
                  classCounts,
                  classDetections,
                  'model_2_predictions',
                );
                totalDetections++;
              }
            }
          }
        }

        developer.log('✅ Class extraction completed');
        developer.log('📈 Total unique classes found: ${classCounts.length}');
        developer.log('🎯 Total detections: $totalDetections');
        developer.log('📋 Class counts: $classCounts');

        return RoboflowClassCounts(
          classCounts: classCounts,
          classDetections: classDetections,
          totalDetections: totalDetections,
        );
      } else {
        developer.log('⚠️ No outputs found in Roboflow data');
        return RoboflowClassCounts.empty();
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error extracting class counts: $e');
      developer.log('📚 Stack trace: $stackTrace');
      return RoboflowClassCounts.empty();
    }
  }

  /// Extracts individual object counts for database storage
  static Map<String, int> extractIndividualCounts(
    Map<String, dynamic> roboflowData,
  ) {
    developer.log('🔢 Extracting individual object counts for database');

    final classCounts = extractClassCounts(roboflowData);

    // Map Roboflow class names to database column names
    final Map<String, int> dbCounts = {
      'doors': 0,
      'rooms': 0,
      'window': 0,
      'sofa': 0,
      'large_sofa': 0,
      'sink': 0,
      'large_sink': 0,
      'twin_sink': 0,
      'tub': 0,
      'coffee_table': 0,
      'total_detections': classCounts.totalDetections,
    };

    // Map class names from Roboflow to database columns
    for (final entry in classCounts.classCounts.entries) {
      final className = entry.key.toLowerCase();
      final count = entry.value;

      // Direct mappings
      if (dbCounts.containsKey(className)) {
        dbCounts[className] = count;
      }

      // Handle variations and mappings
      switch (className) {
        case 'door':
          dbCounts['doors'] = (dbCounts['doors'] ?? 0) + count;
          break;
        case 'room':
          dbCounts['rooms'] = (dbCounts['rooms'] ?? 0) + count;
          break;
        case 'windows':
          dbCounts['window'] = (dbCounts['window'] ?? 0) + count;
          break;
        case 'small_sofa':
          dbCounts['sofa'] = (dbCounts['sofa'] ?? 0) + count;
          break;
        case 'small_sink':
          dbCounts['sink'] = (dbCounts['sink'] ?? 0) + count;
          break;
        case 'bathtub':
        case 'bath_tub':
          dbCounts['tub'] = (dbCounts['tub'] ?? 0) + count;
          break;
        case 'table':
        case 'coffee table':
          dbCounts['coffee_table'] = (dbCounts['coffee_table'] ?? 0) + count;
          break;
      }
    }

    // Calculate average confidence
    double avgConfidence = 0.0;
    if (classCounts.totalDetections > 0) {
      double totalConfidence = 0.0;
      for (final detections in classCounts.classDetections.values) {
        for (final detection in detections) {
          totalConfidence += detection.confidence;
        }
      }
      avgConfidence = totalConfidence / classCounts.totalDetections;
    }

    // Store confidence as integer (percentage)
    dbCounts['confidence_score'] = (avgConfidence * 100).round();

    developer.log('📊 Extracted counts for database: $dbCounts');
    return dbCounts;
  }

  /// Processes a single prediction and updates class counts
  static void _processPrediction(
    Map<String, dynamic> prediction,
    Map<String, int> classCounts,
    Map<String, List<RoboflowDetection>> classDetections,
    String source,
  ) {
    try {
      final className = prediction['class'] as String?;
      final confidence = prediction['confidence'] as double?;
      final classId = prediction['class_id'] as int?;

      if (className != null) {
        // Update class count
        classCounts[className] = (classCounts[className] ?? 0) + 1;

        // Create detection object
        final detection = RoboflowDetection(
          className: className,
          confidence: confidence ?? 0.0,
          classId: classId ?? -1,
          x: prediction['x']?.toDouble() ?? 0.0,
          y: prediction['y']?.toDouble() ?? 0.0,
          width: prediction['width']?.toDouble() ?? 0.0,
          height: prediction['height']?.toDouble() ?? 0.0,
          detectionId: prediction['detection_id'] as String? ?? '',
          source: source,
        );

        // Add to class detections list
        if (!classDetections.containsKey(className)) {
          classDetections[className] = [];
        }
        classDetections[className]!.add(detection);

        developer.log(
          '🏷️ Processed $className from $source (confidence: ${confidence?.toStringAsFixed(2) ?? "N/A"})',
        );
      }
    } catch (e) {
      developer.log('⚠️ Error processing prediction: $e');
    }
  }

  /// Gets the most common class from the analysis
  static String? getMostCommonClass(RoboflowClassCounts classCounts) {
    if (classCounts.classCounts.isEmpty) return null;

    return classCounts.classCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets classes with count greater than specified threshold
  static Map<String, int> getClassesAboveThreshold(
    RoboflowClassCounts classCounts,
    int threshold,
  ) {
    return Map.fromEntries(
      classCounts.classCounts.entries.where((entry) => entry.value > threshold),
    );
  }

  /// Gets summary statistics for the detected classes
  static RoboflowClassSummary getClassSummary(RoboflowClassCounts classCounts) {
    if (classCounts.classCounts.isEmpty) {
      return RoboflowClassSummary.empty();
    }

    final sortedClasses = classCounts.classCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostCommon = sortedClasses.first;
    final leastCommon = sortedClasses.last;

    return RoboflowClassSummary(
      totalClasses: classCounts.classCounts.length,
      totalDetections: classCounts.totalDetections,
      mostCommonClass: mostCommon.key,
      mostCommonCount: mostCommon.value,
      leastCommonClass: leastCommon.key,
      leastCommonCount: leastCommon.value,
      sortedClasses: sortedClasses,
    );
  }
}

/// Container class for class counts and detection details
class RoboflowClassCounts {
  final Map<String, int> classCounts;
  final Map<String, List<RoboflowDetection>> classDetections;
  final int totalDetections;

  RoboflowClassCounts({
    required this.classCounts,
    required this.classDetections,
    required this.totalDetections,
  });

  factory RoboflowClassCounts.empty() {
    return RoboflowClassCounts(
      classCounts: {},
      classDetections: {},
      totalDetections: 0,
    );
  }

  bool get isEmpty => classCounts.isEmpty;
  bool get isNotEmpty => classCounts.isNotEmpty;
}

/// Individual detection data
class RoboflowDetection {
  final String className;
  final double confidence;
  final int classId;
  final double x;
  final double y;
  final double width;
  final double height;
  final String detectionId;
  final String source; // 'main_predictions' or 'model_2_predictions'

  RoboflowDetection({
    required this.className,
    required this.confidence,
    required this.classId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.detectionId,
    required this.source,
  });

  @override
  String toString() {
    return 'RoboflowDetection(class: $className, confidence: ${confidence.toStringAsFixed(2)}, source: $source)';
  }
}

/// Summary statistics for detected classes
class RoboflowClassSummary {
  final int totalClasses;
  final int totalDetections;
  final String mostCommonClass;
  final int mostCommonCount;
  final String leastCommonClass;
  final int leastCommonCount;
  final List<MapEntry<String, int>> sortedClasses;

  RoboflowClassSummary({
    required this.totalClasses,
    required this.totalDetections,
    required this.mostCommonClass,
    required this.mostCommonCount,
    required this.leastCommonClass,
    required this.leastCommonCount,
    required this.sortedClasses,
  });

  factory RoboflowClassSummary.empty() {
    return RoboflowClassSummary(
      totalClasses: 0,
      totalDetections: 0,
      mostCommonClass: '',
      mostCommonCount: 0,
      leastCommonClass: '',
      leastCommonCount: 0,
      sortedClasses: [],
    );
  }

  @override
  String toString() {
    return 'RoboflowClassSummary(totalClasses: $totalClasses, totalDetections: $totalDetections, mostCommon: $mostCommonClass($mostCommonCount))';
  }
}
