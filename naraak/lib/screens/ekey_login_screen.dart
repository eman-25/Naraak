import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/clinical_data_provider.dart';
import '../providers/family_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/naraak_button.dart';
import '../widgets/naraak_logo.dart';

class EkeyLoginScreen extends StatefulWidget {
  const EkeyLoginScreen({super.key});

  @override
  State<EkeyLoginScreen> createState() => _EkeyLoginScreenState();
}

class _EkeyLoginScreenState extends State<EkeyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cprController = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _cprController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final profile = context.read<UserProfileProvider>();
    final success = await profile.login(_cprController.text.trim());
    if (!mounted) return;
    if (!success) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profile.errorMessage ?? 'Sign in failed.')),
      );
      return;
    }
    try {
      await Future.wait([
        context.read<AuthProvider>().loadUsers(),
        context.read<FamilyProvider>().loadMembers(),
        context.read<ClinicalDataProvider>().loadNotifications(),
      ]);
    } catch (_) {
      // Individual providers already record a friendly errorMessage and
      // return false/empty state instead of rethrowing — this catch only
      // guards against something unexpected so _loading never gets stuck.
    }
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPaletteExtension.of(context);
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(child: NaraakLogo(size: 112)),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Naraak',
                        style: AppTextStyles.display,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use your CPR number to continue securely.',
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkOutline
                                : AppColors.outline,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color:
                                        AppColors.ink900.withValues(alpha: .07),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: palette.primary
                                          .withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.fingerprint_rounded,
                                        color: palette.primary),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('eKey Authentication',
                                            style: AppTextStyles.h3),
                                        SizedBox(height: 2),
                                        Text('Simulated prototype access',
                                            style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _cprController,
                                focusNode: _focusNode,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(9),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'CPR Number',
                                  hintText: 'Enter your 9-digit CPR',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  final cpr = value?.trim() ?? '';
                                  if (cpr.isEmpty) {
                                    return 'Enter your CPR number';
                                  }
                                  if (cpr.length != 9) {
                                    return 'CPR number must contain 9 digits';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 20),
                              NaraakButton(
                                label: 'Continue with eKey',
                                icon: Icons.arrow_forward_rounded,
                                isLoading: _loading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
