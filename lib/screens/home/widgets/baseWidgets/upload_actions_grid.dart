import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'action_card.dart';

class UploadActionsGrid extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onRecentImagesPressed;
  final VoidCallback onUploadFilesPressed;

  const UploadActionsGrid({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onRecentImagesPressed,
    required this.onUploadFilesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Images',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.9, // Even more height for cards
          children: [
            ActionCard(
              icon: Icons.camera_alt_outlined,
              title: 'Take Photo',
              subtitle: 'Capture with camera',
              onTap: onCameraPressed,
            ),
            ActionCard(
              icon: Icons.photo_library_outlined,
              title: 'Select an Image',
              subtitle: 'Choose from gallery',
              onTap: onGalleryPressed,
            ),
            ActionCard(
              icon: Icons.history_outlined,
              title: 'Recent Images',
              subtitle: 'View recently taken photos',
              onTap: onRecentImagesPressed,
            ),
            ActionCard(
              icon: Icons.schedule,
              title: 'History',
              subtitle: 'View your recent uploads and actions',
              onTap: onRecentImagesPressed,
            ),
          ],
        ),
      ],
    );
  }
}
