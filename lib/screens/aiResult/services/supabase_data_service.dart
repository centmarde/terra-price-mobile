import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SupabaseDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Helper method to check if user is authenticated and session is valid
  bool _isAuthenticated() {
    try {
      final user = _supabase.auth.currentUser;
      final session = _supabase.auth.currentSession;

      if (user == null || session == null) {
        developer.log('❌ User not authenticated - no user or session');
        return false;
      }

      // Check if session is expired
      final now = DateTime.now();
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );

      if (now.isAfter(expiresAt)) {
        developer.log('❌ Session expired at: $expiresAt, current time: $now');
        return false;
      }

      return true;
    } catch (e) {
      developer.log('❌ Error checking authentication status: $e');
      return false;
    }
  }

  /// Attempts to refresh the session if needed
  Future<bool> _ensureValidSession() async {
    try {
      if (!_isAuthenticated()) {
        developer.log('🔄 Attempting to refresh session...');

        final response = await _supabase.auth.refreshSession();
        if (response.session != null) {
          developer.log('✅ Session refreshed successfully');
          return true;
        } else {
          developer.log('❌ Failed to refresh session');
          return false;
        }
      }
      return true;
    } catch (e) {
      developer.log('❌ Error refreshing session: $e');
      return false;
    }
  }

  /// Helper method to safely convert database values to int
  int _safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Helper method to safely convert database values to double
  double _safeToDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Fetches the latest analysis data for the current user
  Future<Map<String, dynamic>?> getLatestAnalysisData() async {
    try {
      // Ensure we have a valid session
      final hasValidSession = await _ensureValidSession();
      if (!hasValidSession) {
        developer.log('❌ Cannot fetch data - invalid session');
        return null;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('❌ User ID is null after session check');
        return null;
      }

      developer.log('🔍 Fetching latest analysis data for user: $userId');

      final response = await _supabase
          .from('mobile_uploads')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'processed')
          .order('analyzed_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        developer.log('⚠️ No analysis data found for user');
        return null;
      }

      final latestData = response.first as Map<String, dynamic>;

      // Convert numeric values to ensure proper types
      final processedData = <String, dynamic>{
        ...latestData,
        'doors': _safeToInt(latestData['doors']),
        'rooms': _safeToInt(latestData['rooms']),
        'window': _safeToInt(latestData['window']),
        'sofa': _safeToInt(latestData['sofa']),
        'large_sofa': _safeToInt(latestData['large_sofa']),
        'sink': _safeToInt(latestData['sink']),
        'large_sink': _safeToInt(latestData['large_sink']),
        'twin_sink': _safeToInt(latestData['twin_sink']),
        'tub': _safeToInt(latestData['tub']),
        'coffee_table': _safeToInt(latestData['coffee_table']),
        'total_detections': _safeToInt(latestData['total_detections']),
        'confidence_score': _safeToInt(latestData['confidence_score']),
        'file_size': _safeToInt(latestData['file_size']),
      };

      developer.log(
        '✅ Found latest analysis data: ${processedData['file_name']}',
      );
      developer.log(
        '📊 Object counts: doors=${processedData['doors']}, rooms=${processedData['rooms']}, window=${processedData['window']}',
      );

      return processedData;
    } catch (e) {
      developer.log('❌ Error fetching analysis data: $e');
      return null;
    }
  }

  /// Fetches all analysis data for the current user
  Future<List<Map<String, dynamic>>> getAllAnalysisData() async {
    try {
      // Ensure we have a valid session
      final hasValidSession = await _ensureValidSession();
      if (!hasValidSession) {
        developer.log('❌ Cannot fetch data - invalid session');
        return [];
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        developer.log('❌ User ID is null after session check');
        return [];
      }

      developer.log('🔍 Fetching all analysis data for user: $userId');

      final response = await _supabase
          .from('mobile_uploads')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'processed')
          .order('analyzed_at', ascending: false);

      developer.log('✅ Found ${response.length} analysis records');

      // Process each record to ensure proper types
      final processedData = response.map<Map<String, dynamic>>((record) {
        final data = record as Map<String, dynamic>;
        return {
          ...data,
          'doors': _safeToInt(data['doors']),
          'rooms': _safeToInt(data['rooms']),
          'window': _safeToInt(data['window']),
          'sofa': _safeToInt(data['sofa']),
          'large_sofa': _safeToInt(data['large_sofa']),
          'sink': _safeToInt(data['sink']),
          'large_sink': _safeToInt(data['large_sink']),
          'twin_sink': _safeToInt(data['twin_sink']),
          'tub': _safeToInt(data['tub']),
          'coffee_table': _safeToInt(data['coffee_table']),
          'total_detections': _safeToInt(data['total_detections']),
          'confidence_score': _safeToInt(data['confidence_score']),
          'file_size': _safeToInt(data['file_size']),
        };
      }).toList();

      return processedData;
    } catch (e) {
      developer.log('❌ Error fetching all analysis data: $e');
      return [];
    }
  }

  /// Gets analysis statistics
  Future<Map<String, dynamic>> getAnalysisStatistics() async {
    try {
      // Ensure we have a valid session
      final hasValidSession = await _ensureValidSession();
      if (!hasValidSession) {
        developer.log('❌ Cannot fetch stats - invalid session');
        return {
          'totalAnalyses': 0,
          'totalDetections': 0,
          'averageConfidence': 0.0,
          'mostCommonObject': 'None',
        };
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {
          'totalAnalyses': 0,
          'totalDetections': 0,
          'averageConfidence': 0.0,
          'mostCommonObject': 'None',
        };
      }

      final response = await _supabase
          .from('mobile_uploads')
          .select(
            'doors, rooms, window, sofa, large_sofa, sink, large_sink, twin_sink, tub, coffee_table, total_detections, confidence_score',
          )
          .eq('user_id', userId)
          .eq('status', 'processed');

      if (response.isEmpty) {
        return {
          'totalAnalyses': 0,
          'totalDetections': 0,
          'averageConfidence': 0.0,
          'mostCommonObject': 'None',
        };
      }

      int totalAnalyses = response.length;
      int totalDetections = 0;
      double totalConfidence = 0.0;
      Map<String, int> objectCounts = {};

      for (var record in response) {
        final data = record as Map<String, dynamic>;
        totalDetections += _safeToInt(data['total_detections']);
        totalConfidence += _safeToDouble(data['confidence_score']);

        // Count objects across all analyses
        objectCounts['doors'] =
            (objectCounts['doors'] ?? 0) + _safeToInt(data['doors']);
        objectCounts['rooms'] =
            (objectCounts['rooms'] ?? 0) + _safeToInt(data['rooms']);
        objectCounts['windows'] =
            (objectCounts['windows'] ?? 0) + _safeToInt(data['window']);
        objectCounts['sofas'] =
            (objectCounts['sofas'] ?? 0) +
            _safeToInt(data['sofa']) +
            _safeToInt(data['large_sofa']);
        objectCounts['sinks'] =
            (objectCounts['sinks'] ?? 0) +
            _safeToInt(data['sink']) +
            _safeToInt(data['large_sink']) +
            _safeToInt(data['twin_sink']);
        objectCounts['tubs'] =
            (objectCounts['tubs'] ?? 0) + _safeToInt(data['tub']);
        objectCounts['tables'] =
            (objectCounts['tables'] ?? 0) + _safeToInt(data['coffee_table']);
      }

      double averageConfidence = totalAnalyses > 0
          ? totalConfidence / totalAnalyses
          : 0.0;

      // Find most common object
      String mostCommonObject = 'None';
      int maxCount = 0;
      objectCounts.forEach((key, value) {
        if (value > maxCount) {
          maxCount = value;
          mostCommonObject = key;
        }
      });

      return {
        'totalAnalyses': totalAnalyses,
        'totalDetections': totalDetections,
        'averageConfidence': averageConfidence,
        'mostCommonObject': mostCommonObject,
      };
    } catch (e) {
      developer.log('❌ Error fetching analysis statistics: $e');
      return {
        'totalAnalyses': 0,
        'totalDetections': 0,
        'averageConfidence': 0.0,
        'mostCommonObject': 'None',
      };
    }
  }

  /// Fetches AI analysis data for a specific file name
  Future<Map<String, dynamic>?> getAnalysisDataByFileName(
    String fileName,
  ) async {
    try {
      final response = await _supabase
          .from('ai_analysis_results')
          .select()
          .eq('file_name', fileName)
          .order('analyzed_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching analysis data by file name: $e');
      return null;
    }
  }
}
