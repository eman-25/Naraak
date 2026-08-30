import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_center_option.dart';
import '../../providers/change_doctor_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/naraak_card.dart';
import '../../widgets/external_api_notice.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/state_views.dart';

/// Change Family Doctor â€” single-screen form matching the approved mockup.
/// Reference Number, Patient CPR, Patient Name, Current Health Center, and
/// Current Family Doctor are all auto-filled and read-only. Only
/// "Requested Family Doctor" (scoped to the other doctors at the patient's
/// current health center) and "Reason for Request" are entered by the
/// user, gated by a confirmation checkbox before Submit.
class ChangeFamilyDoctorScreen extends StatefulWidget {
  const ChangeFamilyDoctorScreen({super.key});

  @override
  State<ChangeFamilyDoctorScreen> createState() =>
      _ChangeFamilyDoctorScreenState();
}

class _ChangeFamilyDoctorScreenState extends State<ChangeFamilyDoctorScreen> {
  static const _referenceNumber = 'NRK-DOC-2026-054';

  String? _selectedDoctor;
  final _reasonController = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeDoctorProvider>().init();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  HealthCenterOption? _findCurrentCenter(
      List<HealthCenterOption> centers, String? currentCenterName) {
    if (currentCenterName == null) return null;
    for (final c in centers) {
      if (c.name == currentCenterName) return c;
    }
    return null;
  }

  Future<void> _handleSubmit(
      HealthCenterOption currentCenter, String currentDoctor) async {
    final confirmed = await showExternalApiNotice(
      context,
      serviceName: 'Change Family Doctor',
      integrationName: 'the MOH Family Doctor Registry',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<ChangeDoctorProvider>();
    final request = await provider.submit(
      currentDoctor: currentDoctor,
      newCenter: currentCenter.name,
      newDoctor: _selectedDoctor!,
      reason: _reasonController.text.trim(),
    );
    if (!mounted) return;

    if (request != null) {
      _showSuccessDialog(currentCenter.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                provider.errorMessage ?? 'Submission failed, please retry.')),
      );
    }
  }

  void _showSuccessDialog(String centerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Request Submitted'),
        content: Text(
          'Your request to transfer to $_selectedDoctor at $centerName has been submitted. '
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
    final currentCenterName = profile?.assignedHealthCenter;

    return Scaffold(
      appBar: const NaraakAppBar(title: 'Change Family Doctor'),
      body: Consumer<ChangeDoctorProvider>(
        builder: (context, provider, _) {
          if (provider.initState == LoadState.idle ||
              provider.initState == LoadState.loading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }
          if (provider.initState == LoadState.error) {
            return ErrorState(
              title: 'Could not check eligibility',
              message: provider.errorMessage ?? 'Please try again.',
              actionLabel: 'Retry',
              onAction: () => provider.init(),
            );
          }
          // Decision point: an open request already exists for this service.
          if (provider.hasPendingRequest) {
            return EmptyState(
              title: 'You already have a pending request',
              message:
                  'A family doctor change request is already being processed. '
                  'You can submit a new one once it\'s resolved.',
              actionLabel: 'View Pending Requests',
              onAction: () =>
                  Navigator.pushReplacementNamed(context, '/pending-requests'),
            );
          }

          final currentCenter =
              _findCurrentCenter(provider.centers, currentCenterName);

          // Decision point: profile's assigned center isn't in the transfer
          // directory (or no center has been set yet).
          if (currentCenter == null) {
            return EmptyState(
              title: 'Health center not found',
              message:
                  'We couldn\'t find your assigned health center in the family doctor directory. '
                  'Please update your profile or contact your health center.',
            );
          }

          final currentDoctor = currentCenter.doctors.isNotEmpty
              ? currentCenter.doctors.first
              : 'Not assigned';
          final requestableDoctors =
              currentCenter.doctors.where((d) => d != currentDoctor).toList();

          final canSubmit = _confirmed &&
              _selectedDoctor != null &&
              _reasonController.text.trim().isNotEmpty &&
              !provider.isSubmitting;

          return ResponsivePageFrame(
            maxWidth: 820,
            child: Column(
              children: [
                NaraakCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reference Number',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      _buildReadOnlyField(_referenceNumber),
                      const SizedBox(height: 16),
                      const Text('Patient CPR', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      _buildReadOnlyField(profile?.cpr ?? 'â€”'),
                      const SizedBox(height: 16),
                      const Text('Patient Name', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      _buildReadOnlyField(profile?.fullName ?? 'â€”'),
                      const SizedBox(height: 16),
                      const Text('Current Health Center',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      _buildReadOnlyField(currentCenter.name),
                      const SizedBox(height: 16),
                      const Text('Current Family Doctor',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      _buildReadOnlyField(currentDoctor),
                      const SizedBox(height: 16),
                      const Text('Requested Family Doctor *',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      if (requestableDoctors.isEmpty)
                        EmptyState(
                          title: 'No other doctors available',
                          message:
                              '${currentCenter.name} has no other family doctors currently accepting transfers.',
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDoctor,
                          hint: const Text('Select doctor'),
                          items: requestableDoctors
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (d) => setState(() => _selectedDoctor = d),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                      const SizedBox(height: 16),
                      const Text('Reason for Request *',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText:
                              'Describe why you\'d like to change your family doctor...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _confirmed,
                        onChanged: (val) =>
                            setState(() => _confirmed = val ?? false),
                        title: const Text(
                          'I confirm the above information is correct.',
                          style: AppTextStyles.bodySecondary,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: NaraakButton(
                    label: 'Submit',
                    isLoading: provider.isSubmitting,
                    onPressed: canSubmit
                        ? () => _handleSubmit(currentCenter, currentDoctor)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryIce,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralGray.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
