import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppStatus { pending, approved, rejected, inProgress, confirmed }

/// Status badge — color + icon together (never color alone), per Phase 4
/// Section 6 colorblind-accessibility requirement.
class StatusBadge extends StatelessWidget {
  final AppStatus status;

  const StatusBadge({super.key, required this.status});

  ({Color color, IconData icon, String label}) get _config {
    switch (status) {
      case AppStatus.approved:
      case AppStatus.confirmed:
        return (color: AppColors.success, icon: Icons.check_circle, label: 'Confirmed');
      case AppStatus.pending:
      case AppStatus.inProgress:
        return (color: AppColors.warning, icon: Icons.hourglass_top, label: 'In Progress');
      case AppStatus.rejected:
        return (color: AppColors.bahrainAccent, icon: Icons.cancel, label: 'Rejected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, size: 14, color: c.color),
          const SizedBox(width: 6),
          Text(c.label, style: AppTextStyles.caption.copyWith(color: c.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
