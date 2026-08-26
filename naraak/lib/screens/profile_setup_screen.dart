import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';

/// Shown once after login — collects the fields the rest of the app
/// displays (Home dashboard, Profile tab). Kept separate from login so
/// it's obvious which fields are "real" entered data vs. demo content
/// still hardcoded elsewhere.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();

  String _gender = 'Female';
  String _healthCenter = 'Hoora Health Center';

  static const _healthCenters = [
    'Hoora Health Center',
    'Naim Health Center',
    'Muharraq Health Center',
    'Bilad Al-Qadeem Health Center',
    'Yousif HC (Sitra)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProfileProvider>();
    final profile = UserProfile(
      fullName: _nameController.text.trim(),
      cpr: provider.loggedInCpr ?? '',
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _gender,
      mobileNumber: _mobileController.text.trim(),
      assignedHealthCenter: _healthCenter,
    );
    provider.completeProfile(profile);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final cpr = context.watch<UserProfileProvider>().loggedInCpr ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'A few details to personalize your dashboard. This data stays on '
              'your device for this demo session only.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),

            // Read-only field — carried over from login, not re-entered.
            TextFormField(
              initialValue: cpr,
              enabled: false,
              decoration:
                  const InputDecoration(labelText: 'CPR Number (from login)'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0 || n > 120)
                        return 'Enter a valid age';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? _gender),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: '+973 3XXX XXXX',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter your mobile number'
                  : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _healthCenter,
              decoration:
                  const InputDecoration(labelText: 'Assigned Health Center'),
              items: _healthCenters
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _healthCenter = v ?? _healthCenter),
            ),
            const SizedBox(height: 32),

            AppButton(label: 'Save & Continue', onPressed: _handleSave),
          ],
        ),
      ),
    );
  }
}
