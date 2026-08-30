import 'package:flutter/material.dart';

import '../../widgets/service_choice_screen.dart';
import 'booking_appointment_screen.dart';
import 'tele_appointment_screen.dart';

class BookingEntryScreen extends StatelessWidget {
  const BookingEntryScreen({super.key});

  @override
  Widget build(BuildContext context) => ServiceChoiceScreen(
        title: 'Book Appointment',
        heroImage: 'assets/images/service_booking.jpg',
        heroTitle: 'Care that fits your day',
        heroDescription:
            'Choose a video consultation or an in-center visit. Tele-appointment remains part of Book Appointment.',
        prompt: 'Choose appointment type',
        choices: [
          ServiceChoice(
            icon: Icons.videocam_outlined,
            title: 'Tele-appointment',
            description: 'Video call with your doctor from a private place.',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TeleAppointmentScreen())),
          ),
          ServiceChoice(
            icon: Icons.medical_services_outlined,
            title: 'In-center appointment',
            description: 'Visit your health center and meet the care team.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BookingAppointmentScreen())),
          ),
        ],
      );
}
