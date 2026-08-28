import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';

class _ServiceMeta {
  final String category;
  final String? resubmitRoute;
  const _ServiceMeta(this.category, this.resubmitRoute);
}

const _serviceMeta = <String, _ServiceMeta>{
  'Change Family Doctor':
      _ServiceMeta('Administrative', '/services/change-doctor'),
  'Health Fee Exemption Card':
      _ServiceMeta('Administrative', '/services/fee-exemption'),
  'Electronic Hajj Certificate':
      _ServiceMeta('My Records', '/services/hajj-certificate'),
};

/// Request Detail — Phase 3 §2.7 / Figure 33: tapping a Pending Requests
/// card routes to one of three read-outs depending on status. This is the
/// only place a submitted request's full detail (what's missing, or its
/// outcome) can be reviewed.
class RequestDetailScreen extends StatelessWidget {
  final ServiceRequest request;
  const RequestDetailScreen({super.key, required this.request});

  _ServiceMeta get _meta =>
      _serviceMeta[request.serviceName] ?? const _ServiceMeta('General', null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Request Detail'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusPill(status: request.status),
          const SizedBox(height: 14),
          Text(request.serviceName, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            '${_meta.category} · Submitted ${_formatDate(request.submittedAt)}',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          if (request.requiresAction)
            _ActionNeededSection(
                request: request, resubmitRoute: _meta.resubmitRoute)
          else if (request.isCompleted)
            _CompletedSection(request: request)
          else
            _UnderReviewSection(request: request),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  ({Color color, String label}) get _config {
    switch (status) {
      case 'approved':
      case 'ready':
        return (color: AppColors.success, label: 'Completed');
      case 'rejected':
        return (color: AppColors.error, label: 'Action Needed');
      case 'processing':
        return (color: AppColors.warning, label: 'Processing');
      case 'submitted':
      default:
        return (color: AppColors.warning, label: 'Under Review');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        c.label,
        style: AppTextStyles.caption
            .copyWith(color: c.color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActionNeededSection extends StatelessWidget {
  final ServiceRequest request;
  final String? resubmitRoute;
  const _ActionNeededSection(
      {required this.request, required this.resubmitRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.errorSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What\'s missing',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.error, fontSize: 15)),
              const SizedBox(height: 6),
              Text(
                request.note ??
                    'Additional documents are required. Please resubmit with the missing information.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Resubmit',
            onPressed: resubmitRoute == null
                ? null
                : () => Navigator.pushNamed(context, resubmitRoute!),
          ),
        ),
        if (resubmitRoute != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text('You\'ll be taken back to the document upload step.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.neutralGray)),
          ),
        ],
      ],
    );
  }
}

class _UnderReviewSection extends StatelessWidget {
  final ServiceRequest request;
  const _UnderReviewSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
              label: 'Status',
              value: request.status == 'processing'
                  ? 'Processing'
                  : 'Under Review'),
          const Divider(height: 24),
          _DetailRow(
              label: 'Submitted',
              value: RequestDetailScreen._formatDate(request.submittedAt)),
          if (request.note != null) ...[
            const Divider(height: 24),
            _DetailRow(label: 'Notes', value: request.note!),
          ],
          const SizedBox(height: 8),
          Text(
            'Read-only — no editable fields while a request is being reviewed.',
            style: AppTextStyles.caption.copyWith(color: AppColors.neutralGray),
          ),
        ],
      ),
    );
  }
}

class _CompletedSection extends StatelessWidget {
  final ServiceRequest request;
  const _CompletedSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                  label: 'Status',
                  value: request.status == 'ready' ? 'Ready' : 'Approved'),
              const Divider(height: 24),
              _DetailRow(
                  label: 'Completed on',
                  value: RequestDetailScreen._formatDate(request.submittedAt)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'View / Download Record',
            icon: Icons.download_outlined,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Downloading isn\'t wired up in this demo.')),
            ),
          ),
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: AppTextStyles.bodySecondary),
        ),
        Expanded(
          child: Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
