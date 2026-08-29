import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vaccination_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';

/// Missing Vaccination Request — Phase 3 §4.2, Figure 38's third screen:
/// a full form (not a bottom sheet) with auto-filled identity fields, a
/// supporting-document upload, optional comments, and contact details.
class MissingVaccinationScreen extends StatefulWidget {
  const MissingVaccinationScreen({super.key});

  @override
  State<MissingVaccinationScreen> createState() =>
      _MissingVaccinationScreenState();
}

class _MissingVaccinationScreenState extends State<MissingVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vaccineController;
  late TextEditingController _commentsController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  String? _uploadedFileName;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _vaccineController = TextEditingController();
    _commentsController = TextEditingController();
    _contactController =
        TextEditingController(text: profile?.mobileNumber ?? '');
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _vaccineController.dispose();
    _commentsController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a supporting document.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final provider = context.read<VaccinationProvider>();
    final success = await provider.reportMissingRecord(
      vaccineName: _vaccineController.text.trim().isEmpty
          ? 'Unspecified vaccine'
          : _vaccineController.text.trim(),
      fakeFileName: _uploadedFileName!,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Report submitted. We will update your status shortly.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                provider.errorMessage ?? 'Submission failed, please retry.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: const AppTopBar(title: 'Missing Vaccination Request'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  _ReadOnlyField(
                      text: '${profile?.fullName ?? '—'} (auto-filled)'),
                  const SizedBox(height: 16),
                  const Text('Personal Number / CPR',
                      style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  _ReadOnlyField(text: '${profile?.cpr ?? '—'} (auto-filled)'),
                  const SizedBox(height: 16),
                  const Text('Vaccine Name (if known)',
                      style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _vaccineController,
                    decoration: const InputDecoration(
                        hintText: 'e.g. Hepatitis B (3rd dose)'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Supporting Document', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => setState(
                        () => _uploadedFileName = 'vaccination_proof.pdf'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.ink050,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _uploadedFileName != null
                              ? AppColors.primary
                              : AppColors.ink500,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _uploadedFileName ?? '[Tap to upload]',
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: _uploadedFileName != null
                                  ? AppColors.ink900
                                  : AppColors.ink500,
                            ),
                          ),
                          Icon(
                            _uploadedFileName != null
                                ? Icons.check_circle_rounded
                                : Icons.add_rounded,
                            color: _uploadedFileName != null
                                ? AppColors.primary
                                : AppColors.ink500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('PDF or JPG · max 5 MB',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.ink500)),
                  const SizedBox(height: 16),
                  const Text('Comments (optional)', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _commentsController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Contact Number', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Email', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Submit Request',
              isLoading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String text;
  const _ReadOnlyField({required this.text});

  @override
  Widget build(BuildContext context) {
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
}
