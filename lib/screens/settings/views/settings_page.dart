import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_option_card.dart';
import '../widgets/app_info_card.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// Settings page widget - app settings and preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
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
                            value: settingsProvider.isDarkMode,
                            onChanged: (value) {
                              settingsProvider.toggleDarkMode(value);
                              // TODO: Integrate with app theme
                            },
                          ),
                        ),
                        SettingsOptionCard(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Select Language'),
                                content: const Text(
                                  'Language selection coming soon.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
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
                            value: settingsProvider.dataSyncEnabled,
                            onChanged: (value) {
                              settingsProvider.toggleDataSync(value);
                            },
                          ),
                        ),
                        SettingsOptionCard(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Privacy Policy'),
                                content: const Text(
                                  'Privacy policy details coming soon.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SettingsOptionCard(
                          icon: Icons.article_outlined,
                          title: 'Terms of Service',
                          subtitle: 'Read terms and conditions',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Terms of Service'),
                                content: const Text(
                                  'Terms and conditions coming soon.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
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
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Help Center'),
                                content: const Text('Help center coming soon.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SettingsOptionCard(
                          icon: Icons.feedback_outlined,
                          title: 'Send Feedback',
                          subtitle: 'Help us improve the app',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Send Feedback'),
                                content: const Text(
                                  'Feedback form coming soon.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SettingsOptionCard(
                          icon: Icons.star_outline,
                          title: 'Rate App',
                          subtitle: 'Rate us on the app store',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Rate App'),
                                content: const Text(
                                  'App store rating coming soon.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
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
        },
      ),
    );
  }
}
