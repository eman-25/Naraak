import 'package:flutter/material.dart';

/// Primary / Secondary / Loading button variants — Phase 4 component
/// checklist. Uses ElevatedButtonTheme / OutlinedButtonTheme from AppTheme.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    bool isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(label);

    if (isSecondary) {
      return OutlinedButton(
          onPressed: isLoading ? null : onPressed, child: child);
    }
    return ElevatedButton(
        onPressed: isLoading ? null : onPressed, child: child);
  }
}
