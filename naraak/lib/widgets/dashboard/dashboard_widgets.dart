// lib/widgets/dashboard/dashboard_widgets.dart
//
// Shared Home-dashboard components used by BOTH the mobile app and the web
// shell, so the two never visually drift apart — mobile just arranges them
// in a single column while web uses a two-column grid. Ported from the
// Bolt reference design, with its hardcoded teal swapped for the app's
// selected palette (light + dark aware) everywhere.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart' show ShellNavigation;
import '../../models/appointment.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/service_request_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// A light palette-tinted background — reused everywhere the reference
/// used its `--ice` token, e.g. quick-access icon chips, the privacy
/// banner. Slightly stronger alpha in dark mode so it still reads as a
/// tint against the dark surface.
Color dashboardIce(BuildContext context, dynamic palette) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return palette.primary.withValues(alpha: isDark ? 0.16 : 0.08);
}

class WelcomeHeader extends StatelessWidget {
  final String firstName;
  final Widget? trailing;
  const WelcomeHeader({super.key, required this.firstName, this.trailing});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(dateLabel.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: palette.primary)),
        const SizedBox(height: 7),
        RichText(
          // Unlike Text, RichText doesn't fall back to the ambient
          // DefaultTextStyle color — it needs an explicit one, or it
          // renders default black regardless of theme.
          text: TextSpan(
            style: AppTextStyles.h1.copyWith(
              fontSize: 28,
              letterSpacing: -0.9,
              color: isDark ? AppColors.darkTextPrimary : AppColors.ink900,
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
    );

    if (trailing == null) return title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        const SizedBox(width: 20),
        trailing!,
      ],
    );
  }
}

class FamilySwitchButton extends StatelessWidget {
  const FamilySwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
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
                Text('Viewing as',
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
                Text(profile?.fullName ?? 'Guest',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
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

class DashboardSectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const DashboardSectionHeading({
    super.key,
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
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 17)),
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
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            label: const Icon(Icons.arrow_forward_rounded, size: 15),
          ),
      ],
    );
  }
}

class DoctorFeatureCard extends StatelessWidget {
  final bool compact;
  const DoctorFeatureCard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final profile = context.watch<UserProfileProvider>().profile;

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 172 : 200),
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
            child: compact
                ? _CompactBody(palette: palette, profile: profile)
                : _WideBody(palette: palette, profile: profile),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: Color(0xFFC9EEEB), size: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideBody extends StatelessWidget {
  final dynamic palette;
  final dynamic profile;
  const _WideBody({required this.palette, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    colors: [Colors.transparent, palette.primaryDark],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 25, 26, 25),
            child: _DoctorInfo(palette: palette, profile: profile, wide: true),
          ),
        ),
      ],
    );
  }
}

class _CompactBody extends StatelessWidget {
  final dynamic palette;
  final dynamic profile;
  const _CompactBody({required this.palette, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: _DoctorInfo(palette: palette, profile: profile, wide: false),
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  final dynamic palette;
  final dynamic profile;
  final bool wide;
  const _DoctorInfo(
      {required this.palette, required this.profile, required this.wide});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                style: AppTextStyles.overline
                    .copyWith(color: const Color(0xFFADEDD0), fontSize: 10)),
          ],
        ),
        SizedBox(height: wide ? 12 : 10),
        Text(profile?.familyDoctorName ?? 'Family Doctor',
            style: AppTextStyles.h2
                .copyWith(color: Colors.white, fontSize: wide ? 21 : 18)),
        const SizedBox(height: 4),
        Text('Consultant · Family Medicine',
            style: AppTextStyles.bodySecondary
                .copyWith(color: const Color(0xFFC7E6E4))),
        SizedBox(height: wide ? 17 : 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: const Color(0xFFD3E9E8)),
              const SizedBox(width: 5),
              Text(
                profile?.assignedHealthCenter ?? 'Naim Health Center',
                style: AppTextStyles.caption
                    .copyWith(color: const Color(0xFFD3E9E8)),
              ),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: Color(0xFFD3E9E8)),
              const SizedBox(width: 5),
              Text('Usually replies in 1 day',
                  style: AppTextStyles.caption
                      .copyWith(color: const Color(0xFFD3E9E8))),
            ]),
          ],
        ),
        SizedBox(height: wide ? 18 : 14),
        OutlinedButton.icon(
          onPressed: () => ShellNavigation.of(context)?.selectTab(3),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFB5E2DF)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Text('View doctor details',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          label: const Icon(Icons.arrow_forward_rounded, size: 15),
        ),
      ],
    );
  }
}

class DashboardNextAppointment extends StatelessWidget {
  const DashboardNextAppointment({super.key});

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
          padding: const EdgeInsets.all(18),
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
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(15)),
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
                          color: palette.primaryDark, fontSize: 26, height: 1)),
                  Text('${next.slotDateTime.year}',
                      style: AppTextStyles.caption.copyWith(fontSize: 10)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(next.doctorName,
                        style: AppTextStyles.h3.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(next.centerName,
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: palette.primaryDark),
                          const SizedBox(width: 5),
                          Text(
                            localizations.formatMediumDate(next.slotDateTime),
                            style: AppTextStyles.caption.copyWith(
                                color: palette.primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 11),
                          ),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: palette.primaryDark),
                          const SizedBox(width: 5),
                          Text(
                            localizations.formatTimeOfDay(
                                TimeOfDay.fromDateTime(next.slotDateTime)),
                            style: AppTextStyles.caption.copyWith(
                                color: palette.primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 11),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month - 1];
}

class DashboardPendingRequestsCard extends StatelessWidget {
  const DashboardPendingRequestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final requests = context.watch<ServiceRequestProvider>().requests;
    final total = requests.length;
    final needsAttention = requests.where((r) => r.requiresAction).length;
    final inProgress = requests.where((r) => r.isOpen).length;
    final completed = requests.where((r) => r.isCompleted).length;
    final pendingBase =
        (total - inProgress - completed - needsAttention).clamp(0, total);

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
                        style:
                            TextStyle(color: Color(0xFFCBE5E3), fontSize: 11)),
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

class DashboardQuickAccessCard extends StatelessWidget {
  final int crossAxisCount;
  const DashboardQuickAccessCard({super.key, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final ice = dashboardIce(context, palette);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (Icons.calendar_month_rounded, 'Book appointment', '/services/booking'),
      (
        Icons.description_rounded,
        'Medical reports',
        '/services/medical-reports'
      ),
      (Icons.vaccines_rounded, 'Vaccinations', '/services/vaccinations'),
      (Icons.grid_view_rounded, 'All services', null),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
                  Text('Quick access',
                      style: AppTextStyles.h3.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Common services', style: AppTextStyles.bodySecondary),
                ],
              ),
              const Icon(Icons.tune_rounded, size: 17, color: AppColors.ink500),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: crossAxisCount,
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
                        color:
                            isDark ? AppColors.darkOutline : AppColors.outline),
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
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 11, fontWeight: FontWeight.w700)),
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

class DashboardPopularServicesGrid extends StatelessWidget {
  const DashboardPopularServicesGrid({super.key});

  static const _tiles = [
    (
      'Book Appointment',
      'Choose a clinic, doctor, and time that suits you.',
      Icons.calendar_month_rounded,
      '/services/booking',
      'assets/images/service_booking.jpg',
      Color(0xFF0E7C7B),
    ),
    (
      'Mammogram Screening',
      'Check your eligibility and request a screening.',
      Icons.favorite_rounded,
      '/services/mammogram',
      'assets/images/service_mammogram.jpg',
      Color(0xFFB04855),
    ),
    (
      'Vaccination Records',
      'View your history or report a missing record.',
      Icons.vaccines_rounded,
      '/services/vaccinations',
      'assets/images/service_vaccination.jpg',
      Color(0xFF2D6B9B),
    ),
    (
      'Medical Reports',
      'View reports or request one from a recent visit.',
      Icons.description_rounded,
      '/services/medical-reports',
      'assets/images/service_medical_reports.jpg',
      Color(0xFFA66B22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, constraints) {
      final columns =
          constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 2);
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: columns == 2 ? 1.05 : 1.42,
        children: _tiles.map((t) {
          final (title, desc, icon, route, imagePath, iconFg) = t;
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
                  Expanded(
                    flex: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: iconFg.withValues(alpha: 0.15)),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 10,
                          child: Container(
                            width: 36,
                            height: 36,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            style: AppTextStyles.body.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(desc,
                            style: AppTextStyles.bodySecondary
                                .copyWith(fontSize: 12.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
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

class DashboardPrivacyBanner extends StatelessWidget {
  const DashboardPrivacyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final ice = dashboardIce(context, palette);
    return InkWell(
      onTap: () => ShellNavigation.of(context)?.selectTab(3),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: ice,
          border: Border.all(color: palette.primary.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(Icons.shield_rounded,
                      color: palette.primary, size: 18),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Your privacy matters',
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(
                        'Naraak keeps your health information safe and only uses it to provide your care.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Privacy & security',
                      style: TextStyle(
                          color: palette.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: palette.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
