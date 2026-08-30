import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/appointment_provider.dart' show LoadState;
import '../models/service_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import 'request_detail_screen.dart';

enum _RequestFilter { all, inProgress, completed, actionNeeded }

/// Pending Requests — pure content (no Scaffold/AppBar; the shell renders
/// the top bar). A single aggregated view across every request-based
/// service, matching the reference's page title + filter tabs + progress
/// tracker card list.
class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  _RequestFilter _filter = _RequestFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadRequests();
    });
  }

  List<ServiceRequest> _applyFilter(List<ServiceRequest> requests) {
    switch (_filter) {
      case _RequestFilter.inProgress:
        return requests.where((r) => r.isOpen).toList();
      case _RequestFilter.completed:
        return requests.where((r) => r.isCompleted).toList();
      case _RequestFilter.actionNeeded:
        return requests.where((r) => r.requiresAction).toList();
      case _RequestFilter.all:
        return requests;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: palette.primary,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text('TRACK PROGRESS',
                style: AppTextStyles.overline.copyWith(color: palette.primary)),
            const SizedBox(height: 6),
            Text('Pending requests', style: AppTextStyles.h1.copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text('See what is happening with your applications.',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 20),
            Consumer<ServiceRequestProvider>(
              builder: (context, provider, _) {
                switch (provider.state) {
                  case LoadState.idle:
                  case LoadState.loading:
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryTeal)),
                    );
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
                      message: 'Requests you submit for services \n'
                          'will appear here.',
                    );
                  case LoadState.success:
                    final all = provider.requests;
                    final filtered = _applyFilter(all);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterTabs(
                          filter: _filter,
                          allCount: all.length,
                          onChanged: (f) => setState(() => _filter = f),
                        ),
                        const SizedBox(height: 16),
                        if (filtered.isEmpty)
                          const EmptyStateView(
                            icon: Icons.filter_alt_off_outlined,
                            title: 'No requests in this filter',
                            message:
                                'Try a different filter, or check back once you\'ve submitted a request.',
                          )
                        else
                          ...filtered.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RequestCard(request: r, palette: palette),
                              )),
                      ],
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _RequestFilter filter;
  final int allCount;
  final ValueChanged<_RequestFilter> onChanged;
  const _FilterTabs(
      {required this.filter, required this.allCount, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      (_RequestFilter.all, 'All', allCount),
      (_RequestFilter.inProgress, 'In progress', null),
      (_RequestFilter.actionNeeded, 'Action needed', null),
      (_RequestFilter.completed, 'Completed', null),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final (value, label, count) = t;
          final active = value == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onChanged(value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? palette.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? palette.primaryDark
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.ink500),
                        )),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                                color: palette.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final dynamic palette;
  const _RequestCard({required this.request, required this.palette});

  int get _stage {
    switch (request.status) {
      case 'submitted':
        return 1;
      case 'processing':
        return 2;
      case 'approved':
      case 'ready':
        return 4;
      case 'rejected':
        return 2;
      default:
        return 1;
    }
  }

  Color get _statusColor {
    switch (request.status) {
      case 'approved':
      case 'ready':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'processing':
        return AppColors.warning;
      default:
        return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case 'approved':
      case 'ready':
        return 'Approved';
      case 'rejected':
        return 'Action Needed';
      case 'processing':
        return 'Processing';
      default:
        return 'Submitted';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = ['Submitted', 'Review', 'Decision', 'Complete'];

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RequestDetailScreen(request: request)),
      ),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.outline),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.description_outlined,
                      color: palette.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(request.serviceName,
                                style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_statusLabel,
                                style: TextStyle(
                                    color: _statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      if (request.note != null) ...[
                        const SizedBox(height: 5),
                        Text(request.note!,
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 5),
                      Text('${request.id} · Submitted ${_formatDate(request.submittedAt)}',
                          style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.ink300, size: 18),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(4, (i) {
                final done = i < _stage;
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: done
                          ? palette.primary
                          : (isDark ? AppColors.darkOutline : const Color(0xFFE3EBEB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map((l) => Text(l,
                      style: AppTextStyles.caption.copyWith(fontSize: 9)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'just now';
  }
}
