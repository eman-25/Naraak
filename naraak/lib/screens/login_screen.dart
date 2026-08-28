// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

/// Single-user demo login — SCOPE LIMIT: no real eKey authentication.
/// Enter any CPR number to continue; this is a dummy-data prototype only.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cprController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _cprController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700)); // simulated eKey call

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.read<UserProfileProvider>().login(_cprController.text.trim());
    Navigator.pushReplacementNamed(context, '/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo & Brand ─────────────────────────────
                    _LogoMark(),
                    const SizedBox(height: 24),
                    Text(
                      'Naraak',
                      style: AppTextStyles.display.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Primary Healthcare Portal',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Login Card ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sign in', style: AppTextStyles.h2),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your CPR number to continue',
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 22),

                            Text('CPR NUMBER', style: AppTextStyles.overline),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _cprController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                              decoration: InputDecoration(
                                hintText: '990422345',
                                hintStyle: AppTextStyles.h3.copyWith(
                                  color: AppColors.ink300,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.primary,
                                ),
                                filled: true,
                                fillColor: AppColors.ink050,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: BorderSide(color: AppColors.outline, width: 1.4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: BorderSide(color: AppColors.outline, width: 1.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: const BorderSide(color: AppColors.error, width: 1.6),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter your CPR number to continue';
                                }
                                if (value.trim().length < 9) {
                                  return 'CPR number looks too short';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                            const SizedBox(height: 22),

                            AppButton(
                              label: 'Log in with eKey (Demo)',
                              icon: Icons.fingerprint_rounded,
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Footer note ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: Colors.white.withValues(alpha: 0.85)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'eKey is Bahrain\'s national digital identity system. '
                              'This demo does not perform real authentication.',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the real Naraak logo asset with a soft card backdrop.
/// Falls back to a placeholder mark only if the asset is missing, so the
/// screen never breaks during setup.
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/naraak_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.local_hospital_rounded,
          color: AppColors.primary,
          size: 40,
        ),
      ),
    );
  }
}