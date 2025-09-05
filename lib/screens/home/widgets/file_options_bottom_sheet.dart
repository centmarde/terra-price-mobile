import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FileOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onDocumentsPressed;

  const FileOptionsBottomSheet({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onDocumentsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upload Options',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Documents'),
            subtitle: const Text('PDF, Word files, etc.'),
            onTap: () {
              Navigator.pop(context);
              onDocumentsPressed();
            },
          ),
        ],
      ),
    );
  }
}
