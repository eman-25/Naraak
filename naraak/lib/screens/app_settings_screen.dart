// lib/screens/app_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      appBar: const AppTopBar(title: 'App Settings'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('DISPLAY', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
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
                          const Text('Text Size', style: AppTextStyles.body),
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
          const Text('NOTIFICATIONS', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Appointment Reminders'),
                  subtitle: const Text('Get notified before upcoming visits'),
                  value: _appointmentReminders,
                  onChanged: (v) => setState(() => _appointmentReminders = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                SwitchListTile(
                  title: const Text('Request Status Updates'),
                  subtitle:
                      const Text('When a submitted request changes status'),
                  value: _requestStatusUpdates,
                  onChanged: (v) => setState(() => _requestStatusUpdates = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                SwitchListTile(
                  title: const Text('Promotional Messages'),
                  subtitle: const Text('Health campaigns and PHC news'),
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
