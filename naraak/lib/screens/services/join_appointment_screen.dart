import 'package:flutter/material.dart';
import '../../providers/app_settings_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

/// Join Appointment — Phase 3 §4.1 tele path: on the appointment day, the
/// join link is reached from Appointments and opens this instructions
/// screen before handing off to WhatsApp/Teams.
class JoinAppointmentScreen extends StatelessWidget {
  final String doctorName;
  const JoinAppointmentScreen({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar: const AppTopBar(title: 'Join Appointment'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam_rounded,
                    size: 46, color: palette.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'This will open a WhatsApp video call or Microsoft Teams '
                'session with $doctorName. Ensure you are in a quiet, '
                'private location.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Open Video Call',
                  icon: Icons.video_call_rounded,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Video calling isn\'t wired up in this demo.')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
