import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../services/image_picker_service.dart';
import '../services/image_upload_service.dart';
import '../../aiResult/services/roboflow_fetch.dart';

class HomeProvider extends ChangeNotifier {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _uploadService = ImageUploadService();
  final PageController _pageController = PageController();

  // Navigation properties
  int _currentIndex = 0;

  // Image properties
  List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _showLoader = false;
  File? _capturedImage; // Store the latest captured image

  // Roboflow analysis results
  Map<String, dynamic>? _latestRoboflowResult;
  bool _roboflowAnalysisFailed = false;
  String? _roboflowErrorMessage;
  Function(String)? _navigationCallback; // Callback for navigation
  bool _isAnalysisInProgress = false; // Track if analysis is currently running

  // Navigation getters
  PageController get pageController => _pageController;
  int get currentIndex => _currentIndex;

  // Image getters
  List<File> get selectedImages => _selectedImages;
  bool get isUploading => _isUploading;
  bool get showLoader => _showLoader;
  File? get capturedImage => _capturedImage;

  // Roboflow getters
  Map<String, dynamic>? get latestRoboflowResult => _latestRoboflowResult;
  bool get roboflowAnalysisFailed => _roboflowAnalysisFailed;
  String? get roboflowErrorMessage => _roboflowErrorMessage;
  bool get isAnalysisInProgress => _isAnalysisInProgress;

  // Set navigation callback
  void setNavigationCallback(Function(String)? callback) {
    _navigationCallback = callback;
  }

  // Safe navigation that checks for callback availability
  void _navigateToRoute(String route) {
    try {
      print('🎯 Attempting navigation to: $route');
      if (_navigationCallback != null) {
        _navigationCallback!(route);
        print('✅ Navigation callback executed successfully');
      } else {
        print('⚠️ Navigation callback is null, cannot navigate');
      }
    } catch (e) {
      print('❌ Navigation failed: $e');
      // Don't rethrow the error, just log it
    }
  }

  // Navigation methods
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void navigateToPage(int index) {
    _currentIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  // Image picking methods
  Future<String?> pickImageFromCamera() async {
    try {
      print('📷 Starting camera image capture...');

      // Reset previous states
      _roboflowAnalysisFailed = false;
      _roboflowErrorMessage = null;
      _latestRoboflowResult = null;

      final image = await _imagePickerService.pickImageFromCamera();
      if (image != null) {
        print('✅ Camera image captured: ${image.path}');
        _selectedImages.add(image);
        _capturedImage = image; // Store the captured image
        _showLoader = true; // Show loader while analyzing with Roboflow
        notifyListeners();

        // Analyze the captured image with live Roboflow API
        await analyzeImageWithRoboflow(image);
        // Note: Navigation and loader control now happens inside analyzeImageWithRoboflow

        print('✅ Camera image processed');
      } else {
        print('❌ No image captured from camera');
      }
      return null;
    } catch (e) {
      print('❌ Error capturing camera image: $e');
      _showLoader = false;
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = 'Failed to capture image: $e';
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      print('🖼️ Starting gallery image selection...');

      // Reset previous states
      _roboflowAnalysisFailed = false;
      _roboflowErrorMessage = null;
      _latestRoboflowResult = null;

      final image = await _imagePickerService.pickImageFromGallery();
      if (image != null) {
        print('✅ Gallery image selected: ${image.path}');
        _selectedImages.add(image);
        _capturedImage = image; // Store the selected image
        _showLoader = true; // Show loader while analyzing with Roboflow
        notifyListeners();

        // Analyze the selected image with live Roboflow API
        await analyzeImageWithRoboflow(image);
        // Note: Navigation and loader control now happens inside analyzeImageWithRoboflow

        print('✅ Gallery image processed');
      } else {
        print('❌ No image selected from gallery');
      }
      return null;
    } catch (e) {
      print('❌ Error selecting gallery image: $e');
      _showLoader = false;
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = 'Failed to select image: $e';
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> pickMultipleImages() async {
    try {
      final images = await _imagePickerService.pickMultipleImages();
      if (images.isNotEmpty) {
        _selectedImages.addAll(images);
        _showLoader = true;
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  Future<String?> uploadImages() async {
    if (_selectedImages.isEmpty) return null;

    _isUploading = true;
    notifyListeners();

    try {
      // Upload images to Supabase
      final uploadedFilePaths = await _uploadService.uploadImages(
        _selectedImages,
      );

      // Analyze each uploaded image with Roboflow
      for (String filePath in uploadedFilePaths) {
        final imageUrl = _uploadService.getImageUrl(filePath);
        if (imageUrl != null) {
          print('🔍 Starting Roboflow analysis for: $imageUrl');
          final result = await RoboflowFetch.analyzeImageWithResult(
            imageUrl,
          ); //base Gateway sa roboflow
          print('📊 Roboflow analysis result: $result');

          // Log the full result JSON if successful
          if (result.success && result.data != null) {
            print('🚀 LIVE ROBOFLOW API JSON RESPONSE:');
            print('=' * 60);
            const encoder = JsonEncoder.withIndent('  ');
            final prettyJson = encoder.convert(result.data!);
            print(prettyJson);
            print('=' * 60);
          }
        }
      }

      _selectedImages.clear();
      _isUploading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      return 'Upload failed: ${e.toString()}';
    }
  }

  void setShowLoader(bool value) {
    _showLoader = value;
    notifyListeners();
  }

  /// Clears the latest Roboflow analysis result and failure state
  void clearRoboflowResult() {
    _latestRoboflowResult = null;
    _roboflowAnalysisFailed = false;
    _roboflowErrorMessage = null;
    notifyListeners();
  }

  /// Retry Roboflow analysis for the current captured image
  Future<String?> retryRoboflowAnalysis() async {
    if (_capturedImage == null) {
      return 'No image available to analyze';
    }

    print('🔄 Retrying Roboflow analysis...');

    // Reset failure state
    _roboflowAnalysisFailed = false;
    _roboflowErrorMessage = null;
    _latestRoboflowResult = null;
    _showLoader = true;
    _isAnalysisInProgress = true;
    notifyListeners();

    final analysisError = await analyzeImageWithRoboflow(_capturedImage!);
    if (analysisError != null) {
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = analysisError;
    }

    _showLoader = false;
    _isAnalysisInProgress = false;
    notifyListeners();

    print('🔄 Retry analysis completed');
    return analysisError;
  }

  /// Analyzes a single image with Roboflow immediately after upload
  Future<String?> analyzeImageWithRoboflow(File imageFile) async {
    try {
      print(
        '🚀 Starting immediate Roboflow analysis for picked image: ${imageFile.path}',
      );

      // Set analysis in progress flag
      _isAnalysisInProgress = true;
      notifyListeners();

      // Upload the single image first
      print('📤 Uploading image to cloud storage...');
      final uploadedPaths = await _uploadService.uploadImages([imageFile]);
      print('✅ Image upload completed. Uploaded paths: $uploadedPaths');

      if (uploadedPaths.isEmpty) {
        print('❌ No files were uploaded successfully');
        _roboflowAnalysisFailed = true;
        _roboflowErrorMessage = 'Failed to upload image to cloud storage';
        _showLoader = false;
        _isAnalysisInProgress = false;
        notifyListeners();
        _navigateToRoute('/ai_results_page');
        return 'Failed to upload image to cloud storage';
      }

      final imageUrl = _uploadService.getImageUrl(uploadedPaths.first);
      if (imageUrl == null) {
        print(
          '❌ Failed to generate image URL from uploaded path: ${uploadedPaths.first}',
        );
        _roboflowAnalysisFailed = true;
        _roboflowErrorMessage = 'Failed to generate image URL for analysis';
        _showLoader = false;
        _isAnalysisInProgress = false;
        notifyListeners();
        _navigateToRoute('/ai_results_page');
        return 'Failed to generate image URL for analysis';
      }

      print('🌐 Generated image URL for Roboflow: $imageUrl');
      print('🔍 Calling Roboflow API and waiting for result...');

      // Wait for the Roboflow API result before proceeding
      final result = await RoboflowFetch.analyzeImageWithResult(imageUrl);
      print('📊 Roboflow API response received: $result');

      // Process the result regardless of success or failure
      if (result.success && result.data != null) {
        // Success case - store the result data
        _latestRoboflowResult = result.data;
        print(
          '✅ Successfully stored Roboflow analysis result for AI Results page',
        );
        print('🗂️ Stored data keys: ${result.data!.keys.toList()}');

        // Enhanced JSON logging for live API response
        print('🚀 LIVE ROBOFLOW API JSON RESPONSE LOGGING:');
        print('=' * 60);
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(result.data!);
        print(prettyJson);
        print('=' * 60);

        // Log specific data we're looking for
        if (result.data!.containsKey('outputs') &&
            result.data!['outputs'] is List &&
            (result.data!['outputs'] as List).isNotEmpty) {
          final firstOutput = result.data!['outputs'][0];
          if (firstOutput.containsKey('label_vis_model_output')) {
            print('🏷️ Found label_vis_model_output in response');
          }
          if (firstOutput.containsKey('bbox_vis_model_output')) {
            print('📦 Found bbox_vis_model_output in response');
          }
        }

        // Clear failure state on success
        _roboflowAnalysisFailed = false;
        _roboflowErrorMessage = null;

        print('🎯 Roboflow API analysis complete! Triggering navigation...');
      } else {
        // Failure case - set failure state but still navigate to show the failure
        print('❌ Roboflow analysis failed or returned no data');
        print(
          '📄 Result details: success=${result.success}, data=${result.data}, error=${result.error}',
        );

        _roboflowAnalysisFailed = true;
        _roboflowErrorMessage =
            result.error ?? 'Analysis failed - no data returned';

        print(
          '⚠️ Roboflow API failed! Triggering navigation to show failure state...',
        );
      }

      // Always hide loader, clear analysis progress, and navigate after API call completes
      _showLoader = false;
      _isAnalysisInProgress = false;
      notifyListeners();

      // Use safe navigation method
      _navigateToRoute('/ai_results_page');

      return null; // Return null for success, the caller will check failure state
    } catch (e) {
      print('💥 Exception in immediate analysis: $e');

      // Set failure state
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = 'Analysis failed: ${e.toString()}';

      // Navigate to AI results page to show failure state
      print(
        '⚠️ Analysis exception occurred! Triggering navigation to show failure state...',
      );
      _showLoader = false;
      _isAnalysisInProgress = false;
      notifyListeners();

      // Use safe navigation method
      _navigateToRoute('/ai_results_page');

      return 'Analysis failed: ${e.toString()}';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
