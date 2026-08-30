// lib/screens/app_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/app_settings_provider.dart';
import '../responsive/breakpoints.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

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
    final web = isWebWidth(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              web ? 32 : 20,
              web ? 28 : 20,
              web ? 32 : 20,
              48,
            ),
            children: [
              _PageHeading(title: strings.text('appSettingsTitle')),
              const SizedBox(height: 28),
              _SectionLabel(strings.text('display')),
              const SizedBox(height: 10),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      title: Text(strings.text('darkMode'),
                          style: AppTextStyles.body),
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (_) => settings.toggleTheme(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
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
                          const SizedBox(height: 8),
                          Slider(
                            value: settings.textScale,
                            min: AppSettingsProvider.minScale,
                            max: AppSettingsProvider.maxScale,
                            divisions: 10,
                            label: '${settings.textScalePercent}%',
                            onChanged: settings.setTextSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _SectionLabel(strings.text('notificationsSection')),
              const SizedBox(height: 10),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _NotificationToggle(
                      title: strings.text('appointmentReminders'),
                      subtitle: strings.text('beforeUpcomingVisits'),
                      value: _appointmentReminders,
                      onChanged: (value) =>
                          setState(() => _appointmentReminders = value),
                    ),
                    const _SettingsDivider(),
                    _NotificationToggle(
                      title: strings.text('requestStatusUpdates'),
                      subtitle: strings.text('submittedRequestStatus'),
                      value: _requestStatusUpdates,
                      onChanged: (value) =>
                          setState(() => _requestStatusUpdates = value),
                    ),
                    const _SettingsDivider(),
                    _NotificationToggle(
                      title: strings.text('promotionalMessages'),
                      subtitle: strings.text('healthCampaigns'),
                      value: _promotionalMessages,
                      onChanged: (value) =>
                          setState(() => _promotionalMessages = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Text(title, style: AppTextStyles.h2),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.overline);
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(subtitle, style: AppTextStyles.bodySecondary),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1),
    );
  }
}
