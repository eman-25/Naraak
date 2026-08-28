import 'package:flutter/material.dart';
import '../../widgets/external_api_service_view.dart';
import '../../widgets/app_top_bar.dart';

class TeleAppointmentScreen extends StatelessWidget {
  const TeleAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Tele-Appointment Instructions'),
      body: const ExternalApiServiceView(
          title: 'Tele-Appointment Instructions', icon: Icons.videocam),
    );
  }
}
