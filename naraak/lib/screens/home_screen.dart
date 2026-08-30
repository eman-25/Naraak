// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/dashboard/dashboard_widgets.dart';

/// Mobile Home tab content. The top bar is rendered once by RootShell (see
/// [MobileTopBar]) and shared across all four tabs, matching the reference
/// shell — this widget is pure page content, no Scaffold/AppBar of its own.
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedEntry(index: 0, child: WelcomeHeader(firstName: firstName)),
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
