import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../aiResultsWidgets/property_dashboard_card.dart';
import '../aiResultsWidgets/floorplan_analysis_card.dart';
import '../aiResultsWidgets/download_report_card.dart';
import '../services/roboflow_data_parser.dart';
import 'package:go_router/go_router.dart';

/// Wrapper for AI Results Page that handles historical data
class AIResultsPageWrapper extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const AIResultsPageWrapper({super.key, required this.analysisData});

  /// Helper method to safely convert database values to int
  int _safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, String> _getPropertyMetrics() {
    // Calculate total furniture count with safe conversion
    int totalFurniture =
        _safeToInt(analysisData['sofa']) +
        _safeToInt(analysisData['large_sofa']) +
        _safeToInt(analysisData['sink']) +
        _safeToInt(analysisData['large_sink']) +
        _safeToInt(analysisData['twin_sink']) +
        _safeToInt(analysisData['tub']) +
        _safeToInt(analysisData['coffee_table']);

    // Estimate size based on rooms and doors (simplified calculation)
    int rooms = _safeToInt(analysisData['rooms'], defaultValue: 1);
    int doors = _safeToInt(analysisData['doors']);
    int windows = _safeToInt(analysisData['window']);
    int estimatedSize =
        (rooms * 25) + (doors * 5) + (windows * 3) + 50; // Simple formula

    return {
      'size': '$estimatedSize sqm',
      'rooms': rooms.toString(),
      'doors': doors.toString(),
      'windows': windows.toString(),
      'furnitures': totalFurniture.toString(),
    };
  }

  String? _getConfidenceScore() {
    if (analysisData['confidence_score'] != null) {
      int confidence = _safeToInt(analysisData['confidence_score']);
      return confidence.toString();
    }
    return null;
  }

  Map<String, dynamic>? _getDetailedCounts() {
    return {
      'rooms': _safeToInt(analysisData['rooms']),
      'sofa': _safeToInt(analysisData['sofa']),
      'large_sofa': _safeToInt(analysisData['large_sofa']),
      'coffee_table': _safeToInt(analysisData['coffee_table']),
      'sink': _safeToInt(analysisData['sink']),
      'large_sink': _safeToInt(analysisData['large_sink']),
      'twin_sink': _safeToInt(analysisData['twin_sink']),
      'tub': _safeToInt(analysisData['tub']),
    };
  }

  List<String> _getInsights() {
    final aiResponse = analysisData['ai_response'] as String?;
    if (aiResponse != null && aiResponse.isNotEmpty) {
      return aiResponse
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }

    // Generate basic insights from available data
    List<String> insights = [];
    int rooms = _safeToInt(analysisData['rooms']);
    int doors = _safeToInt(analysisData['doors']);
    int windows = _safeToInt(analysisData['window']);

    if (rooms > 0) insights.add('✓ $rooms room(s) detected');
    if (doors > 0) insights.add('✓ $doors door(s) identified');
    if (windows > 0) insights.add('✓ $windows window(s) found');

    final status = analysisData['status'] as String?;
    if (status == 'completed') {
      insights.add('✅ Analysis completed successfully');
    } else if (status == 'failed') {
      insights.add('❌ Analysis encountered issues');
    }

    if (insights.isEmpty) {
      insights.add('📊 Historical analysis data available');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final propertyMetrics = _getPropertyMetrics();
    final confidenceScore = _getConfidenceScore();
    final detailedCounts = _getDetailedCounts();
    final insights = _getInsights();
    final fileName =
        analysisData['file_name'] as String? ?? 'Historical Analysis';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.green,
        title: Text('AI Results - $fileName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Historical data notice
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historical Analysis Data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Viewing saved analysis results from ${analysisData['analyzed_at'] ?? analysisData['created_at'] ?? 'previous session'}',
                        style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashboard Section with historical data
          PropertyDashboardCard(
            size: propertyMetrics['size']!,
            rooms: propertyMetrics['rooms']!,
            doors: propertyMetrics['doors']!,
            windows: propertyMetrics['windows']!,
            furnitures: propertyMetrics['furnitures']!,
            confidence: confidenceScore,
            isLoading: false,
            detailedCounts: detailedCounts,
          ),
          const SizedBox(height: 24),

          // Floorplan Analysis Section
          FloorplanAnalysisCard(
            insights: insights,
            roboflowImageData: null, // Historical data might not have image
            capturedImage: null,
            hasAnalysisFailed: analysisData['status'] == 'failed',
            errorMessage: analysisData['status'] == 'failed'
                ? 'Historical analysis had issues'
                : null,
            onRetry: null, // No retry for historical data
            aiResponse: analysisData['ai_response'] as String?,
            isAILoading: false,
            aiGeneratedImageUrl: analysisData['file_path'] as String?,
          ),
          const SizedBox(height: 24),

          // Download Report Section with historical data
          DownloadReportCard(
            price:
                '\$500,000', // Could be extracted from AI response if available
            confidence: confidenceScore != null ? '$confidenceScore%' : '92%',
            propertyMetrics: propertyMetrics,
            insights: insights,
            roboflowImageData: null,
            confidenceScore: confidenceScore,
            detailedCounts: detailedCounts,
            capturedImage: null,
            supabaseData: analysisData,
            roboflowData: null, // Historical data doesn't have roboflow data
            hasAnalysisFailed: analysisData['status'] == 'failed',
            errorMessage: analysisData['status'] == 'failed'
                ? 'Historical analysis had issues'
                : null,
          ),
        ],
      ),
    );
  }
}
