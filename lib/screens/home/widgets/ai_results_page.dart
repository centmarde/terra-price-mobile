import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

// Import widget components
import './price_predicion_card.dart';
import './property_dashboard_card.dart';
import './floorplan_analysis_card.dart';
import './price_trend_chart.dart';
import './download_report_card.dart';

class AIResultsPage extends StatelessWidget {
  const AIResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for trend graph
    final List<FlSpot> spots = [
      FlSpot(1, 480),
      FlSpot(2, 490),
      FlSpot(3, 500),
      FlSpot(4, 510),
      FlSpot(5, 505),
    ];

    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];

    final List<String> insights = [
      '✓ Open floor plan maximizes space utilization',
      '✓ Natural light optimization detected',
      '✓ Efficient room layout increases property value',
      '✓ Modern furniture placement suggests premium quality',
    ];

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
            size: '120 sqm',
            rooms: '3',
            doors: '5',
            furnitures: '10',
          ),
          const SizedBox(height: 24),

          // Floorplan Analysis Section
          FloorplanAnalysisCard(insights: insights),
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
