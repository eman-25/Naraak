import 'package:flutter/material.dart';
import 'appointment.dart';
import 'service_request.dart';

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

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
  });
}

/// Single source of truth for "what are my notifications" — used by both
/// the Notifications screen and the top bar's unread badge, so the two
/// can never disagree about what counts as a notification.
List<NotificationItem> buildNotifications(
  BuildContext context,
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
