import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const sky = Color(0xFF6CC6FF);
  static const skyDeep = Color(0xFF2F8FE8);
  static const grass = Color(0xFF4CCB55);
  static const grassDark = Color(0xFF2E8F4A);
  static const turquoise = Color(0xFF2FD9C8);
  static const gold = Color(0xFFFFC93C);
  static const goldDark = Color(0xFFE08A00);
  static const orange = Color(0xFFFF8A2A);
  static const purple = Color(0xFF8A4FE0);
  static const purpleDark = Color(0xFF4E2A96);
  static const pink = Color(0xFFFF7AB6);
  static const red = Color(0xFFFF4D5E);
  static const ink = Color(0xFF2A1636);
  static const panel = Color(0xFFFFF8EC);
  static const panelEdge = Color(0xFFE9C98F);
  static const cream = Color(0xFFFFF4D6);
}

class AppText {
  AppText._();
  static const String display = 'LilitaOne';
  static const String body = 'Fredoka';

  static TextStyle title(double size, {Color color = Colors.white}) => TextStyle(
    fontFamily: display,
    fontSize: size,
    color: color,
    letterSpacing: 1.0,
    shadows: const [Shadow(color: Color(0xAA2A1636), offset: Offset(0, 3), blurRadius: 0)],
  );

  static TextStyle label(double size, {Color color = Colors.white, FontWeight weight = FontWeight.w600}) => TextStyle(
    fontFamily: body,
    fontSize: size,
    color: color,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight == FontWeight.w700 ? 700 : (weight == FontWeight.w600 ? 600 : 450))],
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange, brightness: Brightness.light),
    fontFamily: AppText.body,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.sky,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.panel),
  );
}
