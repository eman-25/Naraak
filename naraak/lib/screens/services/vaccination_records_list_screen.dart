import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vaccination_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../models/vaccination_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_top_bar.dart';

/// View / Download Records — Phase 3 Figure 38's second screen: a list of
/// on-file vaccine records, each opening a detail view with a Download
/// action. Records flagged as expected-but-missing route to a report
/// action instead of a download.
class VaccinationRecordsListScreen extends StatefulWidget {
  const VaccinationRecordsListScreen({super.key});

  @override
  State<VaccinationRecordsListScreen> createState() =>
      _VaccinationRecordsListScreenState();
}

class _VaccinationRecordsListScreenState
    extends State<VaccinationRecordsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaccinationProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Vaccination Records'),
      body: Consumer<VaccinationProvider>(
        builder: (context, provider, _) {
          switch (provider.state) {
            case LoadState.idle:
            case LoadState.loading:
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryTeal));
            case LoadState.error:
              return EmptyStateView(
                isError: true,
                title: 'Could not load records',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: () => provider.loadRecords(),
              );
            case LoadState.empty:
              return const EmptyStateView(
                icon: Icons.vaccines_outlined,
                title: 'No vaccination records found',
                message:
                    'Records for you and linked family members will appear here.',
              );
            case LoadState.success:
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.records.length,
                itemBuilder: (context, i) {
                  final record = provider.records[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VaccinationRecordDetailScreen(record: record),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            record.isFlaggedMissing
                                ? Icons.flag
                                : Icons.vaccines,
                            color: record.isFlaggedMissing
                                ? AppColors.warning
                                : AppColors.primaryTeal,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(record.vaccineName,
                                    style: AppTextStyles.h3),
                                Text(
                                  record.isFlaggedMissing
                                      ? 'Expected but not on file — tap to report'
                                      : '${record.dateAdministered.day}/${record.dateAdministered.month}/${record.dateAdministered.year}',
                                  style: record.isFlaggedMissing
                                      ? AppTextStyles.caption
                                          .copyWith(color: AppColors.warning)
                                      : AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.neutralGray),
                        ],
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}

/// Individual vaccine record detail — Figure 38: dose date, health
/// facility, and a Download PDF action.
class VaccinationRecordDetailScreen extends StatelessWidget {
  final VaccinationRecord record;
  const VaccinationRecordDetailScreen({super.key, required this.record});

  Future<void> _handleDownload(BuildContext context) async {
    final provider = context.read<VaccinationProvider>();
    final url = await provider.getCertificateUrl(record.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(url != null
            ? 'Downloading isn\'t wired up in this demo.'
            : 'Certificate unavailable'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Vaccination Records'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.certificateUrl != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _handleDownload(context),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download PDF'),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                record.vaccineName,
                style: AppTextStyles.h3
                    .copyWith(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: 'Date of Dose',
                    value:
                        '${record.dateAdministered.day}-${record.dateAdministered.month.toString().padLeft(2, '0')}-${record.dateAdministered.year}',
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Health Facility',
                    value: record.healthCenter,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
