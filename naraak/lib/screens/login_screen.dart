// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';
import '../providers/clinical_data_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/skyline_background.dart';

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
    final profileProvider = context.read<UserProfileProvider>();
    final success = await profileProvider.login(_cprController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      context
          .read<AppSettingsProvider>()
          .setLocaleFromApiLanguage(profileProvider.preferredLanguage);
    }
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(profileProvider.errorMessage ?? 'Sign in failed.')),
      );
      return;
    }
    await Future.wait([
      context.read<AuthProvider>().loadUsers(),
      context.read<FamilyProvider>().loadMembers(),
      context.read<ClinicalDataProvider>().loadNotifications(),
    ]);
    if (mounted) Navigator.pushReplacementNamed(context, '/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SkylineBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 48),
                    // ── Logo & Brand ─────────────────────────────
                    _LogoMark(),
                    const SizedBox(height: 24),
                    Text(
                      strings.text('appName'),
                      style:
                          AppTextStyles.display.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.text('primaryHealthcarePortal'),
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
                            Text('eKey National Authentication',
                                style: AppTextStyles.h2),
                            const SizedBox(height: 4),
                            Text(
                              'Login securely with your eKey to access Naraak services.',
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 22),
                            Text(strings.text('cprNumber'),
                                style: AppTextStyles.overline),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _cprController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: BorderSide(
                                      color: AppColors.outline, width: 1.4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: BorderSide(
                                      color: AppColors.outline, width: 1.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                  borderSide: const BorderSide(
                                      color: AppColors.error, width: 1.6),
                                ),
                              ),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return strings.text('enterCprNumber');
                                }
                                if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
                                  return strings.text('cprDigitsOnly');
                                }
                                if (trimmed.length < 9) {
                                  return strings.text('cprTooShort');
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                            const SizedBox(height: 22),
                            AppButton(
                              label: strings.text('loginDemo'),
                              icon: Icons.fingerprint_rounded,
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 20),
                            const _AccessibilitySection(),
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
    );
  }
}

class _AccessibilitySection extends StatelessWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final settings = context.watch<AppSettingsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.accessibility_new_rounded,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(strings.text('accessibility'), style: AppTextStyles.h3),
        ]),
        const SizedBox(height: 16),
        Text(strings.text('language'), style: AppTextStyles.overline),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _LanguageButton(
            label: strings.text('english'),
            selected: !settings.isArabic,
            onPressed: () => settings.setLocale(const Locale('en')),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _LanguageButton(
            label: strings.text('arabic'),
            selected: settings.isArabic,
            onPressed: () => settings.setLocale(const Locale('ar')),
          )),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: Text(strings.text('textSize'),
                  style: AppTextStyles.overline)),
          _FontSizeButton(
            label: 'A−',
            tooltip: strings.text('decreaseTextSize'),
            onPressed: settings.textScale > AppSettingsProvider.minScale
                ? settings.decreaseTextSize
                : null,
          ),
          SizedBox(
            width: 58,
            child: Text('${settings.textScalePercent}%',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.ink700, fontWeight: FontWeight.w700)),
          ),
          _FontSizeButton(
            label: 'A+',
            tooltip: strings.text('increaseTextSize'),
            onPressed: settings.textScale < AppSettingsProvider.maxScale
                ? settings.increaseTextSize
                : null,
          ),
        ]),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.white : AppColors.primary,
          backgroundColor: selected ? AppColors.primary : Colors.transparent,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;
  const _FontSizeButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.outlined(
        onPressed: onPressed,
        icon: Text(label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
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
        shape: BoxShape.circle,
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
