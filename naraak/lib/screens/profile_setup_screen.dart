import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_text_styles.dart';
import '../widgets/naraak_button.dart';
import '../widgets/naraak_app_bar.dart';
import '../widgets/naraak_logo.dart';

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

  String _healthCenterLabel(AppLocalizations strings, String center) {
    switch (center) {
      case 'Hoora Health Center':
        return strings.text('hooraHealthCenter');
      case 'Naim Health Center':
        return strings.text('naimHealthCenter');
      case 'Muharraq Health Center':
        return strings.text('muharraqHealthCenter');
      case 'Bilad Al-Qadeem Health Center':
        return strings.text('biladQadeemHealthCenter');
      case 'Yousif HC (Sitra)':
        return strings.text('yousifHealthCenter');
      default:
        return center;
    }
  }

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
    final apiProfile = provider.profile;
    final profile = UserProfile(
      fullName: _nameController.text.trim(),
      cpr: provider.loggedInCpr ?? '',
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _gender,
      mobileNumber: _mobileController.text.trim(),
      assignedHealthCenter: _healthCenter,
      bloodType: apiProfile?.bloodType,
      nationality: apiProfile?.nationality,
      emergencyContactName: apiProfile?.emergencyContactName,
      emergencyContactPhone: apiProfile?.emergencyContactPhone,
      familyDoctorName: apiProfile?.familyDoctorName,
      familyDoctorSpecialty: apiProfile?.familyDoctorSpecialty,
    );
    provider.completeProfile(profile);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final cpr = context.watch<UserProfileProvider>().loggedInCpr ?? '';
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: NaraakAppBar(title: strings.text('completeYourProfile')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              children: [
                const Center(child: NaraakLogo(size: 88)),
                const SizedBox(height: 18),
                Text(
                  strings.text('tellUsAboutYourself'),
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.text('profileSetupSubtitle'),
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Read-only field — carried over from login, not re-entered.
                TextFormField(
                  initialValue: cpr,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: strings.text('cprFromLogin'),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: strings.text('fullName'),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? strings.text('enterFullName')
                      : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.text('age'),
                          prefixIcon: Icon(Icons.cake_outlined),
                          errorMaxLines: 2,
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n > 120)
                            return strings.text('enterValidAge');
                          if (n < 15) return strings.text('mustBeFifteen');
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: InputDecoration(
                          labelText: strings.text('gender'),
                          prefixIcon: Icon(Icons.people_outline),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: 'Female',
                              child: Text(strings.text('female'))),
                          DropdownMenuItem(
                              value: 'Male', child: Text(strings.text('male'))),
                        ],
                        onChanged: (v) =>
                            setState(() => _gender = v ?? _gender),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: strings.text('mobileNumber'),
                    hintText: '+973 3XXX XXXX',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? strings.text('enterMobileNumber')
                      : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _healthCenter,
                  decoration: InputDecoration(
                    labelText: strings.text('assignedHealthCenter'),
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                  items: _healthCenters
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(_healthCenterLabel(strings, c))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _healthCenter = v ?? _healthCenter),
                ),
                const SizedBox(height: 32),

                NaraakButton(
                  label: strings.text('saveAndContinue'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
