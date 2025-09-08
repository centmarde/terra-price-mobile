import 'dart:io';
import '../services/image_upload_service.dart';

class ImageUploadManager {
  final ImageUploadService _uploadService = ImageUploadService();

  Future<List<String>> uploadImages(List<File> images) async {
    return await _uploadService.uploadImages(images);
  }

  String? getImageUrl(String filePath) {
    return _uploadService.getImageUrl(filePath);
  }
}
