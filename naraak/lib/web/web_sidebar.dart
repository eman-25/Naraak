// lib/web/web_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/app_settings_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Fixed left navigation rail for the desktop/web shell — mirrors the
/// reference layout's sidebar (logo, active-profile card, nav links, help
/// link, footer) using our own palette instead of a hardcoded color.
class WebSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  const WebSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.calendar_today_rounded, 'Appointments'),
    (Icons.favorite_rounded, 'Services'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    final ice = palette.primary.withValues(alpha: isDark ? 0.16 : 0.08);

    return Container(
      width: 254,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outline,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 10),
                Text('Naraak',
                    style: AppTextStyles.h3.copyWith(
                        fontSize: 18, color: palette.primaryDark)),
              ],
            ),
          ),
          const SizedBox(height: 34),

          // Active profile card
          InkWell(
            onTap: () => ShellNavigation.of(context)?.pushNamed('/profile/family'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ice,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: palette.primary,
                    child: Text(
                      _initials(profile?.fullName),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(profile?.fullName ?? 'Guest',
                            style: AppTextStyles.caption.copyWith(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                          profile?.cpr != null && profile!.cpr.length >= 4
                              ? 'CPR ending in ${profile.cpr.substring(profile.cpr.length - 4)}'
                              : 'Not verified',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Nav links
          ...List.generate(_items.length, (i) {
            final (icon, label) = _items[i];
            final active = i == currentIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onSelectTab(i),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? ice : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          size: 18,
                          color: active
                              ? palette.primaryDark
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.ink500)),
                      const SizedBox(width: 13),
                      Text(
                        label,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? palette.primaryDark
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.ink500),
                        ),
                      ),
                      if (active) ...[
                        const Spacer(),
                        Container(
                          width: 3,
                          height: 23,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Help + footer
          InkWell(
            onTap: () => ShellNavigation.of(context)?.pushNamed('/profile/help-support'),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.help_outline_rounded,
                      size: 17,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.ink500),
                  const SizedBox(width: 9),
                  Text('Help & support',
                      style: AppTextStyles.caption.copyWith(fontSize: 13)),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.only(top: 16, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkOutline : AppColors.outline,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE1126),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Kingdom of Bahrain', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                const Spacer(),
                Text('2026', style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }
}
