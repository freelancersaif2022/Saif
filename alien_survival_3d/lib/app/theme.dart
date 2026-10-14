import 'package:flutter/material.dart';

/// Visual identity from the reference sheet: black / dark grey panels with a
/// neon lime accent (#D1FE17), black text on lime buttons, white on dark.
class AppColors {
  static const lime = Color(0xFFD1FE17);
  static const limeDim = Color(0x59D1FE17);
  static const black = Color(0xFF070907);
  static const panel = Color(0xCC0E120F);
  static const panelSolid = Color(0xFF141A15);
  static const panelBorder = Color(0x40D1FE17);
  static const text = Colors.white;
  static const textDim = Color(0xFFA9B3A0);
  static const red = Color(0xFFE8262A);
  static const blue = Color(0xFF2A7BFF);
  static const gold = Color(0xFFFFC21A);
  static const gem = Color(0xFF3FB6FF);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.lime,
      onPrimary: Colors.black,
      secondary: AppColors.lime,
      surface: AppColors.panelSolid,
    ),
    textTheme: base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.lime,
      thumbColor: AppColors.lime,
      inactiveTrackColor: Color(0xFF2A3226),
      overlayColor: Color(0x33D1FE17),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.black : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.lime : const Color(0xFF2A3226)),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.panelSolid),
  );
}

const headline = TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.text);
const label = TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.text, fontSize: 13);
const dim = TextStyle(color: AppColors.textDim, fontSize: 12);
