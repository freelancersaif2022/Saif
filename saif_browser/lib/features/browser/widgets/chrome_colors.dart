import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Colors for the browser toolbars. Private tabs use a dark toolbar so the
/// mode is always obvious.
class ChromeColors {
  const ChromeColors({
    required this.bar,
    required this.pill,
    required this.foreground,
    required this.secondary,
    required this.border,
    required this.accent,
  });

  factory ChromeColors.of(BuildContext context, {required bool private}) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    if (private) {
      return ChromeColors(
        bar: const Color(0xFF1C1D1F),
        pill: const Color(0xFF303134),
        foreground: Colors.white,
        secondary: const Color(0xFFBDC1C6),
        border: const Color(0xFF3C4043),
        accent: palette.accent,
      );
    }
    return ChromeColors(
      bar: scheme.surface,
      pill: palette.surface,
      foreground: scheme.onSurface,
      secondary: palette.textSecondary,
      border: palette.border,
      accent: palette.accent,
    );
  }

  final Color bar;
  final Color pill;
  final Color foreground;
  final Color secondary;
  final Color border;
  final Color accent;
}
