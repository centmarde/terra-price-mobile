import 'dart:developer' as developer;

/// Utility class for parsing AI responses
class AIResponseParser {
  /// Extracts the total estimated cost from AI response text
  ///
  /// Looks for patterns like:
  /// - "TOTAL ESTIMATED COST: $50,000"
  /// - "TOTAL ESTIMATED COST: $50,000 - $60,000"
  /// - "TOTAL ESTIMATED COST: 50000"
  ///
  /// Returns the extracted cost string or null if not found
  static String? extractTotalCost(String? aiResponse) {
    if (aiResponse == null || aiResponse.isEmpty) {
      developer.log('⚠️ AI response is null or empty');
      return null;
    }

    try {
      // Look for "TOTAL ESTIMATED COST:" pattern (case insensitive)
      final RegExp costPattern = RegExp(
        r'TOTAL\s+ESTIMATED\s+COST:\s*(.+?)(?:\n|$)',
        caseSensitive: false,
        multiLine: true,
      );

      final match = costPattern.firstMatch(aiResponse);

      if (match != null && match.group(1) != null) {
        String extractedCost = match.group(1)!.trim();

        // Clean up the extracted cost
        extractedCost = _cleanCostString(extractedCost);

        developer.log('✅ Extracted cost from AI response: $extractedCost');
        return extractedCost;
      }

      // Fallback: look for any cost pattern at the end of the response
      final RegExp fallbackPattern = RegExp(
        r'₱[\d,]+(?:\s*-\s*₱[\d,]+)?',
        caseSensitive: false,
      );

      final fallbackMatches = fallbackPattern.allMatches(aiResponse);
      if (fallbackMatches.isNotEmpty) {
        final lastMatch = fallbackMatches.last;
        String extractedCost = lastMatch.group(0)!.trim();

        developer.log(
          '✅ Extracted cost using fallback pattern: $extractedCost',
        );
        return extractedCost;
      }

      developer.log('⚠️ No cost pattern found in AI response');
      return null;
    } catch (e) {
      developer.log('❌ Error extracting cost from AI response: $e');
      return null;
    }
  }

  /// Cleans and formats the extracted cost string
  static String _cleanCostString(String cost) {
    // Remove extra whitespace
    cost = cost.trim();

    // Remove any trailing punctuation except hyphens (for ranges)
    cost = cost.replaceAll(RegExp(r'[.,;!?]+$'), '');

    // Ensure peso sign is present if we have numbers
    if (RegExp(r'^\d').hasMatch(cost) && !cost.startsWith('₱')) {
      cost = '₱$cost';
    }

    // Add commas to numbers if missing
    cost = cost.replaceAllMapped(RegExp(r'₱(\d+)(?!\d*,)'), (match) {
      String number = match.group(1)!;
      if (number.length > 3) {
        // Add commas for thousands
        String formatted = '';
        for (int i = number.length; i > 0; i -= 3) {
          int start = i - 3 < 0 ? 0 : i - 3;
          String chunk = number.substring(start, i);
          if (formatted.isEmpty) {
            formatted = chunk;
          } else {
            formatted = '$chunk,$formatted';
          }
        }
        return '₱$formatted';
      }
      return match.group(0)!;
    });

    return cost;
  }

  /// Extracts confidence percentage from AI response
  ///
  /// Looks for patterns like:
  /// - "confidence: 85%"
  /// - "I'm 90% confident"
  /// - "with 95% certainty"
  static String? extractConfidence(String? aiResponse) {
    if (aiResponse == null || aiResponse.isEmpty) {
      return null;
    }

    try {
      // Look for confidence patterns
      final List<RegExp> confidencePatterns = [
        RegExp(r'confidence[:\s]+(\d+)%', caseSensitive: false),
        RegExp(r'(\d+)%\s+confident', caseSensitive: false),
        RegExp(r'with\s+(\d+)%\s+certainty', caseSensitive: false),
        RegExp(r'(\d+)%\s+accuracy', caseSensitive: false),
      ];

      for (final pattern in confidencePatterns) {
        final match = pattern.firstMatch(aiResponse);
        if (match != null && match.group(1) != null) {
          String confidence = '${match.group(1)}%';
          developer.log('✅ Extracted confidence from AI response: $confidence');
          return confidence;
        }
      }

      developer.log('⚠️ No confidence pattern found in AI response');
      return null;
    } catch (e) {
      developer.log('❌ Error extracting confidence from AI response: $e');
      return null;
    }
  }

  /// Validates if a cost string looks reasonable
  static bool isValidCost(String? cost) {
    if (cost == null || cost.isEmpty) return false;

    // Check if it contains peso sign and numbers
    return RegExp(r'₱\d+').hasMatch(cost);
  }

  /// Formats a numeric cost value into a currency string
  static String formatCurrency(double amount) {
    if (amount < 1000) {
      return '₱${amount.toStringAsFixed(0)}';
    } else if (amount < 1000000) {
      return '₱${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '₱${(amount / 1000000).toStringAsFixed(1)}M';
    }
  }
}
