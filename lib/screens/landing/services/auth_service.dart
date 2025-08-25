/// Authentication service for handling login and registration
/// Separated from UI following clean architecture principles
class AuthService {
  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool isValidPassword(String password) {
    // Minimum 8 characters, at least one letter and one number
    if (password.length < 8) return false;

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }

  /// Validate full name
  bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  /// Simulate login API call
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation (replace with actual API call)
      if (!isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      // Simulate successful login
      return AuthResult.success('Login successful');
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Simulate registration API call
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Validation
      if (!isValidName(fullName)) {
        return AuthResult.failure('Please enter your full name');
      }

      if (!isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (!isValidPassword(password)) {
        return AuthResult.failure(
          'Password must be at least 8 characters with letters and numbers',
        );
      }

      if (password != confirmPassword) {
        return AuthResult.failure('Passwords do not match');
      }

      // Simulate successful registration
      return AuthResult.success('Registration successful');
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Simulate forgot password API call
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (!isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      // Simulate successful password reset
      return AuthResult.success('Password reset link sent to your email');
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String message;

  const AuthResult._({required this.isSuccess, required this.message});

  factory AuthResult.success(String message) {
    return AuthResult._(isSuccess: true, message: message);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}
