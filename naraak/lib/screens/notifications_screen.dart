// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/notifications_read_provider.dart';
import '../models/notification_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../main.dart' show ShellNavigation;
import 'request_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadMyAppointments();
      context.read<ServiceRequestProvider>().loadRequests();
    });
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_month_rounded;
      case NotificationType.request:
        return Icons.assignment_outlined;
      case NotificationType.telehealth:
        return Icons.video_camera_front_rounded;
      case NotificationType.certificate:
        return Icons.verified_user_rounded;
      case NotificationType.actionRequired:
        return Icons.error_outline_rounded;
    }
  }

  void _handleTap(NotificationItem item, List requests) {
    context.read<NotificationsReadProvider>().markRead(item.id);

    if (item.type == NotificationType.appointment) {
      Navigator.of(context).pop();
      ShellNavigation.of(context)?.selectTab(1);
      return;
    }

    final requestId = item.id.replaceFirst('request-', '');
    final match = requests.where((r) => r.id == requestId);
    if (match.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RequestDetailScreen(request: match.first),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentProvider = context.watch<AppointmentProvider>();
    final requestProvider = context.watch<ServiceRequestProvider>();
    final readProvider = context.watch<NotificationsReadProvider>();
    final notifications = buildNotifications(
      context,
      appointmentProvider.myAppointments,
      requestProvider.requests,
    );
    final unreadCount = readProvider.unreadCount(notifications.map((n) => n.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: palette.primary,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text('STAY UP TO DATE',
                style: AppTextStyles.overline.copyWith(color: palette.primary)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: AppTextStyles.h1.copyWith(fontSize: 26)),
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: unreadCount == 0
                        ? null
                        : () => readProvider
                            .markAllRead(notifications.map((n) => n.id)),
                    style: TextButton.styleFrom(foregroundColor: palette.primary),
                    child: const Text('Mark all read',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Important updates from your care team and health center.',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 22),
            if (notifications.isEmpty)
              _EmptyNotifications()
            else ...[
              ...notifications.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _NotificationItemRow(
                      item: item,
                      isRead: readProvider.isRead(item.id),
                      icon: _getNotificationIcon(item.type),
                      palette: palette,
                      onTap: () => _handleTap(item, requestProvider.requests),
                    ),
                  )),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF12241A)
                      : const Color(0xFFF4FBF6),
                  border: Border.all(
                      color: const Color(0xFF1E9E6B).withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_rounded, size: 18, color: Color(0xFF1E9E6B)),
                    SizedBox(width: 8),
                    Text("You're all caught up for now.",
                        style: TextStyle(
                            color: Color(0xFF1E9E6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.ink300),
          SizedBox(height: 12),
          Text('No notifications yet', style: AppTextStyles.h3),
        ],
      ),
    );
  }
}

class _NotificationItemRow extends StatelessWidget {
  final NotificationItem item;
  final bool isRead;
  final IconData icon;
  final dynamic palette;
  final VoidCallback onTap;
  const _NotificationItemRow({
    required this.item,
    required this.isRead,
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.outline),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: palette.primary, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                      Text(item.timeAgo,
                          style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.message,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View details',
                          style: TextStyle(
                              color: palette.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 13, color: palette.primary),
                    ],
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: palette.primary, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
