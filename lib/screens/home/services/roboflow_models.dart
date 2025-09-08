import 'roboflow_class_extractor.dart';

/// Result class for Roboflow API analysis
class RoboflowAnalysisResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final String? uploadedImageUrl;
  final List<String>? aiResultsUrls;
  final RoboflowClassCounts? classCounts;
  final RoboflowClassSummary? classSummary;

  RoboflowAnalysisResult._({
    required this.success,
    this.data,
    this.error,
    this.uploadedImageUrl,
    this.aiResultsUrls,
    this.classCounts,
    this.classSummary,
  });

  /// Creates a successful result
  factory RoboflowAnalysisResult.success(
    Map<String, dynamic> data, {
    String? uploadedImageUrl,
    List<String>? aiResultsUrls,
    RoboflowClassCounts? classCounts,
    RoboflowClassSummary? classSummary,
  }) {
    return RoboflowAnalysisResult._(
      success: true,
      data: data,
      uploadedImageUrl: uploadedImageUrl,
      aiResultsUrls: aiResultsUrls,
      classCounts: classCounts,
      classSummary: classSummary,
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

/// Request payload model for Roboflow API
class RoboflowRequest {
  final String apiKey;
  final Map<String, dynamic> inputs;

  RoboflowRequest({required this.apiKey, required this.inputs});

  Map<String, dynamic> toJson() {
    return {'api_key': apiKey, 'inputs': inputs};
  }
}
