// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Refined type scale — tighter tracking on headlines, generous line-height
/// on body copy for bilingual (EN/AR) readability.
class AppTextStyles {
  AppTextStyles._();

  static const _family = 'NotoSans';

  static const display = TextStyle(
    fontFamily: _family, fontSize: 34, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, height: 1.15, color: AppColors.ink900,
  );

  static const h1 = TextStyle(
    fontFamily: _family, fontSize: 26, fontWeight: FontWeight.w700,
    letterSpacing: -0.3, height: 1.2, color: AppColors.ink900,
  );

  static const h2 = TextStyle(
    fontFamily: _family, fontSize: 21, fontWeight: FontWeight.w700,
    letterSpacing: -0.2, height: 1.25, color: AppColors.ink900,
  );

  static const h3 = TextStyle(
    fontFamily: _family, fontSize: 17, fontWeight: FontWeight.w600,
    height: 1.3, color: AppColors.ink900,
  );

  static const body = TextStyle(
    fontFamily: _family, fontSize: 15, fontWeight: FontWeight.w400,
    height: 1.5, color: AppColors.ink900,
  );

  static const bodySecondary = TextStyle(
    fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400,
    height: 1.5, color: AppColors.ink500,
  );

  static const label = TextStyle(
    fontFamily: _family, fontSize: 13, fontWeight: FontWeight.w600,
    letterSpacing: 0.2, color: AppColors.ink700,
  );

  static const caption = TextStyle(
    fontFamily: _family, fontSize: 12.5, fontWeight: FontWeight.w400,
    height: 1.4, color: AppColors.ink500,
  );

  static const overline = TextStyle(
    fontFamily: _family, fontSize: 11, fontWeight: FontWeight.w700,
    letterSpacing: 1.1, color: AppColors.ink500,
  );

  static const buttonLabel = TextStyle(
    fontFamily: _family, fontSize: 15.5, fontWeight: FontWeight.w600,
    letterSpacing: 0.1, color: Colors.white,
  );
}