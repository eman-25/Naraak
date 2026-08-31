import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import 'package:provider/provider.dart';
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

class AddressUpdateScreen extends StatefulWidget {
  const AddressUpdateScreen({super.key});

  @override
  State<AddressUpdateScreen> createState() => _AddressUpdateScreenState();
}

class _AddressUpdateScreenState extends State<AddressUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedNewBlock;
  bool _isCprConfirmed = false;
  bool _isSubmitted = false;

  final List<String> _availableBlocks = [
    'Block 301 - Manama',
    'Block 302 - Manama',
    'Block 308 - Qudaibiya',
    'Block 318 - Hoora',
    'Block 321 - Juffair',
    'Block 404 - Sanabis',
    'Block 602 - Sitra',
  ];

  bool get _hasUnsavedChanges =>
      !_isSubmitted && (_selectedNewBlock != null || _isCprConfirmed);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmUnsavedChanges(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: const NaraakAppBar(title: 'Update Address'),
        body: ResponsivePageFrame(
          maxWidth: 820,
          child: Column(
            children: [
              if (!_isSubmitted) ...[
                const ServiceHero(
                  imageAsset: 'assets/images/Update residential address.jpg',
                  title: 'Update Residential Address',
                  description:
                      'Update your block and see your newly assigned health center.',
                ),
                const SizedBox(height: 20),
              ],
              _isSubmitted ? _buildSuccessCard() : _buildFormCard(profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(dynamic profile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          NaraakCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).raw('Reference Number'),
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField('NRK-ADD-2026-441'),
                const SizedBox(height: 16),

                Text(AppLocalizations.of(context).raw('Requester CPR'),
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField(profile?.cpr ?? '990422345'),
                const SizedBox(height: 16),

                Text(AppLocalizations.of(context).raw('Current Block Number'),
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField('316 (Hoora)'),
                const SizedBox(height: 16),

                Text(AppLocalizations.of(context).raw('New Block Number *'),
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedNewBlock,
                  hint: Text(
                      AppLocalizations.of(context).raw('Select New Block')),
                  items: _availableBlocks
                      .map((block) => DropdownMenuItem(
                            value: block,
                            child: Text(block),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedNewBlock = val),
                  validator: (val) =>
                      val == null ? 'Please select a new block number' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Healthcare Info Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryIce,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Your assigned Primary Healthcare Center will be updated automatically based on your new block.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Confirmation Checkbox
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isCprConfirmed,
                  onChanged: (val) =>
                      setState(() => _isCprConfirmed = val ?? false),
                  title: const Text(
                    'I confirm my official address is updated in my CPR.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Update Button
          SizedBox(
            width: double.infinity,
            child: NaraakButton(
              label: 'Confirm Address Update',
              onPressed: _isCprConfirmed ? _submitForm : null,
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
          Text(AppLocalizations.of(context).raw('Address Updated'),
              style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Your residential address update request (NRK-ADD-2026-441) has been processed successfully.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Updated Block: $_selectedNewBlock'),
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
      await repository.api.updateAddress(
          patientId: repository.requirePatientId,
          previousBlock: '316',
          newBlock: _selectedNewBlock!,
          consent: _isCprConfirmed);
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
