import 'package:flutter/material.dart';

class KeyInsightCard extends StatelessWidget {
  final String response;
  final bool isLoading;
  final String? errorMessage;

  const KeyInsightCard({
    super.key,
    required this.response,
    this.isLoading = false,
    this.errorMessage,
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
                Icon(Icons.lightbulb, color: Colors.amber[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'AI Key Insights',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content area
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
                gradient: LinearGradient(
                  colors: [Colors.amber[50]!, Colors.amber[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (errorMessage != null) {
      return _buildErrorWidget();
    }

    if (response.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildFormattedResponse(context);
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Colors.amber, strokeWidth: 3),
        const SizedBox(height: 16),
        Text(
          'AI is analyzing your floorplan...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.amber[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This may take a few moments',
          style: TextStyle(fontSize: 14, color: Colors.amber[700]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
        const SizedBox(height: 12),
        Text(
          'Analysis Failed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? 'Unable to get AI insights',
          style: TextStyle(fontSize: 14, color: Colors.red[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyWidget() {
    return Column(
      children: [
        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(
          'No Insights Available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI insights will appear here after analysis',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormattedResponse(BuildContext context) {
    final formattedWidgets = _parseFormattedText(response);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber[700], size: 16),
            const SizedBox(width: 6),
            Text(
              'AI Generated Insights',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.amber[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...formattedWidgets,
      ],
    );
  }

  List<Widget> _parseFormattedText(String text) {
    final List<Widget> widgets = [];
    final lines = text.split('\n');

    for (String line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Parse different formatting patterns
      if (trimmedLine.startsWith('##')) {
        // Main heading
        widgets.add(
          _buildHeading(
            trimmedLine.replaceFirst('##', '').trim(),
            isMain: true,
          ),
        );
      } else if (trimmedLine.startsWith('#')) {
        // Sub heading
        widgets.add(
          _buildHeading(
            trimmedLine.replaceFirst('#', '').trim(),
            isMain: false,
          ),
        );
      } else if (trimmedLine.startsWith('**') && trimmedLine.endsWith('**')) {
        // Bold text
        widgets.add(_buildBoldText(trimmedLine.replaceAll('**', '')));
      } else if (trimmedLine.startsWith('*') && trimmedLine.endsWith('*')) {
        // Italic text
        widgets.add(_buildItalicText(trimmedLine.replaceAll('*', '')));
      } else if (trimmedLine.startsWith('- ') || trimmedLine.startsWith('• ')) {
        // Bullet point
        widgets.add(
          _buildBulletPoint(trimmedLine.replaceFirst(RegExp(r'^[•\-]\s*'), '')),
        );
      } else if (trimmedLine.contains('**')) {
        // Mixed formatting within text
        widgets.add(_buildMixedFormattedText(trimmedLine));
      } else {
        // Regular text
        widgets.add(_buildRegularText(trimmedLine));
      }

      widgets.add(const SizedBox(height: 6));
    }

    return widgets;
  }

  Widget _buildHeading(String text, {required bool isMain}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMain ? 18 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.amber[900],
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildBoldText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.amber[800],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildItalicText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.amber[700],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.amber[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixedFormattedText(String text) {
    List<TextSpan> spans = [];
    String remaining = text;

    while (remaining.isNotEmpty) {
      int boldStart = remaining.indexOf('**');
      if (boldStart == -1) {
        // No more bold text, add remaining as regular
        spans.add(
          TextSpan(
            text: remaining,
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[800],
              height: 1.4,
            ),
          ),
        );
        break;
      }

      // Add text before bold
      if (boldStart > 0) {
        spans.add(
          TextSpan(
            text: remaining.substring(0, boldStart),
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[800],
              height: 1.4,
            ),
          ),
        );
      }

      // Find end of bold text
      int boldEnd = remaining.indexOf('**', boldStart + 2);
      if (boldEnd == -1) {
        // No closing **, treat as regular text
        spans.add(
          TextSpan(
            text: remaining.substring(boldStart),
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[800],
              height: 1.4,
            ),
          ),
        );
        break;
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: remaining.substring(boldStart + 2, boldEnd),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.amber[900],
            height: 1.4,
          ),
        ),
      );

      remaining = remaining.substring(boldEnd + 2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(text: TextSpan(children: spans)),
    );
  }

  Widget _buildRegularText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.amber[800], height: 1.4),
        softWrap: true,
      ),
    );
  }
}
