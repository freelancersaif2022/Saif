import 'package:flutter/material.dart';

/// Brand palette. Accent surfaces always carry black text and icons.
abstract final class AppColors {
  static const Color accent = Color(0xFFD1FE17);
  static const Color onAccent = Color(0xFF000000);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF4F5F2);
  static const Color surfaceStrong = Color(0xFFEAECE6);
  static const Color border = Color(0xFFE3E5DF);
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF55594F);
  static const Color danger = Color(0xFFC5221F);
  static const Color warning = Color(0xFFB06000);
  static const Color success = Color(0xFF1E7B34);

  static const Color darkBackground = Color(0xFF0F110E);
  static const Color darkSurface = Color(0xFF1A1D18);
  static const Color darkSurfaceStrong = Color(0xFF252922);
  static const Color darkBorder = Color(0xFF30342D);
  static const Color darkText = Color(0xFFF4F6F0);
  static const Color darkTextSecondary = Color(0xFFB4B9AD);

  /// Accent choices offered in settings. All are light enough for black text.
  static const Map<String, Color> accentChoices = {
    'lime': accent,
    'lemon': Color(0xFFF5F36B),
    'sun': Color(0xFFFFD84D),
    'mango': Color(0xFFFFB648),
    'peach': Color(0xFFFFB59A),
    'coral': Color(0xFFFF9E9E),
    'pink': Color(0xFFFFA8D5),
    'lavender': Color(0xFFCDBEFF),
    'periwinkle': Color(0xFFAEB9FF),
    'sky': Color(0xFF8FD8FF),
    'aqua': Color(0xFF7FEAE6),
    'mint': Color(0xFF7DF0C2),
    'sage': Color(0xFFB9D99B),
    'sand': Color(0xFFE6D3A8),
    'silver': Color(0xFFD5D9DE),
    'neon': Color(0xFF9DFF5C),
  };

  static String labelFor(String key) => key[0].toUpperCase() + key.substring(1);

  static Color accentFor(String key) => accentChoices[key] ?? accent;
}
