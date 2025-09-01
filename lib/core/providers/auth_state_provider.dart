import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/storage/storage_service.dart';
import '../../screens/landing/services/auth_service.dart';

/// Global authentication state provider
/// Manages authentication state across the entire application
class AuthStateProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  User? _currentUser;

  AuthStateProvider({AuthService? authService, StorageService? storageService})
    : _authService = authService ?? AuthService(),
      _storageService = storageService ?? StorageService() {
    _initializeAuthState();
    _setupAuthListener();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  /// Initialize authentication state on app start
  Future<void> _initializeAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user is currently authenticated
      _currentUser = _authService.getCurrentUser();
      _isAuthenticated = _currentUser != null;

      debugPrint('Auth State Initialized: isAuthenticated = $_isAuthenticated');
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Setup Supabase auth state listener
  void _setupAuthListener() {
    try {
      final supabase = Supabase.instance.client;
      supabase.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data.event, data.session);
      });
    } catch (e) {
      debugPrint('Error setting up auth listener: $e');
    }
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    debugPrint('Auth state change: $event');

    switch (event) {
      case AuthChangeEvent.initialSession:
        _currentUser = session?.user;
        _isAuthenticated = _currentUser != null;
        debugPrint(
          'Initial session loaded: isAuthenticated = $_isAuthenticated',
        );
        break;
      case AuthChangeEvent.signedIn:
        _currentUser = session?.user;
        _isAuthenticated = true;
        debugPrint('User signed in: ${_currentUser?.email}');
        break;
      case AuthChangeEvent.signedOut:
        _currentUser = null;
        _isAuthenticated = false;
        _clearStoredData();
        debugPrint('User signed out');
        break;
      case AuthChangeEvent.tokenRefreshed:
        _currentUser = session?.user;
        _isAuthenticated = _currentUser != null;
        debugPrint('Token refreshed');
        break;
      case AuthChangeEvent.userUpdated:
        _currentUser = session?.user;
        debugPrint('User updated');
        break;
      case AuthChangeEvent.passwordRecovery:
        debugPrint('Password recovery initiated');
        break;
      case AuthChangeEvent.userDeleted:
        _currentUser = null;
        _isAuthenticated = false;
        _clearStoredData();
        debugPrint('User deleted');
        break;
      case AuthChangeEvent.mfaChallengeVerified:
        debugPrint('MFA challenge verified');
        break;
    }

    notifyListeners();
  }

  /// Clear stored user data
  Future<void> _clearStoredData() async {
    try {
      await _storageService.clearAll();
      debugPrint('Stored data cleared');
    } catch (e) {
      debugPrint('Error clearing stored data: $e');
    }
  }

  /// Manual sign out
  Future<void> signOut() async {
    try {
      final result = await _authService.signOut();
      if (!result.isSuccess) {
        debugPrint('Sign out error: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  /// Refresh authentication state manually
  Future<void> refreshAuthState() async {
    await _initializeAuthState();
  }

  /// Check if user session is valid
  bool isSessionValid() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      return session.expiresAt != null && session.expiresAt! > now;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }
}
