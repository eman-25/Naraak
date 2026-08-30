// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations.dart';
import '../widgets/responsive_page_frame.dart';

class _ServiceEntry {
  final String titleKey;
  final String description;
  final IconData icon;
  final String route;
  final bool isNew;
  const _ServiceEntry(this.titleKey, this.description, this.icon, this.route,
      {this.isNew = false});
}

class _ServiceCategory {
  final String labelKey;
  final String subtitle;
  final List<_ServiceEntry> entries;
  const _ServiceCategory(this.labelKey, this.subtitle, this.entries);
}

/// Services tab — pure content (no Scaffold/AppBar; the shell renders the
/// top bar). Matches the reference: page title, teal hero banner, then
/// grouped service rows with a short description under each title.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _categories = [
    _ServiceCategory('catAppointments', 'Find the right kind of care.', [
      _ServiceEntry('booking', 'Choose a clinic, doctor, and time that suits you.',
          Icons.event_available_rounded, '/services/booking'),
      _ServiceEntry('mammogram', 'Check your eligibility and request a screening.',
          Icons.favorite_border_rounded, '/services/mammogram'),
    ]),
    _ServiceCategory(
        'catRecords', 'Your health information, ready when you need it.', [
      _ServiceEntry('vaccinations', 'View your history or report a missing record.',
          Icons.vaccines_rounded, '/services/vaccinations'),
      _ServiceEntry('medicalReports', 'View reports or request one from a recent visit.',
          Icons.description_rounded, '/services/medical-reports'),
      _ServiceEntry('hajj', 'Access your certificate after the required visit.',
          Icons.workspace_premium_rounded, '/services/hajj-certificate'),
    ]),
    _ServiceCategory('catAdmin', 'Manage everyday healthcare needs.', [
      _ServiceEntry('newborn', 'Register your newborn and request their health card.',
          Icons.child_care_rounded, '/services/newborn-sehati'),
      _ServiceEntry('addressUpdate', 'Update your block and see your assigned center.',
          Icons.home_rounded, '/services/address-update'),
      _ServiceEntry('feeExemption', 'Apply with the required supporting documents.',
          Icons.percent_rounded, '/services/fee-exemption'),
      _ServiceEntry('changeDoctor', 'Browse doctors with available capacity.',
          Icons.medical_services_rounded, '/services/change-doctor'),
      _ServiceEntry('mobileUnit', 'Ask for a primary care visit at home.',
          Icons.airport_shuttle_rounded, '/services/mobile-unit'),
    ]),
    _ServiceCategory(
        'catResearch', 'For students, employees and healthcare partners.', [
      _ServiceEntry('research', 'Submit a research application to PHC.',
          Icons.school_rounded, '/services/phc-research',
          isNew: true),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.watch<AppSettingsProvider>().palette;

    return ResponsivePageFrame(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NARAAK SERVICES',
                style: AppTextStyles.overline.copyWith(color: palette.primary)),
            const SizedBox(height: 6),
            Text('How can we help?', style: AppTextStyles.h1.copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text('Access Primary Healthcare Center services for you and your family.',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 20),
            _ServicesHero(palette: palette),
            const SizedBox(height: 30),
            for (final category in _categories) ...[
              Text(strings.text(category.labelKey),
                  style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(category.subtitle, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 12),
              _ServiceGrid(entries: category.entries, palette: palette),
              const SizedBox(height: 26),
            ],
          ],
      ),
    );
  }
}

class _ServicesHero extends StatelessWidget {
  final dynamic palette;
  const _ServicesHero({required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Container(
      decoration: BoxDecoration(
        color: palette.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 26, 20, 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded,
                            size: 15, color: Color(0xFFBCE8E4)),
                        const SizedBox(width: 6),
                        Text('YOUR HEALTH, YOUR WAY',
                            style: AppTextStyles.overline.copyWith(
                                color: const Color(0xFFBCE8E4), fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Simple access to primary care.',
                        style: AppTextStyles.h2.copyWith(
                            color: Colors.white, fontSize: 22, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Book, request and manage services without visiting the '
                      'center for every step.',
                      style: AppTextStyles.bodySecondary
                          .copyWith(color: const Color(0xFFCEE5E4)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 260,
              child: Image.asset(
                'assets/images/service_booking.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  final List<_ServiceEntry> entries;
  final dynamic palette;
  const _ServiceGrid({required this.entries, required this.palette});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 960
          ? 3
          : constraints.maxWidth > 560
              ? 2
              : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
          mainAxisExtent: columns == 1 ? 104 : 112,
        ),
        itemBuilder: (context, i) =>
            _ServiceRow(entry: entries[i], palette: palette),
      );
    });
  }
}

class _ServiceRow extends StatelessWidget {
  final _ServiceEntry entry;
  final dynamic palette;
  const _ServiceRow({required this.entry, required this.palette});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, entry.route),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.outline),
          borderRadius: BorderRadius.circular(13),
          color: isDark ? AppColors.darkSurface : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(entry.icon, color: palette.primary, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.text(entry.titleKey),
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.description,
                    style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (entry.isNew) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('NEW',
                    style: TextStyle(
                        color: palette.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.ink300, size: 20),
          ],
        ),
      ),
    );
  }
}
