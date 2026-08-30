import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/service_request_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';

/// My Screenings — Phase 3 §28: the third Mammogram Screening action,
/// listing every mammogram request the patient has submitted so far.
class MammogramScreeningsListScreen extends StatefulWidget {
  const MammogramScreeningsListScreen({super.key});

  @override
  State<MammogramScreeningsListScreen> createState() =>
      _MammogramScreeningsListScreenState();
}

class _MammogramScreeningsListScreenState
    extends State<MammogramScreeningsListScreen> {
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
      appBar: const NaraakAppBar(title: 'My Screenings'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: switch (provider.state) {
            LoadState.idle || LoadState.loading =>
              const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorState(
                title: 'Could not load your screenings',
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
    final screenings =
        provider.requests.where((r) => r.serviceName == 'mammogram').toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    if (screenings.isEmpty) {
      return const EmptyState(
        title: 'No screenings yet',
        message: 'Requests you submit for mammogram screening will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: screenings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final request = screenings[index];
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
                  color: const Color(0xFFB04855).withValues(alpha: isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Color(0xFFB04855), size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mammogram Screening',
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

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
