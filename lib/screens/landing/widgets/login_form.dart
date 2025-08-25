import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/landing_provider.dart';

/// Login form widget - pure UI component
/// Handles user input for email and password fields
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LandingProvider>(
      builder: (context, authProvider, landingProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    landingProvider.obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: landingProvider.togglePasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (authProvider.email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your email first'),
                            ),
                          );
                          return;
                        }

                        await authProvider.forgotPassword();

                        if (authProvider.hasSuccess && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.successMessage!),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                child: const Text('Forgot Password?'),
              ),
            ),

            SizedBox(height: 24.h),

            // Login button
            ElevatedButton(
              onPressed:
                  authProvider.isLoading || !authProvider.isLoginFormValid
                  ? null
                  : () async {
                      await authProvider.login();

                      if (authProvider.hasSuccess && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.successMessage!),
                            backgroundColor: Colors.green,
                          ),
                        );
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
                  : Text('Sign In', style: TextStyle(fontSize: 16.sp)),
            ),

            SizedBox(height: 16.h),

            // Switch to register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : landingProvider.setRegisterMode,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
