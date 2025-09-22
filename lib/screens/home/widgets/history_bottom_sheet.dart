import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../../aiResult/views/ai_results_page_wrapper.dart';

/// Bottom sheet that displays upload history records
class HistoryBottomSheet extends StatefulWidget {
  const HistoryBottomSheet({super.key});

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchUploadHistory();
    });
  }

  /// Navigate to AI result for a specific upload record
  Future<void> _navigateToAIResult(
    BuildContext context,
    Map<String, dynamic> uploadData,
  ) async {
    try {
      if (context.mounted) {
        // Close the bottom sheet first
        Navigator.pop(context);

        // Navigate to AI results page using Navigator.push instead of GoRouter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AIResultsPageWrapper(analysisData: uploadData),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load AI result: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload History',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Divider(height: 1.h),
          // Content
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, historyProvider, child) {
                if (historyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (historyProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load history',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          historyProvider.error!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: historyProvider.fetchUploadHistory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (historyProvider.uploads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No upload history found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: historyProvider.uploads.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final upload = historyProvider.uploads[index];
                    final fileName = upload['file_name'] ?? 'Unknown';
                    final status = upload['status'] ?? 'Unknown';
                    final createdAt = upload['created_at'];

                    // Show additional analysis info if available
                    final rooms = upload['rooms'];
                    final doors = upload['doors'];
                    final windows = upload['window'];

                    String analysisInfo = '';
                    if (rooms != null || doors != null || windows != null) {
                      final roomsStr = rooms?.toString() ?? '0';
                      final doorsStr = doors?.toString() ?? '0';
                      final windowsStr = windows?.toString() ?? '0';
                      analysisInfo =
                          '$roomsStr rooms • $doorsStr doors • $windowsStr windows';
                    }

                    String formattedDate = 'Unknown date';
                    if (createdAt != null) {
                      try {
                        final date = DateTime.parse(createdAt);
                        formattedDate = DateFormat(
                          'MMM dd, yyyy - HH:mm',
                        ).format(date);
                      } catch (e) {
                        formattedDate = 'Invalid date';
                      }
                    }

                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _navigateToAIResult(context, upload),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildStatusChip(status, context),
                                ],
                              ),
                              if (analysisInfo.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Text(
                                  analysisInfo,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14.sp,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'failed':
      case 'error':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'processing':
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      default:
        backgroundColor = Theme.of(
          context,
        ).colorScheme.outline.withOpacity(0.1);
        textColor = Theme.of(context).colorScheme.outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
