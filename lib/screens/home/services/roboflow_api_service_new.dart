import 'dart:io';
import 'roboflow_analyzer.dart';
import 'roboflow_models.dart';

/// Main service class to handle Roboflow API integration
/// Orchestrates the analysis process using smaller, focused components
class RoboflowApiService {
  final RoboflowAnalyzer _analyzer = RoboflowAnalyzer();

  /// Analyzes a single image with Roboflow API
  Future<RoboflowAnalysisResult> analyzeImage(File imageFile) async {
    return await _analyzer.analyzeImage(imageFile);
  }

  /// Analyzes multiple images with Roboflow API
  Future<List<RoboflowAnalysisResult>> analyzeMultipleImages(
    List<File> imageFiles,
  ) async {
    return await _analyzer.analyzeMultipleImages(imageFiles);
  }

  /// Analyzes images that are already uploaded to cloud storage
  Future<List<RoboflowAnalysisResult>> analyzeUploadedImages(
    List<String> uploadedFilePaths,
  ) async {
    return await _analyzer.analyzeUploadedImages(uploadedFilePaths);
  }
}
