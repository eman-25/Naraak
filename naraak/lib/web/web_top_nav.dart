// lib/web/web_top_nav.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_item.dart';
import '../providers/app_settings_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_read_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Desktop/web top navigation bar — replaces the mobile bottom nav bar once
/// the viewport crosses [kWebBreakpoint]. Built on Flutter's own [AppBar]
/// (via `title`/`actions`) rather than a fully custom [PreferredSizeWidget]
/// — a bespoke widget dropped straight into `Scaffold.appBar` was getting
/// loose (shrink-wrap) width constraints instead of the screen width, which
/// silently squashed everything after the logo down to zero width.
/// `NavigationToolbar` (which backs the real `AppBar`) doesn't have that
/// problem, so building on top of it sidesteps the issue entirely.
class WebTopNav extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onBookAppointment;

  const WebTopNav({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.onBookAppointment,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  static const _tabs = ['Home', 'Appointments', 'Services', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    final notifications = buildNotifications(
      context,
      context.watch<AppointmentProvider>().myAppointments,
      context.watch<ServiceRequestProvider>().requests,
    );
    final hasUnread = context
            .watch<NotificationsReadProvider>()
            .unreadCount(notifications.map((n) => n.id)) >
        0;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.ink900;

    return AppBar(
      toolbarHeight: 76,
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: (isDark ? AppColors.darkOutline : AppColors.outline)
          .withValues(alpha: 0.6),
      titleSpacing: 32,
      title: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/naraak_logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 18,
                backgroundColor: palette.primary,
                child: const Icon(Icons.favorite,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Naraak',
              style: AppTextStyles.h3.copyWith(fontSize: 19, color: textColor)),
          const SizedBox(width: 48),
          ...List.generate(_tabs.length, (i) {
            final active = i == currentIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onSelectTab(i),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: active
                        ? palette.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                  ),
                  child: Text(
                    _tabs[i],
                    style: AppTextStyles.body.copyWith(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? palette.primary : textColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: onBookAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
            // The app-wide button theme sets minimumSize to
            // Size.fromHeight(52) — width: double.infinity — for full-width
            // form buttons. That's fatal here: AppBar.actions lays its
            // children out with intrinsic-width sizing, and a button
            // demanding infinite minimum width breaks that silently in
            // release builds (the whole toolbar renders blank, no error).
            // Pin a finite minimum size to opt back into normal sizing.
            minimumSize: const Size(64, 44),
          ),
          icon: const Icon(Icons.event_available_rounded, size: 18),
          label: const Text('Book Appointment'),
        ),
        const SizedBox(width: 20),
        IconButton(
          tooltip: 'Notifications',
          color: textColor,
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded),
              if (hasUnread)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: 'Switch Account',
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          onSelected: (value) {
            if (value == 'organize-family') {
              Navigator.pushNamed(context, '/profile/family');
              return;
            }
            final auth = context.read<AuthProvider>();
            auth.switchUser(value);
            context
                .read<UserProfileProvider>()
                .switchDisplayName(auth.currentUser.name);
          },
          itemBuilder: (context) {
            final auth = context.watch<AuthProvider>();
            return [
              ...auth.availableUsers.map(
                (user) => PopupMenuItem<String>(
                  value: user.id,
                  child: Text('${user.name} (${user.roleLabel})'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'organize-family',
                child: Row(
                  children: [
                    Icon(Icons.family_restroom_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Organize Family Members'),
                  ],
                ),
              ),
            ];
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: palette.primary.withValues(alpha: 0.14),
            child: Text(
              _initials(profile?.fullName),
              style: AppTextStyles.caption.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
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
