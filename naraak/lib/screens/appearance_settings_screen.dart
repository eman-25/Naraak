// lib/screens/appearance_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../localization/app_localizations.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('appearance'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(l10n.text('appearanceDescription'), style: AppTextStyles.bodySecondary),
          const SizedBox(height: 22),

          Text(l10n.text('colourTheme').toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: 10),
          ...AppPalette.all.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PaletteRow(
                  palette: p,
                  isActive: settings.paletteId == p.id,
                  onTap: () => settings.setPalette(p.id),
                ),
              )),
          const SizedBox(height: 12),

          AppCard(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.dark_mode_rounded, color: settings.palette.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.text('darkMode'), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
                  Switch.adaptive(
                    value: settings.themeMode == ThemeMode.dark,
                    activeColor: settings.palette.primary,
                    onChanged: (_) => settings.toggleTheme(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.language_rounded, color: settings.palette.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.text('language'), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
                _LangPill(label: l10n.text('english'), selected: !settings.isArabic, onTap: () => settings.setLocale(const Locale('en'))),
                const SizedBox(width: 8),
                _LangPill(label: l10n.text('arabic'), selected: settings.isArabic, onTap: () => settings.setLocale(const Locale('ar'))),
              ],
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.text_fields_rounded, color: settings.palette.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.text('textSize'), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
                _StepButton(
                  icon: Icons.remove_rounded,
                  onTap: settings.textScale > AppSettingsProvider.minScale ? settings.decreaseTextSize : null,
                ),
                SizedBox(
                  width: 46,
                  child: Text('${settings.textScalePercent}%',
                      textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  onTap: settings.textScale < AppSettingsProvider.maxScale ? settings.increaseTextSize : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final AppPalette palette;
  final bool isActive;
  final VoidCallback onTap;
  const _PaletteRow({required this.palette, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? palette.primary.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: isActive ? palette.primary : AppColors.outline, width: isActive ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(colors: palette.preview),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(palette.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
            if (isActive)
              Text(l10n.text('active'), style: AppTextStyles.caption.copyWith(color: palette.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? palette.primary : AppColors.ink050,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.ink700, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.ink050,
        foregroundColor: AppColors.ink900,
        shape: const CircleBorder(),
      ),
    );
  }
}
