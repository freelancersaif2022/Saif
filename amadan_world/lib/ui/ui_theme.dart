import 'package:flutter/material.dart';

class UiColors {
  UiColors._();

  static const Color accent = Color(0xFFE08A2E);
  static const Color accentSoft = Color(0xFFB0662A);
  static const Color accentDark = Color(0xFF6E3A14);
  static const Color panel = Color(0xFF15171A);
  static const Color panelEdge = Color(0x55E0C8A0);
  static const Color text = Color(0xFFF0E6D2);
  static const Color muted = Color(0xFFA89E8C);
  static const Color danger = Color(0xFFE0442E);
  static const Color steel = Color(0xFF2A2E33);
}

class UiText {
  UiText._();

  static TextStyle title(double size) => TextStyle(
        color: UiColors.text,
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: size * 0.18,
        height: 1.0,
        shadows: const [
          Shadow(color: Color(0xCC000000), blurRadius: 18, offset: Offset(0, 4)),
        ],
      );

  static TextStyle label(double size, {Color color = UiColors.muted}) => TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: size * 0.16,
      );

  static TextStyle value(double size, {Color color = UiColors.text}) => TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: size * 0.04,
      );
}

/// Cross-fade page transition used between every screen.
Route<T> fadeRoute<T>(Widget page, {int milliseconds = 650}) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: milliseconds),
    reverseTransitionDuration: Duration(milliseconds: milliseconds),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return FadeTransition(opacity: curved, child: child);
    },
  );
}
