import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class ServiceHero extends StatelessWidget {
  const ServiceHero({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
    this.accent,
  });

  final String imageAsset;
  final String title;
  final String description;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
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
              Image.asset(imageAsset, fit: BoxFit.cover),
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
                      Text(title,
                          style:
                              AppTextStyles.h1.copyWith(color: Colors.white)),
                      const SizedBox(height: 7),
                      Text(
                        description,
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
