import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_center_option.dart';
import '../../providers/change_doctor_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/external_api_notice.dart';
import '../../widgets/review_row.dart';
import '../../widgets/step_header.dart';

/// Change Family Doctor — Phase 3 flow: eligibility (no open request) ->
/// reason -> new center & doctor -> review -> submit -> Pending Requests.
class ChangeFamilyDoctorScreen extends StatefulWidget {
  const ChangeFamilyDoctorScreen({super.key});

  @override
  State<ChangeFamilyDoctorScreen> createState() => _ChangeFamilyDoctorScreenState();
}

class _ChangeFamilyDoctorScreenState extends State<ChangeFamilyDoctorScreen> {
  static const _stepLabels = ['Reason', 'New Center & Doctor', 'Review'];

  int _step = 0;
  String? _reason;
  HealthCenterOption? _selectedCenter;
  String? _selectedDoctor;

  static const _reasons = [
    'Relocation',
    'Doctor unavailable',
    'Personal preference',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeDoctorProvider>().init();
    });
  }

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return _reason != null;
      case 1:
        return _selectedCenter != null && _selectedDoctor != null;
      default:
        return true;
    }
  }

  Future<void> _handleSubmit() async {
    final currentCenter = context.read<UserProfileProvider>().profile?.assignedHealthCenter ?? 'Not set';
    final confirmed = await showExternalApiNotice(
      context,
      serviceName: 'Change Family Doctor',
      integrationName: 'the MOH Family Doctor Registry',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<ChangeDoctorProvider>();
    final request = await provider.submit(
      currentDoctor: currentCenter,
      newCenter: _selectedCenter!.name,
      newDoctor: _selectedDoctor!,
      reason: _reason!,
    );
    if (!mounted) return;

    if (request != null) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Submission failed, please retry.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Request Submitted'),
        content: Text(
          'Your request to transfer to $_selectedDoctor at ${_selectedCenter!.name} has been submitted. '
          'You can track its status under Pending Requests.',
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
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Family Doctor')),
      body: Consumer<ChangeDoctorProvider>(
        builder: (context, provider, _) {
          if (provider.initState == LoadState.idle || provider.initState == LoadState.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }
          if (provider.initState == LoadState.error) {
            return EmptyStateView(
              isError: true,
              title: 'Could not check eligibility',
              message: provider.errorMessage ?? 'Please try again.',
              actionLabel: 'Retry',
              onAction: () => provider.init(),
            );
          }
          // Decision point: an open request already exists for this service.
          if (provider.hasPendingRequest) {
            return EmptyStateView(
              icon: Icons.hourglass_top,
              title: 'You already have a pending request',
              message: 'A family doctor change request is already being processed. '
                  'You can submit a new one once it\'s resolved.',
              actionLabel: 'View Pending Requests',
              onAction: () => Navigator.pushReplacementNamed(context, '/pending-requests'),
            );
          }

          return Column(
            children: [
              StepHeader(currentStep: _step, stepLabels: _stepLabels),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStepContent(provider, profile?.assignedHealthCenter ?? 'Not set'),
                ),
              ),
              _buildNavBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepContent(ChangeDoctorProvider provider, String currentCenter) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.local_hospital, color: AppColors.primaryTeal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Health Center', style: AppTextStyles.caption),
                        Text(currentCenter, style: AppTextStyles.h3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Reason for change', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._reasons.map(
              (r) => RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: Text(r, style: AppTextStyles.body),
                value: r,
                groupValue: _reason,
                activeColor: AppColors.primaryTeal,
                onChanged: (v) => setState(() => _reason = v),
              ),
            ),
          ],
        );
      case 1:
        final centers = provider.centers;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Health Center', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<HealthCenterOption>(
              initialValue: _selectedCenter,
              hint: const Text('Select a health center'),
              items: centers
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) => setState(() {
                _selectedCenter = c;
                _selectedDoctor = null;
              }),
            ),
            const SizedBox(height: 20),
            if (_selectedCenter != null && _selectedCenter!.doctors.isEmpty)
              // Decision point: no doctors available at the selected center.
              EmptyStateView(
                icon: Icons.person_off_outlined,
                title: 'No doctors available',
                message: '${_selectedCenter!.name} isn\'t currently accepting new family doctor transfers. '
                    'Please choose a different center.',
              )
            else if (_selectedCenter != null) ...[
              Text('New Doctor', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDoctor,
                hint: const Text('Select a doctor'),
                items: _selectedCenter!.doctors
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (d) => setState(() => _selectedDoctor = d),
              ),
            ],
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review Your Request', style: AppTextStyles.h3),
                  const Divider(height: 24),
                  ReviewRow(label: 'Current Center', value: currentCenter),
                  ReviewRow(label: 'New Center', value: _selectedCenter?.name ?? '—'),
                  ReviewRow(label: 'New Doctor', value: _selectedDoctor ?? '—'),
                  ReviewRow(label: 'Reason', value: _reason ?? '—'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once submitted, this request will appear under Pending Requests until it\'s reviewed.',
              style: AppTextStyles.caption,
            ),
          ],
        );
    }
  }

  Widget _buildNavBar(ChangeDoctorProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: AppButton(
                label: 'Back',
                isSecondary: true,
                onPressed: provider.isSubmitting ? null : () => setState(() => _step -= 1),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: _step == _stepLabels.length - 1 ? 'Submit Request' : 'Next',
              isLoading: provider.isSubmitting,
              onPressed: !_canGoNext
                  ? null
                  : provider.isSubmitting
                      ? null
                      : () {
                          if (_step == _stepLabels.length - 1) {
                            _handleSubmit();
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
