import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Import widget components
import '../aiResultsWidgets/price_predicion_card.dart';
import '../aiResultsWidgets/property_dashboard_card.dart';
import '../aiResultsWidgets/floorplan_analysis_card.dart';
import '../aiResultsWidgets/price_trend_chart.dart';
import '../services/roboflow_data_parser.dart';
import '../aiResultsWidgets/download_report_card.dart';
import '../../home/providers/home_provider.dart';
import '../services/supabase_data_service.dart';

class AIResultsPage extends StatefulWidget {
  const AIResultsPage({super.key});

  @override
  State<AIResultsPage> createState() => _AIResultsPageState();
}

class _AIResultsPageState extends State<AIResultsPage> {
  Map<String, dynamic>? roboflowData;
  Map<String, dynamic>? supabaseData;
  bool isLoading = true;
  bool isDashboardLoading = true;
  String? errorMessage;
  late HomeProvider homeProvider;
  final SupabaseDataService _supabaseService = SupabaseDataService();

  // Timer for checking analysis status
  Timer? _analysisStatusTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    print('🚀 AIResultsPage initialized');
    _loadAllData();

    // Listen for analysis completion
    _startListeningForAnalysisCompletion();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _analysisStatusTimer?.cancel();
    super.dispose();
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
    // Cancel any existing timer
    _analysisStatusTimer?.cancel();

    _analysisStatusTimer = Timer(const Duration(seconds: 1), () {
      if (!_isDisposed && mounted) {
        if (!homeProvider.isAnalysisInProgress) {
          print('✅ Analysis completed, refreshing data...');
          _loadAllData();
        } else {
          print('⏳ Still waiting for analysis to complete...');
          _checkAnalysisStatus(); // Continue checking
        }
      }
    });
  }

  Future<void> _loadAllData() async {
    if (_isDisposed || !mounted) return;

    await Future.wait([_loadRoboflowData(), _loadSupabaseData()]);
  }

  Future<void> _loadRoboflowData() async {
    if (_isDisposed || !mounted) return;

    try {
      print('🔄 Loading Roboflow data in AI Results page...');

      // Get data from HomeProvider (if user just took a photo)
      final providerData = homeProvider.latestRoboflowResult;
      final analysisHasFailed = homeProvider.roboflowAnalysisFailed;
      final isStillAnalyzing = homeProvider.isAnalysisInProgress;

      if (isStillAnalyzing) {
        print('⏳ Analysis still in progress, showing loading state...');
        if (mounted && !_isDisposed) {
          setState(() {
            roboflowData = null;
            isLoading = true;
            errorMessage = null;
          });
        }
        return;
      }

      if (analysisHasFailed) {
        print('⚠️ Analysis failed according to HomeProvider');
        print('❌ Error message: ${homeProvider.roboflowErrorMessage}');

        if (mounted && !_isDisposed) {
          setState(() {
            roboflowData = null;
            isLoading = false;
            errorMessage = homeProvider.roboflowErrorMessage;
          });
        }
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

        if (mounted && !_isDisposed) {
          setState(() {
            roboflowData = providerData;
            isLoading = false;
            errorMessage = null;
          });
        }
        return;
      }

      print(
        '⚠️ No live data available from HomeProvider and no analysis failure or in progress',
      );

      // No data available and no failure - this shouldn't happen in normal flow
      if (mounted && !_isDisposed) {
        setState(() {
          roboflowData = null;
          isLoading = false;
          errorMessage = 'No analysis data available';
        });
      }
    } catch (e) {
      print('💥 Exception loading Roboflow data: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          errorMessage = 'Failed to load AI analysis data: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSupabaseData() async {
    if (_isDisposed || !mounted) return;

    try {
      print('🔄 Loading Supabase data...');
      if (mounted && !_isDisposed) {
        setState(() {
          isDashboardLoading = true;
        });
      }

      final data = await _supabaseService.getLatestAnalysisData();

      if (mounted && !_isDisposed) {
        setState(() {
          supabaseData = data;
          isDashboardLoading = false;
        });
      }

      if (data != null) {
        print('✅ Loaded Supabase data successfully');
        print(
          '📊 Dashboard data: doors=${data['doors']}, rooms=${data['rooms']}, windows=${data['window']}',
        );
      } else {
        print('⚠️ No Supabase data found');
      }
    } catch (e) {
      print('❌ Error loading Supabase data: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          isDashboardLoading = false;
        });
      }
    }
  }

  /// Helper method to safely convert database values to int
  int _safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, String> _getPropertyMetrics() {
    // Try to get data from Supabase first (most recent analysis)
    if (supabaseData != null) {
      print('📊 Using Supabase data for metrics');

      // Calculate total furniture count with safe conversion
      int totalFurniture =
          _safeToInt(supabaseData!['sofa']) +
          _safeToInt(supabaseData!['large_sofa']) +
          _safeToInt(supabaseData!['sink']) +
          _safeToInt(supabaseData!['large_sink']) +
          _safeToInt(supabaseData!['twin_sink']) +
          _safeToInt(supabaseData!['tub']) +
          _safeToInt(supabaseData!['coffee_table']);

      // Estimate size based on rooms and doors (simplified calculation)
      int rooms = _safeToInt(supabaseData!['rooms'], defaultValue: 1);
      int doors = _safeToInt(supabaseData!['doors']);
      int windows = _safeToInt(supabaseData!['window']);
      int estimatedSize =
          (rooms * 25) + (doors * 5) + (windows * 3) + 50; // Simple formula

      return {
        'size': '$estimatedSize sqm',
        'rooms': rooms.toString(),
        'doors': doors.toString(),
        'windows': windows.toString(),
        'furnitures': totalFurniture.toString(),
      };
    }

    // Fallback to parsed Roboflow data
    if (roboflowData != null) {
      print('📊 Using parsed Roboflow data for metrics');
      final metrics = RoboflowDataParser.extractPropertyMetrics(roboflowData!);
      // Add windows count if not present
      if (!metrics.containsKey('windows')) {
        metrics['windows'] = '0';
      }
      return metrics;
    }

    // Final fallback to defaults
    print('📊 Using default metrics');
    final defaultMetrics = RoboflowDataParser.extractPropertyMetrics({});
    defaultMetrics['windows'] = '0';
    return defaultMetrics;
  }

  String? _getConfidenceScore() {
    if (supabaseData != null && supabaseData!['confidence_score'] != null) {
      int confidence = _safeToInt(supabaseData!['confidence_score']);
      return confidence.toString();
    }
    return null;
  }

  Map<String, dynamic>? _getDetailedCounts() {
    if (supabaseData != null) {
      return {
        'rooms': _safeToInt(supabaseData!['rooms']),
        'sofa': _safeToInt(supabaseData!['sofa']),
        'large_sofa': _safeToInt(supabaseData!['large_sofa']),
        'coffee_table': _safeToInt(supabaseData!['coffee_table']),
        'sink': _safeToInt(supabaseData!['sink']),
        'large_sink': _safeToInt(supabaseData!['large_sink']),
        'twin_sink': _safeToInt(supabaseData!['twin_sink']),
        'tub': _safeToInt(supabaseData!['tub']),
      };
    }
    return null;
  }

  Future<void> _handleRetry() async {
    if (_isDisposed || !mounted) return;

    if (mounted && !_isDisposed) {
      setState(() {
        isLoading = true;
      });
    }

    final error = await homeProvider.retryRoboflowAnalysis();

    if (!mounted || _isDisposed) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Retry failed: $error')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis completed successfully!')),
      );
    }

    // Refresh the page data after retry
    await _loadAllData();
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
                  onPressed: _loadAllData,
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

    final propertyMetrics = _getPropertyMetrics();
    final confidenceScore = _getConfidenceScore();
    final detailedCounts = _getDetailedCounts();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Price Prediction Section
          PricePredictionCard(
            price: '\$500,000',
            confidence: confidenceScore != null ? '$confidenceScore%' : '92%',
          ),
          const SizedBox(height: 24),

          // Dashboard Section with live data
          PropertyDashboardCard(
            size: propertyMetrics['size']!,
            rooms: propertyMetrics['rooms']!,
            doors: propertyMetrics['doors']!,
            windows: propertyMetrics['windows']!,
            furnitures: propertyMetrics['furnitures']!,
            confidence: confidenceScore,
            isLoading: isDashboardLoading,
            detailedCounts: detailedCounts,
          ),
          const SizedBox(height: 24),

          // Floorplan Analysis Section
          FloorplanAnalysisCard(
            insights: insights,
            roboflowImageData: labelImageData,
            capturedImage: homeProvider.capturedImage,
            hasAnalysisFailed: homeProvider.roboflowAnalysisFailed,
            errorMessage: homeProvider.roboflowErrorMessage,
            onRetry: _handleRetry,
          ),
          const SizedBox(height: 24),

          // Price Trend Chart Section
          PriceTrendChart(spots: spots, months: months),
          const SizedBox(height: 24),

          // Download Report Section
          DownloadReportCard(
            onDownload: () {
              if (mounted && !_isDisposed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock report downloaded!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
