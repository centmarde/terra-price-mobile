import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget that displays a loader and "Analyzing image, please wait..." label.
/// After a short delay, navigates to the AI results page.
class UploadImageLoader extends StatefulWidget {
  final VoidCallback? onAnalysisComplete;

  const UploadImageLoader({Key? key, this.onAnalysisComplete})
    : super(key: key);

  @override
  State<UploadImageLoader> createState() => _UploadImageLoaderState();
}

class _UploadImageLoaderState extends State<UploadImageLoader> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() async {
    // Simulate analysis time (e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    // Callback to notify parent to transition to results page
    widget.onAnalysisComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24.h),
          Text(
            'Analyzing image, please wait...',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
