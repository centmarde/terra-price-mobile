import 'package:flutter/material.dart';
import '../services/pdf_report_service.dart';
import 'dart:developer' as developer;

class DownloadReportCard extends StatefulWidget {
  final String? price;
  final String? confidence;
  final Map<String, String>? propertyMetrics;
  final List<String>? insights;
  final String? roboflowImageData;
  final String? confidenceScore;
  final Map<String, dynamic>? detailedCounts;
  final dynamic capturedImage; // Can be File or other type
  final Map<String, dynamic>? supabaseData; // Add Supabase data
  final Map<String, dynamic>? roboflowData; // Add Roboflow data
  final bool hasAnalysisFailed; // Add analysis failure status
  final String? errorMessage; // Add error message

  const DownloadReportCard({
    super.key,
    this.price,
    this.confidence,
    this.propertyMetrics,
    this.insights,
    this.roboflowImageData,
    this.confidenceScore,
    this.detailedCounts,
    this.capturedImage,
    this.supabaseData,
    this.roboflowData,
    this.hasAnalysisFailed = false,
    this.errorMessage,
  });

  @override
  State<DownloadReportCard> createState() => _DownloadReportCardState();
}

class _DownloadReportCardState extends State<DownloadReportCard> {
  bool _isGenerating = false;

  Future<void> _handleDownload() async {
    if (_isGenerating) return; // Prevent multiple simultaneous downloads

    setState(() {
      _isGenerating = true;
    });

    try {
      developer.log('🚀 Starting PDF download with real AI results data...');

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  const Text('Generating AI Analysis Report...'),
                  const SizedBox(height: 8),
                  Text(
                    widget.hasAnalysisFailed
                        ? 'Compiling available data and analysis status'
                        : 'Processing AI insights, visualizations, and metrics',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      }

      // Generate PDF with ALL real data from the AI results page
      await PDFReportService.generateAndSaveReport(
        // Use actual data or fallbacks
        price: widget.price ?? '\$500,000',
        confidence: widget.confidence ?? '92%',
        propertyMetrics:
            widget.propertyMetrics ??
            {
              'size': '120 sqm',
              'rooms': '3',
              'doors': '5',
              'windows': '4',
              'furnitures': '8',
            },
        insights:
            widget.insights ??
            [
              '✓ AI analysis could not be completed',
              '⚠️ Using default property insights',
              '🔄 Please retry analysis for accurate results',
            ],
        // Real AI analysis data
        roboflowImageData: widget.roboflowImageData,
        confidenceScore: widget.confidenceScore,
        detailedCounts: widget.detailedCounts,
        capturedImage: widget.capturedImage,
        supabaseData: widget.supabaseData,
        roboflowData: widget.roboflowData,
        hasAnalysisFailed: widget.hasAnalysisFailed,
        errorMessage: widget.errorMessage,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show success message with details
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Analysis Report Generated!'),
                      Text(
                        widget.hasAnalysisFailed
                            ? 'Report includes analysis status and available data'
                            : 'Complete report with real AI insights and visualizations',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      developer.log('✅ PDF download completed with real AI data');
    } catch (e) {
      developer.log('❌ Error generating PDF: $e');

      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Failed to generate PDF report'),
                      Text(
                        'Error: ${e.toString()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                size: 32,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download AI Analysis Report',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.supabaseData != null) ...[
                    const SizedBox(height: 2),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _handleDownload,
              icon: _isGenerating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : const Icon(Icons.download, size: 18),
              label: Text(_isGenerating ? 'Generating...' : 'Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
