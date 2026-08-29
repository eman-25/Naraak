// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_read_provider.dart';
import '../models/notification_item.dart';
import '../widgets/dashboard/dashboard_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadRequests();
      context.read<AppointmentProvider>().loadMyAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final firstName = (profile?.fullName ?? 'there').split(' ').first;

    return Scaffold(
      appBar: const _MobileTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimatedEntry(
                index: 0, child: WelcomeHeader(firstName: firstName)),
            const SizedBox(height: 14),
            _AnimatedEntry(index: 0, child: const FamilySwitchButton()),
            const SizedBox(height: 26),
            _AnimatedEntry(
              index: 1,
              child: DashboardSectionHeading(
                title: 'Your care team',
                subtitle: 'Your assigned family doctor',
              ),
            ),
            const SizedBox(height: 10),
            _AnimatedEntry(index: 1, child: const DoctorFeatureCard(compact: true)),
            const SizedBox(height: 24),
            _AnimatedEntry(
              index: 2,
              child: DashboardSectionHeading(
                title: 'Next appointment',
                subtitle: 'Your upcoming visit',
              ),
            ),
            const SizedBox(height: 10),
            _AnimatedEntry(index: 2, child: const DashboardNextAppointment()),
            const SizedBox(height: 24),
            _AnimatedEntry(index: 3, child: const DashboardPendingRequestsCard()),
            const SizedBox(height: 24),
            _AnimatedEntry(index: 3, child: const DashboardQuickAccessCard()),
            const SizedBox(height: 28),
            _AnimatedEntry(
              index: 4,
              child: DashboardSectionHeading(
                title: 'Popular services',
                subtitle: 'Start with what you need today',
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedEntry(index: 4, child: const DashboardPopularServicesGrid()),
            const SizedBox(height: 20),
            _AnimatedEntry(index: 5, child: const DashboardPrivacyBanner()),
          ],
        ),
      ),
    );
  }
}

/// Plain (non-gradient) top bar for mobile — compact logo, notification
/// bell, avatar-only profile trigger — matching the reference's mobile
/// `.topbar` (breadcrumb and the standalone accessibility icon are both
/// hidden at that width in the reference CSS; text size / dark mode are
/// still reachable from Profile > App Settings).
class _MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _MobileTopBar();

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

class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 16),
          child: c,
        ),
      ),
      child: child,
    );
  }
}
