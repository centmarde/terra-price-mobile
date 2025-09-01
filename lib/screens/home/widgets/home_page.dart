import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../landing/providers/auth_provider.dart';

/// Home page widget - main dashboard for authenticated users
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _selectedImagePaths = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TerraPrice',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () {
              // Show notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Ready to upload images for floorplan analysis?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Image Upload Section
              Text(
                'Upload Images',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),

              // Upload Options Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.1, // Reduced from 1.2 to give more height
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Take Photo',
                    subtitle: 'Camera not available',
                    onTap: () => _showCameraNotAvailable(),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.photo_library_outlined,
                    title: 'Select Images',
                    subtitle: 'Choose from device',
                    onTap: () => _showImagePicker(),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.add_photo_alternate_outlined,
                    title: 'Add More',
                    subtitle: 'Select additional images',
                    onTap: () => _showImagePicker(),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.upload_file_outlined,
                    title: 'Upload Files',
                    subtitle: 'Browse documents',
                    onTap: () => _showFileOptions(context),
                  ),
                ],
              ),

              if (_selectedImagePaths.isNotEmpty) ...[
                SizedBox(height: 32.h),
                Text(
                  'Selected Images (${_selectedImagePaths.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSelectedImagesGrid(),
                SizedBox(height: 16.h),
                _buildUploadButton(),
              ],

              SizedBox(height: 32.h),

              // Recent Activity Section (placeholder for now)
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48.w,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No recent activity',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        'Upload your first floorplan to get started',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildSelectedImagesGrid() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImagePaths.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120.w,
            margin: EdgeInsets.only(right: 8.w),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 40.w,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Image ${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 16.w, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadImages,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isUploading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12.w),
                  const Text('Uploading...'),
                ],
              )
            : Text(
                'Upload ${_selectedImagePaths.length} Image${_selectedImagePaths.length > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  void _showImagePicker() {
    // Simulate image selection
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Images'),
          content: const Text(
            'This would open your device\'s image picker. For now, we\'ll simulate adding images.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _simulateImageSelection();
              },
              child: const Text('Add Mock Images'),
            ),
          ],
        );
      },
    );
  }

  void _simulateImageSelection() {
    setState(() {
      _selectedImagePaths.addAll([
        'floorplan_${DateTime.now().millisecondsSinceEpoch}_1.jpg',
        'floorplan_${DateTime.now().millisecondsSinceEpoch}_2.jpg',
      ]);
    });
  }

  void _showCameraNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera functionality requires image_picker package'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImagePaths.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Implement your actual upload logic here
      // This is where you would send the images to your backend/API
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload

      // Clear selected images after successful upload
      setState(() {
        _selectedImagePaths.clear();
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
      _showErrorSnackBar('Upload failed: $e');
    }
  }

  void _showFileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                leading: const Icon(Icons.info_outline),
                title: const Text('Camera'),
                subtitle: const Text('Requires image_picker package'),
                onTap: () {
                  Navigator.pop(context);
                  _showCameraNotAvailable();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select Images'),
                subtitle: const Text('Simulate image selection'),
                onTap: () {
                  Navigator.pop(context);
                  _showImagePicker();
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Documents'),
                subtitle: const Text('PDF, Word files, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorSnackBar('File picker not implemented yet');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
