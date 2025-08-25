import 'package:flutter/foundation.dart';

/// Landing page state management provider
/// Coordinates UI state for the landing page (form switching, etc.)
class LandingProvider extends ChangeNotifier {
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Getters
  bool get isLoginMode => _isLoginMode;
  bool get isRegisterMode => !_isLoginMode;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  /// Switch between login and register modes
  void toggleAuthMode() {
    _isLoginMode = !_isLoginMode;
    notifyListeners();
  }

  /// Set to login mode
  void setLoginMode() {
    if (!_isLoginMode) {
      _isLoginMode = true;
      notifyListeners();
    }
  }

  /// Set to register mode
  void setRegisterMode() {
    if (_isLoginMode) {
      _isLoginMode = false;
      notifyListeners();
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
