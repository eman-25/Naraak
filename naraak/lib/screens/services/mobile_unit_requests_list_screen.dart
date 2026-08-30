import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/service_request_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';

/// My Requests — Phase 3 §27: every mobile unit visit request the patient
/// (or a linked family member) has submitted.
class MobileUnitRequestsListScreen extends StatefulWidget {
  const MobileUnitRequestsListScreen({super.key});

  @override
  State<MobileUnitRequestsListScreen> createState() =>
      _MobileUnitRequestsListScreenState();
}

class _MobileUnitRequestsListScreenState
    extends State<MobileUnitRequestsListScreen> {
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
      appBar: const NaraakAppBar(title: 'My Requests'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: switch (provider.state) {
            LoadState.idle || LoadState.loading =>
              const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorState(
                title: 'Could not load your requests',
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
    final requests = provider.requests
        .where((r) => r.serviceName == 'mobile-unit')
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    if (requests.isEmpty) {
      return const EmptyState(
        title: 'No requests yet',
        message: 'Mobile unit visit requests you submit will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final request = requests[index];
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
                  color: AppColors.secondary.withValues(alpha: isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.airport_shuttle_rounded,
                    color: AppColors.secondary, size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile Unit Visit',
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
