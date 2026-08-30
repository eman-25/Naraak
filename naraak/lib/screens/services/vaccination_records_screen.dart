import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import 'vaccination_records_list_screen.dart';
import 'missing_vaccination_screen.dart';

/// Vaccination Records entry — Phase 3 §4.2, Figure 38: the first screen
/// is a choice between viewing/downloading existing records or reporting
/// a missing one, not a flat list.
class VaccinationRecordsScreen extends StatelessWidget {
  const VaccinationRecordsScreen({super.key});

  @override
  State<VaccinationRecordsScreen> createState() =>
      _VaccinationRecordsScreenState();
}

class _VaccinationRecordsScreenState extends State<VaccinationRecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaccinationProvider>().loadRecords();
    });
  }

  Future<void> _handleDownload(VaccinationRecord record) async {
    if (record.certificateUrl == null) {
      _showReportMissingSheet(record);
      return;
    }
    // Certificate URLs are supplied only by the production records service.
    // Never expose a non-functional placeholder link to the user.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A certificate is not available for this record yet.')),
    );
  }

  void _showReportMissingSheet(VaccinationRecord record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _ReportMissingSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar: const AppTopBar(title: 'Vaccination Records'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VaccinationRecordsListScreen()),
              ),
              child: Row(
                children: [
                  _IconBadge(
                      icon: Icons.description_outlined, color: palette.primary),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('View / Download Records',
                            style: AppTextStyles.h3),
                        SizedBox(height: 2),
                        Text('Get your vaccination certificate as PDF',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink300),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MissingVaccinationScreen()),
              ),
              child: Row(
                children: [
                  _IconBadge(icon: Icons.flag_outlined, color: palette.primary),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Missing Vaccination', style: AppTextStyles.h3),
                        SizedBox(height: 2),
                        Text('Submit a request for missing records',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink300),
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
