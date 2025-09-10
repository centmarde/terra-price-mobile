import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'key_insight_card.dart';

class FloorplanAnalysisCard extends StatelessWidget {
  final List<String> insights;
  final String? roboflowImageData; // Base64 image data from Roboflow
  final File? capturedImage; // Captured image from camera/gallery
  final bool hasAnalysisFailed; // Whether Roboflow analysis failed
  final String? errorMessage; // Error message if analysis failed
  final VoidCallback? onRetry; // Retry callback
  final String? aiResponse; // AI analysis response
  final bool isAILoading; // Whether AI is loading
  final String? aiErrorMessage; // AI error message

  const FloorplanAnalysisCard({
    super.key,
    required this.insights,
    this.roboflowImageData,
    this.capturedImage,
    this.hasAnalysisFailed = false,
    this.errorMessage,
    this.onRetry,
    this.aiResponse,
    this.isAILoading = false,
    this.aiErrorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.architecture, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'AI Floorplan Analysis',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // AI Generated Floorplan Image - Now tappable for preview
            GestureDetector(
              onTap: () => _showImagePreview(context),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                  gradient: LinearGradient(
                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Show failure widget if analysis failed, otherwise show images
                    Positioned.fill(
                      child: hasAnalysisFailed
                          ? _buildFailureWidget()
                          : roboflowImageData != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(roboflowImageData!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to captured image if Roboflow image fails
                                  return capturedImage != null
                                      ? Image.file(
                                          capturedImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return _buildFailureWidget();
                                              },
                                        )
                                      : _buildFailureWidget();
                                },
                              ),
                            )
                          : capturedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                capturedImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Show failure widget if image fails to load
                                  return _buildFailureWidget();
                                },
                              ),
                            )
                          : _buildFailureWidget(),
                    ),
                    // AI Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              roboflowImageData != null
                                  ? 'Computer Vision Result'
                                  : 'AI Generated',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tap indicator overlay
                    if (!hasAnalysisFailed)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
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

            const SizedBox(height: 12),

            // Analysis insights
            KeyInsightCard(
              response: aiResponse ?? '',
              isLoading: isAILoading,
              errorMessage: aiErrorMessage,
            ),
          ],
        ),
      ),
    );
  }

  // Updated method to show zoomable image preview
  void _showImagePreview(BuildContext context) {
    if (hasAnalysisFailed) return; // Don't show preview if analysis failed

    // Determine which image to show
    Widget? imageWidget;
    String title = 'AI Floorplan Analysis';

    if (roboflowImageData != null) {
      imageWidget = Image.memory(
        base64Decode(roboflowImageData!),
        errorBuilder: (context, error, stackTrace) {
          return capturedImage != null
              ? Image.file(capturedImage!)
              : const Center(child: Text('Failed to load image'));
        },
      );
      title = 'Computer Vision Result';
    } else if (capturedImage != null) {
      imageWidget = Image.file(capturedImage!);
      title = 'AI Generated Floorplan';
    }

    if (imageWidget == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ZoomableImagePreview(imageWidget: imageWidget!, title: title),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildFailureWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorMessage ?? 'Unable to analyze the image with Roboflow AI',
              style: TextStyle(fontSize: 14, color: Colors.red[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// New StatefulWidget for zoomable image preview
class ZoomableImagePreview extends StatefulWidget {
  final Widget imageWidget;
  final String title;

  const ZoomableImagePreview({
    super.key,
    required this.imageWidget,
    required this.title,
  });

  @override
  State<ZoomableImagePreview> createState() => _ZoomableImagePreviewState();
}

class _ZoomableImagePreviewState extends State<ZoomableImagePreview>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: Matrix4.identity(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.reset();
    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Reset Zoom',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          constrained: false,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: widget.imageWidget),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.zoom_in,
                    label: 'Zoom In',
                    onPressed: () {
                      final double currentScale = _transformationController
                          .value
                          .getMaxScaleOnAxis();
                      if (currentScale < 5.0) {
                        final Matrix4 matrix = Matrix4.identity()
                          ..scale(currentScale * 1.2);
                        _transformationController.value = matrix;
                      }
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.zoom_out,
                    label: 'Zoom Out',
                    onPressed: () {
                      final double currentScale = _transformationController
                          .value
                          .getMaxScaleOnAxis();
                      if (currentScale > 0.5) {
                        final Matrix4 matrix = Matrix4.identity()
                          ..scale(currentScale * 0.8);
                        _transformationController.value = matrix;
                      }
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.center_focus_strong,
                    label: 'Reset',
                    onPressed: _resetZoom,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pinch to zoom • Drag to pan • Double tap to fit',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white24,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }
}
