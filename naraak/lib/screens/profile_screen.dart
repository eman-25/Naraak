import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/app_settings_provider.dart';
import '../localization/app_localizations.dart';

/// Profile screen — personal details + entry point to Family management
/// and Update Residential Address, per Phase 3 sitemap.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final settings = context.watch<AppSettingsProvider>();
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('profile'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.secondaryIce,
            child: Icon(Icons.person, size: 40, color: AppColors.primaryTeal),
          ),
          const SizedBox(height: 12),
          Center(
              child:
                  Text(profile?.fullName ?? 'Guest', style: AppTextStyles.h2)),
          Center(
              child: Text('CPR: ${profile?.cpr ?? '—'}',
                  style: AppTextStyles.caption)),
          const SizedBox(height: 24),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileRow(
                    label: 'Mobile', value: profile?.mobileNumber ?? '—'),
                const Divider(height: 24),
                _ProfileRow(
                    label: 'Age',
                    value: profile != null ? '${profile.age}' : '—'),
                const Divider(height: 24),
                _ProfileRow(
                    label: 'Assigned Health Center',
                    value: profile?.assignedHealthCenter ?? '—'),
              ],
            ),
          ),
          // ...rest of the screen stays exactly as before
          const SizedBox(height: 16),

          AppCard(
            onTap: () =>
                Navigator.pushNamed(context, '/services/address-update'),
            child: Row(
              children: [
                const Icon(Icons.edit_location_alt,
                    color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Update Residential Address',
                        style: AppTextStyles.body)),
                const Icon(Icons.chevron_right, color: AppColors.neutralGray),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.family_restroom, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        Text('Family Management', style: AppTextStyles.body)),
                const Icon(Icons.chevron_right, color: AppColors.neutralGray),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.brightness_6_outlined,
                      color: AppColors.primaryTeal),
                  title:
                      Text(strings.text('darkMode'), style: AppTextStyles.body),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => settings.toggleTheme(),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.language, color: AppColors.primaryTeal),
                  title: Text(
                      settings.isArabic
                          ? strings.text('arabic')
                          : strings.text('english'),
                      style: AppTextStyles.body),
                  trailing: TextButton(
                    onPressed: () => settings.setLocale(settings.isArabic
                        ? const Locale('en')
                        : const Locale('ar')),
                    child: Text(settings.isArabic
                        ? strings.text('english')
                        : strings.text('arabic')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            onTap: () {
              context.read<UserProfileProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
            child: Row(
              children: [
                const Icon(Icons.logout, color: AppColors.bahrainAccent),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(strings.text('logout'),
                        style: AppTextStyles.body)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
