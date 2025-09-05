import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/home_provider.dart';
import 'widgets/home_page.dart';
import '../profile/profile_page.dart';
import '../settings/settings_page.dart';
import '.././profile/providers/profile_provider.dart'; // Add this import

/// Home screen with bottom navigation and page view
/// Main screen for authenticated users
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(),
        ), // Add this
      ],
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          return Scaffold(
            body: PageView(
              controller: homeProvider.pageController,
              onPageChanged: homeProvider.setCurrentIndex,
              children: const [HomePage(), ProfilePage(), SettingsPage()],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: BottomNavigationBar(
                    currentIndex: homeProvider.currentIndex,
                    onTap: homeProvider.navigateToPage,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    selectedLabelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        activeIcon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
