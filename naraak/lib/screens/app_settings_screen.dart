// lib/screens/app_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _appointmentReminders = true;
  bool _requestStatusUpdates = true;
  bool _promotionalMessages = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppTopBar(title: strings.text('appSettingsTitle')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(strings.text('display'), style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(strings.text('darkMode')),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => settings.toggleTheme(),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(strings.text('textSize'),
                              style: AppTextStyles.body),
                          Text('${settings.textScalePercent}%',
                              style: AppTextStyles.bodySecondary),
                        ],
                      ),
                      Slider(
                        value: settings.textScale,
                        min: AppSettingsProvider.minScale,
                        max: AppSettingsProvider.maxScale,
                        divisions: 10,
                        onChanged: settings.setTextSize,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(strings.text('notificationsSection'),
              style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(strings.text('appointmentReminders')),
                  subtitle: Text(strings.text('beforeUpcomingVisits')),
                  value: _appointmentReminders,
                  onChanged: (v) => setState(() => _appointmentReminders = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                SwitchListTile(
                  title: Text(strings.text('requestStatusUpdates')),
                  subtitle: Text(strings.text('submittedRequestStatus')),
                  value: _requestStatusUpdates,
                  onChanged: (v) => setState(() => _requestStatusUpdates = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                SwitchListTile(
                  title: Text(strings.text('promotionalMessages')),
                  subtitle: Text(strings.text('healthCampaigns')),
                  value: _promotionalMessages,
                  onChanged: (v) => setState(() => _promotionalMessages = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
