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
import '../../widgets/service_hero.dart';
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
              ? currentCenter.doctors.first.name
              : 'Not assigned';
          final requestableDoctors = currentCenter.doctors
              .where((d) => d.name != currentDoctor)
              .toList();

          final canSubmit = _confirmed &&
              _selectedDoctor != null &&
              _reasonController.text.trim().isNotEmpty &&
              !provider.isSubmitting;

          return ResponsivePageFrame(
            maxWidth: 820,
            child: Column(
              children: [
                const ServiceHero(
                  imageAsset: 'assets/images/family_doctor_card.jpeg',
                  title: 'Change Family Doctor',
                  description:
                      'Choose a new family doctor at your health center.',
                ),
                const SizedBox(height: 20),
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
                        Column(
                          children: [
                            for (final doctor in requestableDoctors)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DoctorOptionCard(
                                  doctor: doctor,
                                  healthCenter: currentCenter.name,
                                  selected: _selectedDoctor == doctor.name,
                                  onTap: doctor.capacityAvailable
                                      ? () => setState(
                                          () => _selectedDoctor = doctor.name)
                                      : null,
                                ),
                              ),
                            if (requestableDoctors
                                .every((d) => !d.capacityAvailable))
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  'None of the doctors at this center currently '
                                  'have capacity. Please check back later.',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.warning),
                                ),
                              ),
                          ],
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

/// Phase 3 §29 doctor card: name, gender, specialty, health center,
/// available quota, and a distinct disabled/no-capacity state.
class _DoctorOptionCard extends StatelessWidget {
  final FamilyDoctorOption doctor;
  final String healthCenter;
  final bool selected;
  final VoidCallback? onTap;
  const _DoctorOptionCard({
    required this.doctor,
    required this.healthCenter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unavailable = !doctor.capacityAvailable;

    return Opacity(
      opacity: unavailable ? 0.6 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: selected
                ? AppColors.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? AppColors.darkSurface2 : Colors.white),
            border: Border.all(
              color: selected
                  ? AppColors.primaryTeal
                  : (isDark ? AppColors.darkOutline : AppColors.outline),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.primaryTeal.withValues(alpha: isDark ? 0.24 : 0.12),
                child: Icon(
                  doctor.gender.toLowerCase() == 'female'
                      ? Icons.face_3_rounded
                      : Icons.face_6_rounded,
                  color: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${doctor.specialty} · ${doctor.gender}',
                        style: AppTextStyles.caption),
                    Text(healthCenter, style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    unavailable
                        ? Text(
                            'This doctor currently has no available capacity.',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.warning),
                          )
                        : Text(
                            'Available quota: ${doctor.availableQuota}',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700),
                          ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: selected ? AppColors.primaryTeal : AppColors.ink300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
