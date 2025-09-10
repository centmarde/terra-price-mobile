import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/views/splash_screen.dart';
import '../screens/landing/views/landing_screen.dart';
import '../screens/home/views/home_screen.dart';
import '../core/providers/auth_state_provider.dart';
import '../screens/aiResult/views/ai_results_page.dart';

/// Application routes configuration using go_router
/// Supports navigation between splash, landing, and home screens with authentication guards
class AppRoutes {
  // Route paths
  static const String splash = '/';
  static const String landing = '/landing';
  static const String home = '/home';
  static const String aiResults = '/ai_results_page';

  /// Create router with authentication state provider
  static GoRouter createRouter(AuthStateProvider authStateProvider) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,
      refreshListenable: authStateProvider,
      redirect: (context, state) {
        final isAuthenticated = authStateProvider.isAuthenticated;
        final isLoading = authStateProvider.isLoading;
        final currentLocation = state.uri.path;

        // Show splash while loading authentication state
        if (isLoading) {
          return splash;
        }

        // If user is authenticated and trying to access landing, redirect to home
        if (isAuthenticated && currentLocation == landing) {
          return home;
        }

        // If user is not authenticated and trying to access home, redirect to landing
        if (!isAuthenticated && currentLocation == home) {
          return landing;
        }

        // If on splash and auth state is determined, redirect appropriately
        if (currentLocation == splash && !isLoading) {
          return isAuthenticated ? home : landing;
        }

        // No redirect needed
        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: landing,
          name: 'landing',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: aiResults,
          name: 'ai_results_page',
          builder: (context, state) => const AIResultsPage(),
        ),
      ],
      // Error handling
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The requested page could not be found.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(splash),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
