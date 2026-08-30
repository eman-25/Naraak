import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vaccination_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../models/vaccination_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';

/// View / Download Records — Phase 3 §15: filter chips (All / Childhood /
/// Adult / Travel) over a list of on-file vaccine records, each opening a
/// detail/certificate view. Records flagged as expected-but-missing route to
/// a report action instead of a download.
class VaccinationRecordsListScreen extends StatefulWidget {
  const VaccinationRecordsListScreen({super.key});

  @override
  State<VaccinationRecordsListScreen> createState() =>
      _VaccinationRecordsListScreenState();
}

const _filters = ['All', 'Childhood', 'Adult', 'Travel'];

class _VaccinationRecordsListScreenState
    extends State<VaccinationRecordsListScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaccinationProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const NaraakAppBar(title: 'Vaccination Records'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Consumer<VaccinationProvider>(
            builder: (context, provider, _) {
              switch (provider.state) {
                case LoadState.idle:
                case LoadState.loading:
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryTeal));
                case LoadState.error:
                  return ErrorState(
                    title: 'Could not load records',
                    message: provider.errorMessage ?? 'Please try again.',
                    actionLabel: 'Retry',
                    onAction: () => provider.loadRecords(),
                  );
                case LoadState.empty:
                  return const EmptyState(
                    title: 'No vaccination records found',
                    message:
                        'Records for you and linked family members will appear here.',
                  );
                case LoadState.success:
                  final filtered = _filter == 'All'
                      ? provider.records
                      : provider.records
                          .where((r) => r.category == _filter)
                          .toList();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                        child: SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final f = _filters[i];
                              final active = f == _filter;
                              return _FilterChip(
                                label: f,
                                active: active,
                                onTap: () => setState(() => _filter = f),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? const EmptyState(
                                title: 'No records in this category',
                                message:
                                    'Try a different filter to see more records.',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _RecordCard(
                                    record: filtered[i],
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryTeal
              : (isDark ? AppColors.darkSurface2 : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active
                ? AppColors.primaryTeal
                : (isDark ? AppColors.darkOutline : AppColors.outline),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.ink700),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final VaccinationRecord record;
  final bool isDark;
  const _RecordCard({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final missing = record.isFlaggedMissing;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VaccinationRecordDetailScreen(record: record),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: missing
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : (isDark ? AppColors.darkOutline : AppColors.outline),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: missing
                        ? [
                            AppColors.warning.withValues(alpha: 0.28),
                            AppColors.warning.withValues(alpha: 0.10),
                          ]
                        : [
                            AppColors.primaryTeal.withValues(alpha: 0.24),
                            AppColors.primaryTeal.withValues(alpha: 0.08),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  missing ? Icons.flag_rounded : Icons.vaccines_rounded,
                  color: missing ? AppColors.warning : AppColors.primaryTeal,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(record.vaccineName,
                              style: AppTextStyles.h3.copyWith(fontSize: 14)),
                        ),
                        missing
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.warning
                                      .withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        size: 13, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    Text('Missing',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              )
                            : const StatusBadge(status: AppStatus.completed),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (record.dose.isNotEmpty) ...[
                      Text(record.dose, style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      missing
                          ? 'Expected but not on file — tap to report'
                          : '${record.dateAdministered.day}/${record.dateAdministered.month}/${record.dateAdministered.year} · ${record.healthCenter}',
                      style: missing
                          ? AppTextStyles.caption
                              .copyWith(color: AppColors.warning)
                          : AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.neutralGray),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vaccination Certificate — Phase 3 §16: patient name, CPR, vaccine, date,
/// certificate reference and a QR/reference area, with a Download PDF
/// action. A flagged-missing record has no certificate to show.
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

  String _maskCpr(String? cpr) {
    if (cpr == null || cpr.length <= 4) return cpr ?? '—';
    return '${cpr.substring(0, 4)}${'*' * (cpr.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    final reference = 'VAC-CERT-${record.id.split('-').last}';

    return Scaffold(
      appBar: const NaraakAppBar(title: 'Vaccination Certificate'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark,
                        AppColors.primaryTeal,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 15, color: Color(0xFFBCE8E4)),
                          const SizedBox(width: 6),
                          Text('VACCINATION CERTIFICATE',
                              style: AppTextStyles.overline.copyWith(
                                  color: const Color(0xFFBCE8E4),
                                  fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        record.vaccineName,
                        style: AppTextStyles.h2
                            .copyWith(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      if (record.dose.isNotEmpty)
                        Text(record.dose,
                            style: AppTextStyles.bodySecondary
                                .copyWith(color: const Color(0xFFCEE5E4))),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkOutline
                            : AppColors.outline),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(label: 'Patient Name', value: profile?.fullName ?? '—'),
                      const Divider(height: 24),
                      _DetailRow(label: 'CPR', value: _maskCpr(profile?.cpr)),
                      const Divider(height: 24),
                      _DetailRow(
                        label: 'Date of Dose',
                        value:
                            '${record.dateAdministered.day}-${record.dateAdministered.month.toString().padLeft(2, '0')}-${record.dateAdministered.year}',
                      ),
                      const Divider(height: 24),
                      _DetailRow(label: 'Health Facility', value: record.healthCenter),
                      const Divider(height: 24),
                      _DetailRow(label: 'Certificate Reference', value: reference),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.ink050,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkOutline
                                : AppColors.outline),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded,
                          size: 52, color: AppColors.neutralGray),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Scan this code at the health center to verify this certificate.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: record.certificateUrl != null
                        ? () => _handleDownload(context)
                        : null,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download PDF'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
