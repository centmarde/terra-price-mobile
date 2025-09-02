import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/upload_repository.dart';

class RecentActivitySection extends StatelessWidget {
  final UploadRepository uploadRepository;

  const RecentActivitySection({super.key, required this.uploadRepository});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: uploadRepository.getUserUploads(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final uploads = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (uploads.isEmpty)
              _buildEmptyState(context)
            else
              ...uploads
                  .take(5)
                  .map(
                    (upload) => Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: ListTile(
                        leading: const Icon(Icons.image),
                        title: Text(upload['file_name']),
                        subtitle: Text(
                          'Uploaded: ${DateTime.parse(upload['created_at']).toString().split('.')[0]}',
                        ),
                        trailing: Text(upload['status']),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48.w,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              SizedBox(height: 12.h),
              Text(
                'No recent activity',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
