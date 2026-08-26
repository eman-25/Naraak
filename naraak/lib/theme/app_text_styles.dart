import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Naraak design tokens — typography.
/// Source: Phase 4 Section 2.2. Font family: Noto Sans (Noto Sans Arabic for RTL).
/// TO CONFIRM: register the actual font files in pubspec.yaml — falls back to
/// the platform default font until then.
class AppTextStyles {
  AppTextStyles._();

  static const _fontFamily = 'NotoSans'; // add Noto Sans Arabic swap for RTL locales

  static const h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.neutralDark,
  );

  static const h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 23,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralDark,
  );

  static const h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralDark,
  );

  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.neutralDark,
  );

  static const bodySecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.neutralGray,
  );

  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.neutralGray,
  );

  static const buttonLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
