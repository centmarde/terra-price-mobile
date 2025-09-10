import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.h,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            padding: EdgeInsets.only(top: 4.h),
            margin: EdgeInsets.only(left: 60.w),
            child: ClipRRect(
              child: Image.asset(
                'lib/assets/logo.png',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.green,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        IconButton(
          onPressed: () {
            // Show notifications
          },
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
