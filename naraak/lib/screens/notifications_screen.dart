import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart' show LoadState;
import '../providers/clinical_data_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ClinicalDataProvider>().loadNotifications());
  }

  IconData _icon(String type) => type.contains('appointment')
      ? Icons.calendar_month_rounded
      : type.contains('request')
          ? Icons.assignment_outlined
          : Icons.notifications_outlined;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicalDataProvider>();
    return Scaffold(
        appBar: AppBar(title: const Text('Notifications'), actions: [
          if (provider.unreadCount > 0)
            TextButton(
                onPressed: () async {
                  for (final item in provider.notifications
                      .where((n) => !n.read)
                      .toList()) {
                    await provider.markRead(item.id);
                  }
                },
                child: const Text('Mark all read'))
        ]),
        body: switch (provider.notificationsState) {
          LoadState.idle ||
          LoadState.loading =>
            const Center(child: CircularProgressIndicator()),
          LoadState.error => EmptyStateView(
              isError: true,
              title: 'Could not load notifications',
              message: provider.errorMessage ?? 'Please try again.',
              actionLabel: 'Retry',
              onAction: provider.loadNotifications),
          LoadState.empty => const EmptyStateView(
              icon: Icons.notifications_none,
              title: 'No notifications',
              message: 'Updates and reminders will appear here.'),
          LoadState.success => RefreshIndicator(
              onRefresh: provider.loadNotifications,
              child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = provider.notifications[index];
                    return Card(
                        color: item.read ? null : AppColors.secondaryIce,
                        child: ListTile(
                            onTap: () => provider.markRead(item.id),
                            leading:
                                CircleAvatar(child: Icon(_icon(item.type))),
                            title: Text(item.title, style: AppTextStyles.h3),
                            subtitle: Text(
                                '${item.body}\n${MaterialLocalizations.of(context).formatMediumDate(item.createdAt.toLocal())}'),
                            isThreeLine: true,
                            trailing: item.read
                                ? null
                                : const Icon(Icons.circle,
                                    size: 10, color: AppColors.primaryTeal)));
                  })),
        });
  }
}
