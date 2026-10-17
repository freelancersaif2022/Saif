import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();
  static const bg0 = Color(0xFF0A0817);
  static const bg1 = Color(0xFF15102B);
  static const bg2 = Color(0xFF221A42);
  static const surface = Color(0xFF1C1636);
  static const surfaceHi = Color(0xFF2A2150);
  static const stroke = Color(0x22FFFFFF);
  static const text = Color(0xFFF4F1FF);
  static const textDim = Color(0xFFA9A2C9);
  static const textMute = Color(0xFF6E678F);
  static const primary = Color(0xFFFF7A1A);
  static const primaryDeep = Color(0xFFD9480F);
  static const cyan = Color(0xFF38E1FF);
  static const gold = Color(0xFFFFC93C);
  static const gem = Color(0xFF5BF0B0);
  static const energy = Color(0xFF8E7CFF);
  static const success = Color(0xFF34D399);
  static const danger = Color(0xFFFF4D6D);
  static const warning = Color(0xFFFFB020);

  static const bgGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bg2, bg1, bg0], stops: [0, 0.45, 1]);
}

class AppText {
  AppText._();
  static const display = TextStyle(fontFamily: 'Lilita', fontSize: 34, color: AppColors.text, height: 1.05, letterSpacing: 0.5);
  static const h1 = TextStyle(fontFamily: 'Lilita', fontSize: 26, color: AppColors.text, letterSpacing: 0.4);
  static const h2 = TextStyle(fontFamily: 'Lilita', fontSize: 20, color: AppColors.text, letterSpacing: 0.3);
  static const h3 = TextStyle(fontFamily: 'Lilita', fontSize: 16, color: AppColors.text, letterSpacing: 0.3);
  static const body = TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDim, height: 1.35);
  static const label = TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text);
  static const small = TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDim);
  static const number = TextStyle(fontFamily: 'Lilita', fontSize: 15, color: AppColors.text);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Nunito',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg0,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()}),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppText.h2,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg1,
      hintStyle: AppText.body.copyWith(color: AppColors.textMute),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.stroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.textDim),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.bg2),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent, elevation: 0),
  );
}
