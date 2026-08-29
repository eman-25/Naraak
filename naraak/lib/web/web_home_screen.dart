// lib/web/web_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/app_settings_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../screens/home_screen.dart';
import '../theme/app_text_styles.dart';

/// Desktop dashboard home — a wide hero banner (same Bahrain skyline photo
/// used on splash/login, tinted with the selected accent color) over the
/// same "Good morning" dashboard content as mobile, laid out in a grid
/// instead of a single scrolling column.
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
    final firstName = (profile?.fullName ?? 'there').split(' ').first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(firstName: firstName, palette: palette),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Family Doctor', style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              const FamilyDoctorCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Next Appointment',
                                  style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              const NextAppointmentCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const PendingRequestsCard(),
                    const SizedBox(height: 40),
                    Text('Top services', style: AppTextStyles.h3),
                    const SizedBox(height: 14),
                    const TopServicesGrid(crossAxisCount: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String firstName;
  final dynamic palette;
  const _Hero({required this.firstName, required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: palette.primary),
          ),
          Container(color: palette.primary.withValues(alpha: 0.80)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Good morning, $firstName',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your virtual primary healthcare companion — appointments, '
                      'records, and requests, all in one place.',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        _HeroAction(
                          icon: Icons.event_available_rounded,
                          label: 'Book Appointment',
                          filled: true,
                          onTap: () => Navigator.pushNamed(
                              context, '/services/booking'),
                        ),
                        const SizedBox(width: 14),
                        _HeroAction(
                          icon: Icons.description_outlined,
                          label: 'View Requests',
                          filled: false,
                          onTap: () => Navigator.pushNamed(
                              context, '/pending-requests'),
                        ),
                        const SizedBox(width: 14),
                        _HeroAction(
                          icon: Icons.grid_view_rounded,
                          label: 'All Services',
                          filled: false,
                          onTap: () =>
                              ShellNavigation.of(context)?.selectTab(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _HeroAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? Colors.white : Colors.white.withValues(alpha: 0.14),
        foregroundColor: filled ? const Color(0xFF0E7C7B) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: filled
              ? BorderSide.none
              : BorderSide(color: Colors.white.withValues(alpha: 0.4)),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
