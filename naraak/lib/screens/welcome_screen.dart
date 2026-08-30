import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/naraak_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const NaraakLogo(size: 58),
                      const Spacer(),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('EN')),
                          ButtonSegment(value: 'ar', label: Text('عربي')),
                        ],
                        selected: {settings.locale.languageCode},
                        onSelectionChanged: (value) =>
                            settings.setLocale(Locale(value.first)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 230,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/images/splash.jpg',
                              fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  (isDark
                                          ? AppColors.darkBg
                                          : AppColors.primaryDark)
                                      .withValues(alpha: .72),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Primary Healthcare, Closer to You',
                      style: AppTextStyles.display),
                  const SizedBox(height: 12),
                  Text(
                    'All your PHC services in one place. Fast. Easy. Secure.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 22),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Benefit(icon: Icons.bolt_rounded, label: 'Fast'),
                      _Benefit(icon: Icons.lock_rounded, label: 'Secure'),
                      _Benefit(icon: Icons.touch_app_rounded, label: 'Easy'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Login with eKey',
                    icon: Icons.fingerprint_rounded,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Learn more about Naraak',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (context) => const Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Text(
                          'Naraak is a prototype digital e-services platform '
                          'for Bahrain Primary Healthcare Centers.',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 7),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
