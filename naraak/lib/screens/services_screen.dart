// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../localization/app_localizations.dart';
import '../widgets/app_top_bar.dart';

class _ServiceEntry {
  final String titleKey;
  final String
      subtitleKey; // short one-liner, adds density instead of empty space
  final IconData icon;
  final String route;
  final Color color;
  const _ServiceEntry(
      this.titleKey, this.subtitleKey, this.icon, this.route, this.color);
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _higherPriority = [
    _ServiceEntry('booking', 'Find and reserve a slot',
        Icons.event_available_rounded, '/services/booking', AppColors.primary),
    _ServiceEntry(
        'medicalReports',
        'Request or download reports',
        Icons.description_rounded,
        '/services/medical-reports',
        AppColors.secondary),
    _ServiceEntry(
        'teleAppointment',
        'Join your video consultation',
        Icons.videocam_rounded,
        '/services/tele-appointment',
        Color(0xFF7C5CBF)),
    _ServiceEntry('changeDoctor', 'Browse and switch doctors',
        Icons.badge_rounded, '/services/change-doctor', Color(0xFF1E9E6B)),
    _ServiceEntry('addressUpdate', 'Update your registered address',
        Icons.home_rounded, '/services/address-update', Color(0xFFDB8A1E)),
    _ServiceEntry('vaccinations', 'View records & certificates',
        Icons.vaccines_rounded, '/services/vaccinations', Color(0xFF2D6CDF)),
  ];

  static const _standardPriority = [
    _ServiceEntry(
        'hajj',
        'Track your certificate status',
        Icons.flight_takeoff_rounded,
        '/services/hajj-certificate',
        Color(0xFF0E7C7B)),
    _ServiceEntry(
        'feeExemption',
        'Apply for a fee exemption card',
        Icons.card_membership_rounded,
        '/services/fee-exemption',
        Color(0xFFDB8A1E)),
    _ServiceEntry(
        'mobileUnit',
        'Request a home visit',
        Icons.local_shipping_rounded,
        '/services/mobile-unit',
        Color(0xFF2D6CDF)),
    _ServiceEntry('mammogram', 'Book a screening appointment',
        Icons.favorite_rounded, '/services/mammogram', Color(0xFFD64550)),
    _ServiceEntry(
        'newborn',
        'Register a newborn\'s card',
        Icons.child_care_rounded,
        '/services/newborn-sehati',
        Color(0xFF7C5CBF)),
    _ServiceEntry('research', 'Submit a research proposal',
        Icons.science_rounded, '/services/phc-research', Color(0xFF1E9E6B)),
  ];

  List<_ServiceEntry> _filter(List<_ServiceEntry> list, AppLocalizations s) {
    if (_query.isEmpty) return list;
    return list
        .where((e) =>
            s.text(e.titleKey).toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final higher = _filter(_higherPriority, strings);
    final standard = _filter(_standardPriority, strings);
    final noResults = higher.isEmpty && standard.isEmpty;

    return Scaffold(
      appBar: AppTopBar(title: strings.text('services'), showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search services…',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.ink500),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _query = '';
                      }),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 22),
          if (higher.isNotEmpty) ...[
            _SectionLabel(text: strings.text('higherPriority')),
            const SizedBox(height: 10),
            _ServiceListCard(entries: higher),
            const SizedBox(height: 26),
          ],
          if (standard.isNotEmpty) ...[
            _SectionLabel(text: strings.text('moreServices')),
            const SizedBox(height: 10),
            _ServiceListCard(entries: standard),
          ],
          if (noResults)
            Padding(
              padding: const EdgeInsets.only(top: 72),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                        color: AppColors.ink050, shape: BoxShape.circle),
                    child: const Icon(Icons.search_off_rounded,
                        size: 32, color: AppColors.ink300),
                  ),
                  const SizedBox(height: 14),
                  Text('No services match "$_query"',
                      style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text.toUpperCase(), style: AppTextStyles.overline),
    );
  }
}

/// One AppCard housing all rows in a section, with dividers between —
/// this is what actually fixes the dead-space problem: rows are as tall
/// as their content needs to be, not stretched to fill a grid cell.
class _ServiceListCard extends StatelessWidget {
  final List<_ServiceEntry> entries;
  const _ServiceListCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Column(
            children: [
              _ServiceRow(entry: e),
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
  const _ServiceRow({required this.entry});

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: entry.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(entry.icon, color: entry.color, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.text(entry.titleKey),
                      style: AppTextStyles.h3.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(strings.text(entry.subtitleKey),
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}
