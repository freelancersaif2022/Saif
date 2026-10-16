import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Ghost City design tokens: a night-dark ground with warm, film-like accents.
class GC {
  GC._();

  static const ground = Color(0xFF0F0E0C);
  static const surface = Color(0xFF1A1815);
  static const surface2 = Color(0xFF24211C);
  static const surface3 = Color(0xFF2E2A23);
  static const line = Color(0x1AF3EBDD);
  static const lineStrong = Color(0x33F3EBDD);

  static const text = Color(0xFFF3EBDD);
  static const textSoft = Color(0xFFD9CFBD);
  static const muted = Color(0xFFB3A893);
  static const faint = Color(0xFF8C8371);

  static const amber = Color(0xFFE9B44C);
  static const amberLight = Color(0xFFF3D9A1);
  static const amberDeep = Color(0xFF3A2F1A);
  static const onAmber = Color(0xFF1B1408);
  static const coral = Color(0xFFF08A6E);
  static const green = Color(0xFF6FD08C);

  static const serif = 'Fraunces';
  static const sans = 'Manrope';

  static const radiusS = 12.0;
  static const radiusM = 16.0;
  static const radiusL = 24.0;

  static TextStyle display(double size, {Color color = text, FontStyle? style, double height = 1.1}) => TextStyle(
        fontFamily: serif,
        fontSize: size,
        fontWeight: FontWeight.w400,
        fontStyle: style,
        height: height,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle body(double size, {Color color = textSoft, FontWeight weight = FontWeight.w500, double height = 1.5}) =>
      TextStyle(fontFamily: sans, fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle label({Color color = faint, double size = 11.5}) => TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: color,
      );

  static ThemeData theme() {
    final scheme = const ColorScheme.dark(
      primary: amber,
      onPrimary: onAmber,
      secondary: amberLight,
      onSecondary: onAmber,
      surface: surface,
      onSurface: text,
      error: coral,
      onError: onAmber,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ground,
      fontFamily: sans,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textSoft),
        bodyLarge: TextStyle(color: textSoft),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: amber,
        inactiveTrackColor: surface3,
        thumbColor: amber,
        overlayColor: Color(0x33E9B44C),
        trackHeight: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: body(14, color: text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: lineStrong,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onAmber : muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? amber : surface3),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
