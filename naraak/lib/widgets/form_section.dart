import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'naraak_card.dart';

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.description,
  });

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => NaraakCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTextStyles.h3),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!, style: AppTextStyles.bodySecondary),
            ],
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      );
}
