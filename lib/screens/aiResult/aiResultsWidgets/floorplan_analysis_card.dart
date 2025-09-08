import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// FloorplanAnalysisCard now supports:
/// - persistedImageUrl: a stored/public URL (highest priority display)
/// - isSavingPersisted: shows an uploading overlay
/// - persistError: optional (shows a small warning badge if provided)
///
/// Image priority:
///   1. persistedImageUrl (network)
///   2. roboflowImageData (base64)
///   3. capturedImage (local file)
///   4. Failure widget
class FloorplanAnalysisCard extends StatelessWidget {
  final List<String> insights;
  final String? roboflowImageData;
  final File? capturedImage;
  final bool hasAnalysisFailed;
  final String? errorMessage;
  final VoidCallback? onRetry;

  // New
  final String? persistedImageUrl;
  final bool isSavingPersisted;
  final String? persistError;

  const FloorplanAnalysisCard({
    super.key,
    required this.insights,
    this.roboflowImageData,
    this.capturedImage,
    this.hasAnalysisFailed = false,
    this.errorMessage,
    this.onRetry,
    this.persistedImageUrl,
    this.isSavingPersisted = false,
    this.persistError,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildImageSection(context),
            const SizedBox(height: 12),
            _buildInsightsSection(context),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.architecture, color: Colors.green[700], size: 24),
        const SizedBox(width: 8),
        const Text(
          'AI Floorplan Analysis',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (persistError != null && !hasAnalysisFailed)
          Tooltip(
            message: 'Persistence failed: $persistError',
            child: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Colors.orange[700],
            ),
          ),
      ],
    );
  }

  // ---------------- Image Section ----------------
  Widget _buildImageSection(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasAnalysisFailed) _buildFailureWidget() else _buildBestImage(),
            _buildStatusBadge(),

            if (isSavingPersisted && !hasAnalysisFailed)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestImage() {
    // Priority: persisted -> base64 -> captured -> failure
    if (persistedImageUrl != null) {
      return Image.network(
        persistedImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAfterNetworkError(),
      );
    }

    if (roboflowImageData != null) {
      try {
        final bytes = base64Decode(
          roboflowImageData!.contains(',')
              ? roboflowImageData!.split(',').last
              : roboflowImageData!,
        );
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAfterBase64Error(),
        );
      } catch (_) {
        return _fallbackAfterBase64Error();
      }
    }

    if (capturedImage != null) {
      return Image.file(
        capturedImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFailureWidget(),
      );
    }

    return _buildFailureWidget();
  }

  Widget _fallbackAfterNetworkError() {
    if (roboflowImageData != null) {
      try {
        final bytes = base64Decode(
          roboflowImageData!.contains(',')
              ? roboflowImageData!.split(',').last
              : roboflowImageData!,
        );
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => capturedImage != null
              ? Image.file(capturedImage!, fit: BoxFit.cover)
              : _buildFailureWidget(),
        );
      } catch (_) {}
    }
    if (capturedImage != null) {
      return Image.file(
        capturedImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFailureWidget(),
      );
    }
    return _buildFailureWidget();
  }

  Widget _fallbackAfterBase64Error() {
    if (capturedImage != null) {
      return Image.file(
        capturedImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFailureWidget(),
      );
    }
    return _buildFailureWidget();
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    if (hasAnalysisFailed) {
      color = Colors.red;
      text = 'Failed';
      icon = Icons.error_outline;
    } else if (persistedImageUrl != null) {
      color = Colors.teal;
      text = 'Persisted';
      icon = Icons.cloud_done;
    } else if (roboflowImageData != null) {
      color = Colors.green;
      text = 'Computer Vision Result';
      icon = Icons.auto_awesome;
    } else if (capturedImage != null) {
      color = Colors.blueGrey;
      text = 'Captured';
      icon = Icons.camera_alt;
    } else {
      color = Colors.grey;
      text = 'Unavailable';
      icon = Icons.help_outline;
    }

    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Insights Section ----------------
  Widget _buildInsightsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasAnalysisFailed ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasAnalysisFailed ? Colors.red[200]! : Colors.green[200]!,
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
              color: hasAnalysisFailed ? Colors.red[800] : Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          if (hasAnalysisFailed)
            ..._getFailureInsights().map(_failureInsightItem)
          else if (insights.isEmpty)
            Text(
              'No insights available.',
              style: TextStyle(
                color: Colors.green[700],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...insights.map(_insightItem),
          if (hasAnalysisFailed && onRetry != null) ...[
            const SizedBox(height: 14),
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

  // ---------------- Failure Widget ----------------
  Widget _buildFailureWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 10),
              Text(
                'Analysis Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Unable to analyze the image with Roboflow AI',
                style: TextStyle(fontSize: 14, color: Colors.red[600]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Failure Helpers ----------------
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
