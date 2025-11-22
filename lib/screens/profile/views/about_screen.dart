import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About This App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              leading: Icon(Icons.developer_mode_outlined),
              title: Text('Developed by'),
              subtitle: Text('Roy A. Bayotlang, Greg Carl Calo'),
            ),
            const ListTile(
              leading: Icon(Icons.copyright_outlined),
              title: Text('Copyright'),
              subtitle: Text(
                '© 2025 Roy A. Bayotlang, Greg Carl Calo. All rights reserved.',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.description_outlined),
              title: Text('Description'),
              subtitle: Text(
                'Terra Price Mobile lets you analyze property images using AI, detect and count rooms and features, generate property reports, and store your analysis history securely in the cloud.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
