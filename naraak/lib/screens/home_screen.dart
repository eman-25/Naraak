import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../localization/app_localizations.dart';

/// Home dashboard — Phase 3 Section 2: upcoming appointments, notifications,
/// assigned health center. All data below is fictional demo data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('appName'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
              '${strings.text('welcome')}, ${profile?.fullName ?? strings.text('guest')}',
              style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('${strings.text('cpr')}: ${profile?.cpr ?? '—'}',
              style: AppTextStyles.caption),
          const SizedBox(height: 20),

          AppCard(
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.text('healthCenter'),
                          style: AppTextStyles.caption),
                      Text(
                          profile?.assignedHealthCenter ??
                              strings.text('notSet'),
                          style: AppTextStyles.h3),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ...rest of the screen stays exactly as before
          const SizedBox(height: 16),

          Text(strings.text('upcoming'), style: AppTextStyles.h3),
          const SizedBox(height: 8),
          AppCard(
            onTap: () => Navigator.pushNamed(context, '/appointments'),
            child: Row(
              children: [
                const Icon(Icons.event_available, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. Layla Al-Ansari', style: AppTextStyles.body),
                      Text('Tomorrow, 10:00 AM — Hoora Health Center',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.neutralGray),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(strings.text('notifications'), style: AppTextStyles.h3),
          const SizedBox(height: 8),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your Hepatitis B (3rd dose) record looks incomplete — tap Vaccination Records to review.',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
