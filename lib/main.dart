import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/services/storage/storage_service.dart';
import 'core/providers/auth_state_provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'screens/splash/providers/splash_provider.dart';
import 'screens/landing/providers/auth_provider.dart';
import 'screens/landing/providers/landing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.initialize();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // Global authentication state provider
            ChangeNotifierProvider(
              create: (context) => AuthStateProvider(),
              lazy: false, // Initialize immediately
            ),

            // Splash provider
            ChangeNotifierProvider(create: (context) => SplashProvider()),

            // Authentication provider
            ChangeNotifierProvider(create: (context) => AuthProvider()),

            // Landing page provider
            ChangeNotifierProvider(create: (context) => LandingProvider()),
          ],
          child: Consumer<AuthStateProvider>(
            builder: (context, authStateProvider, child) {
              return MaterialApp.router(
                title: 'TerraPrice',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: AppRoutes.createRouter(authStateProvider),
              );
            },
          ),
        );
      },
    );
  }
}
