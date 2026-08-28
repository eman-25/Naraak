// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Naraak Design System v2 — refined healthcare palette.
/// Moves from a flat single-teal scheme to a layered, modern palette with
/// a proper tonal ramp, softer semantic colors, and dark-mode parity.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  static const primary        = Color(0xFF0E7C7B); // Deep teal — trust, calm
  static const primaryDark    = Color(0xFF0A5C5C);
  static const primaryLight   = Color(0xFF4FA8A6);
  static const primarySurface = Color(0xFFE6F4F3); // tinted container

  static const secondary        = Color(0xFF2D6CDF); // Confident blue accent
  static const secondarySurface = Color(0xFFE8F0FE);

  // ── Semantic ─────────────────────────────────────────────
  static const success        = Color(0xFF1E9E6B);
  static const successSurface = Color(0xFFE3F7EE);
  static const warning        = Color(0xFFDB8A1E);
  static const warningSurface = Color(0xFFFCF0DD);
  static const error          = Color(0xFFD64550); // softer than pure red
  static const errorSurface   = Color(0xFFFCE8E9);
  static const bahrainAccent  = Color(0xFFCE1126); // reserved: critical only

  // ── Neutrals (tonal ramp) ────────────────────────────────
  static const ink900 = Color(0xFF12181B); // primary text
  static const ink700 = Color(0xFF3C474D); // secondary text
  static const ink500 = Color(0xFF6B767C); // captions, disabled
  static const ink300 = Color(0xFFAEB8BC);
  static const ink100 = Color(0xFFE7ECEE);
  static const ink050 = Color(0xFFF5F8F9); // subtle fills

  static const surface        = Color(0xFFFFFFFF);
  static const surfaceMuted   = Color(0xFFF7FAFA);
  static const outline        = Color(0xFFE1E8EA);

  // ── Dark mode ────────────────────────────────────────────
  static const darkBg      = Color(0xFF0D1417);
  static const darkSurface = Color(0xFF16201F);
  static const darkSurface2= Color(0xFF1E2B2A);
  static const darkOutline = Color(0xFF2A3A39);

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
  static const primaryTeal   = primary;
  static const primaryDark_  = primaryDark;
  static const secondaryIce  = primarySurface;
  static const neutralDark   = ink900;
  static const neutralGray   = ink500;
  static const background    = surface;
  static const darkBackground= darkBg;
}