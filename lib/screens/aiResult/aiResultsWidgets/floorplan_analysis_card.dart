import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class FloorplanAnalysisCard extends StatelessWidget {
  final List<String> insights;
  final String? roboflowImageData; // Base64 image data from Roboflow
  final File? capturedImage; // Captured image from camera/gallery
  final bool hasAnalysisFailed; // Whether Roboflow analysis failed
  final String? errorMessage; // Error message if analysis failed
  final VoidCallback? onRetry; // Retry callback

  const FloorplanAnalysisCard({
    super.key,
    required this.insights,
    this.roboflowImageData,
    this.capturedImage,
    this.hasAnalysisFailed = false,
    this.errorMessage,
    this.onRetry,
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

            // AI Generated Floorplan Image
            Container(
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
                  ), // AI Badge
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Analysis insights
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasAnalysisFailed ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasAnalysisFailed
                      ? Colors.red[200]!
                      : Colors.green[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAnalysisFailed ? 'Analysis Status:' : 'Key Insights:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasAnalysisFailed
                          ? Colors.red[800]
                          : Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasAnalysisFailed)
                    ..._getFailureInsights().map(
                      (insight) => _failureInsightItem(insight),
                    )
                  else
                    ...insights.map((insight) => _insightItem(insight)),
                ],
              ),
            ),
          ],
        ),
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

  List<String> _getFailureInsights() {
    return [
      '❌ Unable to connect to Roboflow AI service',
      '❌ Image analysis could not be completed',
      '⚠️ Please check your internet connection',
      '🔄 Try again or use a different image',
    ];
  }

  Widget _failureInsightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.red[700], height: 1.3),
      ),
    );
  }

  Widget _insightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.green[700], height: 1.3),
      ),
    );
  }
}
