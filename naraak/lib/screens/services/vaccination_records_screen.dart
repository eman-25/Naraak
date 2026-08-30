import 'package:flutter/material.dart';

import '../../widgets/service_choice_screen.dart';
import 'missing_vaccination_screen.dart';
import 'vaccination_records_list_screen.dart';

class VaccinationRecordsScreen extends StatelessWidget {
  const VaccinationRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) => ServiceChoiceScreen(
        title: 'Vaccination Records',
        heroImage: 'assets/images/service_vaccination.jpg',
        heroTitle: 'Your vaccination history',
        heroDescription:
            'Review your recorded vaccinations, download a certificate, or report a missing entry.',
        prompt: 'What would you like to do?',
        choices: [
          ServiceChoice(
            icon: Icons.description_outlined,
            title: 'View or download records',
            description: 'Open your vaccination history and certificate.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VaccinationRecordsListScreen())),
          ),
          ServiceChoice(
            icon: Icons.flag_outlined,
            title: 'Report a missing vaccination',
            description: 'Submit a request from within Vaccination Records.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MissingVaccinationScreen())),
          ),
        ],
      );
}
