// lib/web/web_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../providers/app_settings_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/user_profile_provider.dart';
import '../screens/home_screen.dart';
import '../theme/app_colors.dart';
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
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 64),
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
                    const SizedBox(height: 56),
                    Center(
                      child: Column(
                        children: [
                          Text('Our Services',
                              style: AppTextStyles.overline.copyWith(
                                  color: palette.primary, letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text('Everything your care needs in one place',
                              style: AppTextStyles.h2, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _DepartmentGrid(),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      child: Stack(
        // Non-positioned children (the content Padding below) size this
        // Stack; Positioned.fill children then just match whatever that
        // ends up being. A previous fixed-height version clipped/overflowed
        // whenever text wrapped or the user bumped up text size in
        // Settings — this can never overflow, it just grows.
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: palette.primary),
            ),
          ),
          Positioned.fill(
            child: Container(color: palette.primary.withValues(alpha: 0.82)),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Good morning, $firstName',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontSize: 44,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Compassionate primary care, always within reach.',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Text(
                        'Your virtual primary healthcare companion — appointments, '
                        'records, and requests, all in one place.',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _HeroAction(
                          icon: Icons.event_available_rounded,
                          label: 'Book Appointment',
                          filled: true,
                          onTap: () => Navigator.pushNamed(
                              context, '/services/booking'),
                        ),
                        _HeroAction(
                          icon: Icons.description_outlined,
                          label: 'View Requests',
                          filled: false,
                          onTap: () => Navigator.pushNamed(
                              context, '/pending-requests'),
                        ),
                        _HeroAction(
                          icon: Icons.grid_view_rounded,
                          label: 'All Services',
                          filled: false,
                          onTap: () =>
                              ShellNavigation.of(context)?.selectTab(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const _TrustStatsRow(),
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
        minimumSize: const Size(64, 48),
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

class _TrustStatsRow extends StatelessWidget {
  const _TrustStatsRow();

  static const _stats = [
    ('5', 'Health Centers'),
    ('24/7', 'Digital Access'),
    ('100%', 'Secure & Private'),
    ('1 App', 'For The Whole Family'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 16,
      children: _stats
          .map((s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.$1,
                      style: AppTextStyles.h1.copyWith(
                          color: Colors.white, fontSize: 26)),
                  Text(s.$2,
                      style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85))),
                ],
              ))
          .toList(),
    );
  }
}

class _DepartmentGrid extends StatelessWidget {
  const _DepartmentGrid();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tiles = [
      ('Book Appointment', Icons.event_available_rounded, '/services/booking'),
      ('Medical Reports', Icons.description_rounded, '/services/medical-reports'),
      ('Vaccinations', Icons.vaccines_rounded, '/services/vaccinations'),
      ('Hajj Certificate', Icons.workspace_premium_rounded, '/services/hajj-certificate'),
      ('Fee Exemption', Icons.percent_rounded, '/services/fee-exemption'),
      ('Change Doctor', Icons.medical_services_rounded, '/services/change-doctor'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, i) {
        final (label, icon, route) = tiles[i];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.darkOutline : AppColors.outline,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.primary, width: 1.4),
                  ),
                  child: Icon(icon, color: palette.primary, size: 24),
                ),
                const Spacer(),
                Text(label,
                    style: AppTextStyles.h3.copyWith(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
