// lib/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _emergencyNameController =
        TextEditingController(text: profile?.emergencyContactName ?? '');
    _emergencyPhoneController =
        TextEditingController(text: profile?.emergencyContactPhone ?? '');
  }

  @override
  void dispose() {
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _save() {
    final provider = context.read<UserProfileProvider>();
    final current = provider.profile;
    if (current == null) return;

    provider.completeProfile(current.copyWith(
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal info updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Personal Details Card
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ReadOnlyRow(
                    label: 'Full Name', value: profile?.fullName ?? '—'),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _ReadOnlyRow(label: 'CPR Number', value: profile?.cpr ?? '—'),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _ReadOnlyRow(
                    label: 'Age',
                    value: profile != null ? '${profile.age}' : '—'),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _ReadOnlyRow(label: 'Gender', value: profile?.gender ?? '—'),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _ReadOnlyRow(
                    label: 'Assigned Health Center',
                    value: profile?.assignedHealthCenter ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Read-Only Medical Details Section
          Text('MEDICAL DETAILS', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Blood Type',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profile?.bloodType ?? 'Not available',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nationality',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      profile?.nationality ?? 'Not available',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.ink050,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Blood type and nationality are verified identity data retrieved through eKey-linked primary government and health databases. They cannot be edited here.',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Editable Other Details Section
          Text('OTHER DETAILS', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency Contact Name', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emergencyNameController,
                  decoration: const InputDecoration(hintText: 'Optional'),
                ),
                const SizedBox(height: 16),
                Text('Emergency Contact Phone', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Optional'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Save Changes',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
