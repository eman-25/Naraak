// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

/// Profile tab — pure content (no Scaffold/AppBar; the shell renders the
/// top bar). Matches the reference: page title, teal identity card, a
/// two-column "Personal health identity" / "Preferences" grid, sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  String _maskCpr(String? cpr) {
    if (cpr == null || cpr.length <= 4) return cpr ?? '—';
    return '${cpr.substring(0, 4)}${'*' * (cpr.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final settings = context.watch<AppSettingsProvider>();
    final palette = settings.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR NARAAK PROFILE',
                style: AppTextStyles.overline.copyWith(color: palette.primary)),
            const SizedBox(height: 6),
            Text('Profile & settings', style: AppTextStyles.h1.copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text('Manage your identity, preferences and family access.',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 18),
            Text('PRIMARY MEDICAL THEME', style: AppTextStyles.overline),
            const SizedBox(height: 10),
            Row(
              children: AppPalette.all
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _ThemeSwatch(
                          palette: p,
                          isActive: settings.paletteId == p.id,
                          onTap: () => settings.setPalette(p.id),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _IdentityCard(
              profile: profile,
              palette: palette,
              initials: _initials(profile?.fullName),
              maskedCpr: _maskCpr(profile?.cpr),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 720;
              final identity = _PersonalHealthIdentityCard(profile: profile);
              final prefs = _PreferencesCard(settings: settings, palette: palette);
              if (!wide) {
                return Column(children: [identity, const SizedBox(height: 16), prefs]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 16),
                  Expanded(child: prefs),
                ],
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.errorSurface,
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  context.read<UserProfileProvider>().logout();
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil('/login', (_) => false);
                },
                child: const Text('Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final dynamic profile;
  final dynamic palette;
  final String initials;
  final String maskedCpr;
  const _IdentityCard({
    required this.profile,
    required this.palette,
    required this.initials,
    required this.maskedCpr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.primaryDark,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 14,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white24,
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              ),
              const SizedBox(width: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(profile?.fullName ?? 'Guest',
                        style: AppTextStyles.h2
                            .copyWith(color: Colors.white, fontSize: 19)),
                    const SizedBox(height: 5),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('CPR: $maskedCpr  ',
                            style: AppTextStyles.caption
                                .copyWith(color: const Color(0xFFC8E2E1))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F4EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  size: 11, color: Color(0xFF1E9E6B)),
                              SizedBox(width: 2),
                              Text('Verified',
                                  style: TextStyle(
                                      color: Color(0xFF1E9E6B),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(profile?.assignedHealthCenter ?? 'No health center set',
                        style: AppTextStyles.caption
                            .copyWith(color: const Color(0xFFC8E2E1))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _PlainMenuRow(
                  label: 'Personal Info & Blood Type',
                  onTap: () =>
                      Navigator.pushNamed(context, '/profile/personal-info'),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _PlainMenuRow(
                  label: 'Privacy & Security',
                  onTap: () =>
                      Navigator.pushNamed(context, '/profile/privacy-security'),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _PlainMenuRow(
                  label: 'Family Members & Dependents',
                  onTap: () => Navigator.pushNamed(context, '/profile/family'),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _PlainMenuRow(
                  label: 'App Settings',
                  onTap: () =>
                      Navigator.pushNamed(context, '/profile/app-settings'),
                _MenuRow(
                  icon: Icons.support_agent_rounded,
                  color: AppColors.warning,
                  label: 'Help & User Inquiries',
                  subtitle: 'FAQs, contact support, general questions',
                  onTap: () => _showHelp(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Service Feedback & Complaints (Separated from support inquiries)
          Text('FEEDBACK & EVALUATION', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.rate_review_rounded,
                  color: const Color(0xFF00897B),
                  label: 'Service Evaluation',
                  subtitle: 'Rate your healthcare experience',
                  onTap: () => _showFeedbackForm(context, isComplaint: false),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _MenuRow(
                  icon: Icons.report_problem_rounded,
                  color: const Color(0xFFE53935),
                  label: 'Submit a Complaint',
                  subtitle: 'Report issues or suggestions for improvement',
                  onTap: () => _showFeedbackForm(context, isComplaint: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalHealthIdentityCard extends StatelessWidget {
  final dynamic profile;
  const _PersonalHealthIdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fields = [
      ('Age', profile != null ? '${profile.age} years' : '—'),
      ('Gender', profile?.gender ?? '—'),
      ('Blood type', profile?.bloodType ?? 'O+'),
      ('Mobile', profile?.mobileNumber ?? '—'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Personal health identity',
                        style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Information used for your care',
                        style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              const Icon(Icons.lock_outline_rounded,
                  size: 17, color: AppColors.ink500),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 18,
            crossAxisSpacing: 16,
            childAspectRatio: 2.6,
            children: fields
                .map((f) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(f.$1, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(f.$2,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & User Inquiries'),
        content: const Text('For appointments, choose Book Appointment from Services. For account or record questions, contact the PHC support team through your registered health center.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showFeedbackForm(BuildContext context, {required bool isComplaint}) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isComplaint ? 'Submit a Complaint' : 'Service Evaluation', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(hintText: isComplaint ? 'Describe the issue and the service involved.' : 'Tell us about the service you received.'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Please enter your feedback before submitting.')));
                  return;
                }
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isComplaint ? 'Your complaint has been submitted for review.' : 'Thank you. Your evaluation has been submitted.')));
              },
              child: const Text('Submit'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final AppSettingsProvider settings;
  final dynamic palette;
  const _PreferencesCard({required this.settings, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Preferences', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Make Naraak work better for you',
                        style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              const Icon(Icons.tune_rounded, size: 17, color: AppColors.ink500),
            ],
          ),
          const SizedBox(height: 4),
          _SettingRow(
            icon: Icons.accessibility_new_rounded,
            title: 'Accessibility',
            detail: 'Text size · Theme color',
            onTap: () => Navigator.pushNamed(context, '/profile/app-settings'),
          ),
          _SettingRow(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Appearance',
            detail: isDark ? 'Dark mode' : 'Light mode',
            trailing: Switch.adaptive(
              value: isDark,
              activeThumbColor: palette.primary,
              onChanged: (_) => settings.toggleTheme(),
            ),
          ),
          _SettingRow(
            icon: Icons.people_alt_rounded,
            title: 'Family management',
            detail: 'Manage linked members',
            onTap: () => Navigator.pushNamed(context, '/profile/family'),
          ),
          _SettingRow(
            icon: Icons.shield_rounded,
            title: 'Privacy & security',
            detail: 'eKey and data permissions',
            onTap: () => Navigator.pushNamed(context, '/profile/privacy-security'),
          ),
          _SettingRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Feedback & support',
            detail: 'We are here to help',
            onTap: () => Navigator.pushNamed(context, '/profile/help-support'),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLast;
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.detail,
    this.onTap,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.watch<AppSettingsProvider>().palette;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color:
                        isDark ? AppColors.darkOutline : AppColors.outline,
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: palette.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(detail, style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.ink300, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppPalette palette;
  final bool isActive;
  final VoidCallback onTap;
  const _ThemeSwatch(
      {required this.palette, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: palette.primary,
          shape: BoxShape.circle,
          border:
              isActive ? Border.all(color: AppColors.ink900, width: 2) : null,
        ),
        child: isActive
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}
