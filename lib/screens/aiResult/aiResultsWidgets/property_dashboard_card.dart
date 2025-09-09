import 'package:flutter/material.dart';

class PropertyDashboardCard extends StatelessWidget {
  final String size;
  final String rooms;
  final String doors;
  final String furnitures;

  const PropertyDashboardCard({
    super.key,
    required this.size,
    required this.rooms,
    required this.doors,
    required this.furnitures,
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
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dashboardTile(Icons.home, 'Size', size),
                _dashboardTile(Icons.window_sharp, 'Windows', rooms),
                _dashboardTile(Icons.door_front_door, 'Doors', doors),
                _dashboardTile(Icons.devices_other, 'Etc.', furnitures),
              ],
            ),
          ],
        ),
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
}
