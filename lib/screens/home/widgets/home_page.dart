import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import the new component files
import 'welcome_section.dart';
import 'upload_actions_grid.dart';
import 'selected_images_section.dart';
import 'recent_activity_section.dart';
import 'image_selection_bottom_sheet.dart';
import 'file_options_bottom_sheet.dart';
import '../services/upload_repository.dart';
import 'upload_image_loader.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/recent_images_bottom_sheet.dart';
import '../providers/home_provider.dart';
import '../mixins/snackbar_mixin.dart';

/// Home page widget - main dashboard for authenticated users
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SnackBarMixin {
  late final UploadRepository _uploadRepository;

  @override
  void initState() {
    super.initState();
    _uploadRepository = UploadRepository();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Consumer<HomeProvider>(
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
                    SizedBox(height: 32.h),

                    UploadActionsGrid(
                      onCameraPressed: () =>
                          _handleImagePicking(provider.pickImageFromCamera),
                      onGalleryPressed: () =>
                          _showImageSelectionOptions(provider),
                      onRecentImagesPressed: _showRecentImages,
                      onUploadFilesPressed: _showFileOptions,
                    ),

                    if (provider.selectedImages.isNotEmpty) ...[
                      SizedBox(height: 32.h),
                      SelectedImagesSection(
                        selectedImages: provider.selectedImages,
                        isUploading: provider.isUploading,
                        onRemoveImage: provider.removeImage,
                        onUpload: () => _handleUpload(provider),
                      ),
                    ],

                    SizedBox(height: 32.h),

                    RecentActivitySection(uploadRepository: _uploadRepository),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleImagePicking(
    Future<String?> Function() pickFunction,
  ) async {
    final error = await pickFunction();
    if (error != null) {
      showErrorSnackBar(context, error);
    }
  }

  Future<void> _handleUpload(HomeProvider provider) async {
    final error = await provider.uploadImages();
    if (error != null) {
      showErrorSnackBar(context, error);
    } else {
      showSuccessSnackBar(context, 'Images uploaded successfully!');
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
