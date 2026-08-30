// lib/web/web_mini_topbar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clinical_data_provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/app_settings_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Slim top bar that sits above the page content, to the right of
/// [WebSidebar] — breadcrumb on the left, accessibility/notifications/
/// profile-trigger on the right, matching the reference's `.topbar`.
class WebMiniTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageLabel;

  const WebMiniTopBar({super.key, required this.pageLabel});

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    final hasUnread = context.watch<ClinicalDataProvider>().unreadCount > 0;

    return AppBar(
      toolbarHeight: 78,
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: (isDark ? AppColors.darkOutline : AppColors.outline)
          .withValues(alpha: 0.6),
      titleSpacing: 40,
      title: Row(
        children: [
          Text('Naraak',
              style: AppTextStyles.caption.copyWith(
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.ink500)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded,
              size: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.ink500),
          const SizedBox(width: 6),
          Text(pageLabel,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
      actions: [
        _IconAction(
          icon: Icons.accessibility_new_rounded,
          tooltip: 'Accessibility',
          onTap: () =>
              ShellNavigation.of(context)?.pushNamed('/profile/app-settings'),
        ),
        const SizedBox(width: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _IconAction(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              onTap: () =>
                  ShellNavigation.of(context)?.pushNamed('/notifications'),
            ),
            if (hasUnread)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () =>
              ShellNavigation.of(context)?.pushNamed('/profile/personal-info'),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: palette.primary,
                  child: Text(
                    _initials(profile?.fullName),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text((profile?.fullName ?? 'Guest').split(' ').first,
                    style: AppTextStyles.body
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 15),
              ],
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
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

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.outline,
            ),
          ),
          child: Icon(icon,
              size: 19,
              color: isDark ? AppColors.darkTextSecondary : AppColors.ink500),
        ),
      ),
    );
  }
}
