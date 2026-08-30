import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/service_request_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/state_views.dart';

/// Visit Schedule — Phase 3 §27: shows the next confirmed mobile unit
/// visit, if the patient has one ready or approved.
class MobileUnitScheduleScreen extends StatefulWidget {
  const MobileUnitScheduleScreen({super.key});

  @override
  State<MobileUnitScheduleScreen> createState() =>
      _MobileUnitScheduleScreenState();
}

class _MobileUnitScheduleScreenState extends State<MobileUnitScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<ServiceRequestProvider>().loadRequests());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceRequestProvider>();

    return Scaffold(
      appBar: const NaraakAppBar(title: 'Visit Schedule'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: switch (provider.state) {
            LoadState.idle || LoadState.loading =>
              const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorState(
                title: 'Could not load your schedule',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: provider.loadRequests,
              ),
            LoadState.empty || LoadState.success => _buildContent(provider),
          },
        ),
      ),
    );
  }

  Widget _buildContent(ServiceRequestProvider provider) {
    final scheduled = provider.requests
        .where((r) =>
            r.serviceName == 'mobile-unit' &&
            (r.status == 'approved' || r.status == 'ready'))
        .toList();

    if (scheduled.isEmpty) {
      return const EmptyState(
        title: 'No scheduled visits',
        message:
            'Once a mobile unit request is approved, the scheduled visit will appear here.',
      );
    }

    final next = scheduled.first;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.successSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    color: AppColors.success),
                const SizedBox(width: 10),
                Text('Visit confirmed',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Reference: ${next.id}', style: AppTextStyles.body),
            const SizedBox(height: 4),
            Text(
              'Our mobile healthcare team will contact you to confirm the '
              'exact visit time before arriving.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
