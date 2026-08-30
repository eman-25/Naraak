import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/clinical_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class MedicalReportsListScreen extends StatefulWidget {
  const MedicalReportsListScreen({super.key});
  @override
  State<MedicalReportsListScreen> createState() =>
      _MedicalReportsListScreenState();
}

class _MedicalReportsListScreenState extends State<MedicalReportsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ClinicalDataProvider>().loadReports());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicalDataProvider>();
    return Scaffold(
        appBar: const AppTopBar(title: 'All PHC Reports'),
        body: switch (provider.reportsState) {
          LoadState.idle ||
          LoadState.loading =>
            const Center(child: CircularProgressIndicator()),
          LoadState.error => EmptyStateView(
              isError: true,
              title: 'Could not load reports',
              message: provider.errorMessage ?? 'Please try again.',
              actionLabel: 'Retry',
              onAction: provider.loadReports),
          LoadState.empty => const EmptyStateView(
              icon: Icons.description_outlined,
              title: 'No medical reports',
              message: 'Available reports will appear here.'),
          LoadState.success => ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: provider.reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final report = provider.reports[i];
                final date = MaterialLocalizations.of(context)
                    .formatMediumDate(report.date);
                return AppCard(
                    onTap: report.documentReference == null
                        ? null
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Document: ${report.documentReference}'))),
                    child: Row(children: [
                      Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: AppColors.secondaryIce,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm)),
                          child: const Icon(Icons.description_outlined,
                              color: AppColors.primaryTeal)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(report.reportType, style: AppTextStyles.h3),
                            Text(
                                '${report.category} • $date\n${report.consultantName} • ${report.status}',
                                style: AppTextStyles.caption)
                          ])),
                      if (report.documentReference != null)
                        const Icon(Icons.download_outlined)
                    ]));
              }),
        });
  }
}
