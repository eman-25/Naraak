import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

class MammogramScreeningScreen extends StatefulWidget {
  const MammogramScreeningScreen({super.key});

  @override
  State<MammogramScreeningScreen> createState() =>
      _MammogramScreeningScreenState();
}

class _MammogramScreeningScreenState extends State<MammogramScreeningScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedCenter;
  bool _confirmedNoRecentMammogram = false;
  bool _isSubmitted = false;

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

    // Screening criteria: Female, Age >= 40
    final bool isEligibleGender = profile?.gender.toLowerCase() == 'female';
    final bool isEligibleAge = (profile?.age ?? 0) >= 40;
    final bool isEligible = isEligibleGender && isEligibleAge;

    return Scaffold(
      appBar: const AppTopBar(title: 'Mammogram Screening'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              _buildRequestForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildIneligibilityCard(
      dynamic profile, bool isGenderOk, bool isAgeOk) {
    return AppCard(
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

  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: AppCard(
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
              validator: (val) => val == null || val.isEmpty
                  ? 'Please enter contact name'
                  : null,
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
            const Text('Preferred Health Center *',
                style: AppTextStyles.caption),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _selectedCenter,
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
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmedNoRecentMammogram,
              onChanged: (val) =>
                  setState(() => _confirmedNoRecentMammogram = val ?? false),
              title: const Text(
                'I confirm I have not had a mammogram screening in the last 2 years',
                style: AppTextStyles.bodySecondary,
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Submit Request',
                onPressed: _confirmedNoRecentMammogram ? _submitForm : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return AppCard(
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
          AppButton(
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitted = true);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'EK';
  }
}
