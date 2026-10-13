import 'dart:math' as math;
import 'dart:ui';

/// Procedural pickups and obstacles. Origin is the bottom centre unless noted.
class PropArt {
  PropArt._();

  static final Paint _f = Paint()..isAntiAlias = true;
  static final Paint _s = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3;

  static const _ink = Color(0xFF3A2010);

  // ------------------------------------------------------------------- coin
  /// Coin centred on the origin, radius ~[r]. [spin] in 0..1 loops.
  static void coin(Canvas c, double spin, {double r = 22}) {
    final sx = math.cos(spin * math.pi * 2).abs().clamp(0.18, 1.0);
    c.save();
    c.scale(sx, 1);
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    _f.shader = Gradient.radial(
      Offset(-r * 0.3, -r * 0.4),
      r * 1.4,
      const [Color(0xFFFFF6B5), Color(0xFFFFD23F), Color(0xFFE59A0B)],
      const [0.0, 0.5, 1.0],
    );
    c.drawOval(rect, _f);
    _f.shader = null;
    _s
      ..color = const Color(0xFFB86E00)
      ..strokeWidth = 2.5;
    c.drawOval(rect, _s);
    c.drawOval(rect.deflate(r * 0.22), _s..strokeWidth = 1.8);
    // star emboss
    _f.color = const Color(0xFFFFE57A);
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? r * 0.5 : r * 0.22;
      final p = Offset(math.cos(a) * rr, math.sin(a) * rr);
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    c.drawPath(star, _f);
    c.drawPath(star, _s..strokeWidth = 1.4);
    c.restore();
    // glint
    _f.color = const Color(0xCCFFFFFF);
    c.drawCircle(Offset(-r * 0.35 * sx, -r * 0.45), r * 0.14, _f);
  }

  // -------------------------------------------------------------------- gem
  static void gem(Canvas c, double phase, {double r = 22}) {
    final bob = math.sin(phase * math.pi * 2) * 0.08;
    c.save();
    c.scale(1 + bob, 1 - bob);
    final outer = Path()
      ..moveTo(-r, -r * 0.3)
      ..lineTo(-r * 0.55, -r * 0.85)
      ..lineTo(r * 0.55, -r * 0.85)
      ..lineTo(r, -r * 0.3)
      ..lineTo(0, r)
      ..close();
    _f.shader = Gradient.linear(
      Offset(0, -r),
      Offset(0, r),
      const [Color(0xFFFFB3F0), Color(0xFFE23DD0), Color(0xFF8A1FA6)],
      const [0.0, 0.5, 1.0],
    );
    c.drawPath(outer, _f);
    _f.shader = null;
    _f.color = const Color(0x66FFFFFF);
    c.drawPath(
      Path()
        ..moveTo(-r, -r * 0.3)
        ..lineTo(-r * 0.55, -r * 0.85)
        ..lineTo(-r * 0.1, -r * 0.3)
        ..close(),
      _f,
    );
    c.drawPath(
      Path()
        ..moveTo(-r * 0.1, -r * 0.3)
        ..lineTo(r * 0.3, -r * 0.3)
        ..lineTo(0, r)
        ..close(),
      _f,
    );
    _s
      ..color = const Color(0xFF5A0E6E)
      ..strokeWidth = 2.4;
    c.drawPath(outer, _s);
    c.drawLine(Offset(-r, -r * 0.3), Offset(r, -r * 0.3), _s..strokeWidth = 1.5);
    c.restore();
  }

  // ------------------------------------------------------------ crystal ore
  /// Destructible crystal cluster, [w] wide. [crack] 0..1 damage.
  static void crystal(Canvas c, double phase, {double w = 90, double crack = 0}) {
    // base rocks
    _f.color = const Color(0xFF8A7F9E);
    c.drawOval(Rect.fromCenter(center: const Offset(0, -10), width: w, height: 26), _f);
    _s
      ..color = const Color(0xFF3B2A55)
      ..strokeWidth = 2.6;
    c.drawOval(Rect.fromCenter(center: const Offset(0, -10), width: w, height: 26), _s);
    final glow = 0.5 + 0.5 * math.sin(phase * math.pi * 2);
    _f.color = Color.fromRGBO(120, 255, 240, 0.18 + 0.15 * glow);
    c.drawCircle(const Offset(0, -50), w * 0.62, _f);
    const shards = [(-26.0, 46.0, -0.35, 0), (0.0, 78.0, 0.0, 1), (24.0, 56.0, 0.3, 0), (-8.0, 36.0, -0.1, 2)];
    for (final (x, h, a, col) in shards) {
      c.save();
      c.translate(x * w / 90, -12);
      c.rotate(a);
      final ww = 14.0 * w / 90;
      final shard = Path()
        ..moveTo(-ww, 0)
        ..lineTo(-ww, -h * 0.7)
        ..lineTo(0, -h)
        ..lineTo(ww, -h * 0.7)
        ..lineTo(ww, 0)
        ..close();
      final colors = switch (col) {
        0 => const [Color(0xFFBFFFF8), Color(0xFF3FE0D0), Color(0xFF1C9AA6)],
        1 => const [Color(0xFFF0D9FF), Color(0xFFB57BFF), Color(0xFF6A34C7)],
        _ => const [Color(0xFFFFF1C4), Color(0xFFFFC94D), Color(0xFFD1860F)],
      };
      _f.shader = Gradient.linear(Offset(-ww, -h), Offset(ww, 0), colors, const [0.0, 0.5, 1.0]);
      c.drawPath(shard, _f);
      _f.shader = null;
      _f.color = const Color(0x77FFFFFF);
      c.drawPath(
        Path()
          ..moveTo(-ww * 0.6, -4)
          ..lineTo(-ww * 0.6, -h * 0.66)
          ..lineTo(0, -h * 0.95)
          ..lineTo(-ww * 0.1, -4)
          ..close(),
        _f,
      );
      c.drawPath(shard, _s);
      c.restore();
    }
    if (crack > 0) _cracks(c, w, crack, -40);
  }

  static void _cracks(Canvas c, double w, double crack, double cy) {
    _s
      ..color = const Color(0xFF2A1636)
      ..strokeWidth = 2.4;
    final p = Path()
      ..moveTo(-w * 0.2, cy - 20)
      ..lineTo(-w * 0.05, cy - 4)
      ..lineTo(-w * 0.15, cy + 8)
      ..lineTo(0, cy + 20);
    if (crack > 0.5) {
      p
        ..moveTo(w * 0.2, cy - 16)
        ..lineTo(w * 0.05, cy)
        ..lineTo(w * 0.18, cy + 14);
    }
    c.drawPath(p, _s);
  }

  // ----------------------------------------------------------------- boulder
  static void boulder(Canvas c, {double w = 96, double crack = 0}) {
    final h = w * 0.82;
    final path = Path()
      ..moveTo(-w * 0.5, 0)
      ..cubicTo(-w * 0.58, -h * 0.55, -w * 0.3, -h, w * 0.02, -h)
      ..cubicTo(w * 0.36, -h, w * 0.58, -h * 0.6, w * 0.5, 0)
      ..close();
    _f.shader = Gradient.radial(
      Offset(-w * 0.18, -h * 0.7),
      w * 0.9,
      const [Color(0xFFE0CDB8), Color(0xFFB0927A), Color(0xFF7A5F4F)],
      const [0.0, 0.5, 1.0],
    );
    c.drawPath(path, _f);
    _f.shader = null;
    // moss cap
    _f.color = const Color(0xFF66C95A);
    c.drawPath(
      Path()
        ..moveTo(-w * 0.34, -h * 0.82)
        ..quadraticBezierTo(0, -h * 1.08, w * 0.34, -h * 0.84)
        ..quadraticBezierTo(w * 0.18, -h * 0.72, w * 0.04, -h * 0.8)
        ..quadraticBezierTo(-w * 0.12, -h * 0.7, -w * 0.34, -h * 0.82)
        ..close(),
      _f,
    );
    _s
      ..color = const Color(0xFF3E2A22)
      ..strokeWidth = 3;
    c.drawPath(path, _s);
    _f.color = const Color(0x55FFFFFF);
    c.drawOval(Rect.fromLTWH(-w * 0.32, -h * 0.66, w * 0.2, h * 0.12), _f);
    if (crack > 0) _cracks(c, w, crack, -h * 0.45);
  }

  // -------------------------------------------------------------- thorn bush
  static void thorns(Canvas c, double phase, {double w = 100}) {
    final h = w * 0.55;
    final sway = math.sin(phase * math.pi * 2) * 2;
    _f.color = const Color(0xFF3F2A5C);
    final base = Path()
      ..moveTo(-w * 0.5, 0)
      ..quadraticBezierTo(-w * 0.45, -h, 0, -h)
      ..quadraticBezierTo(w * 0.45, -h, w * 0.5, 0)
      ..close();
    c.drawPath(base, _f);
    // spikes
    _f.color = const Color(0xFFE8E0F5);
    _s
      ..color = const Color(0xFF1E1030)
      ..strokeWidth = 2;
    for (var i = 0; i < 9; i++) {
      final a = math.pi + (i + 0.5) / 9 * math.pi;
      final bx = math.cos(a) * w * 0.44, by = math.sin(a) * h * 0.92;
      final tx = math.cos(a) * w * 0.62 + sway, ty = math.sin(a) * h * 1.32;
      final n = Offset(-math.sin(a), math.cos(a)) * 6;
      final spike = Path()
        ..moveTo(bx - n.dx, by - n.dy)
        ..lineTo(tx, ty)
        ..lineTo(bx + n.dx, by + n.dy)
        ..close();
      c.drawPath(spike, _f);
      c.drawPath(spike, _s);
    }
    // vines
    _f.color = const Color(0xFF6B3FA0);
    c.drawPath(base, _f);
    _s
      ..color = const Color(0xFF1E1030)
      ..strokeWidth = 3;
    c.drawPath(base, _s);
    _s
      ..color = const Color(0xFF9B6AD6)
      ..strokeWidth = 3;
    c.drawPath(
      Path()
        ..moveTo(-w * 0.35, -4)
        ..quadraticBezierTo(-w * 0.1, -h * 0.9, w * 0.2, -h * 0.4),
      _s,
    );
    c.drawPath(
      Path()
        ..moveTo(w * 0.32, -4)
        ..quadraticBezierTo(w * 0.1, -h * 0.7, -w * 0.15, -h * 0.55),
      _s,
    );
    // eyes peeking out
    _f.color = const Color(0xFFFFE14D);
    c.drawOval(Rect.fromCenter(center: Offset(-w * 0.12, -h * 0.45), width: 9, height: 6), _f);
    c.drawOval(Rect.fromCenter(center: Offset(w * 0.04, -h * 0.47), width: 9, height: 6), _f);
  }

  // ---------------------------------------------------------- magic barrier
  /// Tall magical barrier, [h] high, origin bottom centre. [hp01] remaining health.
  static void barrier(Canvas c, double phase, {double h = 230, double hp01 = 1}) {
    const w = 64.0;
    // energy field
    final t = phase * math.pi * 2;
    final rect = Rect.fromLTWH(-w * 0.32, -h + 20, w * 0.64, h - 28);
    _f.shader = Gradient.linear(rect.topCenter, rect.bottomCenter, [
      Color.fromRGBO(255, 120, 230, 0.55 * hp01 + 0.2),
      Color.fromRGBO(140, 90, 255, 0.45 * hp01 + 0.15),
    ]);
    c.drawRect(rect, _f);
    _f.shader = null;
    _s
      ..color = const Color.fromRGBO(255, 230, 255, 0.85)
      ..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      final y0 = rect.top + ((i / 4 + phase) % 1.0) * rect.height;
      final p = Path()..moveTo(rect.left, y0);
      for (var k = 1; k <= 6; k++) {
        p.lineTo(rect.left + rect.width * k / 6, y0 + math.sin(t * 2 + k + i) * 8);
      }
      c.drawPath(p, _s);
    }
    // stone pillars
    for (final x in [-w * 0.42, w * 0.42]) {
      final pr = RRect.fromRectAndRadius(Rect.fromLTWH(x - 11, -h, 22, h), const Radius.circular(6));
      _f.shader = Gradient.linear(Offset(x - 11, 0), Offset(x + 11, 0), const [Color(0xFFE6DDF2), Color(0xFF9C8FB8)]);
      c.drawRRect(pr, _f);
      _f.shader = null;
      _s
        ..color = const Color(0xFF3B2A55)
        ..strokeWidth = 2.6;
      c.drawRRect(pr, _s);
      // runes
      _f.color = Color.fromRGBO(255, 120, 230, 0.6 + 0.4 * math.sin(t * 3));
      for (var k = 0; k < 4; k++) {
        c.drawCircle(Offset(x, -h + 30 + k * (h - 60) / 3), 4, _f);
      }
      // cap orb
      _f.color = const Color(0xFFFF8AE6);
      c.drawCircle(Offset(x, -h - 6), 9, _f);
      c.drawCircle(Offset(x, -h - 6), 9, _s);
    }
  }

  // ---------------------------------------------------------- floating spike
  /// Floating thorn pod centred on the origin.
  static void spikePod(Canvas c, double phase, {double r = 30}) {
    final spin = phase * math.pi * 2;
    c.save();
    c.rotate(spin * 0.25);
    _f.color = const Color(0xFFF3E6FF);
    _s
      ..color = const Color(0xFF2A1636)
      ..strokeWidth = 2;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * math.pi * 2;
      final spike = Path()
        ..moveTo(math.cos(a - 0.22) * r * 0.85, math.sin(a - 0.22) * r * 0.85)
        ..lineTo(math.cos(a) * r * 1.45, math.sin(a) * r * 1.45)
        ..lineTo(math.cos(a + 0.22) * r * 0.85, math.sin(a + 0.22) * r * 0.85)
        ..close();
      c.drawPath(spike, _f);
      c.drawPath(spike, _s);
    }
    c.restore();
    _f.shader = Gradient.radial(
      Offset(-r * 0.3, -r * 0.3),
      r * 1.2,
      const [Color(0xFFB98BFF), Color(0xFF6A34C7), Color(0xFF3B1E78)],
      const [0.0, 0.6, 1.0],
    );
    c.drawCircle(Offset.zero, r, _f);
    _f.shader = null;
    _s.strokeWidth = 3;
    c.drawCircle(Offset.zero, r, _s);
    _f.color = const Color(0xFFFFE14D);
    final blink = (math.sin(spin * 1.5) > 0.95) ? 0.2 : 1.0;
    c.drawOval(Rect.fromCenter(center: Offset(-r * 0.3, -r * 0.1), width: 10, height: 12 * blink), _f);
    c.drawOval(Rect.fromCenter(center: Offset(r * 0.1, -r * 0.1), width: 10, height: 12 * blink), _f);
    _f.color = const Color(0x55FFFFFF);
    c.drawCircle(Offset(-r * 0.4, -r * 0.45), r * 0.2, _f);
  }

  // ------------------------------------------------------------------- chest
  static void chest(Canvas c, double phase, {double open = 0, double w = 84}) {
    final h = w * 0.62;
    final glow = 0.5 + 0.5 * math.sin(phase * math.pi * 2);
    _f.color = Color.fromRGBO(255, 220, 90, 0.2 + 0.2 * glow);
    c.drawCircle(Offset(0, -h * 0.6), w * 0.75, _f);
    final box = RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2, -h * 0.62, w, h * 0.62), const Radius.circular(6));
    _f.shader = Gradient.linear(Offset(0, -h), Offset.zero, const [Color(0xFFC07A3A), Color(0xFF7E4520)]);
    c.drawRRect(box, _f);
    _f.shader = null;
    _s
      ..color = _ink
      ..strokeWidth = 3;
    c.drawRRect(box, _s);
    // lid
    c.save();
    c.translate(-w / 2, -h * 0.62);
    c.rotate(-open * 1.2);
    final lid = Path()
      ..moveTo(0, 0)
      ..lineTo(0, -h * 0.25)
      ..quadraticBezierTo(w / 2, -h * 0.62, w, -h * 0.25)
      ..lineTo(w, 0)
      ..close();
    _f.shader = Gradient.linear(Offset(0, -h * 0.5), Offset.zero, const [Color(0xFFD99050), Color(0xFF9A5A2C)]);
    c.drawPath(lid, _f);
    _f.shader = null;
    c.drawPath(lid, _s);
    _f.color = const Color(0xFFFFD23F);
    c.drawRect(Rect.fromLTWH(w * 0.12, -h * 0.42, 9, h * 0.42), _f);
    c.drawRect(Rect.fromLTWH(w * 0.82, -h * 0.42, 9, h * 0.42), _f);
    c.restore();
    // gold trims + lock
    _f.color = const Color(0xFFFFD23F);
    c.drawRect(Rect.fromLTWH(-w / 2 + w * 0.12, -h * 0.62, 9, h * 0.62), _f);
    c.drawRect(Rect.fromLTWH(-w / 2 + w * 0.82, -h * 0.62, 9, h * 0.62), _f);
    final lock = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h * 0.5), width: 16, height: 18), const Radius.circular(4));
    c.drawRRect(lock, _f);
    c.drawRRect(lock, _s..strokeWidth = 2);
    if (open > 0.1) {
      _f.color = Color.fromRGBO(255, 240, 150, 0.7 * open);
      c.drawPath(
        Path()
          ..moveTo(-w * 0.4, -h * 0.62)
          ..lineTo(-w * 0.7, -h * 2.2)
          ..lineTo(w * 0.7, -h * 2.2)
          ..lineTo(w * 0.4, -h * 0.62)
          ..close(),
        _f,
      );
    }
  }

  // ------------------------------------------------------------- magic gate
  /// Magic ring gate centred on the origin with radius [r].
  static void gate(Canvas c, double phase, {double r = 80, bool used = false}) {
    final t = phase * math.pi * 2;
    if (!used) {
      _f.shader = Gradient.radial(Offset.zero, r, [const Color(0x00FFFFFF), Color.fromRGBO(140, 240, 255, 0.35 + 0.1 * math.sin(t * 2))]);
      c.drawCircle(Offset.zero, r, _f);
      _f.shader = null;
      // swirl
      _s
        ..color = const Color(0xAAFFFFFF)
        ..strokeWidth = 3;
      for (var i = 0; i < 3; i++) {
        final a0 = t + i * math.pi * 2 / 3;
        c.drawArc(Rect.fromCircle(center: Offset.zero, radius: r * (0.35 + i * 0.18)), a0, 1.8, false, _s);
      }
    }
    _s
      ..color = const Color(0xFF6A3A08)
      ..strokeWidth = 18;
    c.drawCircle(Offset.zero, r, _s);
    _s
      ..color = used ? const Color(0xFFB59A62) : const Color(0xFFFFCF3A)
      ..strokeWidth = 12;
    c.drawCircle(Offset.zero, r, _s);
    _f.color = used ? const Color(0xFF9C8FB8) : Color.fromRGBO(120, 255, 240, 0.8 + 0.2 * math.sin(t * 4));
    for (var i = 0; i < 8; i++) {
      final a = i / 8 * math.pi * 2 + t * 0.3;
      c.drawCircle(Offset(math.cos(a) * r, math.sin(a) * r), 5, _f);
    }
  }

  // ------------------------------------------------------------- power-ups
  static void heart(Canvas c, double phase, {double r = 20}) {
    final beat = 1 + 0.08 * math.sin(phase * math.pi * 4);
    c.save();
    c.scale(beat);
    final p = Path()
      ..moveTo(0, r * 0.9)
      ..cubicTo(-r * 1.4, 0, -r * 0.9, -r * 1.2, 0, -r * 0.45)
      ..cubicTo(r * 0.9, -r * 1.2, r * 1.4, 0, 0, r * 0.9)
      ..close();
    _f.shader = Gradient.radial(
      Offset(-r * 0.3, -r * 0.4),
      r * 1.4,
      const [Color(0xFFFFA8B8), Color(0xFFFF3D63), Color(0xFFC0123A)],
      const [0.0, 0.5, 1.0],
    );
    c.drawPath(p, _f);
    _f.shader = null;
    _s
      ..color = const Color(0xFF6E0A22)
      ..strokeWidth = 2.6;
    c.drawPath(p, _s);
    _f.color = const Color(0xAAFFFFFF);
    c.drawOval(Rect.fromLTWH(-r * 0.7, -r * 0.55, r * 0.4, r * 0.28), _f);
    c.restore();
  }

  static void magnet(Canvas c, double phase, {double r = 20}) {
    c.save();
    c.rotate(math.sin(phase * math.pi * 2) * 0.15);
    _s
      ..color = const Color(0xFFE53935)
      ..strokeWidth = r * 0.55
      ..strokeCap = StrokeCap.butt;
    c.drawArc(Rect.fromCircle(center: Offset(0, -r * 0.1), radius: r * 0.7), math.pi, math.pi, false, _s);
    c.drawLine(Offset(-r * 0.7, -r * 0.1), Offset(-r * 0.7, r * 0.5), _s);
    c.drawLine(Offset(r * 0.7, -r * 0.1), Offset(r * 0.7, r * 0.5), _s);
    _s.color = const Color(0xFFE8EEF5);
    c.drawLine(Offset(-r * 0.7, r * 0.5), Offset(-r * 0.7, r * 0.85), _s);
    c.drawLine(Offset(r * 0.7, r * 0.5), Offset(r * 0.7, r * 0.85), _s);
    _s.strokeCap = StrokeCap.round;
    c.restore();
  }

  /// Ground shadow ellipse.
  static void shadow(Canvas c, double w, double alpha) {
    _f.color = Color.fromRGBO(30, 40, 30, alpha.clamp(0.0, 1.0));
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.22), _f);
  }
}
