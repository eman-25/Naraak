import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/appointment_provider.dart' show LoadState;
import '../providers/clinical_data_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/naraak_app_bar.dart';
import '../widgets/state_views.dart';

/// Notification center — Phase 3 §32: loading/empty/error/unread states,
/// and tapping a notification navigates to the related request or
/// appointment.
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

  (IconData, Color) _iconFor(String type, bool isDark) {
    if (type.contains('appointment')) {
      return (Icons.calendar_month_rounded, AppColors.primaryTeal);
    }
    if (type.contains('vaccination')) {
      return (Icons.vaccines_rounded, AppColors.secondary);
    }
    if (type.contains('certificate')) {
      return (Icons.workspace_premium_rounded, const Color(0xFF7C6FE0));
    }
    if (type.contains('doctor')) {
      return (Icons.medical_services_rounded, AppColors.warning);
    }
    if (type.contains('mobile')) {
      return (Icons.airport_shuttle_rounded, AppColors.secondary);
    }
    if (type.contains('request')) {
      return (Icons.assignment_outlined, AppColors.warning);
    }
    return (Icons.notifications_outlined, AppColors.neutralGray);
  }

  Future<void> _handleTap(BuildContext context, dynamic item) async {
    await context.read<ClinicalDataProvider>().markRead(item.id);
    final target = item.routeTarget as String?;
    if (target == null || !context.mounted) return;
    final shell = ShellNavigation.of(context);
    if (shell == null) return;
    // '/appointments' is a bottom-nav tab (index 1), not a pushable named
    // route on the shell's nested navigator — switch tabs for it instead
    // of trying to push it.
    if (target == '/appointments') {
      // selectTab already pops the shell's nested navigator back to its
      // first route, which includes this Notifications screen.
      shell.selectTab(1);
    } else {
      shell.pushNamed(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicalDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: NaraakAppBar(
        title: 'Notifications',
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () async {
                for (final item
                    in provider.notifications.where((n) => !n.read).toList()) {
                  await provider.markRead(item.id);
                }
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: switch (provider.notificationsState) {
            LoadState.idle ||
            LoadState.loading =>
              const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorState(
                title: 'Could not load notifications',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: provider.loadNotifications,
              ),
            LoadState.empty => const EmptyState(
                title: 'No notifications',
                message: 'Updates and reminders will appear here.',
              ),
            LoadState.success => RefreshIndicator(
                onRefresh: provider.loadNotifications,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = provider.notifications[index];
                    final (icon, color) = _iconFor(item.type, isDark);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _handleTap(context, item),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.read
                                ? (isDark
                                    ? AppColors.darkSurface
                                    : Colors.white)
                                : (isDark
                                    ? color.withValues(alpha: 0.12)
                                    : AppColors.secondaryIce),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkOutline
                                  : AppColors.outline,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(
                                      alpha: isDark ? 0.22 : 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 19),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title,
                                        style: AppTextStyles.body.copyWith(
                                            fontWeight: item.read
                                                ? FontWeight.w600
                                                : FontWeight.w800)),
                                    const SizedBox(height: 3),
                                    Text(item.body,
                                        style: AppTextStyles.bodySecondary),
                                    const SizedBox(height: 6),
                                    Text(
                                      MaterialLocalizations.of(context)
                                          .formatMediumDate(
                                              item.createdAt.toLocal()),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              if (!item.read) ...[
                                const SizedBox(width: 8),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryTeal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          },
        ),
      ),
    );
  }
}
