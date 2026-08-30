import 'package:flutter/material.dart';

import '../../widgets/service_choice_screen.dart';
import 'phc_research_application_screen.dart';
import 'phc_research_applications_list_screen.dart';
import 'phc_research_guidelines_screen.dart';

/// PHC Research Application overview — Phase 3 §30: New Application, My
/// Applications, Application Guidelines.
class PhcResearchScreen extends StatelessWidget {
  const PhcResearchScreen({super.key});

  @override
  Widget build(BuildContext context) => ServiceChoiceScreen(
        title: 'Research Application',
        heroIcon: Icons.biotech_rounded,
        heroAccent: const Color(0xFF7C6FE0),
        heroTitle: 'PHC Research Application',
        heroDescription: 'Apply to conduct research studies at PHC centers.',
        prompt: 'What would you like to do?',
        choices: [
          ServiceChoice(
            icon: Icons.add_circle_outline_rounded,
            title: 'New application',
            description: 'Submit a research application to PHC.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PhcResearchApplicationScreen())),
          ),
          ServiceChoice(
            icon: Icons.list_alt_rounded,
            title: 'My applications',
            description: 'Track the status of your submitted applications.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const PhcResearchApplicationsListScreen())),
          ),
          ServiceChoice(
            icon: Icons.menu_book_outlined,
            title: 'Application guidelines',
            description: 'Read what is required before you apply.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PhcResearchGuidelinesScreen())),
          ),
        ],
      );
}
