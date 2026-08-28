// lib/screens/appointments_screen.dart  (only the empty-state branch changes)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/status_badge.dart';
import '../widgets/app_top_bar.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadMyAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar: const AppTopBar(title: 'My Appointments', showBackButton: false),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          final appointments = provider.myAppointments;

          if (appointments.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: AppCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: palette.heroGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_note_rounded,
                              size: 36, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text('No appointments yet',
                            style: AppTextStyles.h2,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          'When you book a visit, it\'ll show up here with the doctor, time, and location.',
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: 'Book an Appointment',
                            icon: Icons.add_rounded,
                            onPressed: () => Navigator.pushNamed(
                                context, '/services/booking'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: appointments.length,
            itemBuilder: (context, i) {
              final apt = appointments[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(apt.doctorName,
                                  style: AppTextStyles.h3)),
                          StatusBadge(status: _statusFor(apt.status)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(apt.centerName, style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 4),
                      Text(
                        '${apt.slotDateTime.day}/${apt.slotDateTime.month}/${apt.slotDateTime.year} • '
                        '${apt.slotDateTime.hour.toString().padLeft(2, '0')}:${apt.slotDateTime.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      if (apt.status == 'confirmed')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => provider.cancelAppointment(apt.id),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.error),
                            child: const Text('Cancel'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  AppStatus _statusFor(String status) {
    switch (status) {
      case 'completed':
        return AppStatus.completed;
      case 'cancelled':
        return AppStatus.cancelled;
      case 'confirmed':
      default:
        return AppStatus.confirmed;
    }
  }
}
