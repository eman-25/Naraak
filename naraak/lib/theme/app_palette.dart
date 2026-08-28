// lib/theme/app_palette.dart
import 'package:flutter/material.dart';

enum AppPaletteId { healthcareTeal, ministryBlue, royalIndigo, freshEmerald, warmPlum }

/// One selectable brand palette. `preview` feeds the 3-stop swatch pill
/// shown in the Appearance screen; `primary`/`secondary` feed the actual
/// Material ColorScheme used app-wide once selected.
class AppPalette {
  final AppPaletteId id;
  final String label;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final List<Color> preview;

  const AppPalette({
    required this.id,
    required this.label,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.preview,
  });

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryDark],
      );

  static const healthcareTeal = AppPalette(
    id: AppPaletteId.healthcareTeal,
    label: 'Healthcare Teal',
    primary: Color(0xFF0E7C7B),
    primaryDark: Color(0xFF0A5C5C),
    secondary: Color(0xFF2D6CDF),
    preview: [Color(0xFF0A5C5C), Color(0xFF0E7C7B), Color(0xFF7FCFC9)],
  );

  static const ministryBlue = AppPalette(
    id: AppPaletteId.ministryBlue,
    label: 'Ministry Blue',
    primary: Color(0xFF1B5FA8),
    primaryDark: Color(0xFF0E3A6B),
    secondary: Color(0xFF4FA8D8),
    preview: [Color(0xFF0E3A6B), Color(0xFF1B5FA8), Color(0xFF8FC1E8)],
  );

  static const royalIndigo = AppPalette(
    id: AppPaletteId.royalIndigo,
    label: 'Royal Indigo',
    primary: Color(0xFF4C4FCE),
    primaryDark: Color(0xFF2E2E82),
    secondary: Color(0xFF8B8DE8),
    preview: [Color(0xFF2E2E82), Color(0xFF4C4FCE), Color(0xFFB6B8F4)],
  );

  static const freshEmerald = AppPalette(
    id: AppPaletteId.freshEmerald,
    label: 'Fresh Emerald',
    primary: Color(0xFF1E9E6B),
    primaryDark: Color(0xFF0F6B45),
    secondary: Color(0xFF6FCF97),
    preview: [Color(0xFF0F6B45), Color(0xFF1E9E6B), Color(0xFF8FE0B4)],
  );

  static const warmPlum = AppPalette(
    id: AppPaletteId.warmPlum,
    label: 'Warm Plum',
    primary: Color(0xFF8C3A6E),
    primaryDark: Color(0xFF5C1F45),
    secondary: Color(0xFFD98CC0),
    preview: [Color(0xFF5C1F45), Color(0xFF8C3A6E), Color(0xFFE3A9CE)],
  );

  static const all = [healthcareTeal, ministryBlue, royalIndigo, freshEmerald, warmPlum];

  static AppPalette fromId(AppPaletteId id) =>
      all.firstWhere((p) => p.id == id, orElse: () => healthcareTeal);
}