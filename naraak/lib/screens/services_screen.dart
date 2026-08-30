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
  // Real photography where an asset exists; null falls back to a gradient +
  // icon-motif tile (Phase 3 §2 allows "abstract healthcare illustrations"
  // in place of photography when no suitable image is available).
  final String? imagePath;
  const _ServiceEntry(this.titleKey, this.description, this.icon, this.route,
      {this.isNew = false, this.imagePath});
}

class _ServiceCategory {
  final String labelKey;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final List<_ServiceEntry> entries;
  const _ServiceCategory(
      this.labelKey, this.subtitle, this.accent, this.icon, this.entries);
}

/// Services tab — pure content (no Scaffold/AppBar; the shell renders the
/// top bar). Matches the reference: page title, search field, teal hero
/// banner, then visually differentiated, colour-accented category sections
/// (Phase 3 §9 — "visually differentiated category cards", "each category
/// may have its own restrained accent").
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _categories = [
    _ServiceCategory(
      'catAppointments',
      'Book and manage your appointments.',
      Color(0xFF0F6B72), // teal / aqua — Appointments & Consultation
      Icons.event_available_rounded,
      [
        _ServiceEntry(
            'booking',
            'Choose a clinic, doctor, and time that suits you.',
            Icons.event_available_rounded,
            '/services/booking',
            imagePath: 'assets/images/service_booking.jpg'),
        _ServiceEntry(
            'mammogram',
            'Check your eligibility and request a screening.',
            Icons.favorite_border_rounded,
            '/services/mammogram',
            imagePath: 'assets/images/service_mammogram.jpg'),
      ],
    ),
    _ServiceCategory(
      'catRecords',
      'Access your medical records and certificates.',
      Color(0xFF2D6CDF), // light blue — My Records
      Icons.folder_shared_rounded,
      [
        _ServiceEntry(
            'vaccinations',
            'View your history or report a missing record.',
            Icons.vaccines_rounded,
            '/services/vaccinations',
            imagePath: 'assets/images/service_vaccination.jpg'),
        _ServiceEntry(
            'medicalReports',
            'View reports or request one from a recent visit.',
            Icons.description_rounded,
            '/services/medical-reports',
            imagePath: 'assets/images/Medical reports and certificates..png'),
        _ServiceEntry(
            'hajj',
            'Access your certificate after the required visit.',
            Icons.workspace_premium_rounded,
            '/services/hajj-certificate',
            imagePath: 'assets/images/Electronic Hajj certificate.jpeg'),
      ],
    ),
    _ServiceCategory(
      'catAdmin',
      'Manage your requests and official services.',
      Color(0xFFB45309), // warm orange / sand — Administrative Services
      Icons.assignment_rounded,
      [
        _ServiceEntry(
            'newborn',
            'Register your newborn and request their health card.',
            Icons.child_care_rounded,
            '/services/newborn-sehati',
            imagePath: 'assets/images/Sehati Card request for newborn.png'),
        _ServiceEntry(
            'addressUpdate',
            'Update your block and see your assigned center.',
            Icons.home_rounded,
            '/services/address-update',
            imagePath: 'assets/images/Update residential address.jpg'),
        _ServiceEntry(
            'feeExemption',
            'Apply with the required supporting documents.',
            Icons.percent_rounded,
            '/services/fee-exemption',
            imagePath: 'assets/images/Health fee exemption card issuance.jpg'),
        _ServiceEntry('changeDoctor', 'Browse doctors with available capacity.',
            Icons.medical_services_rounded, '/services/change-doctor',
            imagePath: 'assets/images/family_doctor_card.jpeg'),
        _ServiceEntry('mobileUnit', 'Ask for a primary care visit at home.',
            Icons.airport_shuttle_rounded, '/services/mobile-unit',
            imagePath: 'assets/images/Request mobile unit service.jpg'),
      ],
    ),
    _ServiceCategory(
      'catResearch',
      'Apply for research and studies.',
      Color(0xFF7C6FE0), // lavender — Research Applications
      Icons.science_rounded,
      [
        _ServiceEntry('research', 'Submit a research application to PHC.',
            Icons.school_rounded, '/services/phc-research',
            isNew: true,
            imagePath:
                'assets/images/Primary healthcare research applications.jpg'),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ServiceCategory> _filtered(AppLocalizations strings) {
    if (_query.trim().isEmpty) return _categories;
    final q = _query.trim().toLowerCase();
    final out = <_ServiceCategory>[];
    for (final cat in _categories) {
      final matches = cat.entries
          .where((e) =>
              strings.text(e.titleKey).toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q))
          .toList();
      if (matches.isNotEmpty) {
        out.add(_ServiceCategory(
            cat.labelKey, cat.subtitle, cat.accent, cat.icon, matches));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.watch<AppSettingsProvider>().palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filtered(strings);

    return ResponsivePageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.raw('NARAAK SERVICES'),
              style: AppTextStyles.overline.copyWith(color: palette.primary)),
          const SizedBox(height: 6),
          Text(strings.raw('Services'),
              style: AppTextStyles.h1.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(strings.raw('All your health services in one place.'),
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 18),
          _SearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            isDark: isDark,
            palette: palette,
          ),
          const SizedBox(height: 22),
          if (_query.trim().isEmpty) ...[
            _ServicesHero(palette: palette),
            const SizedBox(height: 30),
          ],
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 40, color: AppColors.ink300),
                    const SizedBox(height: 10),
                    Text('No services match "$_query"',
                        style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
            )
          else
            for (final category in results) ...[
              _CategoryHeading(
                  label: strings.text(category.labelKey),
                  subtitle: strings.raw(category.subtitle),
                  accent: category.accent,
                  icon: category.icon,
                  isDark: isDark),
              const SizedBox(height: 14),
              _ServiceGrid(entries: category.entries, category: category),
              const SizedBox(height: 30),
            ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final dynamic palette;
  const _SearchField(
      {required this.controller,
      required this.onChanged,
      required this.isDark,
      required this.palette});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkOutline : AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: strings.raw('Search for a service...'),
          hintStyle: AppTextStyles.bodySecondary,
          prefixIcon: Icon(Icons.search_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.ink500),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _CategoryHeading extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final bool isDark;
  const _CategoryHeading({
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.h3.copyWith(fontSize: 17)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  final List<_ServiceEntry> entries;
  final _ServiceCategory category;
  const _ServiceGrid({required this.entries, required this.category});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 960
          ? 3
          : constraints.maxWidth > 620
              ? 2
              : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 216,
        ),
        itemBuilder: (context, i) =>
            _ServiceCard(entry: entries[i], accent: category.accent),
      );
    });
  }
}

class _ServiceCard extends StatefulWidget {
  final _ServiceEntry entry;
  final Color accent;
  const _ServiceCard({required this.entry, required this.accent});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entry = widget.entry;
    final accent = widget.accent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        // Deliberately no `transform:` here — combining a MouseRegion with a
        // transformed hit-testable subtree (InkWell/Material below) trips a
        // known Flutter web bug ("Cannot hit test a render box with no
        // size" / mouse_tracker assertion failures) when the pointer moves
        // during the transform. The shadow/border change below still reads
        // as a hover lift without touching layout geometry.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
            color: _hover
                ? accent.withValues(alpha: 0.5)
                : (isDark ? AppColors.darkOutline : AppColors.outline),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : accent)
                  .withValues(alpha: _hover ? 0.22 : (isDark ? 0.24 : 0.09)),
              blurRadius: _hover ? 20 : 12,
              offset: Offset(0, _hover ? 10 : 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, entry.route),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (entry.imagePath != null)
                        Image.asset(
                          entry.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _IllustrationTile(
                                  icon: entry.icon, accent: accent),
                        )
                      else
                        _IllustrationTile(icon: entry.icon, accent: accent),
                      Positioned(
                        left: 12,
                        bottom: 10,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(entry.icon, size: 18, color: accent),
                        ),
                      ),
                      if (entry.isNew)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.text(entry.titleKey),
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.description,
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient + icon-motif fallback for services without a photography asset
/// yet (Phase 3 §2 allows "abstract healthcare illustrations" in place of
/// real photography).
class _IllustrationTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  const _IllustrationTile({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.85), accent],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -18,
            child: Icon(icon,
                size: 110, color: Colors.white.withValues(alpha: 0.18)),
          ),
          Center(
            child: Icon(icon,
                size: 40, color: Colors.white.withValues(alpha: 0.85)),
          ),
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
    final strings = AppLocalizations.of(context);
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primaryDark, palette.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primaryDark.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(Icons.favorite_rounded,
                size: 200, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Row(
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
                          Text(strings.raw('YOUR HEALTH, YOUR WAY'),
                              style: AppTextStyles.overline.copyWith(
                                  color: const Color(0xFFBCE8E4),
                                  fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(strings.raw('Simple access to primary care.'),
                          style: AppTextStyles.h2.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Text(
                        strings.raw(
                            'Book, request and manage services without visiting the center for every step.'),
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
                      Container(color: Colors.white10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
