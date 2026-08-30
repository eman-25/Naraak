import 'package:flutter/material.dart';

import '../../widgets/service_choice_screen.dart';
import 'medical_reports_list_screen.dart';
import 'request_medical_report_screen.dart';

class MedicalReportsScreen extends StatelessWidget {
  const MedicalReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => ServiceChoiceScreen(
        title: 'Medical Reports',
        heroImage: 'assets/images/service_medical_reports.jpg',
        heroTitle: 'Reports in one secure place',
        heroDescription:
            'View available PHC reports or request a report from a previous visit.',
        prompt: 'Choose an option',
        choices: [
          ServiceChoice(
            icon: Icons.folder_open_outlined,
            title: 'View my reports',
            description: 'See and download your available PHC reports.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MedicalReportsListScreen())),
          ),
          ServiceChoice(
            icon: Icons.note_add_outlined,
            title: 'Request a report',
            description: 'Submit a medical report request for a recent visit.',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RequestMedicalReportScreen())),
          ),
        ],
      );
}
