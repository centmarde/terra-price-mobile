import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('Failed to select image: $e');
    }
  }

  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    List<File> selectedImages = [];
    int count = 0;

    while (count < maxImages) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );

        if (image != null) {
          selectedImages.add(File(image.path));
          count++;
        } else {
          break;
        }
      } catch (e) {
        throw Exception('Failed to select image: $e');
      }
    }

    return selectedImages;
  }
}
