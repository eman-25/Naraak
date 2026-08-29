// lib/widgets/mobile_top_bar.dart
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

/// Plain (non-gradient) top bar shared by every mobile tab — compact logo,
/// notification bell, avatar-only profile trigger. Mirrors the reference's
/// mobile `.topbar`: it's rendered ONCE by the shell, not per-screen (the
/// reference's page title/breadcrumb lives in each page's own content, not
/// the topbar, which stays identical across all four tabs).
class MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MobileTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = buildNotifications(
      context,
      context.watch<AppointmentProvider>().myAppointments,
      context.watch<ServiceRequestProvider>().requests,
    );
    final hasUnread = context
            .watch<NotificationsReadProvider>()
            .unreadCount(notifications.map((n) => n.id)) >
        0;

    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: (isDark ? AppColors.darkOutline : AppColors.outline)
          .withValues(alpha: 0.6),
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 9),
          Text('Naraak',
              style: AppTextStyles.h3
                  .copyWith(fontSize: 16, color: palette.primaryDark)),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                right: 8,
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
        PopupMenuButton<String>(
          tooltip: 'Switch Account',
          offset: const Offset(0, 48),
          onSelected: (value) {
            if (value == 'organize-family') {
              Navigator.pushNamed(context, '/profile/family');
            } else {
              final auth = context.read<AuthProvider>();
              auth.switchUser(value);
              context
                  .read<UserProfileProvider>()
                  .switchDisplayName(auth.currentUser.name);
            }
          },
          itemBuilder: (context) {
            final auth = context.read<AuthProvider>();
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
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: palette.primary,
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  auth.currentUser.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
