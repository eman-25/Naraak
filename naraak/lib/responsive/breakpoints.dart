// lib/responsive/breakpoints.dart
import 'package:flutter/widgets.dart';

/// Below this width the app renders its mobile shell (bottom nav, narrow
/// single-column screens). At or above it, the desktop/web shell (top nav,
/// wide dashboard layouts) takes over.
const double kWebBreakpoint = 900;

bool isWebWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kWebBreakpoint;
