import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/landing_provider.dart';

/// Hero section widget for the landing page
/// Displays app branding and form mode toggle
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LandingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // App logo/icon
            Container(
              width: 200.w,
              height: 160.h,

              child: ClipRRect(
                child: Image.asset(
                  'lib/assets/logo.png',
                  width: 200.w,
                  height: 160.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // App description
            Text(
              'Smart Land Pricing Solutions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Form mode toggle tabs
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Login tab
                  Expanded(
                    child: GestureDetector(
                      onTap: provider.setLoginMode,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: provider.isLoginMode
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: provider.isLoginMode
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // Register tab
                  Expanded(
                    child: GestureDetector(
                      onTap: provider.setRegisterMode,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: provider.isRegisterMode
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: provider.isRegisterMode
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
