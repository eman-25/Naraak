// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Refined type scale — tighter tracking on headlines, generous line-height
/// on body copy for bilingual (EN/AR) readability.
class AppTextStyles {
  AppTextStyles._();

  static const _family = 'NotoSans';

  // display/h1/h2/h3/body intentionally carry no hardcoded color: they're
  // passed as an explicit `style:` almost everywhere, and an explicit
  // TextStyle.color always wins over the theme, so a fixed near-black here
  // read as near-invisible text-on-text once dark mode's near-black
  // background kicked in. Leaving color unset lets these inherit the
  // ambient DefaultTextStyle color, which the light/dark ThemeData already
  // sets correctly per theme.
  static const display = TextStyle(
    fontFamily: _family, fontSize: 34, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, height: 1.15,
  );

  static const h1 = TextStyle(
    fontFamily: _family, fontSize: 26, fontWeight: FontWeight.w700,
    letterSpacing: -0.3, height: 1.2,
  );

  static const h2 = TextStyle(
    fontFamily: _family, fontSize: 21, fontWeight: FontWeight.w700,
    letterSpacing: -0.2, height: 1.25,
  );

  static const h3 = TextStyle(
    fontFamily: _family, fontSize: 17, fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const body = TextStyle(
    fontFamily: _family, fontSize: 15, fontWeight: FontWeight.w400,
    height: 1.5,
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