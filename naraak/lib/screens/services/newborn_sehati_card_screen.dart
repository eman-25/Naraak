import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

/// Newborn Sehati Card — single-screen form matching the approved mockup:
/// Reference Number is auto-filled and read-only; Newborn CPR, Father CPR,
/// Mother CPR, and Block are entered by the user. One Submit action leads
/// to the success confirmation card.
class NewbornSehatiCardScreen extends StatefulWidget {
  const NewbornSehatiCardScreen({super.key});

  @override
  State<NewbornSehatiCardScreen> createState() =>
      _NewbornSehatiCardScreenState();
}

class _NewbornSehatiCardScreenState extends State<NewbornSehatiCardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _newbornCprController = TextEditingController();
  final _fatherCprController = TextEditingController();
  final _motherCprController = TextEditingController();
  final _blockController = TextEditingController();

  bool _isSubmitted = false;

  static const _referenceNumber = 'NRK-NSC-2026-092';

  @override
  void dispose() {
    _newbornCprController.dispose();
    _fatherCprController.dispose();
    _motherCprController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: const AppTopBar(title: 'Newborn Sehati Card'),
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
                _buildReadOnlyField(_referenceNumber),
                const SizedBox(height: 16),
                const Text('Newborn CPR *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _newbornCprController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter the newborn\'s CPR'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Father CPR *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _fatherCprController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter the father\'s CPR'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Mother CPR *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _motherCprController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter the mother\'s CPR'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Block *', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _blockController,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter your residential block'
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Submit',
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
            'Your Newborn Sehati Card application ($_referenceNumber) has been submitted successfully.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Registered Block: ${_blockController.text}'),
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
