import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Widgets
import '../aiResultsWidgets/price_predicion_card.dart';
import '../aiResultsWidgets/property_dashboard_card.dart';
import '../aiResultsWidgets/floorplan_analysis_card.dart';
import '../aiResultsWidgets/price_trend_chart.dart';
import '../aiResultsWidgets/download_report_card.dart';

// Data parsing
import '../services/roboflow_data_parser.dart';

// Controllers / Providers
import '../../home/providers/home_provider.dart';
import '../controllers/floorplan_persist_controller.dart';
import '../services/floorplan_persist_service.dart';

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

  // Track the last base64 hash so we can trigger persistence only when new result arrives
  int? _lastBase64Hash;
  bool _snackShownForPersistError = false;
  bool _snackShownForPersistSuccess = false;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    debugPrint('🚀 AIResultsPage initialized');
    _loadRoboflowData();
    _startListeningForAnalysisCompletion();
  }

  void _startListeningForAnalysisCompletion() {
    if (homeProvider.isAnalysisInProgress) {
      debugPrint('⏳ Analysis in progress... starting poll');
      _checkAnalysisStatus();
    }
  }

  void _checkAnalysisStatus() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (!homeProvider.isAnalysisInProgress) {
        debugPrint('✅ Analysis finished, reloading');
        _loadRoboflowData();
      } else {
        debugPrint('⏳ Still analyzing...');
        _checkAnalysisStatus();
      }
    });
  }

  Future<void> _loadRoboflowData() async {
    try {
      debugPrint('🔄 Loading Roboflow data...');
      final providerData = homeProvider.latestRoboflowResult;
      final analysisHasFailed = homeProvider.roboflowAnalysisFailed;
      final stillAnalyzing = homeProvider.isAnalysisInProgress;

      if (stillAnalyzing) {
        setState(() {
          roboflowData = null;
          isLoading = true;
          errorMessage = null;
        });
        return;
      }

      if (analysisHasFailed) {
        setState(() {
          roboflowData = null;
          isLoading = false;
          errorMessage = homeProvider.roboflowErrorMessage;
        });
        return;
      }

      if (providerData != null) {
        debugPrint('✅ Roboflow data found. Keys: ${providerData.keys}');
        setState(() {
          roboflowData = providerData;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          roboflowData = null;
          isLoading = false;
          errorMessage = 'No analysis data available';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load AI analysis data: $e';
        isLoading = false;
      });
    }
  }

  // ---- Persistence trigger logic ----
  void _maybeTriggerPersistence({
    required String? labelBase64,
    required List<String> insights,
  }) {
    if (labelBase64 == null || labelBase64.isEmpty) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ No authenticated user; skipping persistence.');
      return;
    }

    final hash = labelBase64.hashCode;
    final persistCtrl = context.read<FloorplanPersistController>();

    // If new base64 -> reset and persist
    if (_lastBase64Hash != hash) {
      debugPrint('🆕 New floorplan base64 detected, triggering persistence');
      _lastBase64Hash = hash;
      persistCtrl.markNewImageSignature(hash);
      persistCtrl.persistOnce(
        userId: user.id,
        base64Data: labelBase64,
        insights: insights,
        analysisId: null,
        mode: FloorplanPersistMode.rawBase64,
      );
    }
  }

  void _maybeShowPersistSnackbars(FloorplanPersistController ctrl) {
    if (!mounted) return;
    if (!ctrl.saving && ctrl.error != null && !_snackShownForPersistError) {
      _snackShownForPersistError = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Floorplan save failed (${ctrl.stage ?? 'unknown'}): ${ctrl.error}',
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } else if (!ctrl.saving &&
        ctrl.imageUrl != null &&
        !_snackShownForPersistSuccess) {
      _snackShownForPersistSuccess = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Floorplan persisted successfully'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FloorplanPersistController>(
      create: (_) => FloorplanPersistController(),
      builder: (context, _) {
        final persistCtrl = context.watch<FloorplanPersistController>();

        if (isLoading) {
          return _buildScaffold(
            body: const Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        if (errorMessage != null) {
          return _buildScaffold(
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

        // Extract insights / metrics / image
        final insights = roboflowData != null
            ? RoboflowDataParser.extractInsights(roboflowData!)
            : <String>[];

        final propertyMetrics = roboflowData != null
            ? RoboflowDataParser.extractPropertyMetrics(roboflowData!)
            : {
                'size': '120 sqm',
                'rooms': '3',
                'doors': '5',
                'furnitures': '10',
              };

        final labelImageData = roboflowData != null
            ? RoboflowDataParser.extractLabelVisualizationImage(roboflowData!)
            : null;

        // Trigger persistence (post-frame to avoid setState conflicts)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeTriggerPersistence(
            labelBase64: labelImageData,
            insights: insights,
          );
          _maybeShowPersistSnackbars(persistCtrl);
        });

        // Mock price trend
        final spots = <FlSpot>[
          FlSpot(1, 480),
          FlSpot(2, 490),
          FlSpot(3, 500),
          FlSpot(4, 510),
          FlSpot(5, 505),
        ];
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];

        return _buildScaffold(
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              PricePredictionCard(price: '\$500,000', confidence: '92%'),
              const SizedBox(height: 24),
              PropertyDashboardCard(
                size: propertyMetrics['size']!,
                rooms: propertyMetrics['rooms']!,
                doors: propertyMetrics['doors']!,
                furnitures: propertyMetrics['furnitures']!,
              ),
              const SizedBox(height: 24),
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
                  if (!mounted) return;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Retry failed: $error')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analysis completed successfully!'),
                      ),
                    );
                  }
                  await _loadRoboflowData();
                },
                persistedImageUrl: persistCtrl.imageUrl,
                isSavingPersisted: persistCtrl.saving,
                persistError: persistCtrl.error,
              ),
              const SizedBox(height: 24),
              PriceTrendChart(spots: spots, months: months),
              const SizedBox(height: 24),
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
      },
    );
  }

  Scaffold _buildScaffold({required Widget body}) {
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
      body: body,
    );
  }
}
