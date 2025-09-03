import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../landing/providers/auth_provider.dart';
import '../../landing/services/auth_service.dart';

/// Profile page widget - user profile and account information
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // Profile avatar
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 50.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              SizedBox(height: 16.h),

              // User name
              Text(
                'John Doe',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8.h),

              // User email
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Text(
                    authProvider.email.isNotEmpty
                        ? authProvider.email
                        : 'user@example.com',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Profile options
              _buildProfileOption(
                context,
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {
                  // Navigate to edit profile
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                onTap: () {
                  // Navigate to notifications settings
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.security,
                title: 'Security',
                subtitle: 'Change password and security settings',
                onTap: () {
                  // Navigate to security settings
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                onTap: () {
                  // Navigate to help
                },
              ),

              _buildProfileOption(
                context,
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
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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
          context.read<AuthProvider>().clearMessages();
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
