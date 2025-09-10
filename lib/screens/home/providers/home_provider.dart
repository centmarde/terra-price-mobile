import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../services/image_picker_service.dart';
import '../services/image_upload_service.dart';
import '../services/roboflow_api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class HomeProvider extends ChangeNotifier {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _uploadService = ImageUploadService();
  final RoboflowApiService _roboflowService = RoboflowApiService();
  final PageController _pageController = PageController();
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // Authentication state
  bool _isSessionValid = true;

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

  // Authentication getters
  bool get isSessionValid => _isSessionValid;

  /// Check if the current session is valid
  Future<bool> _checkSessionValidity() async {
    try {
      final user = _supabase.auth.currentUser;
      final session = _supabase.auth.currentSession;

      if (user == null || session == null) {
        developer.log('❌ No user or session found');
        _isSessionValid = false;
        notifyListeners();
        return false;
      }

      // Check if session is expired
      final now = DateTime.now();
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );

      if (now.isAfter(expiresAt)) {
        developer.log('❌ Session expired, attempting to refresh...');

        try {
          final response = await _supabase.auth.refreshSession();
          if (response.session != null) {
            developer.log('✅ Session refreshed successfully');
            _isSessionValid = true;
          } else {
            developer.log('❌ Failed to refresh session');
            _isSessionValid = false;
          }
        } catch (e) {
          developer.log('❌ Error refreshing session: $e');
          _isSessionValid = false;
        }
      } else {
        _isSessionValid = true;
      }

      notifyListeners();
      return _isSessionValid;
    } catch (e) {
      developer.log('❌ Error checking session validity: $e');
      _isSessionValid = false;
      notifyListeners();
      return false;
    }
  }

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

      // Check session validity before proceeding
      await _checkSessionValidity();

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

      // Check session validity before proceeding
      await _checkSessionValidity();

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
      // Check session validity before proceeding
      await _checkSessionValidity();

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

    // Check session validity before uploading
    final isValid = await _checkSessionValidity();
    if (!isValid) {
      return 'Session expired. Please log in again.';
    }

    _isUploading = true;
    notifyListeners();

    try {
      // Upload images to Supabase
      final uploadedFilePaths = await _uploadService.uploadImages(
        _selectedImages,
      );

      // Analyze uploaded images with Roboflow using the service
      final results = await _roboflowService.analyzeUploadedImages(
        uploadedFilePaths,
      );

      // Log results
      for (var result in results) {
        print('🔍 Roboflow analysis result: $result');
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

    // Check session validity before retrying
    await _checkSessionValidity();

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

      // Use the RoboflowApiService to handle the analysis
      final result = await _roboflowService.analyzeImage(imageFile);

      // Process the result regardless of success or failure
      if (result.success && result.data != null) {
        // Success case - store the result data
        _latestRoboflowResult = result.data;
        print(
          '✅ Successfully stored Roboflow analysis result for AI Results page',
        );
        print('🗂️ Stored data keys: ${result.data!.keys.toList()}');

        // Clear failure state on success
        _roboflowAnalysisFailed = false;
        _roboflowErrorMessage = null;

        print('🎯 Roboflow API analysis complete! Triggering navigation...');
      } else {
        // Failure case - set failure state but still navigate to show the failure
        print('❌ Roboflow analysis failed or returned no data');
        print('📄 Result details: $result');

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
