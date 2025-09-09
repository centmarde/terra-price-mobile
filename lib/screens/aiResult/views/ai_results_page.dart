import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import widget components
import '../aiResultsWidgets/price_predicion_card.dart';
import '../aiResultsWidgets/property_dashboard_card.dart';
import '../aiResultsWidgets/floorplan_analysis_card.dart';
import '../aiResultsWidgets/price_trend_chart.dart';
import '../services/roboflow_data_parser.dart';
import '../aiResultsWidgets/download_report_card.dart';
import '../../home/providers/home_provider.dart';

class AIResultsPage extends StatefulWidget {
  const AIResultsPage({super.key});

  @override
  State<AIResultsPage> createState() => _AIResultsPageState();
}

class _AIResultsPageState extends State<AIResultsPage> {
  Map<String, dynamic>? roboflowData;
  bool isLoading = true;
  String? errorMessage;
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    print('🚀 AIResultsPage initialized');
    _loadRoboflowData();

    // Listen for analysis completion
    _startListeningForAnalysisCompletion();
  }

  void _startListeningForAnalysisCompletion() {
    // If analysis is still in progress, wait for it to complete
    if (homeProvider.isAnalysisInProgress) {
      print('⏳ Analysis still in progress, setting up listener...');

      // Check periodically for analysis completion
      _checkAnalysisStatus();
    }
  }

  void _checkAnalysisStatus() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (!homeProvider.isAnalysisInProgress) {
          print('✅ Analysis completed, refreshing data...');
          _loadRoboflowData();
        } else {
          print('⏳ Still waiting for analysis to complete...');
          _checkAnalysisStatus(); // Continue checking
        }
      }
    });
  }

  Future<void> _loadRoboflowData() async {
    try {
      print('🔄 Loading Roboflow data in AI Results page...');

      // Get data from HomeProvider (if user just took a photo)
      final providerData = homeProvider.latestRoboflowResult;
      final analysisHasFailed = homeProvider.roboflowAnalysisFailed;
      final isStillAnalyzing = homeProvider.isAnalysisInProgress;

      if (isStillAnalyzing) {
        print('⏳ Analysis still in progress, showing loading state...');
        setState(() {
          roboflowData = null;
          isLoading = true;
          errorMessage = null;
        });
        return;
      }

      if (analysisHasFailed) {
        print('⚠️ Analysis failed according to HomeProvider');
        print('❌ Error message: ${homeProvider.roboflowErrorMessage}');

        setState(() {
          roboflowData = null;
          isLoading = false;
          errorMessage = homeProvider.roboflowErrorMessage;
        });
        return;
      }

      if (providerData != null) {
        print('✅ Found live Roboflow data from HomeProvider');
        print('📋 Live data keys: ${providerData.keys.toList()}');

        // Log the complete data structure
        print('🔍 Complete live Roboflow data:');
        print(providerData.toString());

        // Log specific data we're looking for
        if (providerData.containsKey('outputs') &&
            providerData['outputs'] is List &&
            (providerData['outputs'] as List).isNotEmpty) {
          final firstOutput = providerData['outputs'][0];
          if (firstOutput.containsKey('label_vis_model_output')) {
            final labelData = firstOutput['label_vis_model_output'];
            print(
              '🏷️ Found label_vis_model_output: type=${labelData['type']}',
            );
            if (labelData['value'] != null) {
              print(
                '🖼️ Label image data length: ${labelData['value'].toString().length} characters',
              );
            }
          }
        }

        setState(() {
          roboflowData = providerData;
          isLoading = false;
          errorMessage = null;
        });
        return;
      }

      print(
        '⚠️ No live data available from HomeProvider and no analysis failure or in progress',
      );

      // No data available and no failure - this shouldn't happen in normal flow
      setState(() {
        roboflowData = null;
        isLoading = false;
        errorMessage = 'No analysis data available';
      });
    } catch (e) {
      print('💥 Exception loading Roboflow data: $e');
      setState(() {
        errorMessage = 'Failed to load AI analysis data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.green,
          title: const Text('AI Results'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.green,
          title: const Text('AI Results'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadRoboflowData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get HomeProvider reference
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Extract data from Roboflow response
    final insights = roboflowData != null
        ? RoboflowDataParser.extractInsights(roboflowData!)
        : RoboflowDataParser.extractInsights({});

    final propertyMetrics = roboflowData != null
        ? RoboflowDataParser.extractPropertyMetrics(roboflowData!)
        : RoboflowDataParser.extractPropertyMetrics({});

    final labelImageData = roboflowData != null
        ? RoboflowDataParser.extractLabelVisualizationImage(roboflowData!)
        : null;

    // Mock data for trend graph (would be replaced with real data in production)
    final List<FlSpot> spots = [
      FlSpot(1, 480),
      FlSpot(2, 490),
      FlSpot(3, 500),
      FlSpot(4, 510),
      FlSpot(5, 505),
    ];

    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.green,
        title: const Text('AI Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Price Prediction Section
          PricePredictionCard(price: '\$500,000', confidence: '92%'),
          const SizedBox(height: 24),

          // Dashboard Section
          PropertyDashboardCard(
            size: propertyMetrics['size']!,
            rooms: propertyMetrics['rooms']!,
            doors: propertyMetrics['doors']!,
            furnitures: propertyMetrics['furnitures']!,
          ),
          const SizedBox(height: 24),

          // Floorplan Analysis Section
          FloorplanAnalysisCard(
            insights: insights,
            roboflowImageData: labelImageData,
            capturedImage: homeProvider.capturedImage,
            hasAnalysisFailed: homeProvider.roboflowAnalysisFailed,
            errorMessage: homeProvider.roboflowErrorMessage,
            onRetry: () async {
              setState(() {
                isLoading = true;
              });

              final error = await homeProvider.retryRoboflowAnalysis();
              if (error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Retry failed: $error')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Analysis completed successfully!'),
                  ),
                );
              }

              // Refresh the page data after retry
              await _loadRoboflowData();
            },
          ),
          const SizedBox(height: 24),

          // Price Trend Chart Section
          PriceTrendChart(spots: spots, months: months),
          const SizedBox(height: 24),

          // Download Report Section
          DownloadReportCard(
            onDownload: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock report downloaded!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
