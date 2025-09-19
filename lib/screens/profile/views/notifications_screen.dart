import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Notification Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: true,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: false,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              value: false,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Mute All Notifications'),
              value: false,
              onChanged: (val) {},
            ),
            ListTile(
              leading: const Icon(Icons.volume_off_outlined),
              title: const Text('Mute notification sounds'),
              trailing: Switch(value: false, onChanged: (val) {}),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Do Not Disturb Schedule'),
              subtitle: const Text('Set times to silence notifications'),
              onTap: () {
                // Implement schedule picker
              },
            ),
          ],
        ),
      ),
    );
  }
}
