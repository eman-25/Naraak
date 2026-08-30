import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appointment_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/form_section.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/state_views.dart';

class JoinAppointmentScreen extends StatefulWidget {
  const JoinAppointmentScreen({super.key, required this.doctorName, this.appointmentId});
  final String doctorName;
  final String? appointmentId;
  @override
  State<JoinAppointmentScreen> createState() => _JoinAppointmentScreenState();
}

class _JoinAppointmentScreenState extends State<JoinAppointmentScreen> {
  late Future<Map<String, dynamic>> _details;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _details = context.read<AppointmentProvider>().getTeleDetails(widget.appointmentId ?? 'APT-TELE-001');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const NaraakAppBar(title: 'Join Appointment'),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _details,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return ErrorState(
                title: 'Could not load appointment',
                message: context.read<AppointmentProvider>().errorMessage ?? 'Check the appointment and try again.',
                actionLabel: 'Try Again',
                onAction: () => setState(_load),
              );
            }
            final data = snapshot.data!;
            final instructions = List<String>.from(data['instructions'] as List);
            return ResponsivePageFrame(
              maxWidth: 760,
              child: Column(children: [
                Icon(Icons.video_call_rounded, size: 70, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 14),
                Text(widget.doctorName, textAlign: TextAlign.center, style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Text(data['privacyMessage'] as String, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 24),
                FormSection(
                  title: 'Before you join',
                  children: [
                    for (final instruction in instructions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 32,
                        leading: Icon(Icons.check_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                        title: Text(instruction),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: NaraakButton(
                        label: 'Open Video Call',
                        icon: Icons.video_call_rounded,
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Join link: ' + data['joinLink'].toString())),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final ok = await context.read<AppointmentProvider>().resendTeleLink(widget.appointmentId ?? 'APT-TELE-001');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Consultation link sent.' : 'Could not resend the link.')),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Resend consultation link'),
                    ),
                  ],
                ),
              ]),
            );
          },
        ),
      );
}
