import 'dart:io';
import 'roboflow_analyzer.dart';
import 'roboflow_models.dart';
import '../../aiResult/services/groq_ai_service.dart';

/// Main service class to handle Roboflow API integration
/// Orchestrates the analysis process using smaller, focused components
class RoboflowApiService {
  final RoboflowAnalyzer _analyzer = RoboflowAnalyzer();

  /// Analyzes a single image with Roboflow API and Groq AI
  /// This is the enhanced version that includes AI cost estimation
  Future<RoboflowAnalysisResult> analyzeImage(File imageFile) async {
    // First, get Groq AI analysis
    String? aiResponse;
    try {
      print('🤖 Starting Groq AI analysis for construction cost estimation...');
      final groqResponse = await GroqAIService.analyzeFloorPlanFromFile(
        imageFile: imageFile,
        customPrompt:
            'Please analyze this floor plan and provide a detailed construction cost estimate with comprehensive breakdown.',
      );

      if (groqResponse.choices.isNotEmpty) {
        aiResponse = groqResponse.choices.first.message.content;
        print('✅ Groq AI analysis completed successfully');
        print('📝 AI Response length: ${aiResponse.length} characters');
      } else {
        print('⚠️ Groq AI returned empty response');
        aiResponse = 'No analysis available - empty response from AI service';
      }
    } catch (e) {
      print('❌ Groq AI analysis failed: $e');
      aiResponse = 'AI analysis failed: ${e.toString()}';
    }

    // Then proceed with Roboflow analysis with the AI response
    final result = await _analyzer.analyzeImageWithAI(imageFile, aiResponse);
    return result;
  }

  /// Original analyzeImage method (kept for backward compatibility)
  Future<RoboflowAnalysisResult> analyzeImageOriginal(File imageFile) async {
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
