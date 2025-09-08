import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Enhanced:
/// - Asynchronous decode of roboflowImageData
/// - Layering overlay (base64) on top of capturedImage if both exist
/// - Optional composition fallback
/// - Loading indicator while decoding
/// - Shows failure panel if decode error
/// - Supports persistedImageUrl / saving states (leave null if unused)
class FloorplanAnalysisCard extends StatelessWidget {
  final List<String> insights;
  final String? roboflowImageData;
  final File? capturedImage;
  final bool hasAnalysisFailed;
  final String? errorMessage;
  final VoidCallback? onRetry;

  // From previous enhancement (you can keep passing null if not persisting yet)
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
            _buildImageArea(context),
            const SizedBox(height: 12),
            _buildInsights(context),
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
            message: 'Save failed: $persistError',
            child: Icon(Icons.warning_amber, size: 20, color: Colors.orange),
          ),
      ],
    );
  }

  // ---------------- Image Area ----------------
  Widget _buildImageArea(BuildContext context) {
    return Container(
      height: 220,
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
            if (hasAnalysisFailed)
              _buildFailureWidget()
            else
              _buildPrimaryContent(),

            // Badge
            Positioned(top: 8, right: 8, child: _buildStatusBadge()),

            if (isSavingPersisted && !hasAnalysisFailed)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryContent() {
    // Priority #1: persisted network image
    if (persistedImageUrl != null) {
      return Image.network(
        persistedImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackLayeredOrFailure(),
      );
    }

    // If we have Roboflow overlay (base64) => decode async
    if (roboflowImageData != null) {
      return FutureBuilder<Uint8List?>(
        future: _decodeBase64(roboflowImageData!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                height: 38,
                width: 38,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return _fallbackLayeredOrFailure();
          }

          final overlayBytes = snapshot.data!;

          // If we also have captured image, layer them
          if (capturedImage != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  capturedImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFailureWidget(),
                ),
                // Overlay (annotation)
                Image.memory(
                  overlayBytes,
                  fit: BoxFit.contain, // contain to keep annotation coords
                  errorBuilder: (_, __, ___) =>
                      Image.file(capturedImage!, fit: BoxFit.cover),
                ),
              ],
            );
          }

          // Otherwise just show overlay as a normal image
          return Image.memory(
            overlayBytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackLayeredOrFailure(),
          );
        },
      );
    }

    // Fallback to captured image only
    if (capturedImage != null) {
      return Image.file(
        capturedImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFailureWidget(),
      );
    }

    return _buildFailureWidget();
  }

  Widget _fallbackLayeredOrFailure() {
    if (capturedImage != null) {
      return Image.file(
        capturedImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFailureWidget(),
      );
    }
    return _buildFailureWidget();
  }

  Future<Uint8List?> _decodeBase64(String raw) async {
    try {
      final cleaned = raw.contains(',') ? raw.split(',').last : raw;
      // Basic integrity check: length multiple of 4
      if (cleaned.length % 4 != 0) {
        debugPrint(
          '[FloorplanCard] Base64 length not multiple of 4 (truncated?)',
        );
      }
      final bytes = base64Decode(cleaned);
      if (bytes.length < 1000) {
        debugPrint(
          '[FloorplanCard] Decoded very small image (${bytes.length} bytes). May be empty overlay.',
        );
      }
      return bytes;
    } catch (e) {
      debugPrint('[FloorplanCard] base64 decode error: $e');
      return null;
    }
  }

  // ---------------- Badge ----------------
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Insights ----------------
  Widget _buildInsights(BuildContext context) {
    return Container(
      width: double.infinity,
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
              fontWeight: FontWeight.w700,
              color: hasAnalysisFailed ? Colors.red[800] : Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          if (hasAnalysisFailed)
            ..._failureInsightTexts().map(_failureInsightItem)
          else if (insights.isEmpty)
            Text(
              'No insights generated.',
              style: TextStyle(
                fontSize: 14,
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
      color: Colors.red[50],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 10),
              Text(
                'Analysis Unavailable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'No AI visualization could be produced.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.red[600],
                  height: 1.3,
                ),
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

  List<String> _failureInsightTexts() => [
    '❌ Unable to complete AI floorplan analysis.',
    '⚠️ Check your internet connection.',
    '🧪 The image may be unsupported or low quality.',
    '🔄 Try again or capture a clearer photo.',
  ];

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[700],
              height: 1.3,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
