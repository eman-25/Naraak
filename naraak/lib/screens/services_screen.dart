// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../localization/app_localizations.dart';
import '../widgets/app_top_bar.dart';

class _ServiceEntry {
  final String titleKey;
  final IconData icon;
  final String route;
  const _ServiceEntry(this.titleKey, this.icon, this.route);
}

class _ServiceCategory {
  final String labelKey;
  final List<_ServiceEntry> entries;
  const _ServiceCategory(this.labelKey, this.entries);
}

/// "All Services" — grouped exactly per the Phase 3 sitemap (Section 2.3):
/// Appointments & Consultation, My Records, Administrative Services,
/// Research Applications.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _categories = [
    _ServiceCategory('catAppointments', [
      _ServiceEntry(
          'booking', Icons.event_available_rounded, '/services/booking'),
      _ServiceEntry(
          'mammogram', Icons.favorite_border_rounded, '/services/mammogram'),
    ]),
    _ServiceCategory('catRecords', [
      _ServiceEntry(
          'vaccinations', Icons.vaccines_rounded, '/services/vaccinations'),
      _ServiceEntry('medicalReports', Icons.description_rounded,
          '/services/medical-reports'),
      _ServiceEntry('hajj', Icons.workspace_premium_rounded,
          '/services/hajj-certificate'),
    ]),
    _ServiceCategory('catAdmin', [
      _ServiceEntry(
          'newborn', Icons.child_care_rounded, '/services/newborn-sehati'),
      _ServiceEntry(
          'addressUpdate', Icons.home_rounded, '/services/address-update'),
      _ServiceEntry(
          'feeExemption', Icons.percent_rounded, '/services/fee-exemption'),
      _ServiceEntry('changeDoctor', Icons.medical_services_rounded,
          '/services/change-doctor'),
      _ServiceEntry(
          'mobileUnit', Icons.airport_shuttle_rounded, '/services/mobile-unit'),
    ]),
    _ServiceCategory('catResearch', [
      _ServiceEntry('research', Icons.school_rounded, '/services/phc-research'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.watch<AppSettingsProvider>().palette;

    return Scaffold(
      appBar:
          AppTopBar(title: strings.text('allServices'), showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          for (final category in _categories) ...[
            _CategoryLabel(text: strings.text(category.labelKey)),
            const SizedBox(height: 10),
            _ServiceListCard(
                entries: category.entries, iconColor: palette.primary),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  final String text;
  const _CategoryLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          color: palette.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ServiceListCard extends StatelessWidget {
  final List<_ServiceEntry> entries;
  final Color iconColor;
  const _ServiceListCard({required this.entries, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Column(
            children: [
              _ServiceRow(entry: e, iconColor: iconColor),
              if (i != entries.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final _ServiceEntry entry;
  final Color iconColor;
  const _ServiceRow({required this.entry, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, entry.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(entry.icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                strings.text(entry.titleKey),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}
