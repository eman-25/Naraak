import 'package:flutter/material.dart';

import '../../widgets/service_choice_screen.dart';
import 'mammogram_eligibility_screen.dart';
import 'mammogram_screenings_list_screen.dart';

/// Mammogram Screening overview — Phase 3 §28: Check Eligibility and Book
/// Screening both lead into the same eligibility-gated booking flow (you
/// can't book without first checking eligibility), while My Screenings is
/// its own tracking list.
class MammogramScreeningScreen extends StatelessWidget {
  const MammogramScreeningScreen({super.key});

  @override
  Widget build(BuildContext context) => ServiceChoiceScreen(
        title: 'Mammogram Screening',
        heroImage: 'assets/images/service_mammogram.jpg',
        heroTitle: 'Early detection saves lives',
        heroDescription: 'Check your eligibility and book your screening.',
        prompt: 'What would you like to do?',
        choices: [
          ServiceChoice(
            icon: Icons.fact_check_outlined,
            title: 'Check eligibility',
            description: 'See if you qualify based on age and screening history.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MammogramEligibilityScreen())),
          ),
          ServiceChoice(
            icon: Icons.calendar_month_outlined,
            title: 'Book screening',
            description: 'Start a new screening request.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MammogramEligibilityScreen())),
          ),
          ServiceChoice(
            icon: Icons.history_rounded,
            title: 'My screenings',
            description: 'Track the status of your submitted requests.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MammogramScreeningsListScreen())),
          ),
        ],
      );
}
