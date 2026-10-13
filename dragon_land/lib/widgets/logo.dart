import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_theme.dart';

/// "DRAGON LAND" title with gradient fill, thick outline and a pulsing glow.
class DragonLandLogo extends StatefulWidget {
  const DragonLandLogo({super.key, this.size = 72, this.subtitle});

  final double size;
  final String? subtitle;

  @override
  State<DragonLandLogo> createState() => _DragonLandLogoState();
}

class _DragonLandLogoState extends State<DragonLandLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _text(String s, double size, double glow) {
    final stroke = TextStyle(
      fontFamily: AppText.display,
      fontSize: size,
      letterSpacing: 3,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.14
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.ink,
    );
    final fill = TextStyle(
      fontFamily: AppText.display,
      fontSize: size,
      letterSpacing: 3,
      foreground: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6B0), Color(0xFFFFC93C), Color(0xFFFF7A1F)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size * 6, size * 1.1)),
    );
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, size * 0.07),
          child: Text(s, style: stroke.copyWith(foreground: Paint()..color = const Color(0x882A1636))),
        ),
        Text(s, style: stroke),
        Text(s, style: fill),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final g = _c.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(angle: math.sin(g * math.pi) * 0.01, child: _text('DRAGON LAND', widget.size, g)),
            if (widget.subtitle != null) ...[
              SizedBox(height: widget.size * 0.12),
              Text(widget.subtitle!, style: AppText.title(widget.size * 0.3, color: Colors.white)),
            ],
          ],
        );
      },
    );
  }
}
