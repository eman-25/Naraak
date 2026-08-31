import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../data/naraak_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/form_section.dart';
import '../../widgets/naraak_card.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/progress_stepper.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/service_hero.dart';
import '../../widgets/upload_field.dart';

/// Newborn Sehati Card — Phase 3 §23: Check Eligibility → Newborn
/// Information → Required Documents → Review → Submit → Status.
class NewbornSehatiCardScreen extends StatefulWidget {
  const NewbornSehatiCardScreen({super.key});

  @override
  State<NewbornSehatiCardScreen> createState() =>
      _NewbornSehatiCardScreenState();
}

class _NewbornSehatiCardScreenState extends State<NewbornSehatiCardScreen> {
  int _step = 0; // 0 eligibility, 1 information, 2 documents, 3 review
  bool _isSubmitted = false;
  bool _loadingRegistry = true;

  final _newbornCprController = TextEditingController();
  final _fatherCprController = TextEditingController();
  final _motherCprController = TextEditingController();
  final _blockController = TextEditingController();
  late final TextEditingController _contactController;
  final _notesController = TextEditingController();
  String? _documentName;

  static const _referenceNumber = 'NRK-NSC-2026-092';

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _contactController =
        TextEditingController(text: profile?.mobileNumber ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repository = context.read<NaraakRepository>();
      final response = await repository.api.getDummyNewbornRegistryData(
          guardianPatientId: repository.requirePatientId);
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      if (!mounted) return;
      _newbornCprController.text = data['newbornCpr'] as String;
      _fatherCprController.text = data['fatherCpr'] as String;
      _motherCprController.text = data['motherCpr'] as String;
      _blockController.text = data['residentialBlock'] as String;
      setState(() => _loadingRegistry = false);
    });
  }

  @override
  void dispose() {
    _newbornCprController.dispose();
    _fatherCprController.dispose();
    _motherCprController.dispose();
    _blockController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step -= 1);
  }

  bool get _hasUnsavedChanges => !_isSubmitted && _step > 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmUnsavedChanges(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: NaraakAppBar(
          title: 'Newborn Sehati Card',
          onBack: _isSubmitted ? null : _handleBack,
        ),
        body: ResponsivePageFrame(
          maxWidth: 820,
          child: Column(
            children: [
              if (!_isSubmitted) ...[
                const ServiceHero(
                  imageAsset: 'assets/images/Sehati Card request for newborn.png',
                  icon: Icons.crib_rounded,
                  accent: Color(0xFFC97A93),
                  title: 'Newborn Sehati Card',
                  description:
                      'Register your newborn and request their health card.',
                ),
                const SizedBox(height: 20),
                ProgressStepper(
                  steps: const [
                    'Eligibility',
                    'Information',
                    'Documents',
                    'Review'
                  ],
                  currentStep: _step,
                ),
                const SizedBox(height: 24),
              ],
              _isSubmitted ? _buildSuccessCard() : _buildStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _EligibilityStep(
          loading: _loadingRegistry,
          newbornCpr: _newbornCprController.text,
          onContinue: () => setState(() => _step = 1),
        );
      case 1:
        return _InformationStep(
          newbornCprController: _newbornCprController,
          fatherCprController: _fatherCprController,
          motherCprController: _motherCprController,
          contactController: _contactController,
          notesController: _notesController,
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _DocumentsStep(
          documentName: _documentName,
          onAttached: (name) => setState(() => _documentName = name),
          onCleared: () => setState(() => _documentName = null),
          onNext: () => setState(() => _step = 3),
        );
      default:
        return _ReviewStep(
          newbornCpr: _newbornCprController.text,
          fatherCpr: _fatherCprController.text,
          motherCpr: _motherCprController.text,
          contact: _contactController.text,
          block: _blockController.text,
          notes: _notesController.text,
          documentName: _documentName,
          onBack: () => setState(() => _step = 2),
          onSubmit: _submitForm,
        );
    }
  }

  Widget _buildSuccessCard() {
    return NaraakCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).raw('Request Submitted'),
              style: AppTextStyles.h2),
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
    final repository = context.read<NaraakRepository>();
    try {
      await repository.api.submitNewbornCard(
          patientId: repository.requirePatientId,
          newbornCpr: _newbornCprController.text,
          fatherCpr: _fatherCprController.text,
          motherCpr: _motherCprController.text,
          contactNumber: _contactController.text,
          residentialBlock: _blockController.text);
      if (mounted) setState(() => _isSubmitted = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(repository.friendlyError(error,
                arabic:
                    Localizations.localeOf(context).languageCode == 'ar'))));
      }
    }
  }
}

class _EligibilityStep extends StatelessWidget {
  final bool loading;
  final String newbornCpr;
  final VoidCallback onContinue;
  const _EligibilityStep(
      {required this.loading,
      required this.newbornCpr,
      required this.onContinue});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return FormSection(
      title: 'Check eligibility',
      description: 'We matched a newborn registry record linked to your CPR.',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        AppLocalizations.of(context)
                            .raw('Registry match found'),
                        style: AppTextStyles.body),
                    Text('Newborn CPR: $newbornCpr',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        NaraakButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinue),
      ],
    );
  }
}

class _InformationStep extends StatelessWidget {
  final TextEditingController newbornCprController;
  final TextEditingController fatherCprController;
  final TextEditingController motherCprController;
  final TextEditingController contactController;
  final TextEditingController notesController;
  final VoidCallback onNext;
  const _InformationStep({
    required this.newbornCprController,
    required this.fatherCprController,
    required this.motherCprController,
    required this.contactController,
    required this.notesController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Newborn information',
      description: 'Confirm the family details for this registration.',
      children: [
        Text(AppLocalizations.of(context).raw('Newborn CPR'),
            style: AppTextStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: newbornCprController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).raw('Father CPR'),
            style: AppTextStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: fatherCprController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).raw('Mother CPR'),
            style: AppTextStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: motherCprController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).raw('Contact'),
            style: AppTextStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: contactController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).raw('Notes (optional)'),
            style: AppTextStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 22),
        NaraakButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext),
      ],
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  final String? documentName;
  final ValueChanged<String> onAttached;
  final VoidCallback onCleared;
  final VoidCallback onNext;
  const _DocumentsStep({
    required this.documentName,
    required this.onAttached,
    required this.onCleared,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Required documents',
      description: 'Attach the hospital birth notification if available.',
      children: [
        UploadField(
          label: 'Birth Notification',
          fileName: documentName,
          demoFileName: 'birth_notification.pdf',
          validate: (_) => null,
          onAttached: onAttached,
          onCleared: onCleared,
          onRejected: (_) {},
        ),
        const SizedBox(height: 22),
        NaraakButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String newbornCpr;
  final String fatherCpr;
  final String motherCpr;
  final String contact;
  final String block;
  final String notes;
  final String? documentName;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  const _ReviewStep({
    required this.newbornCpr,
    required this.fatherCpr,
    required this.motherCpr,
    required this.contact,
    required this.block,
    required this.notes,
    required this.documentName,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Review your request',
      description: 'Confirm the details before submitting.',
      children: [
        _ReviewRow(label: 'Newborn CPR', value: newbornCpr),
        _ReviewRow(label: 'Father CPR', value: fatherCpr),
        _ReviewRow(label: 'Mother CPR', value: motherCpr),
        _ReviewRow(label: 'Contact', value: contact),
        _ReviewRow(label: 'Block', value: block),
        _ReviewRow(label: 'Notes', value: notes.isEmpty ? '—' : notes),
        _ReviewRow(label: 'Document', value: documentName ?? 'Not attached'),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: NaraakButton(label: 'Back', onPressed: onBack)),
          const SizedBox(width: 12),
          Expanded(child: NaraakButton(label: 'Submit', onPressed: onSubmit)),
        ]),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 110,
              child: Text(label, style: AppTextStyles.bodySecondary)),
          Expanded(
              child: Text(value,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700))),
        ]),
      );
}
