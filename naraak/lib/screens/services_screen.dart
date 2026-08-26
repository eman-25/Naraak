import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class _ServiceEntry {
  final String title;
  final IconData icon;
  final String route;
  final bool higherPriority;

  const _ServiceEntry(this.title, this.icon, this.route, this.higherPriority);
}

/// Services list — grouped by priority tier per Phase 3 Section 2:
/// 6 Higher Priority pinned above a 'More Services' divider, 6 Standard below.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _higherPriority = [
    _ServiceEntry('Booking Appointments', Icons.event_available, '/services/booking', true),
    _ServiceEntry('Medical Reports & Certificates', Icons.description, '/services/medical-reports', true),
    _ServiceEntry('Tele-Appointment Instructions', Icons.videocam, '/services/tele-appointment', true),
    _ServiceEntry('Change Family Doctor', Icons.badge, '/services/change-doctor', true),
    _ServiceEntry('Update Residential Address', Icons.home, '/services/address-update', true),
    _ServiceEntry('Vaccination Records & Certificate', Icons.vaccines, '/services/vaccinations', true),
  ];

  static const _standardPriority = [
    _ServiceEntry('Electronic Hajj Certificate', Icons.flight_takeoff, '/services/hajj-certificate', false),
    _ServiceEntry('Health Fee Exemption Card', Icons.card_membership, '/services/fee-exemption', false),
    _ServiceEntry('Request Mobile Unit Service', Icons.local_shipping, '/services/mobile-unit', false),
    _ServiceEntry('Mammogram Appointment Requests', Icons.favorite, '/services/mammogram', false),
    _ServiceEntry('Sehati Card for Newborns', Icons.child_care, '/services/newborn-sehati', false),
    _ServiceEntry('PHC Research Applications', Icons.science, '/services/phc-research', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Higher Priority', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          ..._higherPriority.map((s) => _ServiceTile(entry: s)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.neutralGray),
          ),
          Text('More Services', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          ..._standardPriority.map((s) => _ServiceTile(entry: s)),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _ServiceEntry entry;
  const _ServiceTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Navigator.pushNamed(context, entry.route),
        child: Row(
          children: [
            Icon(entry.icon, color: AppColors.primaryTeal),
            const SizedBox(width: 14),
            Expanded(child: Text(entry.title, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right, color: AppColors.neutralGray),
          ],
        ),
      ),
    );
  }
}
