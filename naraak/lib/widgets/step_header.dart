import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows progress through a multi-step service flow (e.g. Change Family
/// Doctor: Reason -> New Center & Doctor -> Review). Used across the
/// request-based service screens so every multi-step flow reads
/// consistently, per the Phase 4 component checklist.
class StepHeader extends StatelessWidget {
  final int currentStep; // 0-indexed
  final List<String> stepLabels;

  const StepHeader({super.key, required this.currentStep, required this.stepLabels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(stepLabels.length, (i) {
              final isDone = i < currentStep;
              final isActive = i == currentStep;
              final color = isDone || isActive ? AppColors.primaryTeal : AppColors.neutralGray.withValues(alpha: 0.3);
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == stepLabels.length - 1 ? 0 : 6),
                  height: 4,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            'Step ${currentStep + 1} of ${stepLabels.length} — ${stepLabels[currentStep]}',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
          ),
        ],
      ),
    );
  }
}
