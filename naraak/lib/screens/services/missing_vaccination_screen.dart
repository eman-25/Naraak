import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_profile_provider.dart';
import '../../providers/vaccination_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/form_section.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/progress_stepper.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/state_views.dart';
import '../../widgets/upload_field.dart';

class MissingVaccinationScreen extends StatefulWidget {
  const MissingVaccinationScreen({super.key});
  @override
  State<MissingVaccinationScreen> createState() => _MissingVaccinationScreenState();
}

class _MissingVaccinationScreenState extends State<MissingVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccine = TextEditingController();
  final _comments = TextEditingController();
  late final TextEditingController _contact;
  final _email = TextEditingController();
  String? _fileName;
  bool _reviewing = false;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _contact = TextEditingController(
        text: context.read<UserProfileProvider>().profile?.mobileNumber ?? '');
  }

  @override
  void dispose() {
    _vaccine.dispose();
    _comments.dispose();
    _contact.dispose();
    _email.dispose();
    super.dispose();
  }

  void _review() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attach a supporting document.')),
      );
      return;
    }
    setState(() => _reviewing = true);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final provider = context.read<VaccinationProvider>();
    final success = await provider.reportMissingRecord(
      vaccineName: _vaccine.text.trim().isEmpty ? 'Unspecified vaccine' : _vaccine.text.trim(),
      fakeFileName: _fileName!,
      contactNumber: _contact.text.trim(),
      comments: _comments.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = success;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Submission failed. Please retry.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    return Scaffold(
      appBar: const NaraakAppBar(title: 'Missing Vaccination'),
      body: ResponsivePageFrame(
        maxWidth: 820,
        child: _submitted
            ? SuccessState(
                title: 'Request submitted',
                message: 'Your missing vaccination request was submitted for review. Its status will appear in Pending Requests.',
                actionLabel: 'Done',
                onAction: () => Navigator.pop(context),
              )
            : Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ProgressStepper(
                    steps: const ['Details', 'Review', 'Submitted'],
                    currentStep: _reviewing ? 1 : 0,
                  ),
                  const SizedBox(height: 24),
                  if (!_reviewing)
                    FormSection(
                      title: 'Vaccination details',
                      description: 'Your identity is filled from your Naraak profile.',
                      children: [
                        _ReadOnlyValue(label: 'Full name', value: profile?.fullName ?? 'Not available'),
                        const SizedBox(height: 14),
                        _ReadOnlyValue(label: 'CPR number', value: profile?.cpr ?? 'Not available'),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _vaccine,
                          decoration: const InputDecoration(labelText: 'Vaccine name (if known)', hintText: 'e.g. Hepatitis B — third dose'),
                        ),
                        const SizedBox(height: 14),
                        UploadField(
                          label: 'Supporting document',
                          fileName: _fileName,
                          demoFileName: 'vaccination_proof.pdf',
                          validate: (name) => name.toLowerCase().endsWith('.pdf') ? null : 'Use PDF, JPG, or PNG.',
                          onAttached: (name) => setState(() => _fileName = name),
                          onCleared: () => setState(() => _fileName = null),
                          onRejected: (message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _comments,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Comments (optional)'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _contact,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Contact number'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Enter a contact number' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email (optional)'),
                        ),
                        const SizedBox(height: 22),
                        NaraakButton(label: 'Review Request', icon: Icons.arrow_forward_rounded, onPressed: _review),
                      ],
                    )
                  else
                    FormSection(
                      title: 'Review your request',
                      description: 'Confirm the information before submitting.',
                      children: [
                        _ReviewRow(label: 'Patient', value: profile?.fullName ?? 'Not available'),
                        _ReviewRow(label: 'Vaccine', value: _vaccine.text.trim().isEmpty ? 'Unspecified vaccine' : _vaccine.text.trim()),
                        _ReviewRow(label: 'Document', value: _fileName!),
                        _ReviewRow(label: 'Contact', value: _contact.text.trim()),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(child: NaraakButton(label: 'Back', onPressed: () => setState(() => _reviewing = false))),
                          const SizedBox(width: 12),
                          Expanded(child: NaraakButton(label: 'Submit Request', isLoading: _submitting, onPressed: _submitting ? null : _submit)),
                        ]),
                      ],
                    ),
                ]),
              ),
      ),
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.lock_outline_rounded)),
      );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.bodySecondary)),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))),
        ]),
      );
}
