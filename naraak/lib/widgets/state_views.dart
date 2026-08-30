import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'naraak_button.dart';

enum NaraakStateType { empty, error, success }

class NaraakStateView extends StatelessWidget {
  const NaraakStateView({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final NaraakStateType type;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final localizedTitle = strings.raw(title);
    final localizedMessage = strings.raw(message);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = switch (type) {
      NaraakStateType.empty => (
          Icons.inbox_outlined,
          Theme.of(context).colorScheme.primary
        ),
      NaraakStateType.error => (
          Icons.error_outline_rounded,
          isDark ? AppColors.darkError : AppColors.error
        ),
      NaraakStateType.success => (
          Icons.check_circle_outline_rounded,
          isDark ? AppColors.darkSuccess : AppColors.success
        ),
    };
    return Semantics(
      liveRegion: true,
      label: '$localizedTitle. $localizedMessage',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 42),
              ),
              const SizedBox(height: 22),
              Text(localizedTitle,
                  style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(localizedMessage,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
              if (actionLabel != null) ...[
                const SizedBox(height: 24),
                NaraakButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends NaraakStateView {
  const EmptyState(
      {super.key,
      required super.title,
      required super.message,
      super.actionLabel,
      super.onAction})
      : super(type: NaraakStateType.empty);
}

class ErrorState extends NaraakStateView {
  const ErrorState(
      {super.key,
      required super.title,
      required super.message,
      super.actionLabel,
      super.onAction})
      : super(type: NaraakStateType.error);
}

class SuccessState extends NaraakStateView {
  const SuccessState(
      {super.key,
      required super.title,
      required super.message,
      super.actionLabel,
      super.onAction})
      : super(type: NaraakStateType.success);
}
