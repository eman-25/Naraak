// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import '../widgets/responsive_page_frame.dart';

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
    final strings = AppLocalizations.of(context);
    final profile = context.watch<UserProfileProvider>().profile;
    final settings = context.watch<AppSettingsProvider>();
    final palette = settings.palette;

    return ResponsivePageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.raw('YOUR NARAAK PROFILE'),
              style: AppTextStyles.overline.copyWith(color: palette.primary)),
          const SizedBox(height: 6),
          Text(strings.raw('Profile & settings'),
              style: AppTextStyles.h1.copyWith(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
              strings
                  .raw('Manage your identity, preferences and family access.'),
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 24),
          _IdentityCard(
            profile: profile,
            palette: palette,
            initials: _initials(profile?.fullName),
            maskedCpr: _maskCpr(profile?.cpr),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 720;
            final identity = Column(
              children: [
                _PersonalHealthIdentityCard(profile: profile),
                const SizedBox(height: 16),
                _ThemePaletteCard(settings: settings),
              ],
            );
            final prefs =
                _PreferencesCard(settings: settings, palette: palette);
            if (!wide) {
              return Column(
                  children: [identity, const SizedBox(height: 16), prefs]);
            }
            final columnWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                SizedBox(width: columnWidth, child: identity),
                SizedBox(width: columnWidth, child: prefs),
              ],
            );
          }),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.errorSurface,
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(180, 48),
              ),
              onPressed: () {
                context.read<UserProfileProvider>().logout();
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* Replaced below with a structurally simpler implementation.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;
    final content = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _details(),
              const SizedBox(height: 16),
              _editButton(context),
            ],
          )
        : Row(
            children: [
              Expanded(child: _details()),
              const SizedBox(width: 20),
              _editButton(context),
            ],
          );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            palette.primaryDark.withValues(alpha: isDark ? .88 : .94),
            palette.primary.withValues(alpha: isDark ? .68 : .82),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.primaryDark.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -45,
            top: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          PositionedDirectional(
            start: 180,
            bottom: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;
                final details = Row(
                  children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: Colors.white.withValues(alpha: .16),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile?.fullName ?? 'Guest',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'CPR: $maskedCpr  ',
                          style: AppTextStyles.caption
                              .copyWith(color: const Color(0xFFC8E2E1)),
                        ),
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
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Color(0xFF1E9E6B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.assignedHealthCenter ?? 'No health center set',
                      style: AppTextStyles.caption
                          .copyWith(color: const Color(0xFFC8E2E1)),
                    ),
                  ],
                ),
                      ),
                    ),
                  ],
                );
                final editButton = OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/profile/personal-info'),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.primaryDark,
                backgroundColor: Colors.white.withValues(alpha: .92),
                side: BorderSide(color: Colors.white.withValues(alpha: .7)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                  AppLocalizations.of(context).raw('Edit personal information'),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      details,
                      const SizedBox(height: 16),
                      editButton,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 20),
                    editButton,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.profile,
    required this.palette,
    required this.initials,
    required this.maskedCpr,
  });

  final dynamic profile;
  final dynamic palette;
  final String initials;
  final String maskedCpr;

  Widget _details() {
    return Row(
      children: [
        CircleAvatar(
          radius: 29,
          backgroundColor: Colors.white.withValues(alpha: .16),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile?.fullName ?? 'Guest',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Color(0xFF1E9E6B),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'CPR: $maskedCpr  •  ${profile?.assignedHealthCenter ?? 'No health center set'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFFD8ECEB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () =>
          Navigator.pushNamed(context, '/profile/personal-info'),
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primaryDark,
        backgroundColor: Colors.white.withValues(alpha: .92),
        side: BorderSide(color: Colors.white.withValues(alpha: .7)),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        AppLocalizations.of(context).raw('Edit personal information'),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;
    final Widget content;
    if (compact) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _details(),
          const SizedBox(height: 16),
          _editButton(context),
        ],
      );
    } else {
      content = Row(
        children: [
          Expanded(child: _details()),
          const SizedBox(width: 20),
          _editButton(context),
        ],
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            palette.primaryDark.withValues(alpha: isDark ? .88 : .94),
            palette.primary.withValues(alpha: isDark ? .68 : .82),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.primaryDark.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class _ThemePaletteCard extends StatelessWidget {
  const _ThemePaletteCard({required this.settings});

  final AppSettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.outline,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).raw('PRIMARY MEDICAL THEME'),
              style: AppTextStyles.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text('Applies across Naraak on this device',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppPalette.all
                .map((palette) => _ThemeSwatch(
                      palette: palette,
                      isActive: settings.paletteId == palette.id,
                      onTap: () => settings.setPalette(palette.id),
                    ))
                .toList(),
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
          color: isDark ? AppColors.darkOutline : AppColors.outline,
        ),
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
                    Text(
                      'Personal health identity',
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Information used for your care',
                      style: AppTextStyles.bodySecondary,
                    ),
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
                        Text(f.$1,
                            style:
                                AppTextStyles.caption.copyWith(fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          f.$2,
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ],
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
          color: isDark ? AppColors.darkOutline : AppColors.outline,
        ),
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
                    Text(AppLocalizations.of(context).raw('Preferences'),
                        style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                        AppLocalizations.of(context)
                            .raw('Make Naraak work better for you'),
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
            title: AppLocalizations.of(context).raw('Accessibility'),
            detail: 'Text size · Theme color',
            onTap: () => Navigator.pushNamed(context, '/profile/app-settings'),
          ),
          _SettingRow(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: AppLocalizations.of(context).raw('Appearance'),
            detail: isDark ? 'Dark mode' : 'Light mode',
            trailing: Switch.adaptive(
              value: isDark,
              activeThumbColor: palette.primary,
              onChanged: (_) => settings.toggleTheme(),
            ),
          ),
          _SettingRow(
            icon: Icons.people_alt_rounded,
            title: AppLocalizations.of(context).raw('Family management'),
            detail: 'Manage linked members',
            onTap: () => Navigator.pushNamed(context, '/profile/family'),
          ),
          _SettingRow(
            icon: Icons.shield_rounded,
            title: AppLocalizations.of(context).raw('Privacy & security'),
            detail: 'eKey and data permissions',
            onTap: () =>
                Navigator.pushNamed(context, '/profile/privacy-security'),
          ),
          _SettingRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: AppLocalizations.of(context).raw('Feedback & support'),
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
                    color: isDark ? AppColors.darkOutline : AppColors.outline,
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
                  Text(
                    title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                  ),
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

  const _ThemeSwatch({
    required this.palette,
    required this.isActive,
    required this.onTap,
  });

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
