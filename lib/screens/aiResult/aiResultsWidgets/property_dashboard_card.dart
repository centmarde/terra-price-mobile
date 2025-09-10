import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PropertyDashboardCard extends StatelessWidget {
  final String size;
  final String rooms;
  final String doors;
  final String windows;
  final String furnitures;
  final String? confidence;
  final bool isLoading;
  final Map<String, dynamic>? detailedCounts;

  const PropertyDashboardCard({
    super.key,
    required this.size,
    required this.rooms,
    required this.doors,
    required this.windows,
    required this.furnitures,
    this.confidence,
    this.isLoading = false,
    this.detailedCounts,
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
                Icon(Icons.dashboard, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Analysis Dashboard',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Main metrics row: Size, Windows, Doors, Etc.
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _dashboardTile(
                      context,
                      Icons.straighten,
                      'Size',
                      size,
                      Colors.blue,
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 6), // Reduced spacing
                  Expanded(
                    child: _dashboardTile(
                      context,
                      Icons.window,
                      'Windows',
                      windows,
                      Colors.cyan,
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 6), // Reduced spacing
                  Expanded(
                    child: _dashboardTile(
                      context,
                      Icons.door_front_door,
                      'Doors',
                      doors,
                      Colors.orange,
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 6), // Reduced spacing
                  Expanded(
                    child: _dashboardTile(
                      context,
                      Icons.more_horiz,
                      'Etc.',
                      _calculateTotalEtc(),
                      Colors.purple,
                      onTap: () => _showDetailedModal(context),
                    ),
                  ),
                ],
              ),
            ),

            // Confidence score if available
            if (confidence != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Confidence: $confidence%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Data source indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_done, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    isLoading
                        ? 'Loading live data...'
                        : 'Live data from AI analysis',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 2,
        ), // Reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Reduced padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: onTap != null
                    ? Border.all(color: color.withOpacity(0.3), width: 1)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 24, color: color), // Slightly smaller icon
                  if (onTap != null)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.touch_app,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4), // Reduced spacing
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ), // Smaller font
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            // Make the value text more flexible
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13, // Smaller font
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalEtc() {
    if (detailedCounts == null) return furnitures;

    int total =
        (detailedCounts!['rooms'] ?? 0) +
        (detailedCounts!['sofa'] ?? 0) +
        (detailedCounts!['large_sofa'] ?? 0) +
        (detailedCounts!['coffee_table'] ?? 0) +
        (detailedCounts!['sink'] ?? 0) +
        (detailedCounts!['large_sink'] ?? 0) +
        (detailedCounts!['twin_sink'] ?? 0) +
        (detailedCounts!['tub'] ?? 0);

    return total.toString();
  }

  void _showDetailedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailedAnalysisModal(
        detailedCounts: detailedCounts,
        confidence: confidence,
      ),
    );
  }
}

class _DetailedAnalysisModal extends StatelessWidget {
  final Map<String, dynamic>? detailedCounts;
  final String? confidence;

  const _DetailedAnalysisModal({required this.detailedCounts, this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green[700], size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Analysis Results',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Confidence Score Section
                  if (confidence != null) ...[
                    _buildSectionHeader('AI Analysis Confidence'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[50]!, Colors.green[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.psychology,
                            color: Colors.green[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              '$confidence% Confidence',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Room Analysis Section
                  _buildSectionHeader('Space Analysis'),
                  _buildDetailGrid([
                    _DetailItem(
                      icon: Icons.meeting_room,
                      label: 'Rooms',
                      value: (detailedCounts?['rooms'] ?? 0).toString(),
                      color: Colors.blue,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Furniture Section
                  _buildSectionHeader('Furniture & Seating'),
                  _buildDetailGrid([
                    _DetailItem(
                      icon: Icons.chair,
                      label: 'Sofa',
                      value: (detailedCounts?['sofa'] ?? 0).toString(),
                      color: Colors.brown,
                    ),
                    _DetailItem(
                      icon: Icons.weekend,
                      label: 'Large Sofa',
                      value: (detailedCounts?['large_sofa'] ?? 0).toString(),
                      color: Colors.brown[700]!,
                    ),
                    _DetailItem(
                      icon: Icons.table_restaurant,
                      label: 'Coffee Table',
                      value: (detailedCounts?['coffee_table'] ?? 0).toString(),
                      color: Colors.amber[700]!,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Kitchen & Bathroom Section
                  _buildSectionHeader('Kitchen & Bathroom'),
                  _buildDetailGrid([
                    _DetailItem(
                      icon: Icons.kitchen,
                      label: 'Sink',
                      value: (detailedCounts?['sink'] ?? 0).toString(),
                      color: Colors.cyan,
                    ),
                    _DetailItem(
                      icon: Icons.countertops,
                      label: 'Large Sink',
                      value: (detailedCounts?['large_sink'] ?? 0).toString(),
                      color: Colors.cyan[700]!,
                    ),
                    _DetailItem(
                      icon: Icons.plumbing,
                      label: 'Twin Sink',
                      value: (detailedCounts?['twin_sink'] ?? 0).toString(),
                      color: Colors.cyan[300]!,
                    ),
                    _DetailItem(
                      icon: Icons.bathtub,
                      label: 'Bathtub',
                      value: (detailedCounts?['tub'] ?? 0).toString(),
                      color: Colors.indigo,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Summary Section
                  _buildSectionHeader('Summary'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Items Detected',
                          _getTotalItemCount().toString(),
                          Icons.inventory,
                          Colors.green[700]!,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Analysis Date',
                          _getFormattedDate(),
                          Icons.schedule,
                          Colors.blue[700]!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust cross axis count based on available width
        int crossAxisCount = constraints.maxWidth > 300 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 28, color: item.color),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  int _getTotalItemCount() {
    if (detailedCounts == null) return 0;

    return (detailedCounts!['rooms'] ?? 0) +
        (detailedCounts!['sofa'] ?? 0) +
        (detailedCounts!['large_sofa'] ?? 0) +
        (detailedCounts!['coffee_table'] ?? 0) +
        (detailedCounts!['sink'] ?? 0) +
        (detailedCounts!['large_sink'] ?? 0) +
        (detailedCounts!['twin_sink'] ?? 0) +
        (detailedCounts!['tub'] ?? 0);
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
