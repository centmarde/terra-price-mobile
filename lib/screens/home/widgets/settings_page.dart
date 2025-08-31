import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Settings page widget - app settings and preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Settings Section
              Text(
                'App Settings',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 16.h),

              _buildSettingsOption(
                context,
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

              _buildSettingsOption(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  // Show language selector
                },
              ),

              _buildSettingsOption(
                context,
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

              SizedBox(height: 32.h),

              // Data & Privacy Section
              Text(
                'Data & Privacy',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 16.h),

              _buildSettingsOption(
                context,
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

              _buildSettingsOption(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // Show privacy policy
                },
              ),

              _buildSettingsOption(
                context,
                icon: Icons.article_outlined,
                title: 'Terms of Service',
                subtitle: 'Read terms and conditions',
                onTap: () {
                  // Show terms of service
                },
              ),

              SizedBox(height: 32.h),

              // Support Section
              Text(
                'Support',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 16.h),

              _buildSettingsOption(
                context,
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {
                  // Navigate to help center
                },
              ),

              _buildSettingsOption(
                context,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () {
                  // Show feedback form
                },
              ),

              _buildSettingsOption(
                context,
                icon: Icons.star_outline,
                title: 'Rate App',
                subtitle: 'Rate us on the app store',
                onTap: () {
                  // Open app store rating
                },
              ),

              SizedBox(height: 32.h),

              // App Info
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'App Version',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '1.0.0',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Build Number',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '1',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
