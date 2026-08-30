// lib/widgets/skyline_background.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-bleed Bahrain skyline photo with a translucent brand-green wash on
/// top — shared by the splash screen and the login screen so both carry the
/// same backdrop.
class SkylineBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const SkylineBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.82,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/splash.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: AppColors.primaryDark),
        ),
        Container(color: AppColors.primary.withValues(alpha: overlayOpacity)),
        child,
      ],
    );
  }
}
