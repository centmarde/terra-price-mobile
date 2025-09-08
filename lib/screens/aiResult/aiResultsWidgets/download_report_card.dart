import 'package:flutter/material.dart';

class DownloadReportCard extends StatelessWidget {
  final VoidCallback onDownload;

  const DownloadReportCard({super.key, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.file_download, size: 32, color: Colors.green),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                'Download full AI analysis report (PDF)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: onDownload,
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
