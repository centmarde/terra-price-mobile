import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/splash_provider.dart';
import '../../core/widgets/loading_widget.dart';
import '../../routes/app_routes.dart';

/// Splash screen with loading state and navigation to landing page
/// Displays app branding while initializing core services
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize splash and navigate when complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  /// Initialize splash process and navigate to landing page
  Future<void> _initializeAndNavigate() async {
    final provider = context.read<SplashProvider>();

    try {
      await provider.initializeSplash();

      if (mounted && !provider.hasError) {
        context.go(AppRoutes.landing);
      }
    } catch (e) {
      // Error handling is managed by the provider
      debugPrint('Splash initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Consumer<SplashProvider>(
        builder: (context, provider, child) {
          if (provider.hasError) {
            return _buildErrorView(provider);
          }

          return _buildLoadingView();
        },
      ),
    );
  }

  /// Build loading view with app branding
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/icon placeholder
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.terrain,
              size: 64.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(height: 32.h),

          // App name
          Text(
            'TerraPrice',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          // App tagline
          Text(
            'Smart Land Pricing Solutions',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          SizedBox(height: 48.h),

          // Loading indicator
          LoadingWidget(
            color: Colors.white,
            size: 32.w,
            message: 'Initializing...',
          ),
        ],
      ),
    );
  }

  /// Build error view with retry option
  Widget _buildErrorView(SplashProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.white),

            SizedBox(height: 24.h),

            Text(
              'Initialization Failed',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            Text(
              provider.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Retry button
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      await provider.retry();
                      if (!provider.hasError && mounted) {
                        context.go(AppRoutes.landing);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: provider.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
