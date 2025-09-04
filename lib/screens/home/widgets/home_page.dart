import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

// Import the new component files
import 'welcome_section.dart';
import 'upload_actions_grid.dart';
import 'selected_images_section.dart';
import 'recent_activity_section.dart';
import 'image_selection_bottom_sheet.dart';
import 'file_options_bottom_sheet.dart';
import '../services/image_upload_service.dart';
import '../services/upload_repository.dart';
import 'upload_image_loader.dart';

/// Home page widget - main dashboard for authenticated users
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _showLoader = false; // loader state
  final ImagePicker _picker = ImagePicker();

  late final ImageUploadService _uploadService;
  late final UploadRepository _uploadRepository;

  @override
  void initState() {
    super.initState();
    _uploadService = ImageUploadService();
    _uploadRepository = UploadRepository();
  }

  @override
  Widget build(BuildContext context) {
    // If loader should be shown, display only loader widget
    if (_showLoader) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: UploadImageLoader(onAnalysisComplete: _navigateToAIResults),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeSection(),
              SizedBox(height: 32.h),

              UploadActionsGrid(
                onCameraPressed: _pickImageFromCamera,
                onGalleryPressed: _showImageSelectionOptions,
                onAddMorePressed: _showImageSelectionOptions,
                onUploadFilesPressed: () => _showFileOptions(context),
              ),

              if (_selectedImages.isNotEmpty) ...[
                SizedBox(height: 32.h),
                SelectedImagesSection(
                  selectedImages: _selectedImages,
                  isUploading: _isUploading,
                  onRemoveImage: _removeImage,
                  onUpload: _uploadImages,
                ),
              ],

              SizedBox(height: 32.h),

              RecentActivitySection(uploadRepository: _uploadRepository),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.h,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            padding: EdgeInsets.only(top: 4.h),
            margin: EdgeInsets.only(left: 60.w),
            child: ClipRRect(
              child: Image.asset(
                'lib/assets/logo.png',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.green,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        IconButton(
          onPressed: () {
            // Show notifications
          },
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          _showLoader = true; // show loader after picking image
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          _showLoader = true; // show loader after picking image
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image: $e');
    }
  }

  void _showImageSelectionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImageSelectionBottomSheet(
        onPickSingle: _pickImagesFromGallery,
        onPickMultiple: _pickMultipleImages,
        onTakePhoto: _pickImageFromCamera,
      ),
    );
  }

  Future<void> _pickMultipleImages() async {
    int count = 0;
    const maxImages = 5;

    while (count < maxImages) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImages.add(File(image.path));
          });
          count++;

          if (count == 1) {
            // Show loader after first image
            setState(() {
              _showLoader = true;
            });
            break; // Only analyze first image for now
          }

          if (count < maxImages) {
            final bool? addMore = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Add More Images?'),
                  content: Text(
                    'You have selected $count image${count > 1 ? 's' : ''}. Would you like to add more?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Done'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Add More'),
                    ),
                  ],
                );
              },
            );

            if (addMore != true) break;
          }
        } else {
          break;
        }
      } catch (e) {
        _showErrorSnackBar('Failed to select image: $e');
        break;
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _uploadService.uploadImages(_selectedImages);

      setState(() {
        _selectedImages.clear();
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('Upload failed: ${e.toString()}');
    }
  }

  void _showFileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FileOptionsBottomSheet(
        onCameraPressed: _pickImageFromCamera,
        onGalleryPressed: _pickImagesFromGallery,
        onDocumentsPressed: () {
          _showErrorSnackBar('File picker not implemented yet');
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToAIResults() {
    setState(() {
      _showLoader = false;
    });
    context.go('/ai_results_page');
  }
}
