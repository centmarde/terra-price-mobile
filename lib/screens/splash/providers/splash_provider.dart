import 'package:flutter/foundation.dart';
import '../services/splash_service.dart';

/// Splash screen state management provider
/// Handles loading state and navigation timing for splash screen
class SplashProvider extends ChangeNotifier {
  final SplashService _splashService;

  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  SplashProvider({SplashService? splashService})
    : _splashService = splashService ?? SplashService();

  /// Initialize splash screen process
  Future<void> initializeSplash() async {
    try {
      _setLoading(true);
      _clearError();

      // Simulate app initialization (minimum 2 seconds for branding)
      await _splashService.initializeApp();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize app: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message and notify listeners
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Retry initialization after error
  Future<void> retry() async {
    await initializeSplash();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
