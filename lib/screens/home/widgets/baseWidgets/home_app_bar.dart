import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}

class _HomeAppBarState extends State<HomeAppBar> {
  int _unreadCount = 0;
  late Stream<List<Map<String, dynamic>>> _notificationStream;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupRealtimeListener() {
    // Listen to real-time changes in mobile_uploads table
    _notificationStream = Supabase.instance.client
        .from('mobile_uploads')
        .stream(primaryKey: ['id'])
        .eq('is_read', false);

    _notificationStream.listen((data) {
      if (mounted) {
        setState(() {
          _unreadCount = data.length;
        });
      }
    });
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('mobile_uploads')
          .select('id')
          .eq('is_read', false)
          .count();
      if (mounted) {
        setState(() {
          _unreadCount = response.count;
        });
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  void _openNotificationsModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => NotificationModal(onRead: _fetchUnreadCount),
    );
    // Refresh unread count after modal closes
    _fetchUnreadCount();
  }

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
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: _openNotificationsModal,
                icon: const Icon(Icons.notifications, color: Colors.white),
                color: Colors.white,
                splashColor: Colors.white,
                highlightColor: Colors.white,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 2,
                  top: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF2D55), // Messenger/FB red
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationModal extends StatefulWidget {
  final VoidCallback? onRead;
  const NotificationModal({super.key, this.onRead});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('mobile_uploads')
        .select('id, file_name, status, analyzed_at, is_read')
        .order('analyzed_at', ascending: false)
        .limit(30);
    return List<Map<String, dynamic>>.from(response);
  }

  String _formatNotification(Map<String, dynamic> record) {
    final fileName = record['file_name'] ?? '';
    final status = record['status'] ?? '';
    final analyzedAt = record['analyzed_at'];
    String formattedDate = '';
    if (analyzedAt != null) {
      final date = DateTime.tryParse(analyzedAt.toString());
      if (date != null) {
        formattedDate = DateFormat('MMM. d, yyyy  h:mm a').format(date);
      }
    }
    return '$fileName is $status by the admin  $formattedDate';
  }

  Future<void> _markAsRead(int id) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('mobile_uploads')
        .update({'is_read': true})
        .eq('id', id);
    if (widget.onRead != null) widget.onRead!();
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 24.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Failed to load notifications'));
                }
                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return Center(child: Text('No notifications found'));
                }
                return Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      final record = notifications[index];
                      final isUnread =
                          record['is_read'] == false ||
                          record['is_read'] == null;
                      return InkWell(
                        onTap: isUnread
                            ? () => _markAsRead(record['id'] as int)
                            : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notifications,
                                color: isUnread ? Colors.red : Colors.green,
                                size: 28,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _formatNotification(record),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isUnread ? Colors.red : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
