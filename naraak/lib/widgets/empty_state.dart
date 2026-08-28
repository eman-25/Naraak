// lib/widgets/empty_state.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class EmptyStateView extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  @override
  State<EmptyStateView> createState() => _EmptyStateViewState();
}

class _EmptyStateViewState extends State<EmptyStateView> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? AppColors.error : AppColors.ink500;
    final bg = widget.isError ? AppColors.errorSurface : AppColors.ink050;

    return FadeTransition(
      opacity: _c,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(widget.icon, size: 40, color: color),
              ),
              const SizedBox(height: 20),
              Text(widget.title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(widget.message, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              if (widget.actionLabel != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: 200,
                  child: AppButton(
                    label: widget.actionLabel!,
                    variant: AppButtonVariant.secondary,
                    onPressed: widget.onAction,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}