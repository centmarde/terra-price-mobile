import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'action_card.dart';
import '../../../aiResult/services/supabase_data_service.dart';
import '../../providers/history_provider.dart';
import '../history_bottom_sheet.dart';

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

  void _showHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (context) => HistoryProvider(),
        child: const HistoryBottomSheet(),
      ),
    );
  }

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
          childAspectRatio: 0.9,
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
            // Recent AI Result card (same structure as History, unique icon, no image)
            FutureBuilder<Map<String, dynamic>?>(
              future: SupabaseDataService().getLatestAnalysisData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ActionCard(
                    icon: Icons.insights_outlined,
                    title: 'Recent AI Result',
                    subtitle: 'Loading...',
                    onTap: onRecentImagesPressed,
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return ActionCard(
                    icon: Icons.insights_outlined,
                    title: 'Recent AI Result',
                    subtitle: 'No recent AI results',
                    onTap: onRecentImagesPressed,
                  );
                }
                final data = snapshot.data!;
                final analyzedAt = data['analyzed_at'] as String?;
                DateTime? dateTime;
                if (analyzedAt != null) {
                  dateTime = DateTime.tryParse(analyzedAt);
                }
                return ActionCard(
                  icon: Icons.insights_outlined,
                  title: 'Recent AI Result',
                  subtitle: data['file_name'] != null
                      ? data['file_name']
                      : 'View most recent result',
                  dateTime: dateTime,
                  onTap: onRecentImagesPressed,
                );
              },
            ),
            ActionCard(
              icon: Icons.schedule,
              title: 'History',
              subtitle: 'View your recent uploads and actions',
              onTap: () => _showHistoryBottomSheet(context),
            ),
          ],
        ),
      ],
    );
  }
}
