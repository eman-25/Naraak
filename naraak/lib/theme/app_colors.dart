import 'package:flutter/material.dart';

/// Naraak design tokens — colors.
/// Source: Phase 4 High-Fidelity Design System, Section 2.1
/// TO CONFIRM: verify WCAG 2.1 AA contrast for every text/background pairing
/// before locking these in for production.
class AppColors {
  AppColors._();

  // Primary
  static const primaryTeal = Color(0xFF0F6B72); // Primary buttons, active nav, key headers
  static const primaryDark = Color(0xFF0B4F54); // Pressed/hover, high-emphasis text on light bg

  // Secondary
  static const secondaryIce = Color(0xFFEAF3F3); // Card backgrounds, section fills

  // Neutral
  static const neutralDark = Color(0xFF1F2D3D); // Body text, icons
  static const neutralGray = Color(0xFF5A6472); // Secondary text, captions, helper text

  // Status
  static const success = Color(0xFF2E7D5B); // Confirmed / Approved
  static const warning = Color(0xFFC77B00); // Pending / In Progress
  static const bahrainAccent = Color(0xFFCE1126); // Critical errors ONLY — never decorative

  // Base
  static const background = Color(0xFFFFFFFF);
}
