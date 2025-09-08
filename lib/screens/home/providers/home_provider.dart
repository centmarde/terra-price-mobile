import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../manager/image_manager.dart';
import '../manager/image_upload_manager.dart';
import '../manager/roboflow_analysis_manager.dart';

class HomeProvider extends ChangeNotifier {
  final ImageManager imageManager = ImageManager();
  final ImageUploadManager uploadManager = ImageUploadManager();
  final RoboflowAnalysisManager analysisManager = RoboflowAnalysisManager();
  final PageController _pageController = PageController();

  int _currentIndex = 0;
  bool _isUploading = false;
  bool _showLoader = false;
  Map<String, dynamic>? _latestRoboflowResult;
  bool _roboflowAnalysisFailed = false;
  String? _roboflowErrorMessage;
  bool _isAnalysisInProgress = false;
  Function(String)? _navigationCallback;

  // Navigation getters
  PageController get pageController => _pageController;
  int get currentIndex => _currentIndex;

  // Image getters
  List<File> get selectedImages => imageManager.selectedImages;
  File? get capturedImage => imageManager.capturedImage;
  bool get isUploading => _isUploading;
  bool get showLoader => _showLoader;

  // Roboflow getters
  Map<String, dynamic>? get latestRoboflowResult => _latestRoboflowResult;
  bool get roboflowAnalysisFailed => _roboflowAnalysisFailed;
  String? get roboflowErrorMessage => _roboflowErrorMessage;
  bool get isAnalysisInProgress => _isAnalysisInProgress;

  // Navigation methods
  void setNavigationCallback(Function(String)? callback) {
    _navigationCallback = callback;
  }

  void _navigateToRoute(String route) {
    if (_navigationCallback != null) {
      _navigationCallback!(route);
    }
  }

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

  // Image picking methods (delegate to ImageManager)
  Future<String?> pickImageFromCamera() async {
    try {
      _resetRoboflowState();
      final image = await imageManager.pickImageFromCamera();
      if (image != null) {
        _showLoader = true;
        notifyListeners();
        await analyzeImageWithRoboflow(image);
      }
      return null;
    } catch (e) {
      _showLoader = false;
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = 'Failed to capture image: $e';
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      _resetRoboflowState();
      final image = await imageManager.pickImageFromGallery();
      if (image != null) {
        _showLoader = true;
        notifyListeners();
        await analyzeImageWithRoboflow(image);
      }
      return null;
    } catch (e) {
      _showLoader = false;
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = 'Failed to select image: $e';
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> pickMultipleImages() async {
    try {
      await imageManager.pickMultipleImages();
      _showLoader = true;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void removeImage(int index) {
    imageManager.removeImage(index);
    notifyListeners();
  }

  // Upload images (delegate to ImageUploadManager and RoboflowAnalysisManager)
  Future<String?> uploadImages() async {
    if (selectedImages.isEmpty) return null;

    _isUploading = true;
    notifyListeners();

    try {
      final uploadedFilePaths = await uploadManager.uploadImages(
        selectedImages,
      );

      for (String filePath in uploadedFilePaths) {
        final imageUrl = uploadManager.getImageUrl(filePath);
        if (imageUrl != null) {
          final resultData = await analysisManager.analyzeImage(imageUrl);
          // Process resultData if needed
        }
      }

      imageManager.clearImages();
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

  void clearRoboflowResult() {
    _latestRoboflowResult = null;
    _roboflowAnalysisFailed = false;
    _roboflowErrorMessage = null;
    notifyListeners();
  }

  Future<String?> retryRoboflowAnalysis() async {
    if (capturedImage == null) return 'No image available to analyze';

    _resetRoboflowState();
    _showLoader = true;
    _isAnalysisInProgress = true;
    notifyListeners();

    final analysisError = await analyzeImageWithRoboflow(capturedImage!);
    if (analysisError != null) {
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = analysisError;
    }

    _showLoader = false;
    _isAnalysisInProgress = false;
    notifyListeners();
    return analysisError;
  }

  Future<String?> analyzeImageWithRoboflow(File imageFile) async {
    try {
      _isAnalysisInProgress = true;
      notifyListeners();

      final uploadedPaths = await uploadManager.uploadImages([imageFile]);
      if (uploadedPaths.isEmpty) {
        _roboflowAnalysisFailed = true;
        _roboflowErrorMessage = 'Failed to upload image to cloud storage';
        _showLoader = false;
        _isAnalysisInProgress = false;
        notifyListeners();
        _navigateToRoute('/ai_results_page');
        return 'Failed to upload image to cloud storage';
      }

      final imageUrl = uploadManager.getImageUrl(uploadedPaths.first);
      if (imageUrl == null) {
        _roboflowAnalysisFailed = true;
        _roboflowErrorMessage = 'Failed to generate image URL for analysis';
        _showLoader = false;
        _isAnalysisInProgress = false;
        notifyListeners();
        _navigateToRoute('/ai_results_page');
        return 'Failed to generate image URL for analysis';
      }

      final resultData = await analysisManager.analyzeImage(imageUrl);
      if (resultData != null) {
        _latestRoboflowResult = resultData;
        _roboflowAnalysisFailed = false;
        _roboflowErrorMessage = null;
      } else {
        _roboflowAnalysisFailed = true;
        _roboflowErrorMessage = 'Analysis failed - no data returned';
      }

      _showLoader = false;
      _isAnalysisInProgress = false;
      notifyListeners();
      _navigateToRoute('/ai_results_page');
      return null;
    } catch (e) {
      _roboflowAnalysisFailed = true;
      _roboflowErrorMessage = 'Analysis failed: ${e.toString()}';
      _showLoader = false;
      _isAnalysisInProgress = false;
      notifyListeners();
      _navigateToRoute('/ai_results_page');
      return 'Analysis failed: ${e.toString()}';
    }
  }

  void _resetRoboflowState() {
    _roboflowAnalysisFailed = false;
    _roboflowErrorMessage = null;
    _latestRoboflowResult = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
