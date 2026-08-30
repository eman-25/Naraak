import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/service_request_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';

/// My Applications — Phase 3 §30: every PHC research application the
/// applicant has submitted so far.
class PhcResearchApplicationsListScreen extends StatefulWidget {
  const PhcResearchApplicationsListScreen({super.key});

  @override
  State<PhcResearchApplicationsListScreen> createState() =>
      _PhcResearchApplicationsListScreenState();
}

class _PhcResearchApplicationsListScreenState
    extends State<PhcResearchApplicationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<ServiceRequestProvider>().loadRequests());
  }

  AppStatus _statusFor(String status) => switch (status) {
        'approved' || 'ready' => AppStatus.approved,
        'rejected' => AppStatus.rejected,
        'processing' => AppStatus.inProgress,
        _ => AppStatus.pending,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceRequestProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const NaraakAppBar(title: 'My Applications'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: switch (provider.state) {
            LoadState.idle || LoadState.loading =>
              const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorState(
                title: 'Could not load your applications',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: provider.loadRequests,
              ),
            LoadState.empty || LoadState.success => _buildList(provider, isDark),
          },
        ),
      ),
    );
  }

  Widget _buildList(ServiceRequestProvider provider, bool isDark) {
    final applications = provider.requests
        .where((r) => r.serviceName == 'research-application')
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    if (applications.isEmpty) {
      return const EmptyState(
        title: 'No applications yet',
        message: 'Research applications you submit will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final request = applications[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            border: Border.all(
                color: isDark ? AppColors.darkOutline : AppColors.outline),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FE0).withValues(alpha: isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.biotech_rounded,
                    color: Color(0xFF7C6FE0), size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Research Application',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      '${request.id} · Submitted ${_formatDate(request.submittedAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: _statusFor(request.status)),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
