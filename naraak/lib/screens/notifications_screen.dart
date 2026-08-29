// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/notifications_read_provider.dart';
import '../models/notification_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';
import '../main.dart' show ShellNavigation;
import 'request_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _didScrollToLatest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadMyAppointments();
      context.read<ServiceRequestProvider>().loadRequests();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToLatestWhenReady(List<NotificationItem> notifications) {
    if (notifications.isEmpty || _didScrollToLatest) return;
    _didScrollToLatest = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  /// Phase 3 §2.5: tapping a notification routes by type instead of doing
  /// nothing. Appointment notifications go to the Appointments tab; request
  /// notifications go to that request's detail screen.
  void _handleTap(NotificationItem item, List requests) {
    context.read<NotificationsReadProvider>().markRead(item.id);

    if (item.type == NotificationType.appointment) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
    final palette = AppPaletteExtension.of(context);
    final screenSize = MediaQuery.of(context).size;
    final iconBoxSize = (screenSize.width * 0.11).clamp(42.0, 52.0);
    final appointmentProvider = context.watch<AppointmentProvider>();
    final requestProvider = context.watch<ServiceRequestProvider>();
    final readProvider = context.watch<NotificationsReadProvider>();
    final notifications = buildNotifications(
      context,
      appointmentProvider.myAppointments,
      requestProvider.requests,
    );
    _scrollToLatestWhenReady(notifications);
    final isLoading = appointmentProvider.slotsState == LoadState.loading ||
        requestProvider.state == LoadState.loading;
    final unreadCount =
        readProvider.unreadCount(notifications.map((n) => n.id));

    return Scaffold(
      appBar: const AppTopBar(title: 'Notifications'),
      body: Column(
        children: [
          if (!isLoading && notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unreadCount > 0 ? '$unreadCount unread' : 'All caught up',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.ink500),
                  ),
                  TextButton(
                    onPressed: unreadCount == 0
                        ? null
                        : () => readProvider
                            .markAllRead(notifications.map((n) => n.id)),
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 64,
                              color: AppColors.ink500,
                            ),
                            const SizedBox(height: 12),
                            Text('No notifications yet',
                                style: AppTextStyles.h3),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              (screenSize.width * 0.04).clamp(16.0, 24.0),
                          vertical: 16,
                        ),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          final isRead = readProvider.isRead(item.id);
                          final iconColor = palette.primary;

                          return AppCard(
                            onTap: () =>
                                _handleTap(item, requestProvider.requests),
                            padding: EdgeInsets.all(
                              (screenSize.width * 0.04).clamp(14.0, 20.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: iconBoxSize,
                                  height: iconBoxSize,
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(
                                        alpha: isRead ? 0.05 : 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(item.type),
                                    color:
                                        isRead ? AppColors.ink500 : iconColor,
                                    size:
                                        (iconBoxSize * 0.48).clamp(20.0, 26.0),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.title,
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.ink500,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          if (!isRead) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: AppColors.bahrainAccent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.message,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: isRead
                                              ? FontWeight.normal
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.timeAgo,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.ink500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
