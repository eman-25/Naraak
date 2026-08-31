// lib/screens/services/mobile_unit_request_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/family_member.dart';
import '../../providers/family_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../data/naraak_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_card.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/service_hero.dart';

class MobileUnitRequestScreen extends StatefulWidget {
  const MobileUnitRequestScreen({super.key});

  @override
  State<MobileUnitRequestScreen> createState() => _MobileUnitRequestScreenState();
}

class _MobileUnitRequestScreenState extends State<MobileUnitRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBlock;
  String? _selectedCondition;
  String? _selectedPatientId;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  late final TextEditingController _contactController;
  bool _isSubmitted = false;

  final List<String> _patientConditions = [
    'Person with Special Needs',
    'Elderly (60+ years)',
    'Bedridden Patient',
    'Chronic Illness / High Risk',
    'Post-Surgery Recovery',
    'Other Special Condition',
  ];

  final List<String> _areaBlocks = [
    'Block 301 - Manama',
    'Block 302 - Manama',
    'Block 308 - Qudaibiya',
    'Block 318 - Hoora',
    'Block 321 - Juffair',
    'Block 404 - Sanabis',
    'Block 602 - Sitra',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _contactController = TextEditingController(text: profile?.mobileNumber ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _reasonController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges =>
      !_isSubmitted &&
      (_selectedBlock != null ||
          _selectedCondition != null ||
          _addressController.text.isNotEmpty ||
          _reasonController.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final familyMembers = context.watch<FamilyProvider>().members;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmUnsavedChanges(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      appBar: const NaraakAppBar(title: 'Request Mobile Unit'),
      body: ResponsivePageFrame(
        maxWidth: 820,
        child: Column(
          children: [
            if (!_isSubmitted) ...[
              const ServiceHero(
                imageAsset: 'assets/images/Request mobile unit service.jpg',
                icon: Icons.airport_shuttle_rounded,
                accent: Color(0xFF2D6CDF),
                title: 'Mobile Unit Service',
                description: 'Healthcare at your doorstep.',
              ),
              const SizedBox(height: 20),
            ],
            _isSubmitted
                ? _buildSuccessCard()
                : _buildRequestForm(profile, familyMembers),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRequestForm(dynamic profile, List<FamilyMember> familyMembers) {
    // Phase 3 §27: "Allow a verified linked family member to request the
    // service for the patient" — every linked family member is already
    // verified before appearing here (Family Members screen shows a
    // Verified badge for all of them).
    final patientOptions = <({String id, String label})>[
      (
        id: (profile?.cpr as String?) ?? 'self',
        label: '${profile?.fullName ?? 'Me'} (Me)'
      ),
      for (final member in familyMembers.where((m) => !m.isActive))
        (id: member.id, label: '${member.fullName} (${member.relation})'),
    ];
    _selectedPatientId ??= patientOptions.first.id;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          NaraakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patient *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPatientId,
                  items: patientOptions
                      .map((o) => DropdownMenuItem(
                          value: o.id, child: Text(o.label)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedPatientId = val),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Text('Patient CPR', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField(profile?.cpr ?? '990422345'),
                const SizedBox(height: 16),
                const Text('Contact Number *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a contact number'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Patient Condition / Category *',
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  hint: const Text('Select Patient Condition'),
                  items: _patientConditions
                      .map((condition) => DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCondition = val),
                  validator: (val) => val == null
                      ? 'Please select the patient condition'
                      : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Block Number *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedBlock,
                  hint: const Text('Select Area Block'),
                  items: _areaBlocks
                      .map((block) => DropdownMenuItem(
                            value: block,
                            child: Text(block),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBlock = val),
                  validator: (val) =>
                      val == null ? 'Please select a block number' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Full Residential Address *',
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter building, road, and flat details...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter your residential address'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Reason for Visit Request *',
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Please describe the medical symptoms or reasons requiring a mobile unit visit...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please describe the reason for visit'
                      : null,
                ),
              ],
            ),
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
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          const Text('Request Submitted', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Your Mobile Unit Visit request (NRK-MOB-2026-441) has been received. Our team will contact you shortly.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Patient Category: $_selectedCondition'),
          const SizedBox(height: 12),
          _buildReadOnlyField('Assigned Block: $_selectedBlock'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: NaraakButton(
              label: 'Back to Services',
              onPressed: () => Navigator.pop(context),
            ),
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
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repository = context.read<NaraakRepository>();
    try {
      await repository.api.requestMobileUnit(
          patientId: repository.requirePatientId,
          contactNumber: _contactController.text.trim(),
          blockNumber: _selectedBlock!,
          address: _addressController.text,
          reason: '${_selectedCondition ?? ''}: ${_reasonController.text}');
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
