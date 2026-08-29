// lib/web/web_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../models/appointment.dart';
import '../providers/app_settings_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Desktop dashboard home — mirrors the reference design's sidebar-layout
/// home page (welcome row, doctor-feature card, pending-requests card,
/// quick-access grid, popular services, privacy banner), built with our
/// own palette/providers instead of the reference's hardcoded teal + mock
/// state so it reacts correctly to whichever accent color and theme
/// (light/dark) the user has selected.
class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
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
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = (profile?.fullName ?? 'there').split(' ').first;
    final ice = palette.primary.withValues(alpha: isDark ? 0.16 : 0.08);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeRow(firstName: firstName, palette: palette),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 155,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(
                        title: 'Your care team',
                        subtitle: 'Your assigned family doctor',
                        actionLabel: 'View profile',
                        onAction: () =>
                            ShellNavigation.of(context)?.selectTab(3),
                      ),
                      const SizedBox(height: 12),
                      _DoctorFeatureCard(profile: profile, palette: palette),
                      const SizedBox(height: 22),
                      _SectionHeading(
                        title: 'Next appointment',
                        subtitle: 'Your upcoming visit',
                        actionLabel: 'All appointments',
                        onAction: () =>
                            ShellNavigation.of(context)?.selectTab(1),
                      ),
                      const SizedBox(height: 12),
                      const _NextAppointment(),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  flex: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 34),
                      _PendingRequestsCard(palette: palette),
                      const SizedBox(height: 15),
                      _QuickAccessCard(palette: palette, ice: ice),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            _SectionHeading(
              title: 'Popular services',
              subtitle: 'Start with what you need today',
              actionLabel: 'See all services',
              onAction: () => ShellNavigation.of(context)?.selectTab(2),
            ),
            const SizedBox(height: 14),
            const _PopularServicesGrid(),
            const SizedBox(height: 22),
            _InfoBanner(palette: palette, ice: ice),
          ],
        ),
      ),
    );
  }
}

class _WelcomeRow extends StatelessWidget {
  final String firstName;
  final dynamic palette;
  const _WelcomeRow({required this.firstName, required this.palette});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateLabel.toUpperCase(),
                  style: AppTextStyles.overline
                      .copyWith(color: palette.primary)),
              const SizedBox(height: 7),
              RichText(
                // Unlike Text, RichText doesn't fall back to the ambient
                // DefaultTextStyle color — it needs an explicit one, or it
                // renders default black regardless of theme.
                text: TextSpan(
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    letterSpacing: -0.9,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.ink900,
                  ),
                  children: [
                    TextSpan(text: '$greeting, $firstName'),
                    const TextSpan(
                        text: '.', style: TextStyle(color: Color(0xFFB45309))),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'Your care, connected. Everything you need from your health center in one place.',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        _FamilySwitchButton(firstName: firstName, palette: palette),
      ],
    );
  }
}

class _FamilySwitchButton extends StatelessWidget {
  final String firstName;
  final dynamic palette;
  const _FamilySwitchButton({required this.firstName, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/profile/family'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_rounded, color: palette.primary, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Viewing as', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                Text(profile?.fullName ?? 'Guest',
                    style: AppTextStyles.caption.copyWith(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 17),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySecondary),
          ],
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor:
                  context.watch<AppSettingsProvider>().palette.primary,
            ),
            icon: Text(actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            label: const Icon(Icons.arrow_forward_rounded, size: 15),
          ),
      ],
    );
  }
}

class _DoctorFeatureCard extends StatelessWidget {
  final dynamic profile;
  final dynamic palette;
  const _DoctorFeatureCard({required this.profile, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: palette.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: palette.primaryDark.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IntrinsicHeight: a stretch-aligned Row inside a Stack gets
          // unbounded height (Stack doesn't force one on non-positioned
          // children), and Row can't stretch children to an unbounded
          // height — it fails a layout assertion and, in a release build,
          // silently renders nothing for the whole subtree (no error, no
          // visible fallback). IntrinsicHeight measures the tallest child
          // first and hands Row a real, bounded height to stretch to.
          IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/family_doctor_card.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.black26),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            palette.primaryDark,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 25, 26, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9DE3B7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text('ACCEPTING APPOINTMENTS',
                              style: AppTextStyles.overline.copyWith(
                                  color: const Color(0xFFADEDD0),
                                  fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Dr. Fatima Al-Doseri',
                          style: AppTextStyles.h2.copyWith(
                              color: Colors.white, fontSize: 21)),
                      const SizedBox(height: 4),
                      Text('Consultant · Family Medicine',
                          style: AppTextStyles.bodySecondary
                              .copyWith(color: const Color(0xFFC7E6E4))),
                      const SizedBox(height: 17),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 14, color: const Color(0xFFD3E9E8)),
                          const SizedBox(width: 5),
                          Text(
                            profile?.assignedHealthCenter ??
                                'Naim Health Center',
                            style: AppTextStyles.caption
                                .copyWith(color: const Color(0xFFD3E9E8)),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule_rounded,
                              size: 14, color: Color(0xFFD3E9E8)),
                          const SizedBox(width: 5),
                          Text('Usually replies in 1 day',
                              style: AppTextStyles.caption
                                  .copyWith(color: const Color(0xFFD3E9E8))),
                        ],
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ShellNavigation.of(context)?.selectTab(3),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFB5E2DF)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        icon: const Text('View doctor details',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                        label: const Icon(Icons.arrow_forward_rounded, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
          Positioned(
            top: 21,
            right: 22,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: Color(0xFFC9EEEB), size: 17),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAppointment extends StatelessWidget {
  const _NextAppointment();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointments = context.watch<AppointmentProvider>().myAppointments;
    final localizations = MaterialLocalizations.of(context);

    final upcoming = appointments
        .where((a) =>
            a.status == 'confirmed' && a.slotDateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.slotDateTime.compareTo(b.slotDateTime));

    if (upcoming.isEmpty) {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, '/services/booking'),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            border: Border.all(
                color: isDark ? AppColors.darkOutline : AppColors.outline),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_month_rounded,
                    color: palette.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No upcoming appointments',
                        style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Tap to schedule a new visit',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
            ],
          ),
        ),
      );
    }

    final Appointment next = upcoming.first;
    return InkWell(
      onTap: () => ShellNavigation.of(context)?.selectTab(1),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.outline),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 89,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _monthAbbr(next.slotDateTime.month).toUpperCase(),
                    style: AppTextStyles.overline
                        .copyWith(color: palette.primaryDark, fontSize: 10),
                  ),
                  Text('${next.slotDateTime.day}',
                      style: AppTextStyles.h1.copyWith(
                          color: palette.primaryDark, fontSize: 28, height: 1)),
                  Text('${next.slotDateTime.year}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(next.doctorName,
                        style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(next.centerName, style: AppTextStyles.caption),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13, color: palette.primaryDark),
                        const SizedBox(width: 5),
                        Text(
                          localizations.formatMediumDate(next.slotDateTime),
                          style: AppTextStyles.caption.copyWith(
                              color: palette.primaryDark,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded,
                            size: 13, color: palette.primaryDark),
                        const SizedBox(width: 5),
                        Text(
                          localizations.formatTimeOfDay(
                              TimeOfDay.fromDateTime(next.slotDateTime)),
                          style: AppTextStyles.caption.copyWith(
                              color: palette.primaryDark,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 18),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][month - 1];
}

class _PendingRequestsCard extends StatelessWidget {
  final dynamic palette;
  const _PendingRequestsCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<ServiceRequestProvider>().requests;
    final total = requests.length;
    final needsAttention = requests.where((r) => r.requiresAction).length;
    final inProgress = requests.where((r) => r.isOpen).length;
    final completed = requests.where((r) => r.isCompleted).length;
    final pendingBase = (total - inProgress - completed - needsAttention).clamp(0, total);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/pending-requests'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Color(0xFFFFC58D), size: 17),
                ),
                if (total > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$total active',
                        style: const TextStyle(
                            color: Color(0xFFBCE7D1),
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            const Text('Pending requests',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            const Text('Keep track of applications and updates.',
                style: TextStyle(color: Color(0xFFC4DFDF), fontSize: 12)),
            const SizedBox(height: 22),
            if (total > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 5,
                  child: Row(
                    children: [
                      Expanded(
                          flex: pendingBase == 0 ? 1 : pendingBase,
                          child: Container(color: const Color(0xFF78C8BE))),
                      const SizedBox(width: 2),
                      Expanded(
                          flex: inProgress == 0 ? 1 : inProgress,
                          child: Container(color: const Color(0xFFF2B26D))),
                      const SizedBox(width: 2),
                      Expanded(
                          flex: (completed + needsAttention) == 0
                              ? 1
                              : completed + needsAttention,
                          child: Container(color: const Color(0xFFD7E4E5))),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(total > 0 ? '$total requests' : 'No pending requests',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View requests',
                        style: TextStyle(
                            color: Color(0xFFCBE5E3), fontSize: 11)),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded,
                        size: 13, color: Color(0xFFCBE5E3)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final dynamic palette;
  final Color ice;
  const _QuickAccessCard({required this.palette, required this.ice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (Icons.calendar_month_rounded, 'Book appointment', '/services/booking'),
      (Icons.description_rounded, 'Medical reports', '/services/medical-reports'),
      (Icons.vaccines_rounded, 'Vaccinations', '/services/vaccinations'),
      (Icons.grid_view_rounded, 'All services', null),
    ];

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Quick access', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Common services', style: AppTextStyles.bodySecondary),
                ],
              ),
              const Icon(Icons.tune_rounded, size: 17, color: AppColors.ink500),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.35,
            children: items.map((item) {
              final (icon, label, route) = item;
              return InkWell(
                onTap: () => route != null
                    ? Navigator.pushNamed(context, route)
                    : ShellNavigation.of(context)?.selectTab(2),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkOutline
                            : AppColors.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: ice,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(icon, size: 15, color: palette.primary),
                      ),
                      const Spacer(),
                      Text(label,
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PopularServicesGrid extends StatelessWidget {
  const _PopularServicesGrid();

  static const _tiles = [
    ('Book Appointment', 'Choose a clinic, doctor, and time that suits you.',
        Icons.calendar_month_rounded, '/services/booking', Color(0xFFD8EEED), Color(0xFF0E7C7B)),
    ('Mammogram Screening', 'Check your eligibility and request a screening.',
        Icons.favorite_rounded, '/services/mammogram', Color(0xFFF8E0E3), Color(0xFFB04855)),
    ('Vaccination Records', 'View your history or report a missing record.',
        Icons.vaccines_rounded, '/services/vaccinations', Color(0xFFE2EEF7), Color(0xFF2D6B9B)),
    ('Medical Reports', 'View reports or request one from a recent visit.',
        Icons.description_rounded, '/services/medical-reports', Color(0xFFF7EDDC), Color(0xFFA66B22)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 1);
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
        children: _tiles.map((t) {
          final (title, desc, icon, route, iconBg, iconFg) = t;
          return InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border.all(
                    color: isDark ? AppColors.darkOutline : AppColors.outline),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 92,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: iconBg.withValues(alpha: 0.5)),
                        Positioned(
                          left: 12,
                          bottom: 11,
                          child: Container(
                            width: 37,
                            height: 37,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(icon, size: 18, color: iconFg),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 14, 13, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(desc,
                                style: AppTextStyles.caption.copyWith(fontSize: 10),
                                overflow: TextOverflow.fade),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _InfoBanner extends StatelessWidget {
  final dynamic palette;
  final Color ice;
  const _InfoBanner({required this.palette, required this.ice});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ShellNavigation.of(context)?.selectTab(3),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: ice,
          border: Border.all(color: palette.primary.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(Icons.shield_rounded, color: palette.primary, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Your privacy matters',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(
                    'Naraak keeps your health information safe and only uses it to provide your care.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Privacy & security',
                    style: TextStyle(
                        color: palette.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: palette.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
