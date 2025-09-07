import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import the new component files
import 'welcome_section.dart';
import 'upload_actions_grid.dart';
import '../image_selection_bottom_sheet.dart';
import '../file_options_bottom_sheet.dart';
import 'upload_image_loader.dart';
import 'home_app_bar.dart';
import '../recent_images_bottom_sheet.dart';
import '../../providers/home_provider.dart';
import '../../mixins/snackbar_mixin.dart';

/// Home page widget - main dashboard for authenticated users
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SnackBarMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        // If loader should be shown, display only loader widget
        if (provider.showLoader) {
          return Scaffold(
            appBar: const HomeAppBar(),
            body: SafeArea(
              child: UploadImageLoader(
                onAnalysisComplete: () => _navigateToAIResults(provider),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: const HomeAppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeSection(),
                  SizedBox(height: 48.h),

                  UploadActionsGrid(
                    onCameraPressed: () =>
                        _handleImagePicking(provider.pickImageFromCamera),
                    onGalleryPressed: () =>
                        _showImageSelectionOptions(provider),
                    onRecentImagesPressed: _showRecentImages,
                    onUploadFilesPressed: _showFileOptions,
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleImagePicking(
    Future<String?> Function() pickFunction,
  ) async {
    // Set up navigation callback before starting
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.setNavigationCallback((route) {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        print('✅ Widget is mounted, navigating to: $route');
        GoRouter.of(context).push(route);
      } else {
        print('⚠️ Widget unmounted, cannot navigate to: $route');
      }
    });

    final error = await pickFunction();
    if (error != null) {
      // Only show error if widget is still mounted
      if (mounted) {
        showErrorSnackBar(context, error);
      }
    } else {
      // Wait for the analysis to complete before navigating
      // The navigation will happen automatically when the loader is set to false
      // after the Roboflow analysis completes
      print('📸 Image picking completed, analysis will proceed in background');
    }
  }

  void _showImageSelectionOptions(HomeProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImageSelectionBottomSheet(
        onPickSingle: () => _handleImagePicking(provider.pickImageFromGallery),
        onTakePhoto: () => _handleImagePicking(provider.pickImageFromCamera),
      ),
    );
  }

  void _showRecentImages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecentImagesBottomSheet(),
    );
  }

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FileOptionsBottomSheet(
        onCameraPressed: () => Navigator.pop(context),
        onGalleryPressed: () => Navigator.pop(context),
        onDocumentsPressed: () {
          Navigator.pop(context);
          showErrorSnackBar(context, 'File picker not implemented yet');
        },
      ),
    );
  }

  void _navigateToAIResults(HomeProvider provider) {
    provider.setShowLoader(false);
    context.go('/ai_results_page');
  }
}
