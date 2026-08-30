import 'package:flutter/material.dart';
import 'app_button.dart';

class NaraakButton extends StatelessWidget {
  const NaraakButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => AppButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        variant: variant,
        isLoading: isLoading,
      );
}
