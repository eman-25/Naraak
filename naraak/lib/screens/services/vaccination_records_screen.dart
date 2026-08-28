import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vaccination_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../models/vaccination_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_top_bar.dart';

/// Vaccination Records & Certificate — Phase 3 §3.2, Higher Priority.
/// Flags expected-but-missing records; lets the user download a certificate
/// or report a missing record with a (simulated) file upload.
class VaccinationRecordsScreen extends StatefulWidget {
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
    final provider = context.read<VaccinationProvider>();
    if (record.certificateUrl == null) {
      _showReportMissingSheet(record);
      return;
    }
    final url = await provider.getCertificateUrl(record.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(url != null
              ? 'Certificate ready: $url (demo link)'
              : 'Certificate unavailable')),
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
                      onTap: () => _handleDownload(record),
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
                          Icon(
                            record.certificateUrl != null
                                ? Icons.download
                                : Icons.chevron_right,
                            color: AppColors.neutralGray,
                          ),
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

class _ReportMissingSheet extends StatefulWidget {
  final VaccinationRecord record;
  const _ReportMissingSheet({required this.record});

  @override
  State<_ReportMissingSheet> createState() => _ReportMissingSheetState();
}

class _ReportMissingSheetState extends State<_ReportMissingSheet> {
  bool _submitting = false;
  String? _errorText;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    final provider = context.read<VaccinationProvider>();
    // Simulated fake file — demonstrates the validation branch from Phase 3.
    final success = await provider.reportMissingRecord(
      vaccineName: widget.record.vaccineName,
      fakeFileName: 'supporting_doc.pdf',
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Report submitted. We will update your status shortly.')),
      );
    } else {
      setState(
          () => _errorText = provider.errorMessage ?? 'Submission failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report Missing Record', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(widget.record.vaccineName, style: AppTextStyles.body),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {}, // simulated file picker for the demo
            icon: const Icon(Icons.attach_file),
            label: const Text('Attach supporting document (demo)'),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(_errorText!,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.bahrainAccent)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
