import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import 'booking_appointment_screen.dart';
import 'tele_appointment_screen.dart';

/// Book Appointment entry — Phase 3 §3.1/§4.1, Figure 34: the very first
/// decision is Tele-appointment vs In-center, before anything else.
class BookingEntryScreen extends StatelessWidget {
  const BookingEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar: const AppTopBar(title: 'Book Appointment', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose appointment type', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TeleAppointmentScreen()),
              ),
              child: Row(
                children: [
                  _IconBadge(
                      icon: Icons.videocam_outlined, color: palette.primary),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tele-appointment', style: AppTextStyles.h3),
                        SizedBox(height: 2),
                        Text('Video call with your doctor',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink300),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BookingAppointmentScreen()),
              ),
              child: Row(
                children: [
                  _IconBadge(
                      icon: Icons.medical_services_outlined,
                      color: palette.primary),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('In-center', style: AppTextStyles.h3),
                        SizedBox(height: 2),
                        Text('Visit your health center in person',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
