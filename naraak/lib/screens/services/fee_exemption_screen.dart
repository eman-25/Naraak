// lib/screens/services/fee_exemption_screen.dart
import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_exemption_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/external_api_notice.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/progress_stepper.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/service_hero.dart';
import '../../widgets/upload_field.dart';

class FeeExemptionScreen extends StatefulWidget {
  const FeeExemptionScreen({super.key});

  @override
  State<FeeExemptionScreen> createState() => _FeeExemptionScreenState();
}

class _FeeExemptionScreenState extends State<FeeExemptionScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Phase 3 §26: "Before you begin, please prepare" checklist gates the
  /// form — the user taps Start Application to proceed.
  bool _started = false;

  /// Phase 3 §4.7 / Figure 41: details and uploads are two separate
  /// screens, not one long scroll.
  int _step = 0;

  late String _referenceNumber;
  String? _gender;
  String? _nationality;
  String? _requestType;
  String? _maritalStatus;
  String? _spouseNationality;

  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;

  final List<String> _nationalities = ['Bahraini', 'GCC', 'Other'];
  final List<String> _requestTypes = ['New', 'Renew'];
  final List<String> _maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];

  final Map<String, String?> _uploads = {
    'cprCopy': null,
    'residencePermit': null,
    'marriageCert': null,
    'divorceCert': null,
    'deathCert': null,
    'birthCert': null,
    'medicalReport': null,
  };

  @override
  void initState() {
    super.initState();
    _referenceNumber =
        'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final profile = context.read<UserProfileProvider>().profile;
    _gender = profile?.gender ?? 'Female';
    final storedNationality = profile?.nationality;
    _nationality =
        _nationalities.contains(storedNationality) ? storedNationality : null;
    _contactController =
        TextEditingController(text: profile?.mobileNumber ?? '');
    _emailController = TextEditingController(text: 'f.darraj@example.com');
    _descriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeExemptionProvider>().init();
    });
  }

  @override
  void dispose() {
    _contactController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploads['cprCopy'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .raw('Please upload CPR Copy to proceed.'))),
      );
      return;
    }

    final confirmed = await showExternalApiNotice(
      context,
      serviceName: 'Health Fee Exemption Card',
      integrationName: 'the Ministry of Health eligibility & RMS systems',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<FeeExemptionProvider>();
    final request = await provider.submit(
      category: _requestType ?? 'New',
      documentName: _uploads['cprCopy'] ?? 'cpr_copy.pdf',
      mobile: _contactController.text.trim(),
    );

    if (!mounted) return;

    if (request != null) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                provider.errorMessage ?? 'Submission failed, please retry.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: Text(AppLocalizations.of(context).raw('Application Submitted')),
        content: const Text(
          'Your Health Fee Exemption Card application has been submitted for review. '
          'Track its status under Pending Requests.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pending-requests');
            },
            child:
                Text(AppLocalizations.of(context).raw('View Pending Requests')),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField(String label, String key, String defaultFileName) {
    final provider = context.read<FeeExemptionProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: UploadField(
        label: label,
        fileName: _uploads[key],
        demoFileName: defaultFileName,
        validate: provider.validateDocument,
        onAttached: (name) => setState(() => _uploads[key] = name),
        onCleared: () => setState(() => _uploads[key] = null),
        onRejected: (message) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message))),
      ),
    );
  }

  bool get _hasUnsavedChanges => _started;

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
          title: 'Fee Exemption Card',
          onBack: _step == 1
              ? () => setState(() => _step = 0)
              : (_started ? () => setState(() => _started = false) : null),
        ),
        body: Consumer<FeeExemptionProvider>(
          builder: (context, provider, _) {
            if (provider.initState == LoadState.idle ||
                provider.initState == LoadState.loading) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryTeal));
            }
            if (provider.initState == LoadState.error) {
              return EmptyStateView(
                isError: true,
                title: 'Could not check eligibility',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: () => provider.init(),
              );
            }
            if (provider.hasPendingRequest) {
              return EmptyStateView(
                icon: Icons.hourglass_top,
                title: 'You already have a pending request',
                message:
                    'A fee exemption application is already being processed. '
                    'You can submit a new one once it\'s resolved.',
                actionLabel: 'View Pending Requests',
                onAction: () => Navigator.pushReplacementNamed(
                    context, '/pending-requests'),
              );
            }

            return ResponsivePageFrame(
              maxWidth: 820,
              child: Column(
                children: [
                  const ServiceHero(
                    icon: Icons.shield_rounded,
                    accent: Color(0xFFB45309),
                    title: 'Health Fee Exemption Card',
                    description:
                        'Apply for health fee exemption based on your entitlement.',
                  ),
                  const SizedBox(height: 20),
                  if (!_started)
                    _buildChecklist()
                  else
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ProgressStepper(
                            steps: const ['Eligibility', 'Documents'],
                            currentStep: _step,
                          ),
                          const SizedBox(height: 24),
                          ...(_step == 0
                              ? _buildDetailsStep()
                              : _buildUploadsStep(provider)),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    const items = [
      ('CPR / ID', Icons.badge_outlined),
      ('Income Certificate', Icons.description_outlined),
      ('Family Book (if applicable)', Icons.family_restroom_rounded),
      ('Supporting Documents', Icons.attach_file_rounded),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              AppLocalizations.of(context)
                  .raw('Before you begin, please prepare:'),
              style: AppTextStyles.h3),
          const SizedBox(height: 16),
          for (final (label, icon) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 16, color: AppColors.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: AppTextStyles.body)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Start Application',
            onPressed: () => setState(() => _started = true),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailsStep() {
    return [
      // Form Fields Card
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).raw('Reference Number'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: '$_referenceNumber (auto-filled)',
              enabled: false,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Gender'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _gender,
              items: ['Female', 'Male']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
              decoration: const InputDecoration(hintText: '[Select]'),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Nationality'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _nationality,
              items: _nationalities
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (v) => setState(() => _nationality = v),
              decoration: const InputDecoration(hintText: '[Select]'),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Request Type'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _requestType,
              items: _requestTypes
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _requestType = v),
              decoration: const InputDecoration(hintText: '[New / Renew]'),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Marital Status'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _maritalStatus,
              items: _maritalStatuses
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _maritalStatus = v),
              decoration: const InputDecoration(hintText: '[Select]'),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Spouse Nationality'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _spouseNationality,
              items: _nationalities
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (v) => setState(() => _spouseNationality = v),
              decoration: const InputDecoration(hintText: '[Select]'),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Contact Number'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Email'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).raw('Case Description'),
                style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '[text area]'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      AppButton(
        label: 'Next — Upload Documents',
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setState(() => _step = 1);
          }
        },
      ),
    ];
  }

  List<Widget> _buildUploadsStep(FeeExemptionProvider provider) {
    return [
      // Upload Documents Card
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadField('CPR Copy', 'cprCopy', 'cpr_copy.pdf'),
            _buildUploadField(
                'Residence Permit', 'residencePermit', 'residence_permit.pdf'),
            _buildUploadField('Marriage Certificate (if married/divorced)',
                'marriageCert', 'marriage_cert.pdf'),
            _buildUploadField('Divorce Certificate (if divorced)',
                'divorceCert', 'divorce_cert.pdf'),
            _buildUploadField('Death Certificate (if widowed)', 'deathCert',
                'death_cert.pdf'),
            _buildUploadField('Birth Certificate (if children)', 'birthCert',
                'birth_cert.pdf'),
            _buildUploadField(
                'Medical Report', 'medicalReport', 'medical_report.pdf'),
          ],
        ),
      ),
      const SizedBox(height: 24),

      AppButton(
        label: provider.isSubmitting ? 'Submitting...' : 'Submit',
        isLoading: provider.isSubmitting,
        onPressed: provider.isSubmitting ? null : _handleSubmit,
      ),
    ];
  }
}
