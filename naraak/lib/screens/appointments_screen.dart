// lib/screens/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/status_badge.dart';
import 'services/join_appointment_screen.dart';

enum _ApptFilter { upcoming, past, tele, inCenter }

/// Appointments tab — pure content (no Scaffold/AppBar of its own; the
/// shell renders the top bar). Matches the reference's page-title + filter
/// tabs + appointment-card list structure.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  _ApptFilter _filter = _ApptFilter.upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadMyAppointments();
    });
  }

  List<Appointment> _applyFilter(List<Appointment> all) {
    final now = DateTime.now();
    switch (_filter) {
      case _ApptFilter.upcoming:
        return all
            .where(
                (a) => a.status != 'cancelled' && a.slotDateTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.slotDateTime.compareTo(b.slotDateTime));
      case _ApptFilter.past:
        return all
            .where((a) =>
                a.status == 'completed' ||
                (a.status != 'cancelled' && a.slotDateTime.isBefore(now)))
            .toList()
          ..sort((a, b) => b.slotDateTime.compareTo(a.slotDateTime));
      case _ApptFilter.tele:
        return all.where((a) => a.isTele).toList()
          ..sort((a, b) => a.slotDateTime.compareTo(b.slotDateTime));
      case _ApptFilter.inCenter:
        return all.where((a) => !a.isTele).toList()
          ..sort((a, b) => a.slotDateTime.compareTo(b.slotDateTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final allAppointments = context.watch<AppointmentProvider>().myAppointments;
    final upcomingCount = allAppointments
        .where((a) =>
            a.status != 'cancelled' && a.slotDateTime.isAfter(DateTime.now()))
        .length;
    final filtered = _applyFilter(allAppointments);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 16,
              runSpacing: 14,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('YOUR CARE',
                        style: AppTextStyles.overline
                            .copyWith(color: palette.primary)),
                    const SizedBox(height: 6),
                    Text('Appointments',
                        style: AppTextStyles.h1.copyWith(fontSize: 26)),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Text(
                        'Manage upcoming visits and review your appointment history.',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/services/booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    minimumSize: const Size(64, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 17),
                  label: const Text('Book appointment'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _FilterTabs(
              filter: _filter,
              upcomingCount: upcomingCount,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 18),
            if (filtered.isEmpty)
              _EmptyState(filter: _filter)
            else
              Column(
                children: filtered
                    .map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AppointmentCard(appointment: a),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _ApptFilter filter;
  final int upcomingCount;
  final ValueChanged<_ApptFilter> onChanged;
  const _FilterTabs(
      {required this.filter,
      required this.upcomingCount,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      (_ApptFilter.upcoming, 'Upcoming', upcomingCount),
      (_ApptFilter.past, 'Past', null),
      (_ApptFilter.tele, 'Tele-appointments', null),
      (_ApptFilter.inCenter, 'In-center', null),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final (value, label, count) = t;
          final active = value == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onChanged(value),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? palette.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? palette.primaryDark
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.ink500),
                        )),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: dashboardIceFor(palette, isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                                color: palette.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Color dashboardIceFor(dynamic palette, bool isDark) =>
    palette.primary.withValues(alpha: isDark ? 0.16 : 0.08);

class _EmptyState extends StatelessWidget {
  final _ApptFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = switch (filter) {
      _ApptFilter.upcoming => 'No upcoming appointments yet.',
      _ApptFilter.past => 'No past appointments to show.',
      _ApptFilter.tele => 'No tele-appointments yet.',
      _ApptFilter.inCenter => 'No in-center appointments yet.',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(message,
            style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentCard({required this.appointment});

  AppStatus get _status => switch (appointment.status) {
        'completed' => AppStatus.completed,
        'cancelled' => AppStatus.cancelled,
        _ => AppStatus.confirmed,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = MaterialLocalizations.of(context);
    const monthAbbr = [
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
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      monthAbbr[appointment.slotDateTime.month - 1]
                          .toUpperCase(),
                      style: AppTextStyles.overline
                          .copyWith(color: palette.primaryDark, fontSize: 9)),
                  Text('${appointment.slotDateTime.day}',
                      style: AppTextStyles.h1.copyWith(
                          color: palette.primaryDark, fontSize: 22, height: 1)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (appointment.isTele) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Tele',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(appointment.doctorName,
                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                      ),
                      StatusBadge(status: _status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(appointment.centerName, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: palette.primaryDark),
                      const SizedBox(width: 5),
                      Text(
                        localizations
                            .formatMediumDate(appointment.slotDateTime),
                        style: AppTextStyles.caption.copyWith(
                            color: palette.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded,
                          size: 12, color: palette.primaryDark),
                      const SizedBox(width: 5),
                      Text(
                        localizations.formatTimeOfDay(
                            TimeOfDay.fromDateTime(appointment.slotDateTime)),
                        style: AppTextStyles.caption.copyWith(
                            color: palette.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 11),
                      ),
                    ],
                  ),
                  if (appointment.status == 'confirmed') ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (appointment.isTele) ...[
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JoinAppointmentScreen(
                                    doctorName: appointment.doctorName,
                                    appointmentId: appointment.id),
                              ),
                            ),
                            child: const Text('Join'),
                          ),
                          const SizedBox(width: 4),
                        ],
                        TextButton(
                          onPressed: () => context
                              .read<AppointmentProvider>()
                              .cancelAppointment(appointment.id),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
