import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class ExternalApiServiceView extends StatelessWidget {
  final String title;
  final IconData icon;

  const ExternalApiServiceView(
      {super.key, required this.title, required this.icon});

  void _showApiDialog(BuildContext context) {
    final strings = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.text('externalApiTitle')),
        content: Text(strings.text('externalApiMessage')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.text('close'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryTeal),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).text('externalApiMessage'),
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
                label: AppLocalizations.of(context).text('startService'),
                onPressed: () => _showApiDialog(context)),
          ],
        ),
      ),
    );
  }
}
