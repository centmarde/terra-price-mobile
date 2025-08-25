/// Splash screen business logic service
/// Handles app initialization tasks and timing
/// Separated from UI following clean architecture principles
class SplashService {
  static const int _minimumSplashDuration = 2000; // milliseconds

  /// Initialize app with minimum splash duration for branding
  Future<void> initializeApp() async {
    final startTime = DateTime.now();

    try {
      // Simulate app initialization tasks
      await Future.wait([
        _initializeCore(),
        _loadConfiguration(),
        _checkConnectivity(),
      ]);

      // Ensure minimum splash duration for branding
      final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
      final remainingTime = _minimumSplashDuration - elapsedTime;

      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }
    } catch (e) {
      // Ensure minimum time even on error for consistent UX
      final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
      final remainingTime = _minimumSplashDuration - elapsedTime;

      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }

      rethrow;
    }
  }

  /// Initialize core app services
  Future<void> _initializeCore() async {
    // Simulate core initialization
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Load app configuration
  Future<void> _loadConfiguration() async {
    // Simulate configuration loading
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    // Simulate connectivity check
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
