import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

class JoinAppointmentScreen extends StatefulWidget {
  final String doctorName;
  final String? appointmentId;
  const JoinAppointmentScreen(
      {super.key, required this.doctorName, this.appointmentId});
  @override
  State<JoinAppointmentScreen> createState() => _JoinAppointmentScreenState();
}

class _JoinAppointmentScreenState extends State<JoinAppointmentScreen> {
  late final Future<Map<String, dynamic>> _details;
  @override
  void initState() {
    super.initState();
    _details = context
        .read<AppointmentProvider>()
        .getTeleDetails(widget.appointmentId ?? 'APT-TELE-001');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    return Scaffold(
        appBar: const AppTopBar(title: 'Join Appointment'),
        body: FutureBuilder<Map<String, dynamic>>(
            future: _details,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(
                    child: Text(
                        context.read<AppointmentProvider>().errorMessage ??
                            'Could not load appointment details.'));
              final data = snapshot.data!;
              final instructions =
                  List<String>.from(data['instructions'] as List);
              return ListView(padding: const EdgeInsets.all(24), children: [
                Icon(Icons.videocam_rounded, size: 72, color: palette.primary),
                const SizedBox(height: 20),
                Text(widget.doctorName,
                    textAlign: TextAlign.center, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Text(data['privacyMessage'] as String,
                    textAlign: TextAlign.center, style: AppTextStyles.body),
                const SizedBox(height: 18),
                ...instructions.map((v) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(v))),
                const SizedBox(height: 18),
                AppButton(
                    label: 'Open Video Call',
                    icon: Icons.video_call_rounded,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Join link: ${data['joinLink']}')))),
                TextButton(
                    onPressed: () async {
                      final ok = await context
                          .read<AppointmentProvider>()
                          .resendTeleLink(
                              widget.appointmentId ?? 'APT-TELE-001');
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                ok ? 'Link sent.' : 'Could not resend link.')));
                    },
                    child: const Text('Resend consultation link'))
              ]);
            }));
  }
}
