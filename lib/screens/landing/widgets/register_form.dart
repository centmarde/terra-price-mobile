import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/landing_provider.dart';

/// Register form widget - pure UI component
/// Handles user input for registration fields
class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LandingProvider>(
      builder: (context, authProvider, landingProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full name field
            TextFormField(
              onChanged: authProvider.updateFullName,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                errorText:
                    authProvider.fullName.isNotEmpty && !authProvider.nameValid
                    ? 'Please enter your full name'
                    : null,
              ),
            ),

            SizedBox(height: 16.h),

            // Email field
            TextFormField(
              onChanged: authProvider.updateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: const Icon(Icons.email_outlined),
                errorText:
                    authProvider.email.isNotEmpty && !authProvider.emailValid
                    ? 'Please enter a valid email address'
                    : null,
              ),
            ),

            SizedBox(height: 16.h),

            // Password field
            TextFormField(
              onChanged: authProvider.updatePassword,
              obscureText: landingProvider.obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    landingProvider.obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: landingProvider.togglePasswordVisibility,
                ),
                errorText:
                    authProvider.password.isNotEmpty &&
                        !authProvider.passwordValid
                    ? 'Password must be at least 8 characters with letters and numbers'
                    : null,
              ),
            ),

            SizedBox(height: 16.h),

            // Confirm password field
            TextFormField(
              onChanged: authProvider.updateConfirmPassword,
              obscureText: landingProvider.obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    landingProvider.obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: landingProvider.toggleConfirmPasswordVisibility,
                ),
                errorText:
                    authProvider.confirmPassword.isNotEmpty &&
                        !authProvider.confirmPasswordValid
                    ? 'Passwords do not match'
                    : null,
              ),
            ),

            SizedBox(height: 24.h),

            // Register button
            ElevatedButton(
              onPressed:
                  authProvider.isLoading || !authProvider.isRegisterFormValid
                  ? null
                  : () async {
                      await authProvider.register();

                      if (authProvider.hasSuccess && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.successMessage!),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Switch to login mode after successful registration
                        landingProvider.setLoginMode();
                      }
                    },
              child: authProvider.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Sign Up', style: TextStyle(fontSize: 16.sp)),
            ),

            SizedBox(height: 16.h),

            // Switch to login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : landingProvider.setLoginMode,
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
