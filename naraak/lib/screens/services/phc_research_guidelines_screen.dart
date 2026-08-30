import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/naraak_card.dart';
import '../../widgets/responsive_page_frame.dart';

/// Application Guidelines — Phase 3 §30: reference material shown before
/// starting a PHC research application.
class PhcResearchGuidelinesScreen extends StatelessWidget {
  const PhcResearchGuidelinesScreen({super.key});

  static const _guidelines = [
    (
      'Eligibility',
      'Applications are open to students, employees and delegates '
          'affiliated with a recognized academic or research institution.',
    ),
    (
      'Supervisor sign-off',
      'A named supervisor must be reachable for verification before the '
          'application can be approved by the PHC Ethics Committee.',
    ),
    (
      'Required documents',
      'A research proposal and ethics approval are mandatory. Data '
          'collection tools and supporting letters are recommended where relevant.',
    ),
    (
      'Review timeline',
      'Applications are typically reviewed within 4–6 weeks. You can '
          'track progress at any time under My Applications.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NaraakAppBar(title: 'Application Guidelines'),
      body: ResponsivePageFrame(
        maxWidth: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (title, body) in _guidelines)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: NaraakCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 18, color: AppColors.primaryTeal),
                          const SizedBox(width: 8),
                          Text(title, style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(body, style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
