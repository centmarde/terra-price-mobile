import 'package:flutter/foundation.dart';
import '../services/history_service.dart';

/// Provider for managing upload history state
class HistoryProvider with ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  List<Map<String, dynamic>> _uploads = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get uploads => _uploads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches upload history from the database
  Future<void> fetchUploadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _uploads = await _historyService.getMobileUploads();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
