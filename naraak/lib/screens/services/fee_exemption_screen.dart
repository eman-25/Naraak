// lib/screens/services/fee_exemption_screen.dart
import 'package:flutter/material.dart';
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
import '../../widgets/app_top_bar.dart';

class FeeExemptionScreen extends StatefulWidget {
  const FeeExemptionScreen({super.key});

  @override
  State<FeeExemptionScreen> createState() => _FeeExemptionScreenState();
}

class _FeeExemptionScreenState extends State<FeeExemptionScreen> {
  final _formKey = GlobalKey<FormState>();

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
    _nationality = profile?.nationality ?? 'Bahraini';
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

  void _simulateUpload(String key, String defaultFileName) {
    final provider = context.read<FeeExemptionProvider>();
    final err = provider.validateDocument(defaultFileName);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _uploads[key] = defaultFileName);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploads['cprCopy'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload CPR Copy to proceed.')),
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
        title: const Text('Application Submitted'),
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
            child: const Text('View Pending Requests'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField(String label, String key, String defaultFileName) {
    final fileName = _uploads[key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _simulateUpload(key, defaultFileName),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.ink050,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: fileName != null ? AppColors.primary : AppColors.ink500,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fileName ?? '[Tap to upload]',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color:
                        fileName != null ? AppColors.ink900 : AppColors.ink500,
                  ),
                ),
                Icon(
                  fileName != null
                      ? Icons.check_circle_rounded
                      : Icons.add_rounded,
                  color:
                      fileName != null ? AppColors.primary : AppColors.ink500,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('PDF · max 5 MB',
            style: AppTextStyles.caption.copyWith(color: AppColors.ink500)),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Fee Exemption Card'),
      body: Consumer<FeeExemptionProvider>(
        builder: (context, provider, _) {
          if (provider.initState == LoadState.idle ||
              provider.initState == LoadState.loading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal));
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
              onAction: () =>
                  Navigator.pushReplacementNamed(context, '/pending-requests'),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Form Fields Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reference Number', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: '$_referenceNumber (auto-filled)',
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      Text('Gender', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: ['Female', 'Male']
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _gender = v),
                        decoration: const InputDecoration(hintText: '[Select]'),
                      ),
                      const SizedBox(height: 16),
                      Text('Nationality', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _nationality,
                        items: _nationalities
                            .map((n) =>
                                DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged: (v) => setState(() => _nationality = v),
                        decoration: const InputDecoration(hintText: '[Select]'),
                      ),
                      const SizedBox(height: 16),
                      Text('Request Type', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _requestType,
                        items: _requestTypes
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => _requestType = v),
                        decoration:
                            const InputDecoration(hintText: '[New / Renew]'),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Marital Status', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _maritalStatus,
                        items: _maritalStatuses
                            .map((m) =>
                                DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) => setState(() => _maritalStatus = v),
                        decoration: const InputDecoration(hintText: '[Select]'),
                      ),
                      const SizedBox(height: 16),
                      Text('Spouse Nationality', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _spouseNationality,
                        items: _nationalities
                            .map((n) =>
                                DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _spouseNationality = v),
                        decoration: const InputDecoration(hintText: '[Select]'),
                      ),
                      const SizedBox(height: 16),
                      Text('Contact Number', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Email', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      Text('Case Description', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(hintText: '[text area]'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Upload Documents Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUploadField('CPR Copy', 'cprCopy', 'cpr_copy.pdf'),
                      _buildUploadField('Residence Permit', 'residencePermit',
                          'residence_permit.pdf'),
                      _buildUploadField(
                          'Marriage Certificate (if married/divorced)',
                          'marriageCert',
                          'marriage_cert.pdf'),
                      _buildUploadField('Divorce Certificate (if divorced)',
                          'divorceCert', 'divorce_cert.pdf'),
                      _buildUploadField('Death Certificate (if widowed)',
                          'deathCert', 'death_cert.pdf'),
                      _buildUploadField('Birth Certificate (if children)',
                          'birthCert', 'birth_cert.pdf'),
                      _buildUploadField('Medical Report', 'medicalReport',
                          'medical_report.pdf'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: provider.isSubmitting ? 'Submitting...' : 'Submit',
                  isLoading: provider.isSubmitting,
                  onPressed: provider.isSubmitting ? null : _handleSubmit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
