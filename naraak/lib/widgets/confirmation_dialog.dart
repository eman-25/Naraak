import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'naraak_button.dart';
import 'app_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => ConfirmationDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          isDestructive: isDestructive,
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => AlertDialog(
        icon: Icon(
          isDestructive
              ? Icons.warning_amber_rounded
              : Icons.help_outline_rounded,
          size: 38,
        ),
        title: Text(title, style: AppTextStyles.h2),
        content: Text(message, style: AppTextStyles.bodySecondary),
        actions: [
          NaraakButton(
            label: cancelLabel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
          NaraakButton(
            label: confirmLabel,
            variant: isDestructive
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
}

Future<bool> confirmUnsavedChanges(BuildContext context) =>
    ConfirmationDialog.show(
      context,
      title: 'Are you sure?',
      message: 'You have unsaved changes. Do you want to leave this page?',
      cancelLabel: 'Stay',
      confirmLabel: 'Leave',
      isDestructive: true,
    );
