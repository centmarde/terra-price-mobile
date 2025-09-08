import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Authentication state management provider
/// Handles login and registration form state and validation
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  // Form states
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Form data
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _confirmPassword = '';

  // Form validation
  bool _emailValid = true;
  bool _passwordValid = true;
  bool _nameValid = true;
  bool _confirmPasswordValid = true;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;

  // Form data getters
  String get email => _email;
  String get password => _password;
  String get fullName => _fullName;
  String get confirmPassword => _confirmPassword;

  // Validation getters
  bool get emailValid => _emailValid;
  bool get passwordValid => _passwordValid;
  bool get nameValid => _nameValid;
  bool get confirmPasswordValid => _confirmPasswordValid;

  // Form validation for login
  bool get isLoginFormValid =>
      _email.isNotEmpty && _password.isNotEmpty && _emailValid;

  // Form validation for registration
  bool get isRegisterFormValid =>
      _fullName.isNotEmpty &&
      _email.isNotEmpty &&
      _password.isNotEmpty &&
      _confirmPassword.isNotEmpty &&
      _nameValid &&
      _emailValid &&
      _passwordValid &&
      _confirmPasswordValid;

  /// Update email with validation
  void updateEmail(String email) {
    _email = email.trim();
    _emailValid = _authService.isValidEmail(_email);
    _clearMessages();
    notifyListeners();
  }

  /// Update password with validation
  void updatePassword(String password) {
    _password = password;
    _passwordValid = _authService.isValidPassword(_password);

    // Re-validate confirm password if it exists
    if (_confirmPassword.isNotEmpty) {
      _confirmPasswordValid = _password == _confirmPassword;
    }

    _clearMessages();
    notifyListeners();
  }

  /// Update full name with validation
  void updateFullName(String name) {
    _fullName = name.trim();
    _nameValid = _authService.isValidName(_fullName);
    _clearMessages();
    notifyListeners();
  }

  /// Update confirm password with validation
  void updateConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    _confirmPasswordValid = _password == _confirmPassword;
    _clearMessages();
    notifyListeners();
  }

  /// Perform login
  Future<void> login() async {
    if (!isLoginFormValid) {
      _setError('Please fill in all required fields correctly');
      return;
    }

    try {
      _setLoading(true);
      _clearMessages();

      final result = await _authService.login(
        email: _email,
        password: _password,
      );

      if (result.isSuccess) {
        _setSuccess(result.message);
        _clearForm();
        // The AuthStateProvider will automatically handle the redirect
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  /// Perform registration
  Future<void> register() async {
    if (!isRegisterFormValid) {
      _setError('Please fill in all required fields correctly');
      return;
    }

    try {
      _setLoading(true);
      _clearMessages();

      final result = await _authService.register(
        fullName: _fullName,
        email: _email,
        password: _password,
        confirmPassword: _confirmPassword,
      );

      if (result.isSuccess) {
        _setSuccess(result.message);
        _clearForm();
        // The AuthStateProvider will automatically handle the redirect after email confirmation
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  /// Forgot password
  Future<void> forgotPassword() async {
    if (_email.isEmpty || !_emailValid) {
      _setError('Please enter a valid email address');
      return;
    }

    try {
      _setLoading(true);
      _clearMessages();

      final result = await _authService.forgotPassword(email: _email);

      if (result.isSuccess) {
        _setSuccess(result.message);
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all form data
  void _clearForm() {
    _email = '';
    _password = '';
    _fullName = '';
    _confirmPassword = '';
    _emailValid = true;
    _passwordValid = true;
    _nameValid = true;
    _confirmPasswordValid = true;
  }

  /// Clear success and error messages
  void _clearMessages() {
    if (_errorMessage != null || _successMessage != null) {
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  /// Set success message
  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all messages manually
  void clearMessages() {
    _clearMessages();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
