import 'dart:io';
import '../services/image_picker_service.dart';

class ImageManager {
  final ImagePickerService _imagePickerService = ImagePickerService();
  List<File> _selectedImages = [];
  File? _capturedImage;

  List<File> get selectedImages => _selectedImages;
  File? get capturedImage => _capturedImage;

  Future<File?> pickImageFromCamera() async {
    final image = await _imagePickerService.pickImageFromCamera();
    if (image != null) {
      _selectedImages.add(image);
      _capturedImage = image;
    }
    return image;
  }

  Future<File?> pickImageFromGallery() async {
    final image = await _imagePickerService.pickImageFromGallery();
    if (image != null) {
      _selectedImages.add(image);
      _capturedImage = image;
    }
    return image;
  }

  Future<List<File>> pickMultipleImages() async {
    final images = await _imagePickerService.pickMultipleImages();
    _selectedImages.addAll(images);
    return images;
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
  }

  void clearImages() {
    _selectedImages.clear();
    _capturedImage = null;
  }
}
