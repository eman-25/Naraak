// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const radiusSm = 10.0;
  static const radiusMd = 16.0;
  static const radiusLg = 22.0;

  static ThemeData light(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      primary: palette.primary,
      secondary: palette.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surfaceMuted,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: _FadeThroughTransitionsBuilder(),
        TargetPlatform.iOS: _FadeThroughTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceMuted,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.ink900),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.ink100,
          disabledForegroundColor: AppColors.ink500,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: AppTextStyles.buttonLabel,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
        ).copyWith(
            overlayColor:
                WidgetStateProperty.all(Colors.white.withValues(alpha: 0.08))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: const BorderSide(color: AppColors.outline, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTextStyles.buttonLabel.copyWith(color: palette.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ink050,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.ink500),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.ink500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: palette.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.outline, thickness: 1, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: AppColors.ink300,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.surface,
        indicatorColor: palette.primary.withValues(alpha: .14),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? palette.primary
                  : AppColors.ink500,
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? palette.primary
                  : AppColors.ink500,
              size: 24,
            )),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        labelLarge: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),
      extensions: [AppPaletteExtension(palette)],
    );
  }

  static ThemeData dark(AppPalette palette) {
    final base = light(palette);
    // Regenerated from scratch for dark brightness rather than copyWith'ing
    // the light scheme's brightness flag — a flag flip alone doesn't
    // recompute onSurface/onBackground, which is why icons (back button,
    // bell, etc.) stayed near-black-on-black even after text was fixed.
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkAccent,
      brightness: Brightness.dark,
      primary: AppColors.darkAccent,
      secondary: palette.secondary,
      error: AppColors.darkError,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: scheme,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkTextPrimary,
        titleTextStyle:
            AppTextStyles.h2.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: base.cardTheme.copyWith(color: AppColors.darkSurface),
      inputDecorationTheme:
          base.inputDecorationTheme.copyWith(fillColor: AppColors.darkSurface2),
      dividerTheme: const DividerThemeData(color: AppColors.darkOutline),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: AppColors.darkSurface2,
        selectedItemColor: AppColors.darkAccent,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: palette.primary.withValues(alpha: .28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.darkTextPrimary
                  : AppColors.darkTextSecondary,
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.darkTextPrimary
                  : AppColors.darkTextSecondary,
              size: 24,
            )),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
    );
  }
}

/// Lets any widget grab the active palette via `Theme.of(context)` without
/// re-reading the provider — e.g. `AppPaletteExtension.of(context).palette`.
class AppPaletteExtension extends ThemeExtension<AppPaletteExtension> {
  final AppPalette palette;
  const AppPaletteExtension(this.palette);

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPaletteExtension>()?.palette ??
      AppPalette.healthcareTeal;

  @override
  AppPaletteExtension copyWith({AppPalette? palette}) =>
      AppPaletteExtension(palette ?? this.palette);

  @override
  ThemeExtension<AppPaletteExtension> lerp(
          covariant ThemeExtension<AppPaletteExtension>? other, double t) =>
      this;
}

class _FadeThroughTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeThroughTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}
