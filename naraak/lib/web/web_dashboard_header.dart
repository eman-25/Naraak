import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show ShellNavigation;
import '../localization/app_localizations.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../widgets/accessibility_bar.dart';
import '../widgets/naraak_logo.dart';

class WebDashboardHeader extends StatelessWidget {
  const WebDashboardHeader(
      {super.key, required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final strings = AppLocalizations.of(context);
    final labels = [
      strings.text('home'),
      strings.text('appointments'),
      strings.text('services'),
      strings.text('profile'),
    ];
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        const NaraakLogo(size: 54),
        const SizedBox(width: 22),
        FilledButton.icon(
          onPressed: () =>
              ShellNavigation.of(context)?.pushNamed('/services/booking'),
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(strings.text('bookAppointment')),
        ),
        const SizedBox(width: 18),
        for (var i = 0; i < labels.length; i++)
          TextButton(
            onPressed: () => onSelect(i),
            child: Text(labels[i],
                style: TextStyle(
                    fontWeight:
                        selected == i ? FontWeight.w800 : FontWeight.w600)),
          ),
        const Spacer(),
        if (MediaQuery.sizeOf(context).width >= 1200) ...[
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const AccessibilityBar(),
          ),
          const SizedBox(width: 12),
        ],
        IconButton(
          tooltip: strings.text('notifications'),
          onPressed: () =>
              ShellNavigation.of(context)?.pushNamed('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 8),
        CircleAvatar(child: Text((profile?.fullName ?? 'G').substring(0, 1))),
        const SizedBox(width: 8),
        Text((profile?.fullName ?? strings.text('guest')).split(' ').first,
            style: AppTextStyles.label),
      ]),
    );
  }
}
