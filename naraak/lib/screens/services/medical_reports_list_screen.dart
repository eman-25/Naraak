import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';

class _ReportEntry {
  final String title;
  final String category;
  final String date;
  const _ReportEntry(this.title, this.category, this.date);
}

/// All PHC Reports — Phase 3 §4.3, Figure 39's list screen. Demo data only
/// (no reports backend exists in this prototype).
class MedicalReportsListScreen extends StatelessWidget {
  const MedicalReportsListScreen({super.key});

  static const _reports = [
    _ReportEntry('Complete Blood Count', 'Laboratory', '9 Oct 2024'),
    _ReportEntry('Chest X-Ray', 'Radiology', '23 Sep 2024'),
    _ReportEntry('Annual Health Check', 'General', '1 Aug 2024'),
    _ReportEntry('Lipid Profile', 'Laboratory', '15 Jul 2024'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'All PHC Reports'),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final report = _reports[i];
          return AppCard(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Downloading isn\'t wired up in this demo.')),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryIce,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: AppColors.primaryTeal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text('${report.category} · ${report.date}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Downloading isn\'t wired up in this demo.')),
                    ),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4)),
                    child: const Text('PDF'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
