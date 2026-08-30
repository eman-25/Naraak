// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Naraak Design System v2 — refined healthcare palette.
/// Moves from a flat single-teal scheme to a layered, modern palette with
/// a proper tonal ramp, softer semantic colors, and dark-mode parity.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  static const primary = Color(0xFF0F6B72); // Naraak teal
  static const primaryDark = Color(0xFF0B4F54);
  static const primaryLight = Color(0xFF4FA8A6);
  static const primarySurface = Color(0xFFEAF3F3); // secondary ice

  static const secondary = Color(0xFF2D6CDF); // Confident blue accent
  static const secondarySurface = Color(0xFFE8F0FE);

  // ── Semantic ─────────────────────────────────────────────
  static const success = Color(0xFF2E7D5B);
  static const successSurface = Color(0xFFE3F7EE);
  static const warning = Color(0xFFB45309);
  static const warningSurface = Color(0xFFFCF0DD);
  static const error = Color(0xFFCE1126);
  static const errorSurface = Color(0xFFFCE8E9);
  static const bahrainAccent = Color(0xFFCE1126); // reserved: critical only

  // ── Neutrals (tonal ramp) ────────────────────────────────
  static const ink900 = Color(0xFF1F2D3D); // primary text
  static const ink700 = Color(0xFF5A6472); // secondary text
  static const ink500 = Color(0xFF5A6472); // captions, disabled
  static const ink300 = Color(0xFFAEB8BC);
  static const ink100 = Color(0xFFE7ECEE);
  static const ink050 = Color(0xFFF5F8F9); // subtle fills

  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF7FAFA);
  static const outline = Color(0xFFE1E8EA);

  // ── Dark mode ────────────────────────────────────────────
  static const darkBg = Color(0xFF001F24); // page background
  static const darkSurface = Color(0xFF002A2F); // cards
  static const darkSurface2 = Color(0xFF0B353B); // elevated surfaces
  static const darkOutline = Color(0xFF315158);

  static const darkPrimary = Color(0xFF006B70); // primary teal
  static const darkAccent = Color(0xFF00A6A6); // accent teal / icons
  static const darkTextPrimary = Color(0xFFF2F4F5);
  static const darkTextSecondary = Color(0xFFAAB3BB);

  static const darkSuccess = Color(0xFF00C98B); // approved
  static const darkError = Color(0xFFF22F3D); // alert
  static const darkWarning = Color(0xFFF59E0B); // warning orange
  static const darkAmber = Color(0xFFF5B82E); // amber

  // ── Gradients ────────────────────────────────────────────
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E7C7B), Color(0xFF115E85)],
  );

  static const chipGradient = LinearGradient(
    colors: [Color(0xFF0E7C7B), Color(0xFF17A398)],
  );

  // Legacy aliases so existing call-sites keep compiling during migration.
  static const primaryTeal = primary;
  static const primaryDark_ = primaryDark;
  static const secondaryIce = primarySurface;
  static const neutralDark = ink900;
  static const neutralGray = ink500;
  static const background = surface;
  static const darkBackground = darkBg;
}
