import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart' show ShellNavigation;
import '../../api/naraak_api.dart' show NaraakApiException;
import '../../data/naraak_repository.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/form_section.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/service_hero.dart';
import '../../widgets/state_views.dart';

class TeleAppointmentScreen extends StatefulWidget {
  const TeleAppointmentScreen({super.key});
  @override
  State<TeleAppointmentScreen> createState() => _TeleAppointmentScreenState();
}

class _TeleAppointmentScreenState extends State<TeleAppointmentScreen> {
  bool _isBooking = false;
  String? _doctorName;

  Future<void> _handleBook() async {
    setState(() => _isBooking = true);
    try {
      final appointment =
          await context.read<AppointmentProvider>().bookTeleAppointment();
      if (!mounted) return;
      setState(() {
        _isBooking = false;
        _doctorName = appointment.doctorName;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      final repository = context.read<NaraakRepository>();
      final message = error is NaraakApiException
          ? repository.friendlyError(error, arabic: false)
          : error.toString().replaceFirst('StateError: ', '');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showAppointments() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ShellNavigation.of(context)?.selectTab(1);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const NaraakAppBar(title: 'Tele-Appointment'),
        body: ResponsivePageFrame(
          maxWidth: 980,
          child: _doctorName != null
              ? SuccessState(
                  title: 'Tele-appointment requested',
                  message: 'Your appointment with $_doctorName was created. The simulated repository will provide the consultation link in Appointments closer to the scheduled time.',
                  actionLabel: 'View My Appointments',
                  onAction: _showAppointments,
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const ServiceHero(
                    imageAsset: 'assets/images/service_booking.jpg',
                    title: 'Care from wherever you are',
                    description: 'Request a tele-appointment and receive the consultation details through Naraak.',
                  ),
                  const SizedBox(height: 24),
                  FormSection(
                    title: 'How tele-appointments work',
                    description: 'This prototype uses synthetic appointment data only.',
                    children: [
                      const _InfoStep(number: '1', title: 'Request the appointment', description: 'Naraak sends the request to the existing simulated appointment service.'),
                      const _InfoStep(number: '2', title: 'Receive confirmation', description: 'The health center confirms the doctor and scheduled time.'),
                      const _InfoStep(number: '3', title: 'Join securely', description: 'The prototype consultation link appears in My Appointments.', isLast: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: NaraakButton(
                          label: 'Request Tele-Appointment',
                          icon: Icons.videocam_outlined,
                          isLoading: _isBooking,
                          onPressed: _isBooking ? null : _handleBook,
                        ),
                      ),
                    ],
                  ),
                ]),
        ),
      );
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({required this.number, required this.title, required this.description, this.isLast = false});
  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: primary.withValues(alpha: .12), shape: BoxShape.circle),
          child: Text(number, style: TextStyle(color: primary, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 3),
          Text(description, style: AppTextStyles.bodySecondary),
        ])),
      ]),
    );
  }
}
