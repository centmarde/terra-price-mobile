import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// Authentication service for handling login and registration with Supabase
/// Separated from UI following clean architecture principles
class AuthService {
  /// Get Supabase client instance with error handling
  SupabaseClient? get _supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

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

  /// Login with Supabase authentication
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Check if Supabase is initialized
      final supabase = _supabaseClient;
      if (supabase == null) {
        return AuthResult.failure('Authentication service is not available');
      }

      // Validate input
      if (!isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      // Attempt login with Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success('Login successful');
      } else {
        return AuthResult.failure('Login failed. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_handleAuthError(e.message));
    } on SocketException catch (_) {
      return AuthResult.failure(
        'No internet connection. Please check your network.',
      );
    } on FormatException catch (_) {
      return AuthResult.failure('Invalid server response. Please try again.');
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Register with Supabase authentication
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Check if Supabase is initialized
      final supabase = _supabaseClient;
      if (supabase == null) {
        return AuthResult.failure('Authentication service is not available');
      }

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

      // Attempt registration with Supabase
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        return AuthResult.success(
          'Registration successful! Please check your email to verify your account.',
        );
      } else {
        return AuthResult.failure('Registration failed. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_handleAuthError(e.message));
    } on SocketException catch (_) {
      return AuthResult.failure(
        'No internet connection. Please check your network.',
      );
    } on FormatException catch (_) {
      return AuthResult.failure('Invalid server response. Please try again.');
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Send password reset email via Supabase
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      // Check if Supabase is initialized
      final supabase = _supabaseClient;
      if (supabase == null) {
        return AuthResult.failure('Authentication service is not available');
      }

      if (!isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      await supabase.auth.resetPasswordForEmail(email);
      return AuthResult.success('Password reset link sent to your email');
    } on AuthException catch (e) {
      return AuthResult.failure(_handleAuthError(e.message));
    } on SocketException catch (_) {
      return AuthResult.failure(
        'No internet connection. Please check your network.',
      );
    } on FormatException catch (_) {
      return AuthResult.failure('Invalid server response. Please try again.');
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign out current user
  Future<AuthResult> signOut() async {
    try {
      // Check if Supabase is initialized
      final supabase = _supabaseClient;
      if (supabase == null) {
        return AuthResult.failure('Authentication service is not available');
      }

      await supabase.auth.signOut();
      return AuthResult.success('Signed out successfully');
    } on SocketException catch (_) {
      return AuthResult.failure(
        'No internet connection. Please check your network.',
      );
    } catch (e) {
      return AuthResult.failure('Sign out failed. Please try again.');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    try {
      final supabase = _supabaseClient;
      return supabase?.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is signed in
  bool isSignedIn() {
    try {
      final supabase = _supabaseClient;
      return supabase?.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Handle Supabase auth errors with user-friendly messages
  String _handleAuthError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (lowerError.contains('email not confirmed') ||
        lowerError.contains('email_not_confirmed')) {
      return 'Please check your email and confirm your account.';
    } else if (lowerError.contains('user not found') ||
        lowerError.contains('user_not_found')) {
      return 'No account found with this email address.';
    } else if (lowerError.contains('too many requests') ||
        lowerError.contains('rate_limit_exceeded')) {
      return 'Too many attempts. Please try again later.';
    } else if (lowerError.contains('weak password') ||
        lowerError.contains('password_too_weak')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (lowerError.contains('email already registered') ||
        lowerError.contains('user_already_registered') ||
        lowerError.contains('signup_disabled')) {
      return 'An account with this email already exists.';
    } else if (lowerError.contains('network') ||
        lowerError.contains('timeout')) {
      return 'Network error. Please check your internet connection.';
    } else if (lowerError.contains('server') ||
        lowerError.contains('internal')) {
      return 'Server error. Please try again later.';
    }

    // Return a generic message for unknown errors to avoid exposing sensitive info
    return 'Authentication failed. Please try again.';
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
