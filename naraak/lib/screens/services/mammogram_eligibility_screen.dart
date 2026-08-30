import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../data/naraak_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_card.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/service_hero.dart';

/// Mammogram Screening â€” Phase 3 Â§4.9: age/gender eligibility gate, then a
/// real branching question (tested in the last 2 years?) with its own stop
/// state, not a single self-attest checkbox.
class MammogramEligibilityScreen extends StatefulWidget {
  const MammogramEligibilityScreen({super.key});

  @override
  State<MammogramEligibilityScreen> createState() =>
      _MammogramEligibilityScreenState();
}

class _MammogramEligibilityScreenState extends State<MammogramEligibilityScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedCenter;
  bool? _testedRecently;
  bool _isSubmitted = false;
  bool? _apiEligible;

  final List<String> _healthCenters = [
    'Naim Health Center',
    'Hoora Health Center',
    'Bilad Al Qadeem Health Center',
    'Juffair Health Center',
    'Sitra Health Center',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.mobileNumber ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repository = context.read<NaraakRepository>();
      try {
        final response = await repository.api
            .checkMammogramEligibility(patientId: repository.requirePatientId);
        final data =
            Map<String, dynamic>.from(repository.data(response) as Map);
        if (mounted) setState(() => _apiEligible = data['eligible'] as bool);
      } catch (_) {
        if (mounted) setState(() => _apiEligible = false);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    final bool isEligibleGender = profile?.gender.toLowerCase() == 'female';
    final bool isEligibleAge = (profile?.age ?? 0) >= 40;
    final bool isEligible = _apiEligible ?? false;

    return Scaffold(
      appBar: const NaraakAppBar(title: 'Mammogram Screening'),
      body: _apiEligible == null
          ? const Center(child: CircularProgressIndicator())
          : ResponsivePageFrame(
        maxWidth: 820,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ServiceHero(
              imageAsset: 'assets/images/service_mammogram.jpg',
              title: 'Mammogram Screening',
              description:
                  'Early detection saves lives. Check your eligibility and book your screening.',
              accent: Color(0xFFB04855),
            ),
            const SizedBox(height: 20),
            // Informational Notice Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryIce,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.primaryTeal, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline,
                      color: AppColors.primaryTeal, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This service is available for women above the required age (40+) who have not had a mammogram in the last 2 years.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (!isEligible)
              _buildIneligibilityCard(profile, isEligibleGender, isEligibleAge)
            else if (_isSubmitted)
              _buildSuccessCard()
            else
              _buildEligibilityQuestion(),
          ],
        ),
      ),
    );
  }

  Widget _buildIneligibilityCard(
      dynamic profile, bool isGenderOk, bool isAgeOk) {
    return NaraakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reference Number', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          _buildReadOnlyField('NRK-MAM-2026-102'),
          const SizedBox(height: 16),
          const Text('Date of Birth / Age', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          _buildReadOnlyField('${profile?.age ?? 0} Years Old'),
          const SizedBox(height: 16),
          const Text('Age Eligibility Status', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bahrainAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel, color: AppColors.bahrainAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    !isGenderOk
                        ? 'Service restricted to female patients.'
                        : 'Patients must be 40 years or older to qualify.',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.bahrainAccent,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Branching question: tested in the last 2 years? ---
  Widget _buildEligibilityQuestion() {
    return NaraakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Have you had a mammogram test in the last 2 years?',
              style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _YesNoPill(
                  label: 'Yes',
                  selected: _testedRecently == true,
                  onTap: () => setState(() => _testedRecently = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _YesNoPill(
                  label: 'No',
                  selected: _testedRecently == false,
                  onTap: () => setState(() => _testedRecently = false),
                ),
              ),
            ],
          ),
          if (_testedRecently == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bahrainAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.bahrainAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not eligible yet â€” too soon since your last mammogram.',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.bahrainAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_testedRecently == false) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildRequestForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reference Number', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          _buildReadOnlyField('NRK-MAM-2026-102'),
          const SizedBox(height: 16),
          const Text('Contact Name *', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (val) =>
                val == null || val.isEmpty ? 'Please enter contact name' : null,
          ),
          const SizedBox(height: 16),
          const Text('Contact Number *', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (val) => val == null || val.isEmpty
                ? 'Please enter contact number'
                : null,
          ),
          const SizedBox(height: 16),
          const Text('Preferred Health Center *', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _selectedCenter,
            hint: const Text('Select Health Center'),
            items: _healthCenters
                .map((center) =>
                    DropdownMenuItem(value: center, child: Text(center)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCenter = val),
            validator: (val) =>
                val == null ? 'Please select a health center' : null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: NaraakButton(
              label: 'Submit Request',
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return NaraakCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 60, color: AppColors.success),
          const SizedBox(height: 12),
          const Text('Request Submitted', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Your mammogram screening appointment request (NRK-MAM-2026-102) has been submitted successfully.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          NaraakButton(
            label: 'Back to Services',
            onPressed: () => Navigator.pop(context),
          ),
        ],
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

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repository = context.read<NaraakRepository>();
    try {
      await repository.api.requestMammogram(
          patientId: repository.requirePatientId,
          contactNumber: _phoneController.text);
      if (mounted) setState(() => _isSubmitted = true);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(repository.friendlyError(error,
                arabic:
                    Localizations.localeOf(context).languageCode == 'ar'))));
    }
  }
}

class _YesNoPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _YesNoPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTeal : AppColors.secondaryIce,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primaryTeal
                : AppColors.neutralGray.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected ? Colors.white : AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
