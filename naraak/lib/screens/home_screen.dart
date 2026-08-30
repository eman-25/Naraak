// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/accessibility_bar.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_read_provider.dart';
import '../models/notification_item.dart';
import '../localization/app_localizations.dart';
import '../main.dart' show ShellNavigation;

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
    final settings = context.watch<AppSettingsProvider>();
    final strings = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(
              name: profile?.fullName,
              strings: strings,
              palette: settings.palette,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _AnimatedEntry(
                  index: 0,
                  child: Text('Family Doctor', style: AppTextStyles.h3),
                ),
                const SizedBox(height: 10),
                _AnimatedEntry(index: 0, child: const _FamilyDoctorCard()),
                const SizedBox(height: 24),
                _AnimatedEntry(
                  index: 1,
                  child: Text('Next Appointment', style: AppTextStyles.h3),
                ),
                const SizedBox(height: 10),
                _AnimatedEntry(index: 1, child: const _NextAppointmentCard()),
                const SizedBox(height: 24),
                _AnimatedEntry(index: 2, child: const _PendingRequestsCard()),
                const SizedBox(height: 24),
                _AnimatedEntry(
                  index: 3,
                  child: Text('Top services', style: AppTextStyles.h3),
                ),
                const SizedBox(height: 10),
                _AnimatedEntry(index: 3, child: const _TopServicesGrid()),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String? name;
  final AppLocalizations strings;
  final dynamic palette;
  const _HeroHeader({
    required this.name,
    required this.strings,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final notifications = buildNotifications(
      context,
      context.watch<AppointmentProvider>().myAppointments,
      context.watch<ServiceRequestProvider>().requests,
    );
    final hasUnread = context
            .watch<NotificationsReadProvider>()
            .unreadCount(notifications.map((n) => n.id)) >
        0;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: palette.heroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/naraak_logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
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
                  PopupMenuButton<String>(
                    tooltip: 'Switch Account',
                    offset: const Offset(0, 48),
                    onSelected: (value) {
                      if (value == 'organize-family') {
                        Navigator.pushNamed(context, '/profile/family');
                      } else {
                        final auth = context.read<AuthProvider>();
                        auth.switchUser(value);
                        context.read<UserProfileProvider>().switchDisplayName(
                              auth.currentUser.name,
                            );
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
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) => Text(
                          auth.currentUser.initials,
                          style: TextStyle(
                            color: palette.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '${strings.text('welcome') == 'Welcome back' ? 'Good Morning' : strings.text('welcome')}, ${name ?? strings.text('guest')}',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 16),
              const AccessibilityBar(),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'FA';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }
}

class _FamilyDoctorCard extends StatelessWidget {
  const _FamilyDoctorCard();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: SizedBox(
        height: 132,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/family_doctor_card.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.ink100),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.68),
                    Colors.black.withValues(alpha: 0.42),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dr. Fatima Al-Doseri',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Consultant · Family Medicine',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile?.assignedHealthCenter ?? 'Naim Health Center',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final appointmentProvider = context.watch<AppointmentProvider>();
    final appointments = appointmentProvider.myAppointments;
    final materialLocalizations = MaterialLocalizations.of(context);

    final upcomingAppointments = appointments
        .where(
          (appointment) =>
              appointment.status == 'confirmed' &&
              appointment.slotDateTime.isAfter(DateTime.now()),
        )
        .toList()
      ..sort(
        (first, second) => first.slotDateTime.compareTo(second.slotDateTime),
      );

    // Empty state if no upcoming appointments exist
    if (upcomingAppointments.isEmpty) {
      return AppCard(
        onTap: () => Navigator.pushNamed(context, '/services/booking'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: palette.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Upcoming Appointments',
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to schedule a new visit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
            ],
          ),
        ),
      );
    }

    // Active appointment details
    final nextAppointment = upcomingAppointments.first;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/appointments'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: palette.heroGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Upcoming Visit',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6FE0A8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      nextAppointment.status,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF9FF0C4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              nextAppointment.doctorName,
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Consultant - Family Medicine',
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            Text(
              nextAppointment.centerName,
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  materialLocalizations.formatMediumDate(
                    nextAppointment.slotDateTime,
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  materialLocalizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(nextAppointment.slotDateTime),
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestsCard extends StatelessWidget {
  const _PendingRequestsCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceRequestProvider>();
    final palette = context.watch<AppSettingsProvider>().palette;
    final requests = provider.requests;

    final hasRequests = requests.isNotEmpty;
    final total = requests.length;
    final needsAttention = requests.where((r) => r.requiresAction).length;
    final inProgress = requests.where((r) => r.isOpen).length;
    final completed = requests.where((r) => r.isCompleted).length;
    final rejected = needsAttention;
    final pendingBase =
        (total - inProgress - completed - rejected).clamp(0, total);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () => Navigator.pushNamed(context, '/pending-requests'),
      // A flat dark card here read as "still not themed" next to the
      // translucent accent-tinted accessibility bar above it — blending
      // the palette accent into the dark surface (rather than a raw alpha
      // overlay, which would just look muddy) gives it the same glassy
      // feel while keeping text contrast solid.
      color: isDark
          ? Color.alphaBlend(
              palette.primary.withValues(alpha: 0.20), AppColors.darkSurface)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pending Requests', style: AppTextStyles.h3),
              const SizedBox(width: 8),
              if (needsAttention > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$needsAttention',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: palette.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasRequests
                          ? '$total active request${total == 1 ? '' : 's'}'
                          : 'No Pending Requests',
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasRequests
                          ? (needsAttention > 0
                              ? '$needsAttention need${needsAttention == 1 ? 's' : ''} your attention'
                              : 'All on track')
                          : 'All clear! Tap to view history',
                      style: AppTextStyles.caption.copyWith(
                        color: needsAttention > 0
                            ? AppColors.error
                            : AppColors.ink500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
            ],
          ),
          if (hasRequests) ...[
            const SizedBox(height: 14),
            _SegmentedBar(
              segments: [
                _Segment(
                  pendingBase == 0 ? 1 : pendingBase,
                  AppColors.warning,
                ),
                _Segment(
                  inProgress == 0 ? 1 : inProgress,
                  AppColors.warning.withValues(alpha: 0.55),
                ),
                _Segment(rejected == 0 ? 1 : rejected, AppColors.error),
                _Segment(completed == 0 ? 1 : completed, AppColors.success),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment {
  final int weight;
  final Color color;
  const _Segment(this.weight, this.color);
}

class _SegmentedBar extends StatelessWidget {
  final List<_Segment> segments;
  const _SegmentedBar({required this.segments});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 6,
        child: Row(
          children: segments
              .map(
                (s) => Expanded(
                  flex: s.weight,
                  child: Container(
                    margin: const EdgeInsets.only(right: 3),
                    color: s.color,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TopServicesGrid extends StatelessWidget {
  const _TopServicesGrid();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    final tiles = [
      _TileData(
        'Book Appointment',
        Icons.event_available_rounded,
        '/services/booking',
        palette.primary,
      ),
      _TileData(
        'Medical Reports',
        Icons.description_rounded,
        '/services/medical-reports',
        AppColors.secondary,
      ),
      _TileData(
        'Vaccinations',
        Icons.vaccines_rounded,
        '/services/vaccinations',
        const Color(0xFF1E9E6B),
      ),
      _TileData(
        'All Services',
        Icons.grid_view_rounded,
        '/services-tab',
        const Color(0xFF7C5CBF),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, i) {
        final t = tiles[i];
        return AppCard(
          onTap: () {
            if (t.route == '/services-tab') {
              ShellNavigation.of(context)?.selectTab(2);
            } else {
              Navigator.pushNamed(context, t.route);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(t.icon, color: t.color, size: 19),
              ),
              const Spacer(),
              Text(
                t.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TileData {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  const _TileData(this.label, this.icon, this.route, this.color);
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
