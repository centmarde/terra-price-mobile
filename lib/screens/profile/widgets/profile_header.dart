import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../landing/providers/auth_provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          'Jetross Doe',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            );
          },
        ),
      ],
    );
  }
}
