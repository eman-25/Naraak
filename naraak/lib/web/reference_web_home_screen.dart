import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/appointment_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard/dashboard_widgets.dart';
import '../widgets/naraak_logo.dart';
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
    final dashboard = context.watch<DashboardProvider>();
    if (dashboard.state == LoadState.error) {
      return ErrorState(
        title: 'We could not load your dashboard',
        message: dashboard.errorMessage ?? 'Please try again.',
        actionLabel: 'Try Again',
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
                  title: 'Upcoming Appointment',
                  action: 'View all appointments',
                  onTap: () => ShellNavigation.of(context)?.selectTab(1),
                ),
                const _UpcomingAppointmentPanel(),
                const SizedBox(height: 14),
                const _FamilyDoctorCard(),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'Top Services',
                  action: 'View all services',
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
            Image.asset('assets/images/dashboard_phc_hero.png',
                fit: BoxFit.fill),
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
                        const Text('Primary Healthcare,\nCloser to You',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1.08)),
                        const SizedBox(height: 14),
                        const Text(
                            'All your primary healthcare services in one place.\nFast. Easy. Secure.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.45)),
                        const SizedBox(height: 16),
                        TextField(
                          readOnly: true,
                          onTap: () =>
                              ShellNavigation.of(context)?.selectTab(2),
                          decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              hintText:
                                  'Search for services, health centers and more...',
                              suffixIcon: Icon(Icons.search_rounded)),
                        ),
                      ]),
                ),
              ),
            ),
            const Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(44, 0, 24, 20),
                child: Wrap(spacing: 24, runSpacing: 8, children: [
                  _Trust(
                      icon: Icons.verified_user_outlined,
                      text: 'Secure & Trusted'),
                  _Trust(icon: Icons.schedule_rounded, text: '24/7 Access'),
                  _Trust(
                      icon: Icons.family_restroom_rounded,
                      text: 'For You & Your Family'),
                  _Trust(
                      icon: Icons.favorite_border_rounded,
                      text: 'Better Health, Everyday'),
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
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700))
      ]);
}

class _UpcomingAppointmentPanel extends StatelessWidget {
  const _UpcomingAppointmentPanel();
  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentProvider>().myAppointments;
    final appointment = appointments.isEmpty ? null : appointments.first;
    if (appointment == null) {
      return EmptyState(
        title: 'No upcoming appointment',
        message: 'Book an appointment when you are ready.',
        actionLabel: 'Book Appointment',
        onAction: () => Navigator.pushNamed(context, '/services/booking'),
      );
    }
    final date = appointment.slotDateTime;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final time = '$hour:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(children: [
        CircleAvatar(radius: 31, backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12), child: Icon(Icons.person_rounded, size: 36, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(width: 14),
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appointment.doctorName, style: AppTextStyles.label), const SizedBox(height: 4), Text(appointment.clinic ?? 'General Practitioner', style: AppTextStyles.bodySecondary), Text(appointment.centerName, style: AppTextStyles.caption)])),
        const VerticalDivider(),
        Expanded(flex: 2, child: _AppointmentFact(icon: Icons.calendar_month_outlined, title: '${date.day} ${months[date.month - 1]} ${date.year}', subtitle: weekdays[date.weekday - 1])),
        const VerticalDivider(),
        Expanded(child: _AppointmentFact(icon: Icons.schedule_rounded, title: time)),
        const VerticalDivider(),
        Expanded(child: _AppointmentFact(title: 'Type', subtitle: appointment.isTele ? 'Tele-Appointment' : 'In-center')),
        const VerticalDivider(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: const Row(children: [Icon(Icons.check_circle_outline, color: AppColors.success, size: 17), SizedBox(width: 5), Text('Upcoming', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))])),
        const SizedBox(width: 18),
        SizedBox(width: 190, child: Column(children: [
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => ShellNavigation.of(context)?.selectTab(1), child: const Text('View Details'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => ShellNavigation.of(context)?.selectTab(1), child: const Text('View All Appointments'))),
        ])),
      ]),
    );
  }
}

class _AppointmentFact extends StatelessWidget {
  const _AppointmentFact({this.icon, required this.title, this.subtitle});
  final IconData? icon; final String title; final String? subtitle;
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 24), const SizedBox(width: 9)], Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.label), if (subtitle != null) Text(subtitle!, style: AppTextStyles.caption)]))]);
}

class _FamilyDoctorCard extends StatelessWidget {
  const _FamilyDoctorCard();
  @override Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.medical_services_outlined, color: Colors.white)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Your Family Doctor', style: AppTextStyles.caption), Text(profile?.familyDoctorName ?? 'Not assigned', style: AppTextStyles.h3), Text('${profile?.familyDoctorSpecialty ?? 'Family Medicine'} • ${profile?.assignedHealthCenter ?? ''}', style: AppTextStyles.bodySecondary)])),
        TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/services/change-doctor'), icon: const Text('View Doctor'), label: const Icon(Icons.arrow_forward_rounded, size: 16)),
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
      this.title, this.subtitle, this.route, this.image, this.icon);
  final String title, subtitle, route, image;
  final IconData icon;
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();
  static const services = [
    _ServiceData(
        'Book Appointment',
        'In-center & tele-appointment',
        '/services/booking',
        'assets/images/service_booking.jpg',
        Icons.calendar_month),
    _ServiceData(
        'Mammogram Screening',
        'Early detection saves lives',
        '/services/mammogram',
        'assets/images/service_mammogram.jpg',
        Icons.health_and_safety),
    _ServiceData(
        'Vaccination Records',
        'View and download certificates',
        '/services/vaccinations',
        'assets/images/service_vaccination.jpg',
        Icons.vaccines),
    _ServiceData(
        'Medical Reports',
        'Request and download reports',
        '/services/medical-reports',
        'assets/images/service_medical_reports.jpg',
        Icons.description),
    _ServiceData(
        'Electronic Hajj Certificate',
        'Apply and download',
        '/services/hajj-certificate',
        'assets/images/service_medical_reports.jpg',
        Icons.mosque),
    _ServiceData(
        'Newborn Sehati Card',
        'Apply for your newborn',
        '/services/newborn-sehati',
        'assets/images/service_medical_reports.jpg',
        Icons.child_care),
    _ServiceData(
        'Update Address',
        'Update your assigned center',
        '/services/address-update',
        'assets/images/splash.jpg',
        Icons.location_on),
    _ServiceData(
        'Health Fee Exemption',
        'Apply for exemption',
        '/services/fee-exemption',
        'assets/images/service_medical_reports.jpg',
        Icons.shield_outlined),
    _ServiceData(
        'Change Family Doctor',
        'Choose your family doctor',
        '/services/change-doctor',
        'assets/images/family_doctor_card.jpeg',
        Icons.medical_services_outlined),
    _ServiceData(
        'Mobile Unit Service',
        'Healthcare at your doorstep',
        '/services/mobile-unit',
        'assets/images/service_booking.jpg',
        Icons.emergency),
    _ServiceData(
        'PHC Research',
        'Research projects and studies',
        '/services/phc-research',
        'assets/images/service_medical_reports.jpg',
        Icons.science),
  ];
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth > 900
            ? 5
            : c.maxWidth > 600
                ? 3
                : 2;
        return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.12),
            itemBuilder: (_, i) => _ServiceCard(data: services[i]));
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
                      Text(data.title,
                          style: AppTextStyles.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(data.subtitle,
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
          Text('Healthcare at\nYour Fingertips', style: AppTextStyles.h1),
          const SizedBox(height: 14),
          Text(
              'Book appointments, access your records, track requests, receive reminders and manage your healthcare anywhere.',
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
          Center(
              child: Text('Available as the Naraak prototype app',
                  style: AppTextStyles.caption, textAlign: TextAlign.center)),
        ]),
      );
}

class _HealthTip extends StatelessWidget {
  const _HealthTip();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .28)),
            borderRadius: BorderRadius.circular(40)),
        child: const Row(children: [
          Icon(Icons.favorite_border_rounded),
          SizedBox(width: 12),
          Text('Health Tip', style: AppTextStyles.label),
          VerticalDivider(),
          Expanded(
              child: Text(
                  'Drink plenty of water, eat balanced meals, and get enough sleep. Small daily habits lead to a healthier you.',
                  style: AppTextStyles.bodySecondary))
        ]),
      );
}
