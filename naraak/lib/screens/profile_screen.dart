// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar: const AppTopBar(title: 'Profile', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                      gradient: palette.heroGradient, shape: BoxShape.circle),
                  child: Center(
                    child: Text(_initials(profile?.fullName),
                        style: AppTextStyles.h1
                            .copyWith(color: Colors.white, fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(profile?.fullName ?? 'Guest', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text('CPR: ${profile?.cpr ?? '—'}',
                    style: AppTextStyles.bodySecondary),
                if (profile?.bloodType != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(30)),
                    child: Text('${profile!.bloodType} · Blood Type',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Account Section
          Text('ACCOUNT', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuRow(
                    icon: Icons.badge_rounded,
                    color: palette.primary,
                    label: 'Personal Info & Blood Type',
                    onTap: () =>
                        Navigator.pushNamed(context, '/profile/personal-info')),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _MenuRow(
                    icon: Icons.edit_location_alt_rounded,
                    color: AppColors.secondary,
                    label: 'Update Residential Address',
                    onTap: () => Navigator.pushNamed(
                        context, '/services/address-update')),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _MenuRow(
                    icon: Icons.family_restroom_rounded,
                    color: const Color(0xFF1E9E6B),
                    label: 'Family Management',
                    onTap: () =>
                        Navigator.pushNamed(context, '/profile/family')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preferences Section
          Text('PREFERENCES', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: _MenuRow(
              icon: Icons.palette_rounded,
              color: const Color(0xFF7C5CBF),
              label: 'Appearance',
              subtitle: 'Theme, dark mode, language, text size',
              onTap: () => Navigator.pushNamed(context, '/profile/appearance'),
            ),
          ),
          const SizedBox(height: 20),

          // Support Section
          Text('SUPPORT', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.shield_rounded,
                  color: AppColors.secondary,
                  label: 'Privacy & Security',
                  onTap: () {},
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _MenuRow(
                  icon: Icons.support_agent_rounded,
                  color: AppColors.warning,
                  label: 'Help & User Inquiries',
                  subtitle: 'FAQs, contact support, general questions',
                  onTap: () {},
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
                  onTap: () =>
                      Navigator.pushNamed(context, '/feedback/evaluate'),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _MenuRow(
                  icon: Icons.report_problem_rounded,
                  color: const Color(0xFFE53935),
                  label: 'Submit a Complaint',
                  subtitle: 'Report issues or suggestions for improvement',
                  onTap: () =>
                      Navigator.pushNamed(context, '/feedback/complaint'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button Card
          AppCard(
            padding: EdgeInsets.zero,
            child: _MenuRow(
              icon: Icons.logout_rounded,
              color: AppColors.error,
              label: 'Log out',
              labelColor: AppColors.error,
              onTap: () {
                context.read<UserProfileProvider>().logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.body.copyWith(
                          color: labelColor, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (labelColor == null)
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}
