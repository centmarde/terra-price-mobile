import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'screens/splash/providers/splash_provider.dart';
import 'screens/landing/providers/auth_provider.dart';
import 'screens/landing/providers/landing_provider.dart';

void main() {
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
            // Splash provider
            ChangeNotifierProvider(create: (context) => SplashProvider()),

            // Authentication provider
            ChangeNotifierProvider(create: (context) => AuthProvider()),

            // Landing page provider
            ChangeNotifierProvider(create: (context) => LandingProvider()),
          ],
          child: MaterialApp.router(
            title: 'TerraPrice',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.router,
          ),
        );
      },
    );
  }
}
