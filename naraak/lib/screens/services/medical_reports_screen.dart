import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import 'medical_reports_list_screen.dart';
import 'request_medical_report_screen.dart';

/// Medical Reports entry screen.
class MedicalReportsScreen extends StatelessWidget {
  const MedicalReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar: const AppTopBar(title: 'Medical Reports'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicalReportsListScreen(),
                ),
              ),
              child: Row(
                children: [
                  _IconBadge(
                    icon: Icons.folder_open_outlined,
                    color: palette.primary,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('View My Reports', style: AppTextStyles.h3),
                        SizedBox(height: 2),
                        Text(
                          'See and download your PHC reports',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.ink300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RequestMedicalReportScreen(),
                ),
              ),
              child: Row(
                children: [
                  _IconBadge(
                    icon: Icons.note_add_outlined,
                    color: palette.primary,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Request a Report', style: AppTextStyles.h3),
                        SizedBox(height: 2),
                        Text(
                          'Submit a new medical report request',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.ink300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
