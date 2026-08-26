import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_request_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../models/service_request.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

/// Pending Requests — a single aggregated view across every request-based
/// service (Hajj Certificate, Fee Exemption, Mobile Unit, PHC Research,
/// Newborn Sehati Card, Mammogram, Change Doctor), all sharing the
/// requestId/status shape from Phase 5 §3. Resolves the same "where did my
/// request go" visibility gap flagged in Phase 1/3 for individual services,
/// but as one consolidated list instead of hunting through each service.
class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadRequests();
    });
  }

  AppStatus _statusFor(String status) {
    switch (status) {
      case 'approved':
      case 'ready':
        return AppStatus.approved;
      case 'rejected':
        return AppStatus.rejected;
      case 'processing':
        return AppStatus.inProgress;
      case 'submitted':
      default:
        return AppStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Requests')),
      body: Consumer<ServiceRequestProvider>(
        builder: (context, provider, _) {
          switch (provider.state) {
            case LoadState.idle:
            case LoadState.loading:
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
            case LoadState.error:
              return EmptyStateView(
                isError: true,
                title: 'Could not load your requests',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: () => provider.loadRequests(),
              );
            case LoadState.empty:
              return const EmptyStateView(
                icon: Icons.inbox_outlined,
                title: 'No pending requests',
                message: 'Requests you submit for services like the Hajj Certificate\n'
                    'or Fee Exemption Card will appear here with live status.',
              );
            case LoadState.success:
              return RefreshIndicator(
                color: AppColors.primaryTeal,
                onRefresh: () => provider.loadRequests(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.requests.length,
                  itemBuilder: (context, i) {
                    final req = provider.requests[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(child: _RequestRow(request: req, status: _statusFor(req.status))),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final ServiceRequest request;
  final AppStatus status;
  const _RequestRow({required this.request, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(request.serviceName, style: AppTextStyles.h3)),
            StatusBadge(status: status),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Submitted ${_formatDate(request.submittedAt)}',
          style: AppTextStyles.caption,
        ),
        if (request.note != null) ...[
          const SizedBox(height: 4),
          Text(request.note!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'just now';
  }
}