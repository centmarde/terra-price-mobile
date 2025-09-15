import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../landing/providers/auth_provider.dart' as landing_auth;
import '../../landing/services/auth_service.dart';
import '../widgets/profile_option_card.dart';
import '../widgets/profile_header.dart'; // Add this import for ProfileHeader
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';

/// Profile page widget - user profile and account information
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80.h,
          title: Text(
            'Profile',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                const ProfileHeader(),

                SizedBox(height: 12.h),

                // Edit Profile section (styled like other options)
                ProfileOptionCard(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Profile options
                ProfileOptionCard(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),

                ProfileOptionCard(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help or contact support',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),

                ProfileOptionCard(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    // Show about dialog
                  },
                ),

                SizedBox(height: 24.h),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _handleLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authService = AuthService();
      final result = await authService.signOut();

      if (result.isSuccess && context.mounted) {
        // Clear auth provider state
        if (context.mounted) {
          context.read<landing_auth.AuthProvider>().clearMessages();
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to landing screen (will be handled by route guard)
        // The app should automatically redirect to login when auth state changes
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
