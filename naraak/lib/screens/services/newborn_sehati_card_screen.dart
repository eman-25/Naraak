import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

class NewbornSehatiCardScreen extends StatefulWidget {
  const NewbornSehatiCardScreen({super.key});

  @override
  State<NewbornSehatiCardScreen> createState() => _NewbornSehatiCardScreenState();
}

class _NewbornSehatiCardScreenState extends State<NewbornSehatiCardScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBlock;
  bool _isSubmitted = false;

  final List<String> _residentialBlocks = [
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
      appBar: AppBar(
        title: const Text('Newborn Sehati Card'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                _getInitials(profile?.fullName ?? 'EK'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isSubmitted ? _buildSuccessCard() : _buildRequestForm(),
      ),
    );
  }

  Widget _buildRequestForm() {
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
                _buildReadOnlyField('NRK-NSC-2026-092'),
                const SizedBox(height: 16),

                const Text('Block Number *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedBlock,
                  hint: const Text('Select Residential Block'),
                  items: _residentialBlocks
                      .map((block) => DropdownMenuItem(
                            value: block,
                            child: Text(block),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBlock = val),
                  validator: (val) =>
                      val == null ? 'Please select a residential block' : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Informational Note Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryIce,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'i ',
                        style: TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Note: Newborn information will be auto-verified and fetched directly from the national birth registry.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Submit Request',
              onPressed: _submitForm,
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
          const Text('Request Submitted', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Your Newborn Sehati Card application (NRK-NSC-2026-092) has been submitted successfully.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Registered Block: $_selectedBlock'),
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