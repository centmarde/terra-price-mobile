import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageSelectionBottomSheet extends StatelessWidget {
  final VoidCallback onPickSingle;

  final VoidCallback onTakePhoto;

  const ImageSelectionBottomSheet({
    super.key,
    required this.onPickSingle,

    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Images',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pick Single Image'),
            subtitle: const Text('Select one image from gallery'),
            onTap: () {
              Navigator.pop(context);
              onPickSingle();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            subtitle: const Text('Use camera to take a photo'),
            onTap: () {
              Navigator.pop(context);
              onTakePhoto();
            },
          ),
        ],
      ),
    );
  }
}
