import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'naraak_app_bar.dart';
import 'naraak_card.dart';
import 'responsive_page_frame.dart';
import 'service_hero.dart';

class ServiceChoice {
  const ServiceChoice({required this.icon, required this.title, required this.description, required this.onTap});
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
}

class ServiceChoiceScreen extends StatelessWidget {
  const ServiceChoiceScreen({super.key, required this.title, required this.heroImage, required this.heroTitle, required this.heroDescription, required this.prompt, required this.choices});
  final String title;
  final String heroImage;
  final String heroTitle;
  final String heroDescription;
  final String prompt;
  final List<ServiceChoice> choices;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: NaraakAppBar(title: title),
        body: ResponsivePageFrame(
          maxWidth: 980,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ServiceHero(imageAsset: heroImage, title: heroTitle, description: heroDescription),
            const SizedBox(height: 24),
            Text(prompt, style: AppTextStyles.h2),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final cards = choices.map((choice) => _ServiceChoiceCard(choice: choice)).toList();
              if (constraints.maxWidth < 700) {
                return Column(children: [for (var i = 0; i < cards.length; i++) ...[cards[i], if (i != cards.length - 1) const SizedBox(height: 12)]]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (var i = 0; i < cards.length; i++) ...[Expanded(child: cards[i]), if (i != cards.length - 1) const SizedBox(width: 14)]]);
            }),
          ]),
        ),
      );
}

class _ServiceChoiceCard extends StatelessWidget {
  const _ServiceChoiceCard({required this.choice});
  final ServiceChoice choice;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NaraakCard(
      onTap: choice.onTap,
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: palette.primary.withValues(alpha: isDark ? .2 : .1), borderRadius: BorderRadius.circular(14)), child: Icon(choice.icon, color: palette.primary, size: 25)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(choice.title, style: AppTextStyles.h3), const SizedBox(height: 4), Text(choice.description, style: AppTextStyles.bodySecondary)])),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, color: AppColors.ink500, size: 20),
      ]),
    );
  }
}
