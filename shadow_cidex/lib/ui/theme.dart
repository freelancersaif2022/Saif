import 'package:flutter/material.dart';

class UiColors {
  UiColors._();
  static const Color bg = Color(0xFF040508);
  static const Color panel = Color(0xE60A0C12);
  static const Color accent = Color(0xFF7FD8FF);
  static const Color accentDeep = Color(0xFF2A6CFF);
  static const Color red = Color(0xFFFF2A3A);
  static const Color gold = Color(0xFFFFC21A);
  static const Color text = Color(0xFFE8EEF8);
  static const Color dim = Color(0xFF8A96A8);
  static const Color locked = Color(0xFF4A5262);
}

class UiText {
  UiText._();

  static TextStyle title(double size, {Color color = UiColors.text, double glow = 1}) => TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.w900,
        fontSize: size,
        letterSpacing: size * 0.16,
        color: color,
        height: 1.0,
        shadows: [
          Shadow(color: UiColors.red.withAlpha((150 * glow).round().clamp(0, 255)), blurRadius: size * 0.6),
          Shadow(color: Colors.black.withAlpha(230), blurRadius: size * 0.12, offset: Offset(0, size * 0.04)),
        ],
      );

  static TextStyle heading(double size, {Color color = UiColors.text}) => TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.w700,
        fontSize: size,
        letterSpacing: size * 0.14,
        color: color,
        height: 1.1,
        shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
      );

  static TextStyle body(double size, {Color color = UiColors.text, FontWeight weight = FontWeight.w700}) => TextStyle(
        fontFamily: 'Rajdhani',
        fontWeight: weight,
        fontSize: size,
        letterSpacing: size * 0.08,
        color: color,
        height: 1.15,
        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
      );
}

/// Fade + slight zoom page transition.
class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute({required Widget page, int ms = 650})
      : super(
          transitionDuration: Duration(milliseconds: ms),
          reverseTransitionDuration: Duration(milliseconds: (ms * 0.7).round()),
          pageBuilder: (context, a1, a2) => page,
          transitionsBuilder: (context, anim, secondary, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.06, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
}
