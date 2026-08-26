import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

/// "My Appointments" — Phase 3 Booking Appointments Step 5:
/// view/reschedule/cancel, resolves the Phase 1 reschedule-confusion pain point.
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          final appointments = provider.myAppointments;

          if (appointments.isEmpty) {
            return EmptyStateView(
              icon: Icons.event_busy,
              title: 'No appointments yet',
              message: 'Book an appointment from Services to see it here.',
              actionLabel: 'Book Now',
              onAction: () => Navigator.pushNamed(context, '/services/booking'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, i) {
              final apt = appointments[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(apt.doctorName, style: AppTextStyles.h3),
                          ),
                          const StatusBadge(status: AppStatus.confirmed),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await provider.cancelAppointment(apt.id);
                          },
                          style: TextButton.styleFrom(foregroundColor: AppColors.bahrainAccent),
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
}
