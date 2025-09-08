import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../landing/providers/auth_provider.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load profile data when dependencies change (safer than initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final profileProvider = context.read<ProfileProvider>();
        if (profileProvider.profile == null && !profileProvider.isLoading) {
          profileProvider.loadProfile();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, AuthProvider>(
      builder: (context, profileProvider, authProvider, child) {
        // Show loading state
        if (profileProvider.isLoading) {
          return Column(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Loading profile...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }

        // Show error state
        if (profileProvider.error != null) {
          return Column(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.error.withOpacity(0.1),
                child: Icon(
                  Icons.error_outline,
                  size: 50.w,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                profileProvider.error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              ElevatedButton(
                onPressed: () => profileProvider.loadProfile(),
                child: const Text('Retry'),
              ),
            ],
          );
        }

        final profile = profileProvider.profile;
        final email = authProvider.email.isNotEmpty
            ? authProvider.email
            : 'jetross@example.com'; // Default with current user

        return Column(
          children: [
            // Profile avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: profile?.avatarUrl != null
                      ? NetworkImage(profile!.avatarUrl!)
                      : null,
                  child: profile?.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50.w,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),

                // Edit button
              ],
            ),

            SizedBox(height: 16.h),

            // User name
            Text(
              profile?.fullName ?? email.split('@').first.capitalize(),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8.h),

            // User email
            Text(
              email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            // Bio section (if exists)
            if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  profile.bio!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
