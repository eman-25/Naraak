// lib/screens/services/hajj_certificate_screen.dart
import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/hajj_certificate_provider.dart';
import '../../providers/appointment_provider.dart' show LoadState;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart' show AppButtonVariant;
import '../../widgets/naraak_button.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/progress_stepper.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/service_hero.dart';
import '../../widgets/state_views.dart';

/// Electronic Hajj Certificate â€” Phase 3 Â§3.6/Â§4.5: a read-only check
/// against a doctor visit logged in the MOH DB, not a form the user fills
/// in. "I've requested it from my doctor" self-reports that in-person visit
/// so the request can be tracked through the same Pending Requests
/// lifecycle as every other service (Requested â†’ Processing â†’ Ready â†’
/// Downloaded).
class HajjCertificateScreen extends StatefulWidget {
  const HajjCertificateScreen({super.key});

  @override
  State<HajjCertificateScreen> createState() => _HajjCertificateScreenState();
}

class _HajjCertificateScreenState extends State<HajjCertificateScreen> {
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HajjCertificateProvider>().checkExistingRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NaraakAppBar(title: 'Electronic Hajj Certificate'),
      body: Consumer<HajjCertificateProvider>(
        builder: (context, provider, _) {
          if (provider.initState == LoadState.loading ||
              provider.initState == LoadState.idle) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.initState == LoadState.error) {
            return ErrorState(
              title: 'Error Loading Service',
              message: provider.errorMessage ??
                  'An error occurred while checking existing requests.',
              actionLabel: 'Retry',
              onAction: () => provider.checkExistingRequest(),
            );
          }

          final request = provider.existingRequest;

          return ResponsivePageFrame(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ServiceHero(
                  imageAsset: 'assets/images/Electronic Hajj certificate.jpeg',
                  icon: Icons.mosque_rounded,
                  accent: Color(0xFF0B4F54),
                  title: 'Electronic Hajj Certificate',
                  description:
                      'Download your Hajj health certificate once your pre-travel visit is on file.',
                ),
                const SizedBox(height: 20),
                const _PrerequisiteBanner(),
                const SizedBox(height: 20),
                if (request == null)
                  _NoRequestSection(
                    isSubmitting: provider.isSubmitting,
                    onRequest: () => provider.requestCertificate(),
                  )
                else
                  _StatusSection(
                    status: request.status,
                    downloaded: _downloaded,
                    onDownload: () {
                      setState(() => _downloaded = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Certificate download requires backend connectivity.')),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrerequisiteBanner extends StatelessWidget {
  const _PrerequisiteBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Before downloading your electronic Hajj certificate, you must '
              'first visit your assigned health centre and request it from '
              'your doctor in person.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoRequestSection extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onRequest;
  const _NoRequestSection(
      {required this.isSubmitting, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EmptyState(
          title: 'No download available yet',
          message:
              'You haven\'t requested your certificate from your doctor yet. '
              'Once you have, confirm it below to start tracking it here.',
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NaraakButton(
            label: 'I\'ve Requested It From My Doctor',
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onRequest,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: NaraakButton(
            label: 'Find Nearest Health Center',
            variant: AppButtonVariant.secondary,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .raw('Not available in this demo.'))),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusSection extends StatelessWidget {
  final String status; // 'processing' | 'ready' | 'approved'
  final bool downloaded;
  final VoidCallback onDownload;

  const _StatusSection({
    required this.status,
    required this.downloaded,
    required this.onDownload,
  });

  bool get _isReady => status == 'ready' || status == 'approved';

  /// 0 = Requested, 1 = Processing, 2 = Ready, 3 = Downloaded.
  int get _currentStep {
    if (downloaded) return 3;
    if (_isReady) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).raw('CURRENT REQUEST STATUS'),
            style: AppTextStyles.overline),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                _isReady ? AppColors.successSurface : AppColors.warningSurface,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _isReady ? AppColors.success : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isReady ? 'Ready' : 'Processing',
                style: AppTextStyles.caption.copyWith(
                  color: _isReady ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isReady
              ? 'Your certificate is ready to download.'
              : 'Your certificate request is being reviewed by your doctor.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 24),
        Text(AppLocalizations.of(context).raw('APPLICATION PROGRESS'),
            style: AppTextStyles.overline),
        const SizedBox(height: 14),
        ProgressStepper(
          steps: const ['Requested', 'Processing', 'Ready', 'Downloaded'],
          currentStep: _currentStep,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: NaraakButton(
            label: 'Find my health centre',
            variant: AppButtonVariant.secondary,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .raw('Not available in this demo.'))),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NaraakButton(
            label: 'Download certificate',
            icon: Icons.download_outlined,
            onPressed: _isReady ? onDownload : null,
          ),
        ),
        if (!_isReady) ...[
          const SizedBox(height: 8),
          Text(
            'Available once your request is ready.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.ink500),
          ),
        ],
      ],
    );
  }
}
