// lib/screens/services/hajj_certificate_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hajj_certificate_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/external_api_notice.dart';
import '../../widgets/review_row.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/step_header.dart';
import '../../widgets/app_top_bar.dart';

class HajjCertificateScreen extends StatefulWidget {
  const HajjCertificateScreen({super.key});

  @override
  State<HajjCertificateScreen> createState() => _HajjCertificateScreenState();
}

class _HajjCertificateScreenState extends State<HajjCertificateScreen> {
  static const _stepLabels = ['Find Your Trip', 'Confirm Details', 'Review'];

  int _step = 0;
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HajjCertificateProvider>().checkExistingRequest();
    });
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _handleLookup(HajjCertificateProvider provider) {
    final year = int.tryParse(_yearController.text.trim());
    if (year == null) return;
    provider.lookupTrip(year);
  }

  Future<void> _handleSubmit(HajjCertificateProvider provider) async {
    final confirmed = await showExternalApiNotice(
      context,
      serviceName: 'Electronic Hajj Certificate',
      integrationName: 'the Ministry of Hajj & Umrah Affairs system',
    );
    if (!confirmed || !mounted) return;

    final request = await provider.submit();
    if (!mounted) return;

    if (request != null) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                provider.errorMessage ?? 'Submission failed, please retry.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Request Submitted'),
        content: const Text(
          'Your Electronic Hajj Certificate request has been submitted. Certificate generation '
          'is tracked under Pending Requests and may take a few business days.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pending-requests');
            },
            child: const Text('View Pending Requests'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Electronic Hajj Certificate'),
      body: Consumer<HajjCertificateProvider>(
        builder: (context, provider, _) {
          if (provider.initState == LoadState.loading ||
              provider.initState == LoadState.idle) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }

          if (provider.initState == LoadState.error) {
            return EmptyStateView(
              isError: true,
              title: 'Error Loading Service',
              message: provider.errorMessage ??
                  'An error occurred while checking existing requests.',
              actionLabel: 'Retry',
              onAction: () => provider.checkExistingRequest(),
            );
          }

          final existing = provider.existingRequest;

          if (existing != null && existing.isCompleted) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: AppColors.success, size: 48),
                        const SizedBox(height: 12),
                        Text('Certificate Already Issued',
                            style: AppTextStyles.h3,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          existing.note ??
                              'Your Electronic Hajj Certificate is ready.',
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const StatusBadge(status: AppStatus.approved),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Download Certificate (Demo)',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Certificate download requires backend connectivity.')),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (existing != null && existing.isOpen) {
            return EmptyStateView(
              icon: Icons.hourglass_top,
              title: 'You already have a pending request',
              message: existing.note ??
                  'Your certificate request is already being processed.',
              actionLabel: 'View Pending Requests',
              onAction: () =>
                  Navigator.pushReplacementNamed(context, '/pending-requests'),
            );
          }

          return Column(
            children: [
              StepHeader(currentStep: _step, stepLabels: _stepLabels),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStepContent(provider),
                ),
              ),
              _buildNavBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepContent(HajjCertificateProvider provider) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hijri Year of Travel',
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 1445'),
                  ),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: 'Look Up',
                  isLoading: provider.lookupState == LoadState.loading,
                  onPressed: provider.lookupState == LoadState.loading
                      ? null
                      : () => _handleLookup(provider),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.lookupState == LoadState.empty)
              const EmptyStateView(
                icon: Icons.search_off,
                title: 'No records found',
                message:
                    'We couldn\'t find a completed Hajj trip on file for that year. '
                    'Verify the year with your registered Hajj operator, or try another year.',
              )
            else if (provider.lookupState == LoadState.success &&
                provider.foundTrip != null)
              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trip found', style: AppTextStyles.h3),
                          Text(provider.foundTrip!.operatorName,
                              style: AppTextStyles.bodySecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case 1:
        final trip = provider.foundTrip;
        if (trip == null) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confirm Trip Details', style: AppTextStyles.h3),
              const Divider(height: 24),
              ReviewRow(label: 'Hijri Year', value: '${trip.hijriYear}'),
              ReviewRow(label: 'Operator', value: trip.operatorName),
              ReviewRow(label: 'Group Number', value: trip.groupNumber),
            ],
          ),
        );
      default:
        final trip = provider.foundTrip;
        if (trip == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review Your Request', style: AppTextStyles.h3),
                  const Divider(height: 24),
                  ReviewRow(label: 'Hijri Year', value: '${trip.hijriYear}'),
                  ReviewRow(label: 'Operator', value: trip.operatorName),
                  ReviewRow(label: 'Group Number', value: trip.groupNumber),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once submitted, certificate generation will appear under Pending Requests.',
              style: AppTextStyles.caption,
            ),
          ],
        );
    }
  }

  Widget _buildNavBar(HajjCertificateProvider provider) {
    final canGoNext = switch (_step) {
      0 =>
        provider.lookupState == LoadState.success && provider.foundTrip != null,
      _ => true,
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: AppButton(
                label: 'Back',
                isSecondary: true,
                onPressed: provider.isSubmitting
                    ? null
                    : () => setState(() => _step -= 1),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label:
                  _step == _stepLabels.length - 1 ? 'Submit Request' : 'Next',
              isLoading: provider.isSubmitting,
              onPressed: !canGoNext
                  ? null
                  : provider.isSubmitting
                      ? null
                      : () {
                          if (_step == _stepLabels.length - 1) {
                            _handleSubmit(provider);
                          } else {
                            setState(() => _step += 1);
                          }
                        },
            ),
          ),
        ],
      ),
    );
  }
}
