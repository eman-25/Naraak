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
import '../../widgets/review_row.dart';
import '../../widgets/step_header.dart';
import '../../widgets/upload_field.dart';

/// Health Fee Exemption Card — Phase 3 flow: eligibility (no open request)
/// -> category -> supporting document -> contact info -> review -> submit
/// -> Pending Requests.
class FeeExemptionScreen extends StatefulWidget {
  const FeeExemptionScreen({super.key});

  @override
  State<FeeExemptionScreen> createState() => _FeeExemptionScreenState();
}

class _FeeExemptionScreenState extends State<FeeExemptionScreen> {
  static const _stepLabels = ['Eligibility', 'Supporting Document', 'Contact', 'Review'];

  int _step = 0;
  String? _category;
  String? _documentName;
  String? _documentError;
  final _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeExemptionProvider>().init();
      final profile = context.read<UserProfileProvider>().profile;
      if (profile != null) _mobileController.text = profile.mobileNumber;
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return _category != null;
      case 1:
        return _documentName != null;
      case 2:
        return _mobileController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _handleAttached(String fileName) {
    setState(() {
      _documentName = fileName;
      _documentError = null;
    });
  }

  void _handleCleared() {
    setState(() {
      _documentName = null;
      _documentError = null;
    });
  }

  void _handleRejected(String message) {
    setState(() {
      _documentName = null;
      _documentError = message;
    });
  }

  Future<void> _handleSubmit() async {
    final confirmed = await showExternalApiNotice(
      context,
      serviceName: 'Health Fee Exemption Card',
      integrationName: 'the Ministry of Health eligibility & RMS systems',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<FeeExemptionProvider>();
    final request = await provider.submit(
      category: _category!,
      documentName: _documentName!,
      mobile: _mobileController.text.trim(),
    );
    if (!mounted) return;

    if (request != null) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Submission failed, please retry.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Fee Exemption Card')),
      body: Consumer<FeeExemptionProvider>(
        builder: (context, provider, _) {
          if (provider.initState == LoadState.idle || provider.initState == LoadState.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
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
              message: 'A fee exemption application is already being processed. '
                  'You can submit a new one once it\'s resolved.',
              actionLabel: 'View Pending Requests',
              onAction: () => Navigator.pushReplacementNamed(context, '/pending-requests'),
            );
          }

          return Column(
            children: [
              StepHeader(currentStep: _step, stepLabels: _stepLabels),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStepContent(provider),
                ),
              ),
              _buildNavBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepContent(FeeExemptionProvider provider) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Which category best describes you?', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Choose the eligibility category you\'re applying under.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            ...provider.categories.map(
              (c) => RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: Text(c, style: AppTextStyles.body),
                value: c,
                groupValue: _category,
                activeColor: AppColors.primaryTeal,
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload a document supporting your "$_category" eligibility (e.g. employment letter, '
              'ID card, or medical assessment).',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            UploadField(
              label: 'Supporting Document',
              fileName: _documentName,
              validate: provider.validateDocument,
              onAttached: _handleAttached,
              onCleared: _handleCleared,
              onRejected: _handleRejected,
            ),
            if (_documentError != null) ...[
              const SizedBox(height: 8),
              Text(_documentError!, style: AppTextStyles.caption.copyWith(color: AppColors.bahrainAccent)),
            ],
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _handleRejected(
                provider.validateDocument('scan.exe') ?? 'This file could not be attached.',
              ),
              icon: const Icon(Icons.error_outline, size: 18, color: AppColors.neutralGray),
              label: Text(
                'See what an invalid file looks like (demo)',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Number', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+973 3XXX XXXX'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll use this number to reach you if additional information is needed.',
              style: AppTextStyles.caption,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review Your Application', style: AppTextStyles.h3),
                  const Divider(height: 24),
                  ReviewRow(label: 'Category', value: _category ?? '—'),
                  ReviewRow(label: 'Document', value: _documentName ?? '—'),
                  ReviewRow(label: 'Contact Number', value: _mobileController.text.trim()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once submitted, this application will appear under Pending Requests until it\'s reviewed.',
              style: AppTextStyles.caption,
            ),
          ],
        );
    }
  }

  Widget _buildNavBar(FeeExemptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: AppButton(
                label: 'Back',
                isSecondary: true,
                onPressed: provider.isSubmitting ? null : () => setState(() => _step -= 1),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: _step == _stepLabels.length - 1 ? 'Submit Application' : 'Next',
              isLoading: provider.isSubmitting,
              onPressed: !_canGoNext
                  ? null
                  : provider.isSubmitting
                      ? null
                      : () {
                          if (_step == _stepLabels.length - 1) {
                            _handleSubmit();
                          } else {
                            setState(() => _step += 1);
                          }
                        },
            ),
          ),
        ],
      ),
    );
  }
}
