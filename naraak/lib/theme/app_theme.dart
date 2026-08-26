import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Combines AppColors + AppTextStyles into a single Flutter ThemeData,
/// so every screen stays visually consistent with the Phase 4 design system.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        primary: AppColors.primaryTeal,
        secondary: AppColors.secondaryIce,
        error: AppColors.bahrainAccent,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondaryIce,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18), // Phase 4 Section 2.3: 16-18px
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutralGray.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonLabel,
          minimumSize:
              const Size.fromHeight(48), // >=44px tap target, Phase 3 Section 6
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          side: const BorderSide(color: AppColors.primaryTeal),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryIce,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bahrainAccent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: AppColors.neutralGray,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        labelSmall: AppTextStyles.caption,
      )
          .apply(
              bodyColor: AppColors.neutralDark,
              displayColor: AppColors.neutralDark)
          .copyWith(
            bodyMedium: AppTextStyles.bodySecondary
                .copyWith(color: AppColors.neutralGray),
            labelSmall:
                AppTextStyles.caption.copyWith(color: AppColors.neutralGray),
          ),
    );
  }

  static ThemeData get dark => light.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          brightness: Brightness.dark,
          surface: AppColors.darkSurface,
        ),
        appBarTheme:
            light.appBarTheme.copyWith(backgroundColor: AppColors.darkSurface),
        cardTheme: light.cardTheme.copyWith(color: AppColors.darkSurface),
        inputDecorationTheme: light.inputDecorationTheme
            .copyWith(fillColor: AppColors.darkSurface),
        bottomNavigationBarTheme: light.bottomNavigationBarTheme.copyWith(
          backgroundColor: AppColors.darkSurface,
        ),
        textTheme: light.textTheme
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
      );
}
