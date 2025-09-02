import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'selected_images_grid.dart';
import 'upload_button.dart';

class SelectedImagesSection extends StatelessWidget {
  final List<File> selectedImages;
  final bool isUploading;
  final Function(int) onRemoveImage;
  final VoidCallback onUpload;

  const SelectedImagesSection({
    super.key,
    required this.selectedImages,
    required this.isUploading,
    required this.onRemoveImage,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Images (${selectedImages.length})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        SelectedImagesGrid(
          selectedImages: selectedImages,
          onRemoveImage: onRemoveImage,
        ),
        SizedBox(height: 16.h),
        UploadButton(
          isUploading: isUploading,
          imageCount: selectedImages.length,
          onPressed: onUpload,
        ),
      ],
    );
  }
}
