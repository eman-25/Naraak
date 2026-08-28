// lib/widgets/accessibility_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_text_styles.dart';

/// Quick accessibility controls, per Phase 3 §2.2: text size (A-/A+),
/// dark/light mode toggle, Arabic/English toggle, page-reader icon.
/// Lives in the Home header so it's reachable without a settings dive.
class AccessibilityBar extends StatelessWidget {
  const AccessibilityBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TextStepButton(
            label: 'A-',
            onTap: settings.textScale > AppSettingsProvider.minScale ? settings.decreaseTextSize : null,
          ),
          const SizedBox(width: 2),
          _TextStepButton(
            label: 'A+',
            onTap: settings.textScale < AppSettingsProvider.maxScale ? settings.increaseTextSize : null,
          ),
          _Divider(),
          _LangToggle(settings: settings),
          _Divider(),
          _IconTap(
            icon: settings.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
            onTap: settings.toggleTheme,
            tooltip: 'Toggle dark mode',
          ),
          _IconTap(
            icon: Icons.record_voice_over_rounded,
            tooltip: 'Read screen aloud',
            onTap: () {
              SemanticsService.announce(
                'Good Morning, screen reader activated for this demo.',
                Directionality.of(context),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Screen reader announced (demo).'), duration: Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TextStepButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _TextStepButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: onTap == null ? 0.4 : 1),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final AppSettingsProvider settings;
  const _LangToggle({required this.settings});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => settings.setLocale(settings.isArabic ? const Locale('en') : const Locale('ar')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangChip(label: 'EN', active: !settings.isArabic),
            _LangChip(label: 'عربي', active: settings.isArabic),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool active;
  const _LangChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: active ? const Color(0xFF0E7C7B) : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconTap({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}