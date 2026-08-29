// lib/web/web_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/dashboard/dashboard_widgets.dart';

/// Desktop dashboard home — mirrors the reference design's sidebar-layout
/// home page (welcome row, doctor-feature card, pending-requests card,
/// quick-access grid, popular services, privacy banner). All the actual
/// card widgets live in widgets/dashboard so mobile Home renders the exact
/// same components, just arranged in a single column instead of a grid.
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
    final firstName = (profile?.fullName ?? 'there').split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeHeader(
                firstName: firstName, trailing: const FamilySwitchButton()),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 155,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardSectionHeading(
                        title: 'Your care team',
                        subtitle: 'Your assigned family doctor',
                        actionLabel: 'View profile',
                        onAction: () =>
                            ShellNavigation.of(context)?.selectTab(3),
                      ),
                      const SizedBox(height: 12),
                      const DoctorFeatureCard(),
                      const SizedBox(height: 22),
                      DashboardSectionHeading(
                        title: 'Next appointment',
                        subtitle: 'Your upcoming visit',
                        actionLabel: 'All appointments',
                        onAction: () =>
                            ShellNavigation.of(context)?.selectTab(1),
                      ),
                      const SizedBox(height: 12),
                      const DashboardNextAppointment(),
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
                      const DashboardPendingRequestsCard(),
                      const SizedBox(height: 15),
                      const DashboardQuickAccessCard(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            DashboardSectionHeading(
              title: 'Popular services',
              subtitle: 'Start with what you need today',
              actionLabel: 'See all services',
              onAction: () => ShellNavigation.of(context)?.selectTab(2),
            ),
            const SizedBox(height: 14),
            const DashboardPopularServicesGrid(),
            const SizedBox(height: 22),
            const DashboardPrivacyBanner(),
          ],
        ),
      ),
    );
  }
}
