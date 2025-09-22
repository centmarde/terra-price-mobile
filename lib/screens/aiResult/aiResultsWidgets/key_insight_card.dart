import 'package:flutter/material.dart';

// Modern skeleton loader for KeyInsightCard
class _KeyInsightSkeleton extends StatelessWidget {
  const _KeyInsightSkeleton();
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 100, height: 18, color: Colors.amber[100]),
              ],
            ),
            const SizedBox(height: 12),
            Container(width: 80, height: 16, color: Colors.amber[100]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 60,
              color: Colors.amber[50],
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracts and adjusts confidence from the response string
String? _extractAdjustedConfidence(String? response) {
  if (response == null) return null;
  final RegExp confidencePattern = RegExp(r'(\d+)%');
  final match = confidencePattern.firstMatch(response);
  if (match != null) {
    final value = int.tryParse(match.group(1)!);
    if (value != null) {
      final adjusted = (value + 40).clamp(0, 99);
      return adjusted.toString();
    }
  }
  return null;
}

class KeyInsightCard extends StatelessWidget {
  final String? response;
  final bool isLoading;
  final String? errorMessage;

  const KeyInsightCard({
    super.key,
    this.response,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _KeyInsightSkeleton();
    }
    final adjustedConfidence = _extractAdjustedConfidence(response);
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
            if (adjustedConfidence != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[300]!, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.amber[800], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$adjustedConfidence% Confidence',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[900],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    // Debug print to check what we're receiving
    print('🔍 KeyInsightCard _buildContent called');
    print('📝 Response available: ${response != null}');
    print('⏳ Is loading: $isLoading');
    print('❌ Error message: $errorMessage');

    if (response != null) {
      print('📄 Response length: ${response!.length} characters');
      print(
        '📄 Response preview: ${response!.substring(0, response!.length > 100 ? 100 : response!.length)}...',
      );
    }

    // Check if we're in loading state
    if (isLoading) {
      print('🔄 Showing loading widget');
      return _buildLoadingWidget();
    }

    // Check for error
    if (errorMessage != null) {
      print('❌ Showing error widget: $errorMessage');
      return _buildErrorWidget();
    }

    // Use the response directly - prioritize any available response
    final currentResponse = response ?? '';

    // Only show empty widget if truly no response and not loading
    if (currentResponse.isEmpty && !isLoading) {
      print('📭 No response available, showing empty widget');
      return _buildNoInsightsWidget();
    }

    print('✅ Showing formatted response');
    return _buildFormattedResponse(context, currentResponse);
  }

  Widget _buildNoInsightsWidget() {
    return Column(
      children: [
        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(
          'No AI Insights Available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI analysis completed but no detailed insights were generated for this image.',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Colors.amber, strokeWidth: 3),
        const SizedBox(height: 16),
        Text(
          'Loading AI insights...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.amber[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we retrieve the analysis',
          style: TextStyle(fontSize: 14, color: Colors.amber[700]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    final errorMsg = errorMessage ?? 'Unable to get AI insights';

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
          errorMsg,
          style: TextStyle(fontSize: 14, color: Colors.red[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyWidget() {
    // This method is now renamed and used only when there's truly no data
    return _buildNoInsightsWidget();
  }

  Widget _buildFormattedResponse(BuildContext context, String response) {
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
