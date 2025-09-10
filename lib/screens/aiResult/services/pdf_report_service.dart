import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class PDFReportService {
  /// Generates a comprehensive PDF report with AI analysis results
  static Future<void> generateAndSaveReport({
    required String price,
    required String confidence,
    required Map<String, String> propertyMetrics,
    required List<String> insights,
    String? roboflowImageData,
    String? confidenceScore,
    Map<String, dynamic>? detailedCounts,
    File? capturedImage,
    Map<String, dynamic>? supabaseData,
    Map<String, dynamic>? roboflowData,
    bool hasAnalysisFailed = false,
    String? errorMessage,
  }) async {
    try {
      developer.log('🚀 Starting PDF report generation with real data...');

      // Create PDF document
      final pdf = pw.Document();

      // Try to load fonts, fall back to default if not available
      pw.Font? font;
      pw.Font? boldFont;

      try {
        final fontData = await rootBundle.load(
          'assets/fonts/Roboto-Regular.ttf',
        );
        final boldFontData = await rootBundle.load(
          'assets/fonts/Roboto-Bold.ttf',
        );
        font = pw.Font.ttf(fontData);
        boldFont = pw.Font.ttf(boldFontData);
      } catch (e) {
        developer.log('⚠️ Custom fonts not found, using default fonts: $e');
        // Use default fonts if custom fonts are not available
        font = null;
        boldFont = null;
      }

      // Process images
      pw.ImageProvider? aiVisualizationImage;
      pw.ImageProvider? originalImage;

      // Process Computer Vision visualization image
      if (roboflowImageData != null && roboflowImageData.isNotEmpty) {
        try {
          String cleanBase64 = roboflowImageData;
          if (roboflowImageData.contains(',')) {
            cleanBase64 = roboflowImageData.split(',').last;
          }
          final Uint8List imageBytes = base64Decode(cleanBase64);
          aiVisualizationImage = pw.MemoryImage(imageBytes);
          developer.log('✅ AI visualization image processed for PDF');
        } catch (e) {
          developer.log(
            '⚠️ Warning: Failed to process AI visualization image: $e',
          );
        }
      }

      // Process captured image
      if (capturedImage != null) {
        try {
          final Uint8List imageBytes = await capturedImage.readAsBytes();
          originalImage = pw.MemoryImage(imageBytes);
          developer.log('✅ Original captured image processed for PDF');
        } catch (e) {
          developer.log('⚠️ Warning: Failed to process captured image: $e');
        }
      }

      // Generate report timestamp
      final now = DateTime.now();
      final formattedDate = DateFormat('MMMM dd, yyyy • HH:mm').format(now);
      final reportId =
          'RPT-${now.millisecondsSinceEpoch.toString().substring(7)}';

      // Add pages to PDF
      await _addCoverPage(pdf, font, boldFont, formattedDate, reportId);
      await _addExecutiveSummaryPage(
        pdf,
        font,
        boldFont,
        price,
        confidence,
        propertyMetrics,
        confidenceScore,
        hasAnalysisFailed,
        errorMessage,
      );
      await _addVisualizationPage(
        pdf,
        font,
        boldFont,
        aiVisualizationImage,
        originalImage,
        insights,
        hasAnalysisFailed,
        errorMessage,
      );
      await _addDetailedAnalysisPage(
        pdf,
        font,
        boldFont,
        propertyMetrics,
        detailedCounts,
        insights,
        supabaseData,
      );
      await _addDataSummaryPage(
        pdf,
        font,
        boldFont,
        supabaseData,
        roboflowData,
        formattedDate,
      );
      await _addAppendixPage(pdf, font, boldFont, formattedDate, reportId);

      // Save and open PDF
      await _savePDF(pdf, reportId);

      developer.log('✅ PDF report generated successfully with real data');
    } catch (e, stackTrace) {
      developer.log('❌ Error generating PDF report: $e');
      developer.log('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Helper method to create colors with opacity
  static PdfColor _createColorWithOpacity(String hexColor, double opacity) {
    // Remove # if present
    String cleanHex = hexColor.replaceAll('#', '');

    // Parse RGB values
    int r = int.parse(cleanHex.substring(0, 2), radix: 16);
    int g = int.parse(cleanHex.substring(2, 4), radix: 16);
    int b = int.parse(cleanHex.substring(4, 6), radix: 16);

    // Create color with opacity
    return PdfColor(r / 255.0, g / 255.0, b / 255.0, opacity);
  }

  /// Adds cover page to PDF
  static Future<void> _addCoverPage(
    pw.Document pdf,
    pw.Font? font,
    pw.Font? boldFont,
    String formattedDate,
    String reportId,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: font != null
            ? pw.ThemeData.withFont(base: font, bold: boldFont)
            : null,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [
                  PdfColor.fromHex('#4CAF50'),
                  PdfColor.fromHex('#2E7D32'),
                ],
              ),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(40),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(20),
                    ),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromInt(
                          0x1A000000,
                        ), // 10% black opacity
                        blurRadius: 20,
                        offset: const PdfPoint(0, 10),
                      ),
                    ],
                  ),
                  child: pw.Column(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe88a), // home icon
                        size: 80,
                        color: PdfColor.fromHex('#4CAF50'),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        'AI Property Analysis Report',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 32,
                          color: PdfColor.fromHex('#2E7D32'),
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 100,
                        height: 4,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#4CAF50'),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(2),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        'Comprehensive Property Insights Powered by AI',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          color: PdfColors.grey700,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 50),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Report ID',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.Text(
                                reportId,
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 14,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Generated',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.Text(
                                formattedDate,
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 14,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Adds executive summary page with real data
  static Future<void> _addExecutiveSummaryPage(
    pw.Document pdf,
    pw.Font? font,
    pw.Font? boldFont,
    String price,
    String confidence,
    Map<String, String> propertyMetrics,
    String? confidenceScore,
    bool hasAnalysisFailed,
    String? errorMessage,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: font != null
            ? pw.ThemeData.withFont(base: font, bold: boldFont)
            : null,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#4CAF50'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe8b6), // analytics icon
                      color: PdfColors.white,
                      size: 24,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Executive Summary',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Analysis Status Section
              if (hasAnalysisFailed) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFEBEE'),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#F44336'),
                      width: 1,
                    ),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe86f), // error icon
                        color: PdfColor.fromHex('#F44336'),
                        size: 32,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Analysis Status: Failed',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          color: PdfColor.fromHex('#F44336'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        errorMessage ?? 'AI analysis could not be completed',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ] else ...[
                // Price Prediction Section (only if analysis succeeded)
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#E8F5E8'),
                      width: 1,
                    ),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                    color: PdfColor.fromHex('#F9FDF9'),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Predicted Property Value',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        price,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 36,
                          color: PdfColor.fromHex('#2E7D32'),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'AI Confidence: $confidence',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          color: PdfColor.fromHex('#4CAF50'),
                        ),
                      ),
                      if (confidenceScore != null) ...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Analysis Confidence: $confidenceScore%',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ],

              // Property Metrics Grid
              pw.Text(
                'Property Overview',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.GridView(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMetricCard(
                    font,
                    boldFont,
                    'Total Size',
                    propertyMetrics['size'] ?? 'N/A',
                    '📐',
                  ),
                  _buildMetricCard(
                    font,
                    boldFont,
                    'Rooms',
                    propertyMetrics['rooms'] ?? 'N/A',
                    '🏠',
                  ),
                  _buildMetricCard(
                    font,
                    boldFont,
                    'Doors',
                    propertyMetrics['doors'] ?? 'N/A',
                    '🚪',
                  ),
                  _buildMetricCard(
                    font,
                    boldFont,
                    'Windows',
                    propertyMetrics['windows'] ?? 'N/A',
                    '🪟',
                  ),
                ],
              ),

              pw.Spacer(),

              // Data Source Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Icon(
                          pw.IconData(0xe86f), // info icon
                          color: PdfColors.grey600,
                          size: 16,
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          hasAnalysisFailed
                              ? 'Analysis could not be completed - using default estimates'
                              : 'Data from live AI computer vision analysis',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: PdfColors.grey600,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    if (confidenceScore != null && !hasAnalysisFailed) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Computer Vision AI Analysis • Confidence Score: $confidenceScore%',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Adds visualization page with actual images and insights
  static Future<void> _addVisualizationPage(
    pw.Document pdf,
    pw.Font? font,
    pw.Font? boldFont,
    pw.ImageProvider? aiVisualizationImage,
    pw.ImageProvider? originalImage,
    List<String> insights,
    bool hasAnalysisFailed,
    String? errorMessage,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: font != null
            ? pw.ThemeData.withFont(base: font, bold: boldFont)
            : null,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#4CAF50'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe3b0), // image icon
                      color: PdfColors.white,
                      size: 24,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Visual Analysis',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Images Section
              if (hasAnalysisFailed) ...[
                // Analysis Failed Section
                pw.Container(
                  width: double.infinity,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFEBEE'),
                    border: pw.Border.all(color: PdfColor.fromHex('#F44336')),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Icon(
                        pw.IconData(0xe86f), // error icon
                        color: PdfColor.fromHex('#F44336'),
                        size: 48,
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'Analysis Failed',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          color: PdfColor.fromHex('#F44336'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                        child: pw.Text(
                          errorMessage ??
                              'Unable to analyze the image with Computer Vision AI',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ] else if (aiVisualizationImage != null ||
                  originalImage != null) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Original Image
                    if (originalImage != null) ...[
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Original Image',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 14,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                              height: 200,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey300),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(8),
                                ),
                              ),
                              child: pw.ClipRRect(
                                horizontalRadius: 8,
                                verticalRadius: 8,
                                child: pw.Image(
                                  originalImage,
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 15),
                    ],

                    // AI Analysis Image
                    if (aiVisualizationImage != null) ...[
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'AI Analysis Result',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 14,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                              height: 200,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColor.fromHex('#4CAF50'),
                                ),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(8),
                                ),
                              ),
                              child: pw.ClipRRect(
                                horizontalRadius: 8,
                                verticalRadius: 8,
                                child: pw.Image(
                                  aiVisualizationImage,
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#4CAF50'),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(12),
                                ),
                              ),
                              child: pw.Text(
                                'Computer Vision Result',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 10,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                pw.SizedBox(height: 30),
              ],

              // Key Insights Section (using actual insights from analysis)
              pw.Text(
                hasAnalysisFailed ? 'Analysis Status' : 'Key Insights',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: hasAnalysisFailed
                      ? PdfColor.fromHex('#FFEBEE')
                      : PdfColor.fromHex('#F9FDF9'),
                  border: pw.Border.all(
                    color: hasAnalysisFailed
                        ? PdfColor.fromHex('#F44336')
                        : PdfColor.fromHex('#E8F5E8'),
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: insights.map((insight) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '• ',
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 16,
                              color: hasAnalysisFailed
                                  ? PdfColor.fromHex('#F44336')
                                  : PdfColor.fromHex('#4CAF50'),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              insight,
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 14,
                                color: PdfColors.grey700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Adds detailed analysis page with real data
  static Future<void> _addDetailedAnalysisPage(
    pw.Document pdf,
    pw.Font? font,
    pw.Font? boldFont,
    Map<String, String> propertyMetrics,
    Map<String, dynamic>? detailedCounts,
    List<String> insights,
    Map<String, dynamic>? supabaseData,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: font != null
            ? pw.ThemeData.withFont(base: font, bold: boldFont)
            : null,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#4CAF50'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe8b6), // analytics icon
                      color: PdfColors.white,
                      size: 24,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Detailed Analysis',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              if (detailedCounts != null && detailedCounts.isNotEmpty) ...[
                // Furniture & Fixtures Section with real data
                pw.Text(
                  'Detected Objects & Furniture',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.GridView(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Rooms',
                      '${detailedCounts['rooms'] ?? 0}',
                      PdfColor.fromHex('#2196F3'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Sofas',
                      '${detailedCounts['sofa'] ?? 0}',
                      PdfColor.fromHex('#8D6E63'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Large Sofas',
                      '${detailedCounts['large_sofa'] ?? 0}',
                      PdfColor.fromHex('#6D4C41'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Coffee Tables',
                      '${detailedCounts['coffee_table'] ?? 0}',
                      PdfColor.fromHex('#FFA726'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Sinks',
                      '${detailedCounts['sink'] ?? 0}',
                      PdfColor.fromHex('#26C6DA'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Large Sinks',
                      '${detailedCounts['large_sink'] ?? 0}',
                      PdfColor.fromHex('#00ACC1'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Twin Sinks',
                      '${detailedCounts['twin_sink'] ?? 0}',
                      PdfColor.fromHex('#0097A7'),
                    ),
                    _buildDetailCard(
                      font,
                      boldFont,
                      'Bathtubs',
                      '${detailedCounts['tub'] ?? 0}',
                      PdfColor.fromHex('#3F51B5'),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
              ],

              // Space Utilization Analysis with real metrics
              pw.Text(
                'Space Utilization Analysis',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 18,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildAnalysisRow(
                      font,
                      boldFont,
                      'Room Distribution',
                      'Detected ${propertyMetrics['rooms']} rooms with optimal layout',
                    ),
                    pw.SizedBox(height: 12),
                    _buildAnalysisRow(
                      font,
                      boldFont,
                      'Natural Light',
                      '${propertyMetrics['windows']} windows providing natural illumination',
                    ),
                    pw.SizedBox(height: 12),
                    _buildAnalysisRow(
                      font,
                      boldFont,
                      'Accessibility',
                      '${propertyMetrics['doors']} doors ensuring good room connectivity',
                    ),
                    pw.SizedBox(height: 12),
                    _buildAnalysisRow(
                      font,
                      boldFont,
                      'Furniture & Fixtures',
                      '${propertyMetrics['furnitures']} items detected indicating good furnishing',
                    ),
                    pw.SizedBox(height: 12),
                    _buildAnalysisRow(
                      font,
                      boldFont,
                      'Estimated Area',
                      '${propertyMetrics['size']} based on room analysis',
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Real Analysis Summary
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E8F5E8'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Analysis Summary',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        color: PdfColor.fromHex('#2E7D32'),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      supabaseData != null
                          ? 'This analysis is based on live data from ${supabaseData['file_name'] ?? 'uploaded image'} processed on ${_formatDate(supabaseData['analyzed_at'])}. The AI detected ${_calculateTotalDetections(detailedCounts)} objects with ${supabaseData['confidence_score'] ?? 'N/A'}% overall confidence.'
                          : 'This property analysis was conducted using advanced AI computer vision technology. The detected elements and measurements provide insights into space utilization, property value, and optimization opportunities.',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.grey700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Adds data summary page with raw data
  static Future<void> _addDataSummaryPage(
    pw.Document pdf,
    pw.Font? font,
    pw.Font? boldFont,
    Map<String, dynamic>? supabaseData,
    Map<String, dynamic>? roboflowData,
    String formattedDate,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: font != null
            ? pw.ThemeData.withFont(base: font, bold: boldFont)
            : null,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#4CAF50'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe86f), // data icon
                      color: PdfColors.white,
                      size: 24,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Raw Data Summary',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Supabase Data Section
              if (supabaseData != null) ...[
                pw.Text(
                  'Database Records',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildDataRow(
                        font,
                        boldFont,
                        'File Name',
                        '${supabaseData['file_name'] ?? 'N/A'}',
                      ),
                      _buildDataRow(
                        font,
                        boldFont,
                        'Analysis Date',
                        _formatDate(supabaseData['analyzed_at']),
                      ),
                      _buildDataRow(
                        font,
                        boldFont,
                        'Status',
                        '${supabaseData['status'] ?? 'N/A'}',
                      ),
                      _buildDataRow(
                        font,
                        boldFont,
                        'File Size',
                        '${supabaseData['file_size'] ?? 'N/A'} bytes',
                      ),
                      _buildDataRow(
                        font,
                        boldFont,
                        'Total Detections',
                        '${supabaseData['total_detections'] ?? 'N/A'}',
                      ),
                      _buildDataRow(
                        font,
                        boldFont,
                        'Confidence Score',
                        '${supabaseData['confidence_score'] ?? 'N/A'}%',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ],

              // Computer Vision Analysis Section
              if (roboflowData != null) ...[
                pw.Text(
                  'Computer Vision Analysis Details',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Computer Vision API Response Summary:',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Data structure contains: ${roboflowData.keys.length} main sections',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Available outputs: ${roboflowData.containsKey('outputs') ? (roboflowData['outputs'] as List?)?.length ?? 0 : 0}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Processing status: ${roboflowData.containsKey('outputs') ? 'Success' : 'Incomplete'}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              pw.Spacer(),

              // Report Generation Info
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E3F2FD'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Report Generation Details',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated: $formattedDate',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Data Sources: ${_getDataSources(supabaseData, roboflowData)}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Report Type: Comprehensive AI Property Analysis',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Adds appendix page
  static Future<void> _addAppendixPage(
    pw.Document pdf,
    pw.Font? font,
    pw.Font? boldFont,
    String formattedDate,
    String reportId,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: font != null
            ? pw.ThemeData.withFont(base: font, bold: boldFont)
            : null,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#4CAF50'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe86f), // info icon
                      color: PdfColors.white,
                      size: 24,
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Technical Information',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Methodology Section
              pw.Text(
                'Analysis Methodology',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 18,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '• Computer Vision AI Model: Advanced object detection with custom property analysis workflow',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    pw.Text(
                      '• Image Processing: High-resolution analysis with real-time confidence scoring and object classification',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    pw.Text(
                      '• Data Storage: Processed results stored in Supabase with PostgreSQL backend for data integrity',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    pw.Text(
                      '• Property Valuation: ML algorithms combined with market analysis for price prediction',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    pw.Text(
                      '• Accuracy: Results based on live visual analysis, spatial recognition, and trained models',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Disclaimer Section
              pw.Text(
                'Important Disclaimer',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 18,
                  color: PdfColors.red600,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFF3E0'),
                  border: pw.Border.all(color: PdfColor.fromHex('#FFB74D')),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Text(
                  'This AI-generated analysis is for informational purposes only and should not be considered as professional real estate advice, property appraisal, or investment guidance. The analysis is based on visual recognition technology and may not capture all factors affecting property value. Actual property values may vary significantly based on market conditions, location factors, property condition, legal status, and other variables not captured in this visual analysis. Please consult with qualified real estate professionals, certified appraisers, and local market experts for accurate property valuations and professional advice.',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    color: PdfColors.grey700,
                    height: 1.5,
                  ),
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Report ID: $reportId',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          'Generated: $formattedDate',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Powered by AI Property Analysis Technology • Computer Vision',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 12,
                        color: PdfColor.fromHex('#4CAF50'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Helper method to build metric cards
  static pw.Widget _buildMetricCard(
    pw.Font? font,
    pw.Font? boldFont,
    String label,
    String value,
    String emoji,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColor.fromInt(0x1A9E9E9E), // 10% grey opacity
            blurRadius: 4,
            offset: const PdfPoint(0, 2),
          ),
        ],
      ),
      child: pw.Row(
        children: [
          pw.Text(emoji, style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                    color: PdfColors.grey800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build detail cards with fixed color opacity
  static pw.Widget _buildDetailCard(
    pw.Font? font,
    pw.Font? boldFont,
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _createColorWithOpacity(
          '#${color.toHex().substring(2)}',
          0.1,
        ), // 10% opacity background
        border: pw.Border.all(
          color: _createColorWithOpacity(
            '#${color.toHex().substring(2)}',
            0.3,
          ), // 30% opacity border
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper method to build analysis rows
  static pw.Widget _buildAnalysisRow(
    pw.Font? font,
    pw.Font? boldFont,
    String label,
    String description,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${label}:',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            description,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to build data rows
  static pw.Widget _buildDataRow(
    pw.Font? font,
    pw.Font? boldFont,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '${label}:',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 10,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to calculate total detections
  static int _calculateTotalDetections(Map<String, dynamic>? detailedCounts) {
    if (detailedCounts == null) return 0;

    int total = 0;
    detailedCounts.forEach((key, value) {
      if (value is int) {
        total += value;
      }
    });
    return total;
  }

  /// Helper method to format date
  static String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'N/A';
      }

      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  /// Helper method to get data sources
  static String _getDataSources(
    Map<String, dynamic>? supabaseData,
    Map<String, dynamic>? roboflowData,
  ) {
    List<String> sources = [];

    if (supabaseData != null) {
      sources.add('Supabase Database');
    }

    if (roboflowData != null) {
      sources.add('Computer Vision AI');
    }

    if (sources.isEmpty) {
      sources.add('Default Data');
    }

    return sources.join(', ');
  }

  /// Saves PDF to device and opens it
  static Future<void> _savePDF(pw.Document pdf, String reportId) async {
    try {
      // Save to temporary directory first
      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'AI_Property_Report_$reportId.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      developer.log('💾 PDF saved to: ${file.path}');

      // Open PDF using printing package
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: fileName,
      );

      developer.log('📱 PDF opened successfully');
    } catch (e) {
      developer.log('❌ Error saving/opening PDF: $e');
      rethrow;
    }
  }
}
