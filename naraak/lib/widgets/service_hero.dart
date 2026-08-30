import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Phase 3 §11 Service Hero Template: every service opens with a visual
/// hero — a relevant image, title and short description, dark gradient
/// overlay so the text stays readable.
///
/// When no photography asset exists yet for a service, pass [icon] instead
/// of [imageAsset]: the hero falls back to a gradient + large icon motif,
/// which Phase 3 §2 explicitly allows ("abstract healthcare illustrations")
/// in place of real photography.
class ServiceHero extends StatelessWidget {
  const ServiceHero({
    super.key,
    this.imageAsset,
    this.icon,
    required this.title,
    required this.description,
    this.accent,
  }) : assert(imageAsset != null || icon != null,
            'ServiceHero needs either imageAsset or icon');

  final String? imageAsset;
  final IconData? icon;
  final String title;
  final String description;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final localizedTitle = strings.raw(title);
    final localizedDescription = strings.raw(description);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlay = accent ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      container: true,
      label: '$title. $description',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: SizedBox(
          height: 230,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _IllustratedBackground(
                          icon: icon ?? Icons.favorite_rounded,
                          accent: overlay),
                )
              else
                _IllustratedBackground(icon: icon!, accent: overlay),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      (isDark ? AppColors.darkBg : overlay)
                          .withValues(alpha: .92),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizedTitle,
                          style:
                              AppTextStyles.h1.copyWith(color: Colors.white)),
                      const SizedBox(height: 7),
                      Text(
                        localizedDescription,
                        style: AppTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: .9)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustratedBackground extends StatelessWidget {
  final IconData icon;
  final Color accent;
  const _IllustratedBackground({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.75), accent],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(icon,
                size: 220, color: Colors.white.withValues(alpha: 0.14)),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Icon(icon,
                size: 140, color: Colors.white.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }
}
