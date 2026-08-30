// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';

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

    return Scaffold(
      appBar: const AppTopBar(title: 'Profile', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _initials(profile?.fullName),
                      style: AppTextStyles.h1
                          .copyWith(color: palette.primary, fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(profile?.fullName ?? 'Guest', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  'CPR: ${_maskCpr(profile?.cpr)}'
                  '${profile != null ? ' • ${profile.gender}, Age ${profile.age}' : ''}',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile?.assignedHealthCenter ?? 'No health center set',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded,
                          size: 14, color: palette.primary),
                      const SizedBox(width: 2),
                      Text(
                        'Verified',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Theme / appearance controls, inline per the design reference.
          const Text('PRIMARY MEDICAL THEME', style: AppTextStyles.overline),
          const SizedBox(height: 12),
          Row(
            children: AppPalette.all
                .map((p) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _ThemeSwatch(
                        palette: p,
                        isActive: settings.paletteId == p.id,
                        onTap: () => settings.setPalette(p.id),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Dark Mode',
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      Switch.adaptive(
                        value: settings.themeMode == ThemeMode.dark,
                        activeThumbColor: palette.primary,
                        onChanged: (_) => settings.toggleTheme(),
                      ),
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Language',
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      _LangPill(
                        label: 'EN',
                        selected: !settings.isArabic,
                        onTap: () => settings.setLocale(const Locale('en')),
                      ),
                      const SizedBox(width: 6),
                      _LangPill(
                        label: 'العربية',
                        selected: settings.isArabic,
                        onTap: () => settings.setLocale(const Locale('ar')),
                      ),
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Text Size',
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          const Text('A', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: Slider(
                              value: settings.textScale,
                              min: AppSettingsProvider.minScale,
                              max: AppSettingsProvider.maxScale,
                              activeColor: palette.primary,
                              onChanged: settings.setTextSize,
                            ),
                          ),
                          const Text('A', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                // Escape the shell's nested Navigator (which only knows
                // in-app routes) and clear back to the root '/login'.
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              },
              child: const Text('Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: palette.primary,
          shape: BoxShape.circle,
          border:
              isActive ? Border.all(color: AppColors.ink900, width: 2) : null,
        ),
        child: isActive
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? palette.primary : AppColors.ink050,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.ink700,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _PlainMenuRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PlainMenuRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}
