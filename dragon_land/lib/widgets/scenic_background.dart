import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated fantasy-island backdrop for menus: sky, sun, drifting clouds,
/// slow parallax hills and floating sparkles.
class ScenicBackground extends StatefulWidget {
  const ScenicBackground({super.key, this.child, this.dim = 0, this.showHills = true});

  final Widget? child;
  final double dim;
  final bool showHills;

  @override
  State<ScenicBackground> createState() => _ScenicBackgroundState();
}

class _ScenicBackgroundState extends State<ScenicBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _layer(String asset, double t, double speed, {double opacity = 1}) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        final w = h * 2048 / 720;
        final x = -((t * speed * w) % w);
        return Stack(
          children: [
            for (var i = 0; i < (box.maxWidth / w).ceil() + 1; i++)
              Positioned(
                left: x + i * w,
                top: 0,
                width: w + 1,
                height: h,
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/sky.png', fit: BoxFit.fill),
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder: (context, box) {
                    final s = box.maxHeight * 0.55 * (1 + math.sin(t * math.pi * 40) * 0.03);
                    return Stack(
                      children: [
                        Positioned(
                          left: box.maxWidth * 0.78 - s / 2,
                          top: box.maxHeight * 0.12 - s / 2,
                          width: s,
                          height: s,
                          child: Image.asset('assets/images/sun.png'),
                        ),
                      ],
                    );
                  },
                ),
                _layer('assets/images/bg_far.png', t, 0.5),
                _Clouds(t: t),
                _layer('assets/images/bg_mid.png', t, 1.2),
                if (widget.showHills) _layer('assets/images/bg_near.png', t, 2.0),
                CustomPaint(painter: _SparklePainter(t)),
              ],
            );
          },
        ),
        if (widget.dim > 0) ColoredBox(color: Color.fromRGBO(20, 10, 40, widget.dim)),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Clouds extends StatelessWidget {
  const _Clouds({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        final specs = [(1, 0.05, 0.40, 6.0), (2, 0.25, 0.32, 9.0), (3, 0.12, 0.48, 4.0), (4, 0.35, 0.28, 11.0)];
        return Stack(
          children: [
            for (final (i, y, s, speed) in specs)
              Positioned(
                left: (w + 400) - ((t * speed * (w + 600) + i * 377) % (w + 600)) - 300,
                top: h * y,
                width: h * s * 2.1,
                child: Image.asset('assets/images/cloud_$i.png', fit: BoxFit.contain),
              ),
          ],
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.t);
  final double t;
  static final _rng = math.Random(42);
  static final List<List<double>> _pts = List.generate(26, (_) => [_rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble()]);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..blendMode = BlendMode.plus;
    for (final s in _pts) {
      final phase = (t * 60 + s[2] * 10) % 1.0;
      final x = s[0] * size.width + math.sin(t * 200 + s[2] * 6) * 12;
      final y = size.height * (0.2 + 0.75 * ((s[1] - t * 8) % 1.0));
      final a = math.sin(phase * math.pi);
      p.color = Color.fromRGBO(255, 245, 200, 0.55 * a);
      canvas.drawCircle(Offset(x, y), 2 + 3 * a, p);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}
