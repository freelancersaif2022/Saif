import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/element.dart';

enum FxKind { slash, projectile, impact, shockwave, shield, heal, miss }

class FxEffect {
  FxEffect(this.kind, {required this.from, required this.to, this.element = BeastElement.inferno, this.crit = false, this.duration = 0.7, this.size = 120}) : seed = Random().nextInt(1 << 30);
  final FxKind kind;
  final Offset from;
  final Offset to;
  final BeastElement element;
  final bool crit;
  final double duration; // seconds
  final double size; // roughly the target monster's size
  final int seed;
  double start = 0;
}

/// Drives the attack effects. The battle screen adds effects; the layer
/// repaints only while something is on screen.
class BattleFxController extends ChangeNotifier {
  final List<FxEffect> _effects = [];
  double _now = 0;

  void add(FxEffect e) {
    e.start = _now;
    _effects.add(e);
    notifyListeners();
  }

  /// How long a projectile takes to reach its target (seconds).
  static const projectileTravel = 0.34;

  void _tick(double now) {
    _now = now;
    _effects.removeWhere((e) => now - e.start > e.duration);
  }
}

class BattleFxLayer extends StatefulWidget {
  const BattleFxLayer({super.key, required this.controller});
  final BattleFxController controller;

  @override
  State<BattleFxLayer> createState() => _BattleFxLayerState();
}

class _BattleFxLayerState extends State<BattleFxLayer> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  double _now = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_wake);
  }

  void _wake() {
    if (!_ticker.isActive) _ticker.start();
  }

  void _onTick(Duration elapsed) {
    _now = elapsed.inMicroseconds / 1e6 + _base;
    widget.controller._tick(_now);
    if (widget.controller._effects.isEmpty) {
      _base = _now;
      _ticker.stop();
    }
    setState(() {});
  }

  double _base = 0;

  @override
  void dispose() {
    widget.controller.removeListener(_wake);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _FxPainter(List.of(widget.controller._effects), _now), size: Size.infinite),
      ),
    );
  }
}

class _FxPainter extends CustomPainter {
  _FxPainter(this.effects, this.now);
  final List<FxEffect> effects;
  final double now;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in effects) {
      final p = ((now - e.start) / e.duration).clamp(0.0, 1.0);
      switch (e.kind) {
        case FxKind.slash:
          _slash(canvas, e, p, miss: false);
        case FxKind.miss:
          _slash(canvas, e, p, miss: true);
        case FxKind.projectile:
          _projectile(canvas, e, p, size);
        case FxKind.impact:
          _impact(canvas, e.to, e.element.color, p, e.size, e.seed, big: e.crit);
        case FxKind.shockwave:
          _shockwave(canvas, e, p);
        case FxKind.shield:
          _shield(canvas, e, p);
        case FxKind.heal:
          _heal(canvas, e, p);
      }
    }
  }

  // A glowing blade crescent sweeps across the target, with claw streaks
  // and sparks on contact.
  void _slash(Canvas canvas, FxEffect e, double p, {required bool miss}) {
    final c = miss ? e.to + Offset(e.size * 0.45, -e.size * 0.2) : e.to;
    final r = e.size * 0.5;
    final sweep = Curves.easeOutCubic.transform((p / 0.4).clamp(0.0, 1.0));
    final fade = p < 0.4 ? 1.0 : 1 - (p - 0.4) / 0.6;
    final glow = e.crit ? const Color(0xFFFFD54F) : const Color(0xFF9BE7FF);

    // Blade crescent: area between two arcs, revealed as the blade sweeps.
    const startAngle = -2.4;
    final sweepAngle = 2.2 * sweep;
    final outer = Rect.fromCircle(center: c + Offset(-r * 0.15, r * 0.25), radius: r);
    final inner = Rect.fromCircle(center: c + Offset(-r * 0.02, r * 0.38), radius: r * 0.8);
    final crescent = Path()
      ..arcTo(outer, startAngle, sweepAngle, true)
      ..arcTo(inner, startAngle + sweepAngle, -sweepAngle, false)
      ..close();
    canvas.drawPath(
      crescent,
      Paint()
        ..color = glow.withValues(alpha: 0.45 * fade)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = ui.Gradient.sweep(
          outer.center,
          [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: fade)],
          const [0.0, 1.0],
          TileMode.clamp,
          startAngle,
          startAngle + max(0.01, sweepAngle),
        ),
    );
    // Bright leading edge.
    canvas.drawArc(
      outer,
      startAngle + sweepAngle * 0.55,
      sweepAngle * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.06
        ..color = Colors.white.withValues(alpha: fade),
    );
    if (miss) return;
    // Claw streaks left behind on the target.
    final streak = (p / 0.3).clamp(0.0, 1.0);
    for (var i = -1; i <= 1; i++) {
      final a = c + Offset(-r * 0.55 + i * r * 0.22, -r * 0.45 + i * r * 0.05);
      final b = c + Offset(r * 0.35 + i * r * 0.22, r * 0.45 + i * r * 0.05);
      canvas.drawLine(
        a,
        Offset.lerp(a, b, streak)!,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.07
          ..color = const Color(0xFFFF5252).withValues(alpha: 0.75 * fade),
      );
      canvas.drawLine(
        a,
        Offset.lerp(a, b, streak)!,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.025
          ..color = Colors.white.withValues(alpha: fade),
      );
    }
    if (p > 0.12) _sparks(canvas, c, glow, ((p - 0.12) / 0.88).clamp(0, 1), e.size, e.seed, count: e.crit ? 20 : 12);
  }

  void _sparks(Canvas canvas, Offset c, Color color, double p, double size, int seed, {int count = 10}) {
    final r = Random(seed);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final a = r.nextDouble() * 2 * pi;
      final speed = size * (0.35 + r.nextDouble() * 0.45);
      final d = speed * Curves.easeOut.transform(p);
      final head = c + Offset(cos(a), sin(a)) * d;
      final tail = c + Offset(cos(a), sin(a)) * max(0, d - size * 0.08);
      paint
        ..color = Color.lerp(Colors.white, color, p)!.withValues(alpha: 1 - p)
        ..strokeWidth = 3.2 * (1 - p) + 0.6;
      canvas.drawLine(tail, head, paint);
    }
  }

  void _impact(Canvas canvas, Offset c, Color color, double p, double size, int seed, {bool big = false}) {
    final s = size * (big ? 1.25 : 1.0);
    // flash
    if (p < 0.4) {
      final f = 1 - p / 0.4;
      canvas.drawCircle(
        c,
        s * 0.5,
        Paint()..shader = ui.Gradient.radial(c, s * 0.5, [Colors.white.withValues(alpha: 0.95 * f), color.withValues(alpha: 0.6 * f), color.withValues(alpha: 0)], const [0.0, 0.4, 1.0]),
      );
    }
    // ring
    canvas.drawCircle(
      c,
      s * (0.15 + 0.5 * Curves.easeOut.transform(p)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06 * (1 - p)
        ..color = color.withValues(alpha: 1 - p),
    );
    _sparks(canvas, c, color, p, s, seed, count: big ? 22 : 14);
  }

  void _projectile(Canvas canvas, FxEffect e, double p, Size screen) {
    final travel = BattleFxController.projectileTravel / e.duration;
    final color = e.element.color;
    if (p >= travel) {
      _impact(canvas, e.to, color, (p - travel) / (1 - travel), e.size, e.seed, big: e.crit);
      return;
    }
    final u = Curves.easeIn.transform(p / travel);
    // Arc slightly upward so it feels thrown.
    final mid = Offset.lerp(e.from, e.to, 0.5)! - Offset(0, e.size * 0.35);
    Offset at(double t) {
      final a = Offset.lerp(e.from, mid, t)!;
      final b = Offset.lerp(mid, e.to, t)!;
      return Offset.lerp(a, b, t)!;
    }

    final pos = at(u);
    final dir = at(min(1, u + 0.02)) - at(max(0, u - 0.02));
    final ang = atan2(dir.dy, dir.dx);
    final s = e.size * 0.16;
    switch (e.element) {
      case BeastElement.inferno:
        for (var i = 8; i >= 1; i--) {
          final tp = at(max(0, u - i * 0.035));
          canvas.drawCircle(tp, s * (1 - i * 0.09), Paint()..color = Color.lerp(const Color(0xFFFFEB3B), const Color(0xFFD84315), i / 8)!.withValues(alpha: 0.5 * (1 - i / 9)));
        }
        canvas.drawCircle(
          pos,
          s * 1.5,
          Paint()..shader = ui.Gradient.radial(pos, s * 1.5, const [Color(0xFFFFFDE7), Color(0xFFFFB300), Color(0xFFE64A19), Color(0x00E64A19)], const [0.0, 0.35, 0.7, 1.0]),
        );
      case BeastElement.frost:
        final s = e.size * 0.24;
        for (var k = -1; k <= 1; k++) {
          canvas.save();
          canvas.translate(pos.dx + k * s * 0.4 * cos(ang + pi / 2), pos.dy + k * s * 0.4 * sin(ang + pi / 2) - k.abs() * s * 0.3);
          canvas.rotate(ang);
          final shard = Path()
            ..moveTo(s * 1.6, 0)
            ..lineTo(0, -s * 0.35)
            ..lineTo(-s * 1.0, 0)
            ..lineTo(0, s * 0.35)
            ..close();
          canvas.drawPath(shard, Paint()..shader = ui.Gradient.linear(Offset(-s, 0), Offset(s * 1.6, 0), const [Color(0x6680D8FF), Color(0xFFE1F5FE), Colors.white], const [0.0, 0.6, 1.0]));
          canvas.restore();
        }
      case BeastElement.storm:
        // Lightning strikes down from the sky onto the target.
        final r = Random(e.seed + (u * 12).floor());
        var pt = Offset(e.to.dx + (r.nextDouble() - 0.5) * 40, 0);
        final bolt = Path()..moveTo(pt.dx, pt.dy);
        final reach = e.to.dy * min(1.0, u * 1.6);
        while (pt.dy < reach) {
          pt = Offset(e.to.dx + (r.nextDouble() - 0.5) * e.size * 0.35, pt.dy + 22 + r.nextDouble() * 18);
          bolt.lineTo(pt.dx, min(pt.dy, reach));
        }
        canvas.drawPath(
          bolt,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..color = const Color(0xFFFFF176).withValues(alpha: 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawPath(
          bolt,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Colors.white,
        );
      case BeastElement.tide:
        for (var i = 6; i >= 1; i--) {
          final tp = at(max(0, u - i * 0.04)) + Offset(0, sin(i * 1.7) * s * 0.4);
          canvas.drawCircle(tp, s * 0.35 * (1 - i * 0.1), Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.7 - i * 0.1));
        }
        canvas.drawCircle(
          pos,
          s * 1.3,
          Paint()..shader = ui.Gradient.radial(pos - Offset(s * 0.4, s * 0.4), s * 1.6, const [Colors.white, Color(0xFF4FC3F7), Color(0xFF0277BD)], const [0.0, 0.4, 1.0]),
        );
      case BeastElement.terra:
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(u * 9);
        final rr = Random(e.seed);
        final rock = Path();
        for (var k = 0; k < 7; k++) {
          final a = k / 7 * 2 * pi;
          final d = s * (1.1 + rr.nextDouble() * 0.4);
          final q = Offset(cos(a) * d, sin(a) * d);
          k == 0 ? rock.moveTo(q.dx, q.dy) : rock.lineTo(q.dx, q.dy);
        }
        rock.close();
        canvas.drawPath(rock, Paint()..shader = ui.Gradient.linear(Offset(-s, -s), Offset(s, s), const [Color(0xFFBCAAA4), Color(0xFF5D4037)]));
        canvas.drawPath(
          rock,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF3E2723),
        );
        canvas.restore();
      case BeastElement.shadow:
        for (var i = 5; i >= 1; i--) {
          final tp = at(max(0, u - i * 0.04));
          canvas.drawCircle(tp, s * (1.3 - i * 0.15), Paint()..color = const Color(0xFF6A1B9A).withValues(alpha: 0.18));
        }
        canvas.drawCircle(
          pos,
          s * 1.6,
          Paint()..shader = ui.Gradient.radial(pos, s * 1.6, const [Color(0xFF000000), Color(0xFF4A148C), Color(0xFFE040FB), Color(0x00E040FB)], const [0.0, 0.45, 0.75, 1.0]),
        );
    }
  }

  void _shockwave(Canvas canvas, FxEffect e, double p) {
    for (var k = 0; k < 3; k++) {
      final q = (p * 1.4 - k * 0.2).clamp(0.0, 1.0);
      if (q <= 0) continue;
      canvas.drawCircle(
        e.from,
        e.size * (0.3 + q * 0.9),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = e.size * 0.05 * (1 - q)
          ..color = Color.lerp(const Color(0xFFFF5252), const Color(0xFFFFAB40), q)!.withValues(alpha: 1 - q),
      );
    }
  }

  void _shield(Canvas canvas, FxEffect e, double p) {
    final r = e.size * 0.48;
    final alpha = p < 0.2 ? p / 0.2 : (p > 0.75 ? (1 - p) / 0.25 : 1.0);
    final hex = Path();
    for (var k = 0; k < 6; k++) {
      final a = k / 6 * 2 * pi + pi / 6;
      final q = e.from + Offset(cos(a), sin(a)) * r;
      k == 0 ? hex.moveTo(q.dx, q.dy) : hex.lineTo(q.dx, q.dy);
    }
    hex.close();
    canvas.drawPath(hex, Paint()..shader = ui.Gradient.radial(e.from, r, [const Color(0x0038E1FF), const Color(0xFF38E1FF).withValues(alpha: 0.33 * alpha)]));
    canvas.drawPath(
      hex,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF80F0FF).withValues(alpha: alpha),
    );
  }

  void _heal(Canvas canvas, FxEffect e, double p) {
    final r = Random(e.seed);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    for (var i = 0; i < 7; i++) {
      final x = e.from.dx + (r.nextDouble() - 0.5) * e.size * 0.8;
      final y = e.from.dy + e.size * 0.2 - p * e.size * (0.5 + r.nextDouble() * 0.4);
      final s = e.size * 0.05;
      paint.color = const Color(0xFF69F0AE).withValues(alpha: 1 - p);
      canvas.drawLine(Offset(x - s, y), Offset(x + s, y), paint);
      canvas.drawLine(Offset(x, y - s), Offset(x, y + s), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FxPainter old) => true;
}

/// Custom sword icon for the basic attack button.
class SwordIcon extends StatelessWidget {
  const SwordIcon({super.key, this.size = 22, this.color = Colors.white});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _SwordPainter(color));
}

class _SwordPainter extends CustomPainter {
  _SwordPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.rotate(-pi / 4);
    final blade = Path()
      ..moveTo(0, -s * 0.5)
      ..lineTo(s * 0.09, -s * 0.36)
      ..lineTo(s * 0.09, s * 0.14)
      ..lineTo(-s * 0.09, s * 0.14)
      ..lineTo(-s * 0.09, -s * 0.36)
      ..close();
    canvas.drawPath(blade, Paint()..color = color);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, s * 0.18), width: s * 0.46, height: s * 0.08), Radius.circular(s * 0.04)), Paint()..color = color);
    canvas.drawRect(Rect.fromCenter(center: Offset(0, s * 0.33), width: s * 0.09, height: s * 0.22), Paint()..color = color);
    canvas.drawCircle(Offset(0, s * 0.46), s * 0.06, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SwordPainter old) => old.color != color;
}
