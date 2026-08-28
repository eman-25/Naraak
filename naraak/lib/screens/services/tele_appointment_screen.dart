import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';
import '../../main.dart' show ShellNavigation;

/// Tele-Appointment — Phase 3 §3.1/§4.1: booking happens by phone call to
/// the health center, not through an in-app slot list. A staff member
/// calls back to confirm and sends the video-call link.
class TeleAppointmentScreen extends StatefulWidget {
  const TeleAppointmentScreen({super.key});

  @override
  State<TeleAppointmentScreen> createState() => _TeleAppointmentScreenState();
}

class _TeleAppointmentScreenState extends State<TeleAppointmentScreen> {
  bool _isBooking = false;

  Future<void> _handleBook() async {
    setState(() => _isBooking = true);
    final appointment =
        await context.read<AppointmentProvider>().bookTeleAppointment();
    if (!mounted) return;
    setState(() => _isBooking = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Appointment Scheduled'),
        content: Text(
          'Your tele-appointment with ${appointment.doctorName} has been '
          'scheduled. You\'ll find the join link in My Appointments closer '
          'to the time.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).popUntil((route) => route.isFirst);
              ShellNavigation.of(context)?.selectTab(1);
            },
            child: const Text('View My Appointments'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Tele-Appointment'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Booking is done by phone call to your health center. A '
                'staff member will contact you to confirm the appointment '
                'and send a video call link.',
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Book Appointment',
                isLoading: _isBooking,
                onPressed: _isBooking ? null : _handleBook,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
