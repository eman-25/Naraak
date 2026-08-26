import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable card shell — Phase 4 component checklist, "Cards" (List item /
/// Summary / Status variants all use this base).
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryIce,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
