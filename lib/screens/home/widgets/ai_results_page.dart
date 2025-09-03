import 'package:flutter/material.dart';

class AIResultsPage extends StatelessWidget {
  const AIResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Analysis Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Here will be the AI results of your uploaded image.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            // You can add more widgets here to show real analysis results
          ],
        ),
      ),
    );
  }
}
