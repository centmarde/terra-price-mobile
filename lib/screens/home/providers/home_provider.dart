import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/image_picker_service.dart';
import '../services/image_upload_service.dart';

class HomeProvider extends ChangeNotifier {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _uploadService = ImageUploadService();

  List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _showLoader = false;

  // Getters
  List<File> get selectedImages => _selectedImages;
  bool get isUploading => _isUploading;
  bool get showLoader => _showLoader;

  // Image picking methods
  Future<String?> pickImageFromCamera() async {
    try {
      final image = await _imagePickerService.pickImageFromCamera();
      if (image != null) {
        _selectedImages.add(image);
        _showLoader = true;
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final image = await _imagePickerService.pickImageFromGallery();
      if (image != null) {
        _selectedImages.add(image);
        _showLoader = true;
        notifyListeners();
      }
      return null;
    } catch (e) {
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
      await _uploadService.uploadImages(_selectedImages);
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
}
