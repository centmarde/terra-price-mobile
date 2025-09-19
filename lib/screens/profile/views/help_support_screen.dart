import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get Help & Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Live Chat Support'),
              subtitle: const Text('Chat with our support team'),
              onTap: () {
                // Implement live chat navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email Support'),
              subtitle: const Text('Send us an email'),
              onTap: () {
                // Implement email support
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently Asked Questions'),
              onTap: () {
                // Implement FAQ navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Call Support'),
              subtitle: const Text('Contact us by phone'),
              onTap: () {
                // Implement call support
              },
            ),
          ],
        ),
      ),
    );
  }
}
