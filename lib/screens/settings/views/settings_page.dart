import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_option_card.dart';
import '../widgets/app_info_card.dart';

/// Settings page widget - app settings and preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Settings Section
              SettingsSection(
                title: 'App Settings',
                children: [
                  SettingsOptionCard(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark theme',
                    trailing: Switch(
                      value: false, // This would come from theme provider
                      onChanged: (value) {
                        // Toggle theme
                      },
                    ),
                  ),
                  SettingsOptionCard(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {
                      // Show language selector
                    },
                  ),
                  SettingsOptionCard(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Manage notification preferences',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Toggle notifications
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Data & Privacy Section
              SettingsSection(
                title: 'Data & Privacy',
                children: [
                  SettingsOptionCard(
                    icon: Icons.cloud_sync,
                    title: 'Data Sync',
                    subtitle: 'Sync data across devices',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Toggle data sync
                      },
                    ),
                  ),
                  SettingsOptionCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {
                      // Show privacy policy
                    },
                  ),
                  SettingsOptionCard(
                    icon: Icons.article_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read terms and conditions',
                    onTap: () {
                      // Show terms of service
                    },
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Support Section
              SettingsSection(
                title: 'Support',
                children: [
                  SettingsOptionCard(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  SettingsOptionCard(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Help us improve the app',
                    onTap: () {
                      // Show feedback form
                    },
                  ),
                  SettingsOptionCard(
                    icon: Icons.star_outline,
                    title: 'Rate App',
                    subtitle: 'Rate us on the app store',
                    onTap: () {
                      // Open app store rating
                    },
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // App Info
              const AppInfoCard(),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
