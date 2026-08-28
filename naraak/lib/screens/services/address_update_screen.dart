import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: const AppTopBar(title: 'Update Address'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isSubmitted ? _buildSuccessCard() : _buildFormCard(profile),
      ),
    );
  }

  Widget _buildFormCard(dynamic profile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reference Number', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField('NRK-ADD-2026-441'),
                const SizedBox(height: 16),

                const Text('Requester CPR', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField(profile?.cpr ?? '990422345'),
                const SizedBox(height: 16),

                const Text('Current Block Number',
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField('316 (Hoora)'),
                const SizedBox(height: 16),

                const Text('New Block Number *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedNewBlock,
                  hint: const Text('Select New Block'),
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
            child: AppButton(
              label: 'Confirm Address Update',
              onPressed: _isCprConfirmed ? _submitForm : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          const Text('Address Updated', style: AppTextStyles.h2),
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
            child: AppButton(
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
