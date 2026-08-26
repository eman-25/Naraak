import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state.dart';

/// Booking Appointments — Phase 3 §3.1 / Phase 4 §4.1 worked example.
/// Flow: Results List -> Slot Confirmation -> Booking Success -> My Appointments.
class BookingAppointmentScreen extends StatefulWidget {
  const BookingAppointmentScreen({super.key});

  @override
  State<BookingAppointmentScreen> createState() => _BookingAppointmentScreenState();
}

class _BookingAppointmentScreenState extends State<BookingAppointmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAvailableSlots();
    });
  }

  Future<void> _openConfirmSheet(Appointment slot) async {
    final provider = context.read<AppointmentProvider>();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _SlotConfirmationSheet(slot: slot),
    );

    if (confirmed == true) {
      final success = await provider.bookSlot(slot.id);
      if (!mounted) return;
      if (success) {
        _showBookingSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Booking failed, please retry.')),
        );
      }
    }
  }

  void _showBookingSuccess() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Booking Confirmed'),
        content: const Text('Your appointment has been booked. A reminder will be sent before your visit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/appointments');
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
      appBar: AppBar(title: const Text('Booking Appointments')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          switch (provider.slotsState) {
            case LoadState.idle:
            case LoadState.loading:
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
            case LoadState.error:
              return EmptyStateView(
                isError: true,
                icon: Icons.error_outline,
                title: 'Something went wrong',
                message: provider.errorMessage ?? 'Please try again.',
                actionLabel: 'Retry',
                onAction: () => provider.loadAvailableSlots(),
              );
            case LoadState.empty:
              return EmptyStateView(
                icon: Icons.event_busy,
                title: 'No slots available',
                message: 'Try a different date, doctor, or nearby health center.',
                actionLabel: 'Reset Filters',
                onAction: () => provider.loadAvailableSlots(),
              );
            case LoadState.success:
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.availableSlots.length,
                itemBuilder: (context, i) {
                  final slot = provider.availableSlots[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => _openConfirmSheet(slot),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available, color: AppColors.primaryTeal),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(slot.doctorName, style: AppTextStyles.h3),
                                Text(slot.centerName, style: AppTextStyles.bodySecondary),
                                Text(
                                  '${slot.slotDateTime.day}/${slot.slotDateTime.month} • '
                                  '${slot.slotDateTime.hour.toString().padLeft(2, '0')}:${slot.slotDateTime.minute.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.neutralGray),
                        ],
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}

class _SlotConfirmationSheet extends StatelessWidget {
  final Appointment slot;
  const _SlotConfirmationSheet({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm Appointment', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Text(slot.doctorName, style: AppTextStyles.h3),
          Text(slot.centerName, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 4),
          Text(
            '${slot.slotDateTime.day}/${slot.slotDateTime.month}/${slot.slotDateTime.year} • '
            '${slot.slotDateTime.hour.toString().padLeft(2, '0')}:${slot.slotDateTime.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Cancellation policy: appointments can be cancelled free of charge up to 2 hours before the scheduled time.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Confirm Booking',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
