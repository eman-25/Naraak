import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Shown before the final submit/start action on any service whose real
/// implementation depends on an external system (MOH registries, RMS,
/// Ministry of Hajj & Umrah, notification services, etc.) that isn't
/// actually connected in this build.
///
/// This is intentionally honest with the demo user: the screen, fields,
/// and flow are fully built — only the live backend call is unavailable.
/// Confirming proceeds with the mock submission so the flow and Pending
/// Requests tracking can still be demonstrated end-to-end.
Future<bool> showExternalApiNotice(
  BuildContext context, {
  required String serviceName,
  required String integrationName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.cloud_off_outlined,
          color: AppColors.warning, size: 40),
      title: const Text('External Integration Required'),
      content: Text(
        '$serviceName is fully implemented — the screens, fields, and flow you just '
        'completed match the Naraak spec. In production this step submits to $integrationName, '
        'which isn\'t connected in this build.\n\n'
        'Continuing will simulate the submission with mock data so you can see the '
        'confirmation and request-tracking behavior.',
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 180,
          child: AppButton(
            label: 'Continue (Demo)',
            isOutlined: false,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
