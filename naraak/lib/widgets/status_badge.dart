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

  ({Color fg, Color bg, IconData icon, String label}) get _c {
    switch (status) {
      case AppStatus.approved:
      case AppStatus.confirmed:
        return (
          fg: AppColors.success,
          bg: AppColors.successSurface,
          icon: Icons.check_circle_rounded,
          label: 'Confirmed'
        );
      case AppStatus.completed:
        return (
          fg: AppColors.success,
          bg: AppColors.successSurface,
          icon: Icons.check_circle_rounded,
          label: 'Completed'
        );
      case AppStatus.pending:
      case AppStatus.inProgress:
        return (
          fg: AppColors.warning,
          bg: AppColors.warningSurface,
          icon: Icons.schedule_rounded,
          label: 'In Progress'
        );
      case AppStatus.rejected:
        return (
          fg: AppColors.error,
          bg: AppColors.errorSurface,
          icon: Icons.cancel_rounded,
          label: 'Rejected'
        );
      case AppStatus.cancelled:
        return (
          fg: AppColors.error,
          bg: AppColors.errorSurface,
          icon: Icons.cancel_rounded,
          label: 'Cancelled'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
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
