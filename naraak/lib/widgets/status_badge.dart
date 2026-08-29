// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppStatus {
  pending,
  approved,
  rejected,
  inProgress,
  confirmed,
  completed,
  cancelled,
}

class StatusBadge extends StatelessWidget {
  final AppStatus status;
  const StatusBadge({super.key, required this.status});

  ({Color fg, Color bg, IconData icon, String label}) _colorsFor(bool isDark) {
    switch (status) {
      case AppStatus.approved:
      case AppStatus.confirmed:
        final fg = isDark ? AppColors.darkSuccess : AppColors.success;
        return (
          fg: fg,
          bg: isDark ? fg.withValues(alpha: 0.16) : AppColors.successSurface,
          icon: Icons.check_circle_rounded,
          label: 'Confirmed'
        );
      case AppStatus.completed:
        final fg = isDark ? AppColors.darkSuccess : AppColors.success;
        return (
          fg: fg,
          bg: isDark ? fg.withValues(alpha: 0.16) : AppColors.successSurface,
          icon: Icons.check_circle_rounded,
          label: 'Completed'
        );
      case AppStatus.pending:
      case AppStatus.inProgress:
        final fg = isDark ? AppColors.darkWarning : AppColors.warning;
        return (
          fg: fg,
          bg: isDark ? fg.withValues(alpha: 0.16) : AppColors.warningSurface,
          icon: Icons.schedule_rounded,
          label: 'In Progress'
        );
      case AppStatus.rejected:
        final fg = isDark ? AppColors.darkError : AppColors.error;
        return (
          fg: fg,
          bg: isDark ? fg.withValues(alpha: 0.16) : AppColors.errorSurface,
          icon: Icons.cancel_rounded,
          label: 'Rejected'
        );
      case AppStatus.cancelled:
        final fg = isDark ? AppColors.darkError : AppColors.error;
        return (
          fg: fg,
          bg: isDark ? fg.withValues(alpha: 0.16) : AppColors.errorSurface,
          icon: Icons.cancel_rounded,
          label: 'Cancelled'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = _colorsFor(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration:
          BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, size: 14, color: c.fg),
          const SizedBox(width: 5),
          Text(c.label,
              style: AppTextStyles.caption
                  .copyWith(color: c.fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
