import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart'; // Make sure this is imported if using GoRouter

class AIResultsPage extends StatelessWidget {
  const AIResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for trend graph (x: month, y: price in thousands)
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
          onPressed: () {
            // If using GoRouter:
            context.go('/home');
            // If using Navigator:
            // Navigator.of(context).pushReplacementNamed('/home');
            // Or just Navigator.pop(context); if you want to pop the page
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Predicted property price & confidence
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Predicted Property Price',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$500,000',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Confidence: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '92%',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Interactive dashboard (mock)
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dashboardTile(Icons.home, 'Size', '120 sqm'),
                      _dashboardTile(Icons.location_city, 'Rooms', '3'),
                      _dashboardTile(Icons.door_front_door, 'Doors', '5'),
                      _dashboardTile(Icons.chair, 'Furnitures', '10'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // AI Floorplan Analysis
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.architecture,
                        color: Colors.green[700],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Floorplan Analysis',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
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
                        // Mock floorplan layout
                        Positioned.fill(
                          child: CustomPaint(painter: FloorplanPainter()),
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
                                  'AI Generated',
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
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Insights:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _insightItem(
                          '✓ Open floor plan maximizes space utilization',
                        ),
                        _insightItem('✓ Natural light optimization detected'),
                        _insightItem(
                          '✓ Efficient room layout increases property value',
                        ),
                        _insightItem(
                          '✓ Modern furniture placement suggests premium quality',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Trend graph (using fl_chart)
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Trend',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minY: 470,
                        maxY: 520,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 4,
                            color: Colors.green,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              getTitlesWidget: (value, meta) => Text(
                                '\$${value.toInt()}k',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt() - 1;
                                return Text(
                                  idx >= 0 && idx < months.length
                                      ? months[idx]
                                      : '',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Downloadable report
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.file_download,
                    size: 32,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'Download full AI analysis report (PDF)',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mock report downloaded!'),
                        ),
                      );
                    },
                    child: const Text('Download'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.green),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
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

// Custom painter for mock floorplan visualization
class FloorplanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw rooms outline
    paint.color = Colors.grey[600]!;

    // Living room
    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width * 0.6, size.height * 0.4),
      paint,
    );

    // Kitchen
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.65,
        20,
        size.width * 0.3,
        size.height * 0.25,
      ),
      paint,
    );

    // Bedroom 1
    canvas.drawRect(
      Rect.fromLTWH(
        20,
        size.height * 0.45,
        size.width * 0.35,
        size.height * 0.5,
      ),
      paint,
    );

    // Bedroom 2
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.45,
        size.width * 0.25,
        size.height * 0.35,
      ),
      paint,
    );

    // Bathroom
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.3,
        size.width * 0.25,
        size.height * 0.25,
      ),
      paint,
    );

    // Draw doors
    paint.color = Colors.brown;
    paint.strokeWidth = 3.0;

    // Door lines (simplified)
    canvas.drawLine(
      Offset(size.width * 0.3, 20),
      Offset(size.width * 0.35, 20),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.65, size.height * 0.2),
      paint,
    );

    // Draw furniture (simplified rectangles)
    paint.color = Colors.green[400]!;
    paint.style = PaintingStyle.fill;

    // Sofa
    canvas.drawRect(
      Rect.fromLTWH(40, 40, size.width * 0.2, size.height * 0.1),
      paint,
    );

    // Bed
    canvas.drawRect(
      Rect.fromLTWH(
        30,
        size.height * 0.6,
        size.width * 0.15,
        size.height * 0.2,
      ),
      paint,
    );

    // Table
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.25), 20, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
