import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../localization/app_localizations.dart';
import '../providers/appointment_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/naraak_logo.dart';
import '../widgets/dashboard/dashboard_widgets.dart';
import '../widgets/state_views.dart';

class ReferenceWebHomeScreen extends StatefulWidget {
  const ReferenceWebHomeScreen({super.key});

  @override
  State<ReferenceWebHomeScreen> createState() => _ReferenceWebHomeScreenState();
}

class _ReferenceWebHomeScreenState extends State<ReferenceWebHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadMyAppointments();
      context.read<ServiceRequestProvider>().loadRequests();
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dashboard = context.watch<DashboardProvider>();
    if (dashboard.state == LoadState.error) {
      return ErrorState(
        title: strings.text('dashboardLoadError'),
        message: dashboard.errorMessage ?? strings.text('pleaseTryAgain'),
        actionLabel: strings.text('tryAgain'),
        onAction: dashboard.load,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(children: [
            const _Hero(),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1050;
              final main = Column(children: [
                _SectionHeader(
                  title: strings.text('upcomingAppointment'),
                  action: strings.text('viewAllAppointments'),
                  onTap: () => ShellNavigation.of(context)?.selectTab(1),
                ),
                const _UpcomingAppointmentPanel(),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 760) {
                      return const Column(
                        children: [
                          _FamilyDoctorCard(),
                          SizedBox(height: 14),
                          DashboardPendingRequestsCard(),
                        ],
                      );
                    }
                    return const IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _FamilyDoctorCard()),
                          SizedBox(width: 14),
                          Expanded(flex: 2, child: DashboardPendingRequestsCard()),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: strings.text('topServices'),
                  action: strings.text('viewAllServices'),
                  onTap: () => ShellNavigation.of(context)?.selectTab(2),
                ),
                const _ServicesGrid(),
              ]);
              if (!wide) {
                return Column(children: [
                  main,
                  const SizedBox(height: 20),
                  const _AppPromo()
                ]);
              }
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: main),
                    const SizedBox(width: 20),
                    const Expanded(flex: 3, child: _AppPromo()),
                  ]);
            }),
            const SizedBox(height: 22),
            const _HealthTip(),
          ]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: SizedBox(
          height: 300,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/Primary Healthcare Centers.jpg',
                fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  stops: const [0, .3, .48, .64],
                  colors: const [
                    AppColors.primaryDark,
                    AppColors.primaryDark,
                    Color(0xC90B4F54),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(44, 22, 24, 68),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: 500,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).text('webHeroTitle'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1.08)),
                        const SizedBox(height: 14),
                        Text(
                            AppLocalizations.of(context)
                                .text('webHeroSubtitle'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.45)),
                        const SizedBox(height: 16),
                        TextField(
                          readOnly: true,
                          onTap: () =>
                              ShellNavigation.of(context)?.selectTab(2),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              hintText: AppLocalizations.of(context)
                                  .text('dashboardSearchHint'),
                              suffixIcon: const Icon(Icons.search_rounded)),
                        ),
                      ]),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(44, 0, 24, 20),
                child: Wrap(spacing: 24, runSpacing: 8, children: [
                  _Trust(
                      icon: Icons.verified_user_outlined,
                      text: AppLocalizations.of(context).text('secureTrusted')),
                  _Trust(
                      icon: Icons.schedule_rounded,
                      text: AppLocalizations.of(context).text('allDayAccess')),
                  _Trust(
                      icon: Icons.family_restroom_rounded,
                      text: AppLocalizations.of(context).text('forYourFamily')),
                  _Trust(
                      icon: Icons.favorite_border_rounded,
                      text: AppLocalizations.of(context)
                          .text('betterHealthEveryday')),
                ]),
              ),
            ),
          ]),
        ),
      );
}

class _Trust extends StatelessWidget {
  const _Trust({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 7),
      Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700))
    ]),
  );
}

class _UpcomingAppointmentPanel extends StatelessWidget {
  const _UpcomingAppointmentPanel();
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appointments = context.watch<AppointmentProvider>().myAppointments;
    final appointment = appointments.isEmpty ? null : appointments.first;
    if (appointment == null) {
      return EmptyState(
        title: strings.text('noUpcomingAppointment'),
        message: strings.text('bookWhenReady'),
        actionLabel: strings.text('bookAppointment'),
        onAction: () => Navigator.pushNamed(context, '/services/booking'),
      );
    }
    final date = appointment.slotDateTime;
    final materialStrings = MaterialLocalizations.of(context);
    final dateLabel = materialStrings.formatMediumDate(date);
    final weekdayLabel = materialStrings.formatFullDate(date);
    final time = materialStrings.formatTimeOfDay(TimeOfDay.fromDateTime(date));
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 15, 18, 17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(strings.text('upcomingAppointment'),
            style: AppTextStyles.h3.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        _ResponsiveAppointmentContent(
          doctorName: appointment.doctorName,
          clinic: appointment.clinic ?? strings.text('generalPractitioner'),
          centerName: appointment.centerName,
          date: dateLabel,
          weekday: weekdayLabel,
          time: time,
          type: appointment.isTele
              ? strings.raw('Tele-appointment')
              : strings.text('inCenter'),
          typeLabel: strings.text('type'),
          status: strings.raw('Upcoming'),
          viewDetails: strings.text('viewDetails'),
          viewAll: strings.text('viewAllAppointments'),
          onOpen: () => ShellNavigation.of(context)?.selectTab(1),
        ),
      ]),
    );
  }
}

class _ResponsiveAppointmentContent extends StatelessWidget {
  const _ResponsiveAppointmentContent({
    required this.doctorName,
    required this.clinic,
    required this.centerName,
    required this.date,
    required this.weekday,
    required this.time,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.viewDetails,
    required this.viewAll,
    required this.onOpen,
  });

  final String doctorName;
  final String clinic;
  final String centerName;
  final String date;
  final String weekday;
  final String time;
  final String type;
  final String typeLabel;
  final String status;
  final String viewDetails;
  final String viewAll;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 920;
          final veryNarrow = constraints.maxWidth < 520;
          final details = _AppointmentDetailsCard(
            doctorName: doctorName,
            clinic: clinic,
            centerName: centerName,
            date: date,
            weekday: weekday,
            time: time,
            type: type,
            typeLabel: typeLabel,
            status: status,
            compact: compact,
          );
          final actions = _AppointmentActions(
            viewDetails: viewDetails,
            viewAll: viewAll,
            onOpen: onOpen,
            horizontal: compact && !veryNarrow,
          );

          if (compact) {
            return Column(
              children: [
                details,
                const SizedBox(height: 12),
                actions,
              ],
            );
          }

          return SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: details),
                const SizedBox(width: 16),
                SizedBox(width: 176, child: actions),
              ],
            ),
          );
        },
      );
}

class _AppointmentDetailsCard extends StatelessWidget {
  const _AppointmentDetailsCard({
    required this.doctorName,
    required this.clinic,
    required this.centerName,
    required this.date,
    required this.weekday,
    required this.time,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.compact,
  });

  final String doctorName;
  final String clinic;
  final String centerName;
  final String date;
  final String weekday;
  final String time;
  final String type;
  final String typeLabel;
  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final patient = Row(
      children: [
        CircleAvatar(
          radius: compact ? 24 : 29,
          backgroundColor: colors.primary.withValues(alpha: .11),
          child: Icon(Icons.person_rounded,
              size: compact ? 28 : 34, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctorName,
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(clinic,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(centerName,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
    final statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                patient,
                const SizedBox(height: 12),
                Divider(height: 1, color: colors.outlineVariant),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 22,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _AppointmentFact(
                      icon: Icons.calendar_month_outlined,
                      title: date,
                      subtitle: weekday,
                    ),
                    _AppointmentFact(
                      icon: Icons.schedule_rounded,
                      title: time,
                    ),
                    _AppointmentFact(title: typeLabel, subtitle: type),
                    statusChip,
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 28, child: patient),
                const _AppointmentDivider(),
                Expanded(
                  flex: 23,
                  child: _AppointmentFact(
                    icon: Icons.calendar_month_outlined,
                    title: date,
                    subtitle: weekday,
                  ),
                ),
                const _AppointmentDivider(),
                Expanded(
                  flex: 16,
                  child: _AppointmentFact(
                    icon: Icons.schedule_rounded,
                    title: time,
                  ),
                ),
                const _AppointmentDivider(),
                Expanded(
                  flex: 15,
                  child: _AppointmentFact(title: typeLabel, subtitle: type),
                ),
                const SizedBox(width: 10),
                statusChip,
              ],
            ),
    );
  }
}

class _AppointmentActions extends StatelessWidget {
  const _AppointmentActions({
    required this.viewDetails,
    required this.viewAll,
    required this.onOpen,
    required this.horizontal,
  });

  final String viewDetails;
  final String viewAll;
  final VoidCallback onOpen;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final detailsButton = FilledButton(
      onPressed: onOpen,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(viewDetails, textAlign: TextAlign.center),
      ),
    );
    final allButton = OutlinedButton(
      onPressed: onOpen,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(viewAll, textAlign: TextAlign.center),
      ),
    );

    if (horizontal) {
      return Row(
        children: [
          Expanded(child: detailsButton),
          const SizedBox(width: 10),
          Expanded(child: allButton),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 44, child: detailsButton),
        const SizedBox(height: 8),
        SizedBox(height: 44, child: allButton),
      ],
    );
  }
}

class _AppointmentFact extends StatelessWidget {
  const _AppointmentFact({this.icon, required this.title, this.subtitle});
  final IconData? icon;
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Center(
    child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 24), const SizedBox(width: 9)],
        Flexible(
            child:
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Text(title, style: AppTextStyles.label),
          if (subtitle != null) Text(subtitle!, style: AppTextStyles.caption)
        ]))
      ]),
    );
}

class _AppointmentDivider extends StatelessWidget {
  const _AppointmentDivider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}

class _FamilyDoctorCard extends StatelessWidget {
  const _FamilyDoctorCard();
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final profile = context.watch<UserProfileProvider>().profile;
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.text('yourFamilyDoctor'),
                    style: AppTextStyles.caption),
                const SizedBox(height: 3),
                Text(profile?.familyDoctorName ?? strings.text('notAssigned'),
                    style: AppTextStyles.h3),
                const SizedBox(height: 3),
                Text(
                  '${profile?.familyDoctorSpecialty ?? strings.text('familyMedicine')} • ${profile?.assignedHealthCenter ?? ''}',
                  style: AppTextStyles.bodySecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(
                      context, '/services/change-doctor'),
                  icon: Text(strings.text('viewDoctor')),
                  label: const Icon(Icons.arrow_forward_rounded, size: 16),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(
              'assets/images/yourDoc.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/family_doctor_card.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    colors.primaryContainer,
                    colors.primaryContainer.withValues(alpha: .35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.action, required this.onTap});
  final String title, action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(title, style: AppTextStyles.h3),
          const Spacer(),
          TextButton.icon(
              onPressed: onTap,
              label: Text(action),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16))
        ]),
      );
}

class _ServiceData {
  const _ServiceData(
      this.titleKey, this.subtitleKey, this.route, this.image, this.icon);
  final String titleKey, subtitleKey, route, image;
  final IconData icon;
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  static const services = [
    _ServiceData(
      'bookAppointment',
      'bookingServiceSubtitle',
      '/services/booking',
      'assets/images/service_booking.jpg',
      Icons.calendar_month,
    ),
    _ServiceData(
      'mammogramScreening',
      'mammogramSubtitle',
      '/services/mammogram',
      'assets/images/service_mammogram.jpg',
      Icons.health_and_safety,
    ),
    _ServiceData(
      'vaccinationRecords',
      'vaccinationSubtitle',
      '/services/vaccinations',
      'assets/images/service_vaccination.jpg',
      Icons.vaccines,
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth > 600
            ? 3
            : c.maxWidth > 360
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (_, i) => _ServiceCard(data: services[i]),
        );
      });
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.data});
  final _ServiceData data;
  @override
  Widget build(BuildContext context) => Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: () => Navigator.pushNamed(context, data.route),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Stack(fit: StackFit.expand, children: [
              Image.asset(data.image, fit: BoxFit.cover),
              Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                          radius: 16, child: Icon(data.icon, size: 17))))
            ])),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).text(data.titleKey),
                          style: AppTextStyles.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(AppLocalizations.of(context).text(data.subtitleKey),
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                    ])),
          ])));
}

class _AppPromo extends StatelessWidget {
  const _AppPromo();
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 570),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const NaraakLogo(size: 72),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).text('healthcareAtFingertips'),
              style: AppTextStyles.h1),
          const SizedBox(height: 14),
          Text(AppLocalizations.of(context).text('appPromoDescription'),
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Image.asset(
                'assets/images/naraak_app_promo.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AppLocalizations.of(context).text('availablePrototypeApp'),
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      );
}

class _HealthTip extends StatelessWidget {
  const _HealthTip();
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsetsDirectional.fromSTEB(28, 10, 22, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: primary.withValues(alpha: .22)),
        borderRadius: BorderRadius.circular(38),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: .06),
            border: Border.all(color: primary.withValues(alpha: .35)),
          ),
          child:
              Icon(Icons.health_and_safety_outlined, color: primary, size: 24),
        ),
        const SizedBox(width: 22),
        Text(AppLocalizations.of(context).text('healthTip'),
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: 24),
        Container(width: 1, height: 25, color: primary.withValues(alpha: .3)),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            AppLocalizations.of(context).text('healthTipBody'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary,
          ),
        ),
        const SizedBox(width: 18),
        Icon(Icons.monitor_heart_outlined,
            color: primary.withValues(alpha: .12), size: 46),
      ]),
    );
  }
}
