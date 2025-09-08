import 'dart:io';
import '../../aiResult/services/roboflow_fetch.dart';

class RoboflowAnalysisManager {
  Future<Map<String, dynamic>?> analyzeImage(String imageUrl) async {
    final result = await RoboflowFetch.analyzeImageWithResult(imageUrl);
    if (result.success && result.data != null) {
      return result.data;
    }
    return null;
  }
}
