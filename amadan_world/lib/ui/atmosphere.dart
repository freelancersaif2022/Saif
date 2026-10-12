import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Animated battlefield atmosphere drawn over the menu backgrounds: drifting
/// smoke, rising embers and distant explosion flashes. All shaders are built
/// once; each frame only transforms the canvas.
class AtmosphereLayer extends StatefulWidget {
  const AtmosphereLayer({super.key, this.intensity = 1.0, this.flashes = true});

  final double intensity;
  final bool flashes;

  @override
  State<AtmosphereLayer> createState() => _AtmosphereLayerState();
}

class _AtmosphereLayerState extends State<AtmosphereLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _AtmospherePainter(_controller, widget.intensity, widget.flashes),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Blob {
  _Blob(this.x, this.y, this.r, this.speed, this.phase, this.alpha);

  final double x;
  final double y;
  final double r;
  final double speed;
  final double phase;
  final double alpha;
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter(this.animation, this.intensity, this.flashes) : super(repaint: animation) {
    final r = math.Random(17);
    for (var i = 0; i < 9; i++) {
      _smoke.add(_Blob(r.nextDouble(), 0.25 + r.nextDouble() * 0.6, 0.18 + r.nextDouble() * 0.22,
          0.004 + r.nextDouble() * 0.008, r.nextDouble() * 10, 0.18 + r.nextDouble() * 0.2));
    }
    for (var i = 0; i < 70; i++) {
      _embers.add(_Blob(r.nextDouble(), r.nextDouble(), 1 + r.nextDouble() * 1.8, 0.02 + r.nextDouble() * 0.05,
          r.nextDouble() * 10, 0.5 + r.nextDouble() * 0.5));
    }
  }

  final Animation<double> animation;
  final double intensity;
  final bool flashes;
  final List<_Blob> _smoke = <_Blob>[];
  final List<_Blob> _embers = <_Blob>[];

  static final Paint _smokePaint = Paint()
    ..shader = ui.Gradient.radial(
      Offset.zero,
      1,
      const [Color(0x99302A28), Color(0x55282322), Color(0x00201C1A)],
      const [0.0, 0.5, 1.0],
    );
  static final Paint _glowPaint = Paint()
    ..shader = ui.Gradient.radial(
      Offset.zero,
      1,
      const [Color(0xCCFF9A40), Color(0x44FF5A10), Color(0x00FF3000)],
      const [0.0, 0.4, 1.0],
    );
  static final Paint _ember = Paint()..blendMode = BlendMode.plus;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 60;
    final w = size.width;
    final h = size.height;

    if (flashes) {
      for (var i = 0; i < 3; i++) {
        final period = 5.0 + i * 2.3;
        final local = (t + i * 1.7) % period;
        if (local < 0.9) {
          final a = (1 - local / 0.9) * (local < 0.08 ? local / 0.08 : 1);
          final fx = w * (0.18 + 0.3 * i + 0.05 * math.sin(i + (t / period).floor()));
          final fy = h * 0.5;
          canvas.save();
          canvas.translate(fx, fy);
          canvas.scale(w * 0.22, h * 0.16);
          final p = Paint()
            ..shader = _glowPaint.shader
            ..color = Color.fromRGBO(255, 255, 255, (a * 0.8 * intensity).clamp(0.0, 1.0));
          canvas.drawCircle(Offset.zero, 1, p);
          canvas.restore();
        }
      }
    }

    for (final b in _smoke) {
      final x = ((b.x + t * b.speed) % 1.4 - 0.2) * w;
      final y = b.y * h + math.sin(t * 0.2 + b.phase) * h * 0.02;
      final r = b.r * w * (1 + 0.1 * math.sin(t * 0.3 + b.phase));
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(r, r * 0.55);
      _smokePaint.color = Color.fromRGBO(255, 255, 255, (b.alpha * intensity).clamp(0.0, 1.0));
      canvas.drawCircle(Offset.zero, 1, _smokePaint);
      canvas.restore();
    }

    for (final e in _embers) {
      final life = (t * e.speed + e.phase) % 1.0;
      final x = (e.x + math.sin(t * 0.8 + e.phase * 3) * 0.02 + life * 0.08) % 1.0 * w;
      final y = h * (1.05 - life * 1.1 * (0.6 + e.y * 0.4));
      final a = (life < 0.1 ? life / 0.1 : (1 - life)) * e.alpha * intensity;
      _ember.color = Color.fromRGBO(255, 150 + (e.phase * 10).toInt() % 60, 60, a.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), e.r, _ember);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.intensity != intensity || oldDelegate.flashes != flashes;
}
