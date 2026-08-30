import 'package:flutter/material.dart';

import '../../widgets/service_choice_screen.dart';
import 'mobile_unit_request_screen.dart';
import 'mobile_unit_requests_list_screen.dart';
import 'mobile_unit_schedule_screen.dart';

/// Mobile Unit Service overview — Phase 3 §27: New Request, My Requests,
/// Visit Schedule.
class MobileUnitScreen extends StatelessWidget {
  const MobileUnitScreen({super.key});

  @override
  Widget build(BuildContext context) => ServiceChoiceScreen(
        title: 'Mobile Unit Service',
        heroIcon: Icons.airport_shuttle_rounded,
        heroAccent: const Color(0xFF2D6CDF),
        heroTitle: 'Healthcare at your doorstep',
        heroDescription:
            'Request a primary care visit at home for you or a linked family member.',
        prompt: 'What would you like to do?',
        choices: [
          ServiceChoice(
            icon: Icons.add_circle_outline_rounded,
            title: 'New request',
            description: 'Ask for a primary care visit at home.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MobileUnitRequestScreen())),
          ),
          ServiceChoice(
            icon: Icons.list_alt_rounded,
            title: 'My requests',
            description: 'Track the status of your visit requests.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MobileUnitRequestsListScreen())),
          ),
          ServiceChoice(
            icon: Icons.event_available_outlined,
            title: 'Visit schedule',
            description: 'See your next confirmed visit.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MobileUnitScheduleScreen())),
          ),
        ],
      );
}
