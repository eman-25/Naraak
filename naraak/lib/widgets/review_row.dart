import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Label/value line used on every service's Review & Confirm step.
class ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const ReviewRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.bodySecondary),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutralDark),
            ),
          ),
        ],
      ),
    );
  }
}
