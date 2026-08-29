// lib/widgets/app_top_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/notifications_read_provider.dart';
import '../models/notification_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';

/// Standard top bar used across non-home pages to maintain design consistency.
/// Includes Naraak logo, notification icon with unread badge, and profile menu switcher.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteExtension.of(context);
    final screenSize = MediaQuery.of(context).size;
    final iconContainerSize = (screenSize.width * 0.1).clamp(38.0, 48.0);
    final notifications = buildNotifications(
      context,
      context.watch<AppointmentProvider>().myAppointments,
      context.watch<ServiceRequestProvider>().requests,
    );
    final unreadCount = context
        .watch<NotificationsReadProvider>()
        .unreadCount(notifications.map((n) => n.id));
    final hasNotifications = unreadCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Primary Header (Logo, Notifications, Profile)
        Container(
          color: palette.primary,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/naraak_logo.png',
                    height: (screenSize.width * 0.09).clamp(32.0, 42.0),
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(Icons.favorite,
                          color: palette.primary, size: 22),
                    ),
                  ),

                  Row(
                    children: [
                      // Notifications Button
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                        icon: Stack(
                          children: [
                            Container(
                              width: iconContainerSize,
                              height: iconContainerSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            if (hasNotifications)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: AppColors.bahrainAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Profile Switcher Menu
                      PopupMenuButton<String>(
                        tooltip: 'Switch Account',
                        offset: const Offset(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onSelected: (value) {
                          if (value == 'organize-family') {
                            Navigator.pushNamed(context, '/profile/family');
                            return;
                          }
                          final auth = context.read<AuthProvider>();
                          auth.switchUser(value);
                          context.read<UserProfileProvider>().switchDisplayName(
                                auth.currentUser.name,
                              );
                        },
                        itemBuilder: (context) {
                          final auth = context.watch<AuthProvider>();
                          final users = auth.availableUsers;
                          final currentId = auth.currentUser?.id;

                          return [
                            ...users.map((user) {
                              final isSelected = user.id == currentId;
                              return PopupMenuItem<String>(
                                value: user.id,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primarySurface,
                                      child: Text(
                                        user.initials,
                                        style: AppTextStyles.caption.copyWith(
                                          color: palette.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            user.name,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            user.roleLabel,
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: palette.primary,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            }),
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
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final initials = auth.currentUser?.initials ?? 'EK';
                            return Container(
                              width: iconContainerSize,
                              height: iconContainerSize,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: AppTextStyles.label.copyWith(
                                  color: palette.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // External Title Section (Below Top Bar)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              if (showBackButton && Navigator.canPop(context)) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: onBack ?? () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              Text(title, style: AppTextStyles.h2),
            ],
          ),
        ),
      ],
    );
  }
}
