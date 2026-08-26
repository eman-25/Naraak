import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

class MobileUnitScreen extends StatefulWidget {
  const MobileUnitScreen({super.key});

  @override
  State<MobileUnitScreen> createState() => _MobileUnitScreenState();
}

class _MobileUnitScreenState extends State<MobileUnitScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBlock;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitted = false;

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
  void dispose() {
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Mobile Unit'),
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
        child: _isSubmitted ? _buildSuccessCard() : _buildRequestForm(profile),
      ),
    );
  }

  Widget _buildRequestForm(dynamic profile) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patient CPR', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                _buildReadOnlyField(profile?.cpr ?? '990422345'),
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

                const Text('Full Residential Address *', style: AppTextStyles.caption),
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

                const Text('Reason for Visit Request *', style: AppTextStyles.caption),
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
            'Your Mobile Unit Visit request (NRK-MOB-2026-441) has been received. Our team will contact you shortly.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Assigned Block: $_selectedBlock'),
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