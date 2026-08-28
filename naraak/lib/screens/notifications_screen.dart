// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../models/appointment.dart';
import '../models/service_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';

enum NotificationType {
  appointment,
  request,
  telehealth,
  certificate,
  actionRequired,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });
}

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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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

  List<NotificationItem> _buildNotifications(
    List<Appointment> appointments,
    List<ServiceRequest> requests,
  ) {
    final notifications = <NotificationItem>[];

    for (final appointment in appointments) {
      final isUpcoming = appointment.slotDateTime.isAfter(DateTime.now());
      notifications.add(
        NotificationItem(
          id: 'appointment-${appointment.id}',
          title: isUpcoming ? 'APPOINTMENT REMINDER' : 'APPOINTMENT UPDATE',
          message: isUpcoming
              ? 'Your appointment with ${appointment.doctorName} is scheduled for '
                  '${MaterialLocalizations.of(context).formatMediumDate(appointment.slotDateTime)} '
                  'at ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(appointment.slotDateTime))}'
              : 'Your appointment with ${appointment.doctorName} is ${appointment.status}',
          timeAgo: appointment.status.toUpperCase(),
          type: NotificationType.appointment,
        ),
      );
    }

    for (final request in requests) {
      final needsAction = request.requiresAction;
      notifications.add(
        NotificationItem(
          id: 'request-${request.id}',
          title: needsAction ? 'ACTION NEEDED' : 'REQUEST UPDATE',
          message: needsAction
              ? '${request.serviceName} requires your attention'
              : '${request.serviceName} request status changed to ${request.status}',
          timeAgo: request.status.toUpperCase(),
          type: needsAction
              ? NotificationType.actionRequired
              : NotificationType.request,
        ),
      );
    }

    return notifications;
  }

  void _scrollToLatestWhenReady(List<NotificationItem> notifications) {
    if (notifications.isEmpty || _didScrollToLatest) return;
    _didScrollToLatest = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteExtension.of(context);
    final screenSize = MediaQuery.of(context).size;
    final iconBoxSize = (screenSize.width * 0.11).clamp(42.0, 52.0);
    final appointmentProvider = context.watch<AppointmentProvider>();
    final requestProvider = context.watch<ServiceRequestProvider>();
    final notifications = _buildNotifications(
      appointmentProvider.myAppointments,
      requestProvider.requests,
    );
    _scrollToLatestWhenReady(notifications);
    final isLoading = appointmentProvider.slotsState == LoadState.loading ||
        requestProvider.state == LoadState.loading;

    return Scaffold(
      appBar: const AppTopBar(title: 'Notifications'),
      body: isLoading
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
                      Text('No notifications yet', style: AppTextStyles.h3),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenSize.width * 0.04).clamp(16.0, 24.0),
                    vertical: 16,
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final iconColor = palette.primary;

                    return AppCard(
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
                              color: iconColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getNotificationIcon(item.type),
                              color: iconColor,
                              size: (iconBoxSize * 0.48).clamp(20.0, 26.0),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
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
    );
  }
}
