// lib/widgets/app_button.dart
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

/// Single button component covering every variant used across the app —
/// replaces separate ad-hoc ElevatedButton/OutlinedButton usage with one
/// consistent, animated control.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary; // kept for backward compatibility
  final AppButtonVariant variant;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 52,
    bool isOutlined = false,
  });

  AppButtonVariant get _resolvedVariant =>
      isSecondary ? AppButtonVariant.secondary : variant;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final primaryColor = AppPaletteExtension.of(context).primary;
    final disabled = onPressed == null || isLoading;
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: Colors.white),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 19),
                  const SizedBox(width: 8),
                ],
                Flexible(
                    child: Text(strings.raw(label),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
    );

    switch (_resolvedVariant) {
      case AppButtonVariant.primary:
        return SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
            child: content,
          ),
        );
      case AppButtonVariant.secondary:
        return SizedBox(
          height: height,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(foregroundColor: primaryColor),
            child: content,
          ),
        );
      case AppButtonVariant.ghost:
        return SizedBox(
          height: height,
          child: TextButton(
            onPressed: disabled ? null : onPressed,
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: content,
          ),
        );
      case AppButtonVariant.danger:
        return SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
            child: DefaultTextStyle.merge(
              style: AppTextStyles.buttonLabel,
              child: content,
            ),
          ),
        );
    }
  }
}
