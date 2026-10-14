import 'dart:math' as math;
import 'dart:ui';

import '../core/utils.dart';
import 'soft_sprite.dart';

/// Shared pose values for one tiger frame.
class _TigerGeo {
  _TigerGeo(this.run, double crouch, double mouth, this.morph, this.roar, this.time)
      : dy = crouch * 40 - roar * 10,
        headAngle = -roar * 0.7 + crouch * 0.12,
        jaw = math.max(mouth * 0.38, roar * 0.85),
        neck = Offset(150, -178 + crouch * 40 - roar * 22);
  final double run;
  final double morph;
  final double roar;
  final double time;
  final double dy;
  final double headAngle;
  final double jaw;
  final Offset neck;
}

/// Procedural silhouettes of the shadow beasts. All drawn facing +x.
class BeastPainter {
  BeastPainter._();

  static final Paint _p = Paint()..isAntiAlias = true;
  static final Paint _s = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final Path _path = Path();

  static const Color shadow = Color(0xFF050609);
  static const Color rim = Color(0xFF7F9CC4);
  static const Color redEye = Color(0xFFFF2020);
  static const Color vein = Color(0xFFFF2A1A);
  static const Color detail = Color(0x38A8C0E0);
  static const Color bone = Color(0xFF9A9284);

  static Color _body(double alpha, double flash) =>
      fade(Color.lerp(shadow, const Color(0xFF3E4A62), flash.clamp(0.0, 1.0) * 0.4)!, alpha);

  static void glowEye(Canvas c, Offset e, double r, double g, {Color color = redEye}) {
    if (g <= 0.01) return;
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus
      ..color = fade(color, 0.14 * g);
    c.drawCircle(e, r * 4.2, _p);
    _p.color = fade(color, 0.34 * g);
    c.drawCircle(e, r * 1.9, _p);
    _p.blendMode = BlendMode.srcOver;
    _p.color = fade(Color.lerp(color, const Color(0xFFFFFFFF), 0.55)!, g.clamp(0.0, 1.0));
    _path
      ..reset()
      ..moveTo(e.dx - r * 1.2, e.dy + r * 0.2)
      ..lineTo(e.dx + r * 1.3, e.dy - r * 0.45)
      ..lineTo(e.dx + r * 0.6, e.dy + r * 0.45)
      ..close();
    c.drawPath(_path, _p);
  }

  /// Dark smoke aura and a faint red under-glow around a beast.
  static void aura(Canvas c, Rect r, double time, double alpha, {Color glow = vein}) {
    if (alpha <= 0.02) return;
    for (var i = 0; i < 6; i++) {
      final a = time * 0.6 + i * 1.05;
      final cx = r.center.dx + math.cos(a) * r.width * 0.42;
      final cy = r.center.dy + math.sin(a * 1.3) * r.height * 0.35;
      SoftSprite.draw(c, Offset(cx, cy), r.shortestSide * (0.42 + 0.08 * math.sin(time + i)), fade(const Color(0xFF05060A), 0.5 * alpha));
    }
    SoftSprite.draw(c, Offset(r.center.dx, r.bottom - r.height * 0.05), r.width * 0.55, fade(glow, 0.12 * alpha * (0.8 + 0.2 * math.sin(time * 2.4))), blend: BlendMode.plus);
  }

  static void _veins(Canvas c, List<List<Offset>> lines, double width, double alpha, double time) {
    if (alpha <= 0.02) return;
    final pulse = 0.55 + 0.45 * math.sin(time * 3.0);
    _s
      ..blendMode = BlendMode.plus
      ..strokeWidth = width * 2.6
      ..color = fade(vein, 0.16 * alpha * pulse);
    for (final l in lines) {
      _path.reset();
      _path.moveTo(l.first.dx, l.first.dy);
      for (var i = 1; i < l.length; i++) {
        _path.lineTo(l[i].dx, l[i].dy);
      }
      c.drawPath(_path, _s);
    }
    _s
      ..strokeWidth = width
      ..color = fade(const Color(0xFFFF6A40), 0.7 * alpha * pulse);
    for (final l in lines) {
      _path.reset();
      _path.moveTo(l.first.dx, l.first.dy);
      for (var i = 1; i < l.length; i++) {
        _path.lineTo(l[i].dx, l[i].dy);
      }
      c.drawPath(_path, _s);
    }
    _s.blendMode = BlendMode.srcOver;
  }

  static void _taper(Canvas c, List<Offset> pts, double w0, double w1, Paint paint) {
    final n = pts.length;
    for (var i = 0; i < n - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final wa = lerpD(w0, w1, i / (n - 1));
      final wb = lerpD(w0, w1, (i + 1) / (n - 1));
      final d = b - a;
      final len = d.distance;
      if (len < 0.001) continue;
      final nn = Offset(-d.dy / len, d.dx / len);
      _path
        ..reset()
        ..moveTo(a.dx + nn.dx * wa / 2, a.dy + nn.dy * wa / 2)
        ..lineTo(b.dx + nn.dx * wb / 2, b.dy + nn.dy * wb / 2)
        ..lineTo(b.dx - nn.dx * wb / 2, b.dy - nn.dy * wb / 2)
        ..lineTo(a.dx - nn.dx * wa / 2, a.dy - nn.dy * wa / 2)
        ..close();
      c.drawPath(_path, paint);
      c.drawCircle(b, wb / 2, paint);
    }
    c.drawCircle(pts.first, w0 / 2, paint);
  }

  static void _lens(Canvas c, Offset base, Offset dir, double len, double width, Paint paint) {
    final d = dir / math.max(dir.distance, 0.0001);
    final n = Offset(-d.dy, d.dx);
    final tip = base + d * len;
    final mid = base + d * (len * 0.45);
    _path
      ..reset()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(mid.dx + n.dx * width, mid.dy + n.dy * width, tip.dx, tip.dy)
      ..quadraticBezierTo(mid.dx - n.dx * width, mid.dy - n.dy * width, base.dx, base.dy)
      ..close();
    c.drawPath(_path, paint);
  }

  static Offset _quad(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }

  // ---------------------------------------------------------------- EAGLE

  /// Eagle centred on its body. [flap] in radians drives the wing beat.
  /// [s] is the body half length (boss ~70).
  static void eagle(
    Canvas c, {
    required double s,
    required double flap,
    double alpha = 1,
    double flash = 0,
    double eyeGlow = 1,
    double talons = 0,
    double rimDx = 1,
    double time = 0,
  }) {
    if (alpha <= 0.01) return;
    aura(c, Rect.fromCenter(center: Offset.zero, width: s * 3, height: s * 1.4), time, alpha * 0.8);
    _eagleShape(c, s, flap, talons, fade(rim, 0.5 * alpha * alpha * alpha * alpha), true, rimDx, time, alpha);
    _eagleShape(c, s, flap, talons, _body(alpha, flash), false, rimDx, time, alpha);
    glowEye(c, Offset(1.22 * s, -0.42 * s), 0.075 * s, eyeGlow * alpha);
  }

  static void _eagleShape(Canvas c, double s, double flap, double talons, Color col, bool rimPass, double rimDx, double time, double alpha) {
    c.save();
    if (rimPass) c.translate(rimDx * 0.03 * s, -0.03 * s);
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = rimPass ? col : Color.lerp(col, const Color(0xFF151A26), 0.35)!;
    // Far wing (slightly behind and lagging).
    _wing(c, s, math.sin(flap - 0.35) * 0.95, Offset(-0.05 * s, -0.32 * s), 0.86, rimPass, alpha, time);
    _p.color = col;
    // Tail fan.
    for (var i = 0; i < 7; i++) {
      final a = math.pi + (i - 3) * 0.11 + math.sin(time * 3 + i) * 0.02 - 0.12;
      _lens(c, Offset(-0.8 * s, 0.02 * s), Offset(math.cos(a), math.sin(a)), s * (1.05 - (i - 3).abs() * 0.04), s * 0.11, _p);
    }
    // Legs with feathered thighs and talons.
    final lx = 0.25 * s + talons * 0.45 * s;
    final ly = 0.8 * s - talons * 0.15 * s;
    c.drawOval(Rect.fromCenter(center: Offset(0.12 * s, 0.3 * s), width: 0.42 * s, height: 0.36 * s), _p);
    _s
      ..color = col
      ..strokeWidth = 0.09 * s;
    c.drawLine(Offset(0.15 * s, 0.4 * s), Offset(lx, ly), _s);
    _s.strokeWidth = 0.05 * s;
    for (var i = -1; i <= 1; i++) {
      _path
        ..reset()
        ..moveTo(lx, ly)
        ..quadraticBezierTo(lx + (0.12 + i * 0.07) * s, ly + 0.03 * s, lx + (0.17 + i * 0.11) * s, ly + 0.2 * s);
      c.drawPath(_path, _s);
    }
    c.drawLine(Offset(lx, ly), Offset(lx - 0.14 * s, ly + 0.14 * s), _s);
    // Body.
    _path
      ..reset()
      ..moveTo(1.15 * s, -0.44 * s)
      ..cubicTo(0.75 * s, -0.68 * s, -0.4 * s, -0.5 * s, -1.0 * s, -0.12 * s)
      ..cubicTo(-1.12 * s, 0.06 * s, -0.6 * s, 0.42 * s, 0.1 * s, 0.44 * s)
      ..cubicTo(0.75 * s, 0.42 * s, 1.08 * s, 0.05 * s, 1.15 * s, -0.44 * s)
      ..close();
    c.drawPath(_path, _p);
    // Head, crest and hooked beak.
    c.drawCircle(Offset(1.18 * s, -0.44 * s), 0.27 * s, _p);
    for (var i = 0; i < 3; i++) {
      _lens(c, Offset(1.05 * s, -0.6 * s), Offset(-1, -0.35 + i * 0.25), s * (0.48 - i * 0.08), s * 0.06, _p);
    }
    _path
      ..reset()
      ..moveTo(1.36 * s, -0.58 * s)
      ..quadraticBezierTo(1.76 * s, -0.6 * s, 1.82 * s, -0.33 * s)
      ..quadraticBezierTo(1.78 * s, -0.2 * s, 1.68 * s, -0.22 * s)
      ..quadraticBezierTo(1.64 * s, -0.36 * s, 1.4 * s, -0.31 * s)
      ..close();
    c.drawPath(_path, _p);
    // Neck ruff.
    for (var i = 0; i < 6; i++) {
      final x = 0.72 * s + i * 0.08 * s;
      _lens(c, Offset(x, -0.3 * s), const Offset(-0.6, 0.8), s * 0.3, s * 0.06, _p);
    }
    if (!rimPass) {
      _s
        ..color = fade(detail, alpha)
        ..strokeWidth = 0.012 * s;
      for (var i = 0; i < 5; i++) {
        final x = -0.5 * s + i * 0.28 * s;
        c.drawLine(Offset(x, -0.2 * s), Offset(x - 0.12 * s, 0.25 * s), _s);
      }
      _s.color = fade(bone, alpha * 0.55);
      _s.strokeWidth = 0.025 * s;
      c.drawLine(Offset(1.42 * s, -0.45 * s), Offset(1.7 * s, -0.4 * s), _s);
    }
    // Near wing.
    _p.color = col;
    _wing(c, s, math.sin(flap), Offset(0.1 * s, -0.3 * s), 1.0, rimPass, alpha, time);
    c.restore();
  }

  static void _wing(Canvas c, double s, double up, Offset shoulder, double scale, bool rimPass, double alpha, double time) {
    // up: 1 = fully raised, -1 = fully lowered.
    c.save();
    c.translate(shoulder.dx, shoulder.dy);
    final sy = up >= 0 ? -(0.25 + 0.75 * up) : (0.25 + 0.6 * (-up));
    c.scale(scale, sy * scale);
    final wrist = Offset(0.34 * s, 1.68 * s);
    // Arm membrane and coverts.
    _path
      ..reset()
      ..moveTo(0.3 * s, 0)
      ..cubicTo(0.52 * s, 0.55 * s, 0.52 * s, 1.2 * s, wrist.dx, wrist.dy)
      ..lineTo(0.02 * s, 1.62 * s)
      ..lineTo(-0.66 * s, 0.25 * s)
      ..lineTo(-0.5 * s, 0)
      ..close();
    c.drawPath(_path, _p);
    // Primary flight feathers fanning from the wrist.
    for (var j = 0; j < 7; j++) {
      final t = j / 6;
      final base = Offset.lerp(wrist, Offset(0.0, 1.5 * s), t)!;
      final a = -0.04 - t * 1.05;
      _lens(c, base, Offset(math.sin(a), math.cos(a)), s * (1.5 - t * 0.55), s * 0.12, _p);
    }
    // Secondary feathers along the trailing edge.
    for (var j = 0; j < 8; j++) {
      final t = j / 7;
      final base = Offset.lerp(Offset(0.02 * s, 1.5 * s), Offset(-0.58 * s, 0.2 * s), t)!;
      _lens(c, base, const Offset(-0.85, 0.35), s * 0.52, s * 0.11, _p);
    }
    if (!rimPass) {
      _s
        ..color = fade(detail, alpha)
        ..strokeWidth = 0.014 * s / scale;
      for (var j = 0; j < 7; j++) {
        final t = j / 6;
        final base = Offset.lerp(wrist, Offset(0.0, 1.5 * s), t)!;
        final a = -0.04 - t * 1.05;
        c.drawLine(base, base + Offset(math.sin(a), math.cos(a)) * (s * (1.2 - t * 0.45)), _s);
      }
      // Glowing veins along the leading edge.
      final pulse = 0.5 + 0.5 * math.sin(time * 3 + shoulder.dx);
      _s
        ..blendMode = BlendMode.plus
        ..strokeWidth = 0.02 * s
        ..color = fade(vein, 0.55 * alpha * pulse);
      _path
        ..reset()
        ..moveTo(0.28 * s, 0.1 * s)
        ..cubicTo(0.46 * s, 0.6 * s, 0.46 * s, 1.15 * s, wrist.dx - 0.02 * s, wrist.dy - 0.05 * s)
        ..lineTo(0.1 * s, 2.6 * s);
      c.drawPath(_path, _s);
      _s.blendMode = BlendMode.srcOver;
    }
    c.restore();
  }

  // ---------------------------------------------------------------- ELEPHANT

  /// Armoured war elephant with feet on the origin. [k] scales the 260px model.
  static void elephant(
    Canvas c, {
    required double k,
    required double walk,
    double alpha = 1,
    double flash = 0,
    double eyeGlow = 1,
    double trunk = 0,
    double rear = 0,
    double rimDx = 1,
    double time = 0,
  }) {
    if (alpha <= 0.01) return;
    c.save();
    c.scale(k, k);
    if (rear != 0) {
      c.translate(-120, 0);
      c.rotate(-rear * 0.42);
      c.translate(120, 0);
    }
    aura(c, const Rect.fromLTRB(-200, -300, 260, 0), time, alpha);
    _elephantShape(c, walk, trunk, fade(rim, 0.45 * alpha * alpha * alpha * alpha), true, rimDx, time, alpha);
    _elephantShape(c, walk, trunk, _body(alpha, flash), false, rimDx, time, alpha);
    _veins(c, [
      [const Offset(-120, -150), const Offset(-80, -190), const Offset(-30, -175), const Offset(10, -215)],
      [const Offset(-30, -175), const Offset(20, -140), const Offset(70, -150)],
      [const Offset(40, -230), const Offset(90, -200), const Offset(130, -215)],
      [const Offset(-150, -125), const Offset(-120, -150)],
    ], 2.4, alpha, time);
    glowEye(c, const Offset(196, -214), 6, eyeGlow * alpha);
    c.restore();
  }

  static void _elephantShape(Canvas c, double walk, double trunk, Color col, bool rimPass, double rimDx, double time, double alpha) {
    c.save();
    if (rimPass) c.translate(rimDx * 3, -3);
    final farCol = rimPass ? col : Color.lerp(col, const Color(0xFF151A26), 0.4)!;
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = farCol;
    // Far legs.
    _leg(c, const Offset(-95, -120), walk + math.pi, 48, rimPass, alpha);
    _leg(c, const Offset(95, -120), walk, 48, rimPass, alpha);
    _p.color = col;
    // Tail.
    _s
      ..color = col
      ..strokeWidth = 7;
    final tw = math.sin(time * 2.5) * 10;
    _path
      ..reset()
      ..moveTo(-165, -205)
      ..quadraticBezierTo(-195, -160 + tw, -190 + tw, -110);
    c.drawPath(_path, _s);
    // Body.
    _path
      ..reset()
      ..moveTo(-172, -128)
      ..cubicTo(-205, -212, -120, -278, -30, -272)
      ..cubicTo(60, -282, 122, -264, 152, -226)
      ..lineTo(162, -150)
      ..cubicTo(122, -95, 60, -100, 0, -98)
      ..cubicTo(-80, -96, -150, -95, -172, -128)
      ..close();
    c.drawPath(_path, _p);
    // War armour on the back with spikes.
    _path
      ..reset()
      ..moveTo(-130, -205)
      ..cubicTo(-110, -262, -20, -286, 40, -280)
      ..cubicTo(80, -276, 112, -262, 120, -240)
      ..lineTo(100, -170)
      ..cubicTo(40, -150, -60, -150, -118, -165)
      ..close();
    c.drawPath(_path, _p);
    for (var i = 0; i < 6; i++) {
      final x = -95.0 + i * 38;
      final y = -268 - math.sin((i / 5) * math.pi) * 14;
      _path
        ..reset()
        ..moveTo(x - 9, y + 8)
        ..lineTo(x - 2, y - 30 - math.sin(i * 1.7) * 6)
        ..lineTo(x + 9, y + 8)
        ..close();
      c.drawPath(_path, _p);
    }
    // Head dome and forehead plate with horn.
    c.drawCircle(const Offset(178, -205), 58, _p);
    c.drawCircle(const Offset(160, -245), 34, _p);
    _path
      ..reset()
      ..moveTo(150, -268)
      ..quadraticBezierTo(205, -275, 232, -220)
      ..lineTo(222, -186)
      ..quadraticBezierTo(190, -232, 150, -240)
      ..close();
    c.drawPath(_path, _p);
    _path
      ..reset()
      ..moveTo(196, -262)
      ..lineTo(222, -300)
      ..lineTo(210, -255)
      ..close();
    c.drawPath(_path, _p);
    // Trunk.
    final sway = math.sin(time * 1.8) * 14 + trunk * 60;
    const p0 = Offset(215, -185);
    final p1 = Offset(262 + sway * 0.3, -120);
    final p2 = Offset(232 + sway, -18 - trunk * 120);
    final pts = <Offset>[];
    for (var i = 0; i <= 12; i++) {
      pts.add(_quad(p0, p1, p2, i / 12));
    }
    _taper(c, pts, 42, 13, _p);
    // Tusks with metal bands and glowing tips.
    _s
      ..color = rimPass ? col : fade(bone, col.a)
      ..strokeWidth = 10;
    _path
      ..reset()
      ..moveTo(205, -158)
      ..quadraticBezierTo(270, -126, 305, -178);
    c.drawPath(_path, _s);
    // Ear with ragged edge.
    _p.color = col;
    final ef = math.sin(time * 2.2) * 8;
    _path
      ..reset()
      ..moveTo(150, -258)
      ..cubicTo(98 - ef, -292, 66 - ef, -220, 82 - ef, -170)
      ..lineTo(92 - ef, -176)
      ..lineTo(96 - ef, -150)
      ..lineTo(110 - ef * 0.5, -160)
      ..lineTo(122, -138)
      ..cubicTo(136, -150, 146, -158, 152, -172)
      ..close();
    c.drawPath(_path, _p);
    if (!rimPass) {
      _s
        ..color = fade(detail, alpha)
        ..strokeWidth = 2;
      c.drawPath(_path, _s);
      // Armour plate seams and hanging chain.
      for (var i = 0; i < 3; i++) {
        _path
          ..reset()
          ..moveTo(-118 + i * 8.0, -186 + i * 12.0)
          ..cubicTo(-60, -170 + i * 10.0, 40, -172 + i * 8.0, 108, -190 + i * 12.0);
        c.drawPath(_path, _s);
      }
      for (var i = 0; i < 7; i++) {
        c.drawCircle(Offset(-80.0 + i * 24, -155 + math.sin(i * 0.9) * 4), 3, _s);
      }
      // Trunk rings.
      for (var i = 2; i < 11; i += 2) {
        final q = pts[i];
        c.drawLine(q + const Offset(-12, -3), q + const Offset(12, 3), _s);
      }
      // Tusk bands and glowing tips.
      _s
        ..color = fade(const Color(0xFF6A5A40), alpha)
        ..strokeWidth = 12;
      c.drawLine(const Offset(228, -150), const Offset(234, -147), _s);
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(vein, 0.5 * alpha * (0.7 + 0.3 * math.sin(time * 4)));
      c.drawCircle(const Offset(303, -176), 7, _p);
      _p.blendMode = BlendMode.srcOver;
    }
    // Near legs.
    _p.color = col;
    _leg(c, const Offset(-120, -120), walk, 54, rimPass, alpha);
    _leg(c, const Offset(120, -120), walk + math.pi, 54, rimPass, alpha);
    c.restore();
  }

  static void _leg(Canvas c, Offset top, double phase, double w, bool rimPass, double alpha) {
    final swing = math.sin(phase) * 0.22;
    final lift = math.max(0.0, math.cos(phase)) * 14;
    final knee = top + Offset(math.sin(swing) * 60, 62 - lift * 0.3);
    final foot = Offset(top.dx + math.sin(swing) * 95, -lift);
    _taper(c, [top, knee, foot + const Offset(0, -10)], w, w * 0.92, _p);
    _path
      ..reset()
      ..moveTo(foot.dx - w * 0.56, foot.dy)
      ..lineTo(foot.dx - w * 0.5, foot.dy - 18)
      ..lineTo(foot.dx + w * 0.5, foot.dy - 18)
      ..lineTo(foot.dx + w * 0.62, foot.dy)
      ..close();
    c.drawPath(_path, _p);
    if (!rimPass) {
      final col = _p.color;
      _s
        ..color = fade(detail, alpha)
        ..strokeWidth = 2;
      for (var i = 0; i < 3; i++) {
        c.drawArc(Rect.fromCenter(center: Offset(foot.dx - w * 0.3 + i * w * 0.3, foot.dy - 3), width: w * 0.22, height: 8), math.pi, math.pi, false, _s);
      }
      // Leg armour band.
      c.drawLine(knee + Offset(-w * 0.5, -6), knee + Offset(w * 0.5, -8), _s);
      _p.color = col;
    }
  }

  // ---------------------------------------------------------------- RAT

  /// Giant rat with feet at origin, [k] scales the base ~180px model.
  static void rat(
    Canvas c, {
    required double k,
    required double run,
    double alpha = 1,
    double flash = 0,
    double eyeGlow = 1,
    double crouch = 0,
    double rimDx = 1,
    double time = 0,
  }) {
    if (alpha <= 0.01) return;
    c.save();
    c.scale(k, k);
    aura(c, Rect.fromLTRB(-170, -200 + crouch * 30, 220, 0), time, alpha, glow: const Color(0xFFFFB020));
    _ratShape(c, run, crouch, fade(rim, 0.45 * alpha * alpha * alpha * alpha), true, rimDx, time, alpha);
    _ratShape(c, run, crouch, _body(alpha, flash), false, rimDx, time, alpha);
    final dy = crouch * 30;
    _veins(c, [
      [Offset(-130, -110 + dy), Offset(-60, -165 + dy), Offset(20, -165 + dy), Offset(100, -140 + dy)],
      [Offset(-60, -165 + dy), Offset(-40, -110 + dy), Offset(10, -95 + dy)],
    ], 2.0, alpha, time);
    glowEye(c, Offset(160, -130 + dy), 5.5, eyeGlow * alpha);
    glowEye(c, Offset(146, -126 + dy), 3.5, eyeGlow * alpha * 0.7);
    c.restore();
  }

  static void _ratShape(Canvas c, double run, double crouch, Color col, bool rimPass, double rimDx, double time, double alpha) {
    c.save();
    if (rimPass) c.translate(rimDx * 3, -3);
    final dy = crouch * 30;
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = col;
    // Tail with a spiked tip.
    final pts = <Offset>[];
    for (var i = 0; i <= 16; i++) {
      final t = i / 16;
      pts.add(Offset(-130 - t * 300, -70 + dy * 0.5 + math.sin(time * 4 + t * 5) * 24 * t - t * 34));
    }
    _taper(c, pts, 20, 4, _p);
    final tip = pts.last;
    final pre = pts[pts.length - 2];
    final td = (tip - pre) / math.max((tip - pre).distance, 0.001);
    for (var i = -1; i <= 1; i++) {
      _lens(c, tip, td + Offset(-td.dy, td.dx) * (i * 0.6), 26, 5, _p);
    }
    // Far legs.
    final far = Color.lerp(col, const Color(0xFF151A26), rimPass ? 0 : 0.4)!;
    _p.color = far;
    _ratLeg(c, Offset(-80, -70 + dy), run + math.pi, true);
    _ratLeg(c, Offset(70, -70 + dy), run, false);
    _p.color = col;
    // Body.
    _path
      ..reset()
      ..moveTo(-152, -58 + dy)
      ..cubicTo(-176, -152 + dy, -62, -206 + dy, 30, -178 + dy)
      ..cubicTo(92, -168 + dy, 122, -152 + dy, 142, -122 + dy)
      ..lineTo(122, -60 + dy)
      ..cubicTo(40, -38 + dy, -80, -38 + dy, -152, -58 + dy)
      ..close();
    c.drawPath(_path, _p);
    // Back spines.
    for (var i = 0; i < 10; i++) {
      final x = -128.0 + i * 24;
      final y = -150 + dy - math.sin((i / 9) * math.pi) * 42;
      final h = 26 + math.sin((i / 9) * math.pi) * 20;
      _path
        ..reset()
        ..moveTo(x - 9, y + 12)
        ..lineTo(x - 4, y - h - math.sin(time * 6 + i) * 3)
        ..lineTo(x + 10, y + 12)
        ..close();
      c.drawPath(_path, _p);
    }
    // Head and long snout.
    _path
      ..reset()
      ..moveTo(108, -158 + dy)
      ..cubicTo(152, -170 + dy, 196, -122 + dy, 236, -92 + dy)
      ..lineTo(232, -80 + dy)
      ..cubicTo(186, -66 + dy, 140, -68 + dy, 108, -84 + dy)
      ..close();
    c.drawPath(_path, _p);
    // Torn ears.
    _path
      ..reset()
      ..moveTo(100, -150 + dy)
      ..lineTo(92, -200 + dy)
      ..lineTo(110, -188 + dy)
      ..lineTo(124, -205 + dy)
      ..lineTo(132, -156 + dy)
      ..close();
    c.drawPath(_path, _p);
    if (!rimPass) {
      // Teeth.
      _p.color = fade(bone, col.a);
      for (var i = 0; i < 4; i++) {
        final x = 196.0 + i * 9;
        _path
          ..reset()
          ..moveTo(x, -84 + dy)
          ..lineTo(x + 3, -66 + dy + (i.isEven ? 0 : 6))
          ..lineTo(x + 6, -84 + dy)
          ..close();
        c.drawPath(_path, _p);
      }
      _p.color = col;
      _s
        ..color = fade(const Color(0xFF2A3040), col.a)
        ..strokeWidth = 1.5;
      for (var i = 0; i < 3; i++) {
        c.drawLine(Offset(225, -94 + dy), Offset(278, -112 + dy + i * 14), _s);
      }
      // Spine tips glowing.
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFFFF7A2A), 0.45 * alpha * (0.6 + 0.4 * math.sin(time * 5)));
      for (var i = 2; i < 8; i++) {
        final x = -128.0 + i * 24 - 4;
        final y = -150 + dy - math.sin((i / 9) * math.pi) * 42 - (26 + math.sin((i / 9) * math.pi) * 20);
        c.drawCircle(Offset(x, y + 4), 3, _p);
      }
      _p.blendMode = BlendMode.srcOver;
    }
    // Near legs.
    _p.color = col;
    _ratLeg(c, Offset(-95, -65 + dy), run, true);
    _ratLeg(c, Offset(85, -65 + dy), run + math.pi, false);
    c.restore();
  }

  static void _ratLeg(Canvas c, Offset top, double phase, bool hind) {
    final sw = math.sin(phase) * 0.6;
    final lift = math.max(0.0, math.cos(phase)) * 16;
    final knee = top + Offset(math.sin(sw) * 30 + (hind ? -22 : 10), 30 - lift * 0.4);
    final foot = Offset(top.dx + math.sin(sw) * 50, -lift);
    _taper(c, [top, knee, foot], hind ? 40 : 28, 10, _p);
    _s
      ..color = _p.color
      ..strokeWidth = 4;
    for (var i = 0; i < 3; i++) {
      _path
        ..reset()
        ..moveTo(foot.dx, foot.dy)
        ..quadraticBezierTo(foot.dx + 10.0 + i * 5, foot.dy - 2, foot.dx + 16.0 + i * 6, foot.dy + 4);
      c.drawPath(_path, _s);
    }
  }

  // ---------------------------------------------------------------- MONSTER

  /// Hulking abyss monster, feet at origin. [k] scales the base ~380px model.
  /// [armF]/[armB] raise the arms (0 rest, 1 fully overhead).
  static void monster(
    Canvas c, {
    required double k,
    required double walk,
    double alpha = 1,
    double flash = 0,
    double eyeGlow = 1,
    double armF = 0,
    double armB = 0,
    double lean = 0,
    double rimDx = 1,
    double time = 0,
  }) {
    if (alpha <= 0.01) return;
    c.save();
    c.scale(k, k);
    aura(c, const Rect.fromLTRB(-140, -420, 200, 0), time, alpha, glow: const Color(0xFF2A6AFF));
    _monsterShape(c, walk, armF, armB, lean, fade(rim, 0.45 * alpha * alpha * alpha * alpha), true, rimDx, time, alpha);
    _monsterShape(c, walk, armF, armB, lean, _body(alpha, flash), false, rimDx, time, alpha);
    final breathe = math.sin(time * 1.8) * 4;
    final ox = lean * 25;
    final oy = lean * 25 + breathe;
    _veins(c, [
      [Offset(-60 + ox * 0.5, -180), Offset(-20 + ox, -240 + oy), Offset(30 + ox, -300 + oy), Offset(80 + ox, -330 + oy)],
      [Offset(-20 + ox, -240 + oy), Offset(50 + ox, -230 + oy), Offset(90 + ox, -260 + oy)],
      [Offset(-80 + ox * 0.5, -300 + oy), Offset(-30 + ox, -330 + oy)],
    ], 3.0, alpha, time);
    final hx = 150 + lean * 30;
    final hy = -318 + breathe + lean * 30;
    glowEye(c, Offset(hx + 18, hy - 8), 6, eyeGlow * alpha);
    glowEye(c, Offset(hx + 2, hy - 6), 4.5, eyeGlow * alpha * 0.8);
    c.restore();
  }

  static void _monsterShape(Canvas c, double walk, double armF, double armB, double lean, Color col, bool rimPass, double rimDx, double time, double alpha) {
    c.save();
    if (rimPass) c.translate(rimDx * 4, -4);
    final breathe = math.sin(time * 1.8) * 4;
    final far = Color.lerp(col, const Color(0xFF151A26), rimPass ? 0 : 0.4)!;
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = far;
    // Far arm.
    _arm(c, Offset(-40 + lean * 20, -300 + breathe + lean * 25), armB, walk + math.pi, 0.9);
    // Digitigrade legs.
    final s1 = math.sin(walk) * 0.25;
    final s2 = math.sin(walk + math.pi) * 0.25;
    _taper(c, [const Offset(-40, -175), Offset(-20 + s2 * 80, -110), Offset(-62 + s2 * 100, -55), Offset(-45 + s2 * 120, -6 - math.max(0, math.cos(walk + math.pi)) * 12)], 66, 40, _p);
    _p.color = col;
    _taper(c, [const Offset(35, -175), Offset(60 + s1 * 80, -110), Offset(22 + s1 * 100, -55), Offset(50 + s1 * 120, -6 - math.max(0, math.cos(walk)) * 12)], 70, 42, _p);
    // Torso.
    c.save();
    c.translate(0, -170);
    c.rotate(lean * 0.25);
    _path
      ..reset()
      ..moveTo(-78, 12)
      ..cubicTo(-126, -60, -114, -172 + breathe, -30, -218 + breathe)
      ..cubicTo(30, -240 + breathe, 118, -196 + breathe, 128, -134 + breathe)
      ..cubicTo(132, -72, 94, -10, 72, 12)
      ..close();
    c.drawPath(_path, _p);
    for (var i = 0; i < 7; i++) {
      final t = i / 6;
      final bx = lerpD(-100, 50, t);
      final by = lerpD(-110, -232, t) + breathe;
      _path
        ..reset()
        ..moveTo(bx - 13, by + 10)
        ..lineTo(bx - 30 - i * 2, by - 44 - i * 3)
        ..lineTo(bx + 10, by)
        ..close();
      c.drawPath(_path, _p);
    }
    if (!rimPass) {
      // Ribcage and muscle seams.
      _s
        ..color = fade(detail, alpha)
        ..strokeWidth = 2.5;
      for (var i = 0; i < 4; i++) {
        _path
          ..reset()
          ..moveTo(20, -60 - i * 26.0 + breathe)
          ..quadraticBezierTo(80, -70 - i * 26.0 + breathe, 110, -96 - i * 22.0 + breathe);
        c.drawPath(_path, _s);
      }
      // Chest core.
      final pulse = 0.6 + 0.4 * math.sin(time * 3);
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFF2A7AFF), 0.25 * alpha * pulse);
      c.drawCircle(Offset(60, -140 + breathe), 30, _p);
      _p.color = fade(const Color(0xFF9AD0FF), 0.6 * alpha * pulse);
      c.drawCircle(Offset(60, -140 + breathe), 8, _p);
      _p
        ..blendMode = BlendMode.srcOver
        ..color = col;
    }
    c.restore();
    // Head: elongated skull, open jaw and curled ram horns.
    final hx = 150 + lean * 30;
    final hy = -318 + breathe + lean * 30;
    final jaw = 8 + math.max(0.0, armF) * 18;
    _path
      ..reset()
      ..moveTo(hx - 45, hy + 10)
      ..cubicTo(hx - 40, hy - 40, hx + 20, hy - 38, hx + 62, hy - 4)
      ..lineTo(hx + 58, hy + 10)
      ..cubicTo(hx + 20, hy + 14, hx - 10, hy + 22, hx - 45, hy + 10)
      ..close();
    c.drawPath(_path, _p);
    _path
      ..reset()
      ..moveTo(hx - 30, hy + 16)
      ..lineTo(hx + 48, hy + 12 + jaw)
      ..lineTo(hx + 40, hy + 26 + jaw)
      ..lineTo(hx - 26, hy + 30)
      ..close();
    c.drawPath(_path, _p);
    _s
      ..color = col
      ..strokeWidth = 13;
    _path
      ..reset()
      ..moveTo(hx - 20, hy - 26)
      ..cubicTo(hx - 70, hy - 70, hx - 90, hy - 10, hx - 55, hy + 6)
      ..moveTo(hx + 10, hy - 30)
      ..quadraticBezierTo(hx + 36, hy - 90, hx + 4, hy - 120);
    c.drawPath(_path, _s);
    if (!rimPass) {
      // Glowing maw and teeth.
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFFFF3A1A), 0.55 * alpha);
      c.drawOval(Rect.fromCenter(center: Offset(hx + 18, hy + 14 + jaw * 0.5), width: 56, height: 8 + jaw * 0.8), _p);
      _p.blendMode = BlendMode.srcOver;
      _p.color = fade(bone, alpha);
      for (var i = 0; i < 5; i++) {
        final x = hx - 6 + i * 12.0;
        _path
          ..reset()
          ..moveTo(x, hy + 10)
          ..lineTo(x + 4, hy + 20 + jaw * 0.3)
          ..lineTo(x + 8, hy + 10)
          ..close();
        c.drawPath(_path, _p);
      }
      _p.color = col;
    }
    // Near arm.
    _p.color = col;
    _arm(c, Offset(55 + lean * 20, -295 + breathe + lean * 25), armF, walk, 1.0);
    c.restore();
  }

  static void _arm(Canvas c, Offset shoulder, double raise, double phase, double scale) {
    final swing = math.sin(phase) * 0.12;
    final upper = lerpD(0.35 + swing, 3.0, raise);
    final fore = lerpD(0.15 + swing, 3.3, raise);
    final elbow = shoulder + Offset(math.sin(upper) * 95 * scale, math.cos(upper) * 95 * scale);
    final hand = elbow + Offset(math.sin(fore) * 110 * scale, math.cos(fore) * 110 * scale);
    c.drawCircle(shoulder, 40 * scale, _p);
    _taper(c, [shoulder, elbow], 64 * scale, 46 * scale, _p);
    _taper(c, [elbow, hand], 48 * scale, 38 * scale, _p);
    // Forearm spikes.
    final fd = (hand - elbow) / math.max((hand - elbow).distance, 0.001);
    final fn = Offset(-fd.dy, fd.dx);
    for (var i = 0; i < 3; i++) {
      final b = elbow + fd * (25.0 + i * 25) * scale - fn * 18 * scale;
      _lens(c, b, -fn * 1.0 - fd * 0.5, 30 * scale, 6 * scale, _p);
    }
    c.drawCircle(hand, 30 * scale, _p);
    _s
      ..color = _p.color
      ..strokeWidth = 9 * scale;
    final dir = Offset(math.sin(fore), math.cos(fore));
    final side = Offset(-dir.dy, dir.dx);
    for (var i = -1; i <= 1; i++) {
      final b = hand + side * (i * 16.0 * scale) + dir * (16 * scale);
      final t = b + dir * (38 * scale) + side * (i * 6.0 * scale) + Offset(8 * scale, 0);
      _path
        ..reset()
        ..moveTo(b.dx, b.dy)
        ..quadraticBezierTo(b.dx + dir.dx * 34 * scale, b.dy + dir.dy * 34 * scale, t.dx, t.dy);
      c.drawPath(_path, _s);
    }
  }

  // ---------------------------------------------------------------- TIGER

  /// Shadow tiger (feet at origin, ~420px long at k=1). [morph] 0 = tiger,
  /// 1 = monster tiger with spikes, horns and sabre fangs. [roar] raises the
  /// head and opens the jaws wide.
  static void tiger(
    Canvas c, {
    required double k,
    required double run,
    double alpha = 1,
    double flash = 0,
    double eyeGlow = 1,
    double crouch = 0,
    double mouth = 0,
    double morph = 0,
    double roar = 0,
    double rimDx = 1,
    double time = 0,
    Color stripes = const Color(0xFF3A8BFF),
  }) {
    if (alpha <= 0.01) return;
    c.save();
    c.scale(k, k);
    aura(c, Rect.fromLTRB(-210, -240 - morph * 40, 270, 0), time, alpha, glow: stripes);
    final a4 = alpha * alpha * alpha * alpha;
    final g = _TigerGeo(run, crouch, mouth, morph, roar, time);
    _tigerShape(c, g, fade(rim, 0.5 * a4), true, rimDx, alpha, stripes);
    _tigerShape(c, g, _body(alpha, flash), false, rimDx, alpha, stripes);
    // Eyes.
    c.save();
    c.translate(g.neck.dx, g.neck.dy);
    c.rotate(g.headAngle);
    c.scale(1.28, 1.28);
    glowEye(c, const Offset(66, -22), 4.2, eyeGlow * alpha * (1 + roar * 0.6), color: Color.lerp(const Color(0xFFFFC020), redEye, morph)!);
    c.restore();
    c.restore();
  }

  static void _tigerShape(Canvas c, _TigerGeo g, Color col, bool rimPass, double rimDx, double alpha, Color stripes) {
    c.save();
    if (rimPass) c.translate(rimDx * 3, -3);
    final dy = g.dy;
    final m = g.morph;
    final big = 1 + m * 0.1;
    final farCol = rimPass ? col : Color.lerp(col, const Color(0xFF161B28), 0.42)!;
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = farCol;
    // Far legs.
    _tigerHind(c, Offset(-128, -128 + dy), g.run + math.pi, big);
    _tigerFore(c, Offset(102, -132 + dy), g.run + 0.5, big);
    _p.color = col;
    // Tail: thick base, S-curve, raised when roaring.
    final tail = <Offset>[];
    for (var i = 0; i <= 14; i++) {
      final t = i / 14;
      tail.add(Offset(-170 - t * 160, -165 + dy * 0.6 - math.sin(t * 2.4) * (60 + g.roar * 50) * t + math.sin(g.time * 2.6 + t * 4) * 16 * t));
    }
    _taper(c, tail, 26, 11, _p);
    // Haunch and shoulder masses.
    c.drawOval(Rect.fromCenter(center: Offset(-128, -140 + dy), width: 118, height: 108), _p);
    c.drawOval(Rect.fromCenter(center: Offset(98, -158 + dy - g.roar * 6), width: 126 * big, height: 112 * big), _p);
    // Torso.
    _path
      ..reset()
      ..moveTo(-182, -138 + dy)
      ..cubicTo(-188, -186 + dy, -120, -192 + dy, -40, -176 + dy)
      ..cubicTo(20, -168 + dy, 60, -206 * big + dy, 110, -208 * big + dy - g.roar * 8)
      ..cubicTo(150, -208 + dy, 172, -180 + dy, 172, -146 + dy)
      ..cubicTo(170, -110 + dy, 140, -96 + dy, 100, -98 + dy)
      ..cubicTo(40, -92 + dy, -20, -76 + dy, -70, -84 + dy)
      ..cubicTo(-120, -90 + dy, -176, -98 + dy, -182, -138 + dy)
      ..close();
    c.drawPath(_path, _p);
    // Belly fur fringe.
    for (var i = 0; i < 6; i++) {
      final x = -90.0 + i * 30;
      _lens(c, Offset(x, -88 + dy), const Offset(-0.3, 1), 22, 6, _p);
    }
    // Monster spikes.
    if (m > 0.05) {
      for (var i = 0; i < 9; i++) {
        final x = -165.0 + i * 36;
        final y = -180 * big + dy - math.sin((i / 8) * math.pi) * 22;
        final h = (22 + math.sin((i / 8) * math.pi) * 34) * m;
        _path
          ..reset()
          ..moveTo(x - 11, y + 14)
          ..quadraticBezierTo(x - 10, y - h * 0.6, x - 2, y - h)
          ..quadraticBezierTo(x + 4, y - h * 0.4, x + 11, y + 14)
          ..close();
        c.drawPath(_path, _p);
      }
    }
    // Neck.
    _path
      ..reset()
      ..moveTo(110, -200 + dy)
      ..quadraticBezierTo(g.neck.dx + 10, g.neck.dy - 40, g.neck.dx + 40, g.neck.dy - 30)
      ..lineTo(g.neck.dx + 40, g.neck.dy + 34)
      ..quadraticBezierTo(150, -110 + dy, 120, -110 + dy)
      ..close();
    c.drawPath(_path, _p);
    // Head (pivots at the neck).
    c.save();
    c.translate(g.neck.dx, g.neck.dy);
    c.rotate(g.headAngle);
    c.scale(1.28, 1.28);
    _tigerHead(c, g, col, rimPass, alpha, stripes, big);
    c.restore();
    if (!rimPass) {
      // Body stripes: tapered glowing bands that follow the barrel.
      final pulse = 0.65 + 0.35 * math.sin(g.time * 3);
      for (var i = 0; i < 9; i++) {
        final x = -165.0 + i * 36;
        final topY = -182 + dy - (i > 5 ? (i - 5) * 8.0 : 0);
        final len = 58.0 + (i.isEven ? 16 : 0);
        _stripe(c, Offset(x, topY), Offset(x + 10 + (i.isEven ? 6 : -4), topY + len), 11, alpha * pulse, stripes);
      }
      for (var i = 0; i < 4; i++) {
        final t = 0.35 + i * 0.16;
        final q = tail[(t * 14).round().clamp(0, 14)];
        _stripe(c, q + const Offset(0, -10), q + const Offset(4, 10), 7, alpha * pulse, stripes);
      }
      // Muscle seams.
      _s
        ..color = fade(detail, alpha)
        ..strokeWidth = 2;
      _path
        ..reset()
        ..moveTo(-175, -150 + dy)
        ..quadraticBezierTo(-120, -190 + dy, -80, -120 + dy)
        ..moveTo(50, -190 + dy)
        ..quadraticBezierTo(110, -140 + dy, 70, -104 + dy);
      c.drawPath(_path, _s);
      if (m > 0.05) {
        _veins(c, [
          [Offset(-150, -150 + dy), Offset(-90, -165 + dy), Offset(-30, -140 + dy), Offset(40, -170 + dy), Offset(110, -150 + dy)],
          [Offset(-30, -140 + dy), Offset(-10, -100 + dy)],
        ], 2.6, alpha * m, g.time);
      }
    }
    // Near legs.
    _p.color = col;
    _tigerHind(c, Offset(-140, -126 + dy), g.run, big);
    _tigerFore(c, Offset(118, -130 + dy), g.run + math.pi + 0.5, big);
    if (!rimPass) {
      final pulse = 0.65 + 0.35 * math.sin(g.time * 3);
      // Leg stripes.
      _stripe(c, Offset(-150, -100 + dy), Offset(-130, -96 + dy), 6, alpha * pulse, stripes);
      _stripe(c, Offset(112, -96 + dy), Offset(132, -92 + dy), 6, alpha * pulse, stripes);
      _stripe(c, Offset(114, -66 + dy), Offset(134, -62 + dy), 6, alpha * pulse, stripes);
    }
    c.restore();
  }

  static void _stripe(Canvas c, Offset a, Offset b, double w, double alpha, Color color) {
    final d = b - a;
    final len = math.max(d.distance, 0.001);
    final n = Offset(-d.dy, d.dx) / len;
    final mid = Offset.lerp(a, b, 0.4)! + n * (w * 0.4);
    _path
      ..reset()
      ..moveTo(a.dx - n.dx * w / 2, a.dy - n.dy * w / 2)
      ..quadraticBezierTo(mid.dx + n.dx * w, mid.dy + n.dy * w, b.dx, b.dy)
      ..quadraticBezierTo(mid.dx - n.dx * w * 0.2, mid.dy - n.dy * w * 0.2, a.dx + n.dx * w / 2, a.dy + n.dy * w / 2)
      ..close();
    _p
      ..blendMode = BlendMode.plus
      ..color = fade(color, 0.22 * alpha);
    c.drawPath(_path, _p);
    _s
      ..blendMode = BlendMode.plus
      ..strokeWidth = 1.6
      ..color = fade(color, 0.6 * alpha);
    _path
      ..reset()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
    c.drawPath(_path, _s);
    _p.blendMode = BlendMode.srcOver;
    _s.blendMode = BlendMode.srcOver;
  }

  static void _tigerHead(Canvas c, _TigerGeo g, Color col, bool rimPass, double alpha, Color stripes, double big) {
    final m = g.morph;
    _p
      ..style = PaintingStyle.fill
      ..color = col;
    // Cheek ruff behind the jaw.
    for (var i = 0; i < 6; i++) {
      final ang = 1.5 + i * 0.22;
      _lens(c, Offset(14, 14 + i * 3.0), Offset(-math.cos(ang - 1.2), math.sin(ang - 1.2) * 0.8 + 0.3), 40 + i * 2.0, 8, _p);
    }
    // Skull.
    c.drawOval(Rect.fromCenter(center: const Offset(38, -10), width: 100 * big, height: 80 * big), _p);
    // Brow ridge.
    _path
      ..reset()
      ..moveTo(30, -42)
      ..quadraticBezierTo(62, -46, 84, -26)
      ..lineTo(80, -18)
      ..quadraticBezierTo(60, -30, 34, -28)
      ..close();
    c.drawPath(_path, _p);
    // Muzzle and nose.
    _path
      ..reset()
      ..moveTo(60, -24)
      ..quadraticBezierTo(98, -26, 106, -6)
      ..quadraticBezierTo(108, 6, 98, 10)
      ..lineTo(56, 12)
      ..close();
    c.drawPath(_path, _p);
    // Ears or horns.
    if (m < 0.5) {
      _path
        ..reset()
        ..moveTo(4, -38)
        ..quadraticBezierTo(4, -70, 22, -66)
        ..quadraticBezierTo(30, -52, 26, -38)
        ..close()
        ..moveTo(26, -44)
        ..quadraticBezierTo(30, -74, 46, -66)
        ..quadraticBezierTo(50, -52, 46, -40)
        ..close();
      c.drawPath(_path, _p);
    }
    if (m > 0.05) {
      _s
        ..color = col
        ..strokeWidth = 9 * m + 1;
      _path
        ..reset()
        ..moveTo(20, -40)
        ..cubicTo(-10, -70 * m - 20, -50, -60 * m - 20, -60, -20 * m - 20)
        ..moveTo(40, -44)
        ..cubicTo(30, -90 * m - 20, -10, -100 * m - 20, -30, -70 * m - 20);
      c.drawPath(_path, _s);
    }
    // Lower jaw hinged behind the cheek.
    final jawA = g.jaw;
    if (!rimPass && jawA > 0.04) {
      // Dark mouth cavity between the jaws.
      final cs = math.cos(jawA), sn = math.sin(jawA);
      final tip = Offset(36 + 62 * cs - 4 * sn, 14 + 62 * sn + 4 * cs);
      _p.color = fade(const Color(0xFF2A070A), alpha);
      _path
        ..reset()
        ..moveTo(30, 10)
        ..lineTo(100, 8)
        ..quadraticBezierTo(104, 14, tip.dx, tip.dy)
        ..lineTo(36, 18)
        ..close();
      c.drawPath(_path, _p);
      _p.color = col;
    }
    c.save();
    c.translate(36, 14);
    c.rotate(jawA);
    _path
      ..reset()
      ..moveTo(-10, -4)
      ..quadraticBezierTo(30, 0, 64, -2)
      ..lineTo(60, 12)
      ..quadraticBezierTo(24, 20, -12, 12)
      ..close();
    c.drawPath(_path, _p);
    if (!rimPass) {
      // Lower fangs.
      _p.color = fade(bone, alpha);
      _path
        ..reset()
        ..moveTo(46, -2)
        ..lineTo(50, -14 - m * 6)
        ..lineTo(54, -2)
        ..close();
      c.drawPath(_path, _p);
      _p.color = col;
    }
    c.restore();
    if (!rimPass) {
      // Mouth interior glow when open.
      final open = (jawA / 0.75).clamp(0.0, 1.0);
      if (open > 0.05) {
        _p
          ..blendMode = BlendMode.plus
          ..color = fade(Color.lerp(const Color(0xFFFF4A1A), stripes, 0.35)!, 0.3 * alpha * open);
        c.drawOval(Rect.fromCenter(center: Offset(62, 16 + 12 * open), width: 34, height: 6 + 14 * open), _p);
        _p.blendMode = BlendMode.srcOver;
      }
      // Upper fangs (sabre when monster).
      _p.color = fade(bone, alpha);
      final fang = 18 + m * 30;
      _path
        ..reset()
        ..moveTo(84, 8)
        ..quadraticBezierTo(86, 8 + fang * 0.6, 90, 8 + fang)
        ..lineTo(95, 8)
        ..close()
        ..moveTo(66, 10)
        ..lineTo(69, 10 + fang * 0.55)
        ..lineTo(73, 10)
        ..close();
      c.drawPath(_path, _p);
      // Nose highlight, whiskers and brow detail.
      _s
        ..color = fade(detail, alpha * 1.6)
        ..strokeWidth = 1.2;
      for (var i = 0; i < 4; i++) {
        c.drawLine(Offset(92, -2 + i * 3.0), Offset(140, -16 + i * 9.0 + g.roar * 6), _s);
      }
      _s.strokeWidth = 2;
      c.drawLine(const Offset(44, -32), const Offset(80, -22), _s);
      // Face stripes.
      final pulse = 0.65 + 0.35 * math.sin(g.time * 3);
      _stripe(c, const Offset(18, -30), const Offset(40, -18), 6, alpha * pulse, stripes);
      _stripe(c, const Offset(14, -14), const Offset(38, -6), 6, alpha * pulse, stripes);
      _stripe(c, const Offset(50, -48), const Offset(56, -32), 5, alpha * pulse, stripes);
      _p.color = col;
    }
  }

  static void _tigerHind(Canvas c, Offset hip, double phase, double big) {
    final sw = math.sin(phase) * 0.5;
    final lift = math.max(0.0, math.cos(phase)) * 24;
    final knee = hip + Offset(math.sin(sw) * 34 + 18, 44 - lift * 0.3);
    final hock = Offset(knee.dx - 34 + math.sin(sw) * 10, -48 - lift * 0.6);
    final paw = Offset(hock.dx + 18 + math.sin(sw) * 24, -lift - 9);
    _taper(c, [hip, knee], 66 * big, 42 * big, _p);
    _taper(c, [knee, hock], 40 * big, 26 * big, _p);
    _taper(c, [hock, paw], 26 * big, 22 * big, _p);
    _paw(c, paw, big);
  }

  static void _tigerFore(Canvas c, Offset shoulder, double phase, double big) {
    final sw = math.sin(phase) * 0.5;
    final lift = math.max(0.0, math.cos(phase)) * 26;
    final elbow = shoulder + Offset(math.sin(sw) * 26 - 6, 58 - lift * 0.4);
    final wrist = Offset(elbow.dx + math.sin(sw) * 34 + 6, -26 - lift);
    final paw = Offset(wrist.dx + 10, -lift - 9);
    _taper(c, [shoulder, elbow], 56 * big, 38 * big, _p);
    _taper(c, [elbow, wrist], 36 * big, 28 * big, _p);
    _taper(c, [wrist, paw], 28 * big, 24 * big, _p);
    _paw(c, paw, big);
  }

  static void _paw(Canvas c, Offset paw, double big) {
    c.drawOval(Rect.fromCenter(center: paw + const Offset(12, 4), width: 46 * big, height: 18), _p);
    for (var i = 0; i < 3; i++) {
      c.drawCircle(paw + Offset(22.0 + i * 7, 6), 6 * big, _p);
    }
    _s
      ..color = _p.color
      ..strokeWidth = 3;
    for (var i = 0; i < 3; i++) {
      c.drawLine(paw + Offset(28.0 + i * 7, 6), paw + Offset(36.0 + i * 7, 12), _s);
    }
  }

  // ---------------------------------------------------------------- DRAGON

  /// Two-headed shadow dragon centred on its body ([s] ~ 90 for the boss).
  /// [roar] rears both heads back with jaws wide open.
  static void dragon(
    Canvas c, {
    required double s,
    required double flap,
    double alpha = 1,
    double flash = 0,
    double eyeGlow = 1,
    double mouthA = 0,
    double mouthB = 0,
    double roar = 0,
    double rimDx = 1,
    double time = 0,
  }) {
    if (alpha <= 0.01) return;
    aura(c, Rect.fromCenter(center: Offset(0.3 * s, -0.2 * s), width: 4.6 * s, height: 2.8 * s), time, alpha, glow: const Color(0xFFFF3A10));
    final a4 = alpha * alpha * alpha * alpha;
    final ma = math.max(mouthA, roar);
    final mb = math.max(mouthB, roar);
    _dragonShape(c, s, flap, ma, mb, roar, fade(rim, 0.5 * a4), true, rimDx, time, alpha);
    _dragonShape(c, s, flap, ma, mb, roar, _body(alpha, flash), false, rimDx, time, alpha);
    for (var h = 0; h < 2; h++) {
      final head = _dragonHead(s, time, h, roar);
      final ang = _headAngle(h, roar, time);
      final e = head + Offset(math.cos(ang) * 0.24 * s - math.sin(ang) * -0.1 * s, math.sin(ang) * 0.24 * s + math.cos(ang) * -0.1 * s);
      glowEye(c, e, 0.07 * s, eyeGlow * alpha * (1 + roar * 0.5));
    }
  }

  static Offset _dragonHead(double s, double time, int which, [double roar = 0]) {
    if (which == 0) return Offset(1.95 * s + math.sin(time * 1.3) * 0.12 * s - roar * 0.3 * s, -1.5 * s + math.cos(time * 1.7) * 0.1 * s - roar * 0.35 * s);
    return Offset(2.25 * s + math.sin(time * 1.6 + 1) * 0.12 * s - roar * 0.2 * s, -0.55 * s + math.cos(time * 1.4 + 2) * 0.1 * s - roar * 0.25 * s);
  }

  static double _headAngle(int which, double roar, double time) => (which == 0 ? -0.15 : 0.08) - roar * 0.55 + math.sin(time * 1.5 + which) * 0.05;

  /// Mouth position of a dragon head in model space.
  static Offset dragonMouth(double s, double time, int which) {
    final h = _dragonHead(s, time, which);
    final a = _headAngle(which, 0, time);
    return h + Offset(math.cos(a) * 0.6 * s, math.sin(a) * 0.6 * s);
  }

  static void _dragonShape(Canvas c, double s, double flap, double mouthA, double mouthB, double roar, Color col, bool rimPass, double rimDx, double time, double alpha) {
    c.save();
    if (rimPass) c.translate(rimDx * 0.03 * s, -0.03 * s);
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = rimPass ? col : Color.lerp(col, const Color(0xFF161B28), 0.38)!;
    _batWing(c, s, math.sin(flap - 0.4), Offset(-0.1 * s, -0.42 * s), 0.86, rimPass, alpha, time);
    _p.color = col;
    // Tail with dorsal spikes and a spade tip.
    final tail = <Offset>[];
    for (var i = 0; i <= 16; i++) {
      final t = i / 16;
      tail.add(Offset(-1.0 * s - t * 2.6 * s, 0.1 * s + math.sin(time * 2.4 + t * 5) * 0.26 * s * t + t * 0.32 * s));
    }
    _taper(c, tail, 0.48 * s, 0.07 * s, _p);
    for (var i = 2; i < 15; i += 2) {
      final q = tail[i];
      final d = tail[i + 1] - tail[i - 1];
      final n = Offset(d.dy, -d.dx) / math.max(d.distance, 0.001);
      final w = 0.48 * s * (1 - i / 16);
      _lens(c, q + n * (w * 0.35), n * 1.0 - d / math.max(d.distance, 0.001) * 0.6, 0.22 * s * (1 - i / 20), 0.05 * s, _p);
    }
    final tip = tail.last;
    _path
      ..reset()
      ..moveTo(tip.dx + 0.05 * s, tip.dy)
      ..lineTo(tip.dx - 0.38 * s, tip.dy - 0.22 * s)
      ..lineTo(tip.dx - 0.22 * s, tip.dy + 0.02 * s)
      ..lineTo(tip.dx - 0.34 * s, tip.dy + 0.26 * s)
      ..close();
    c.drawPath(_path, _p);
    // Muscular body with a deep chest.
    _path
      ..reset()
      ..moveTo(-1.3 * s, 0.05 * s)
      ..cubicTo(-1.2 * s, -0.42 * s, 0.2 * s, -0.62 * s, 0.95 * s, -0.4 * s)
      ..cubicTo(1.3 * s, -0.25 * s, 1.2 * s, 0.35 * s, 0.7 * s, 0.48 * s)
      ..cubicTo(0.1 * s, 0.56 * s, -1.0 * s, 0.4 * s, -1.3 * s, 0.05 * s)
      ..close();
    c.drawPath(_path, _p);
    // Hind and fore legs with talons.
    for (var i = 0; i < 2; i++) {
      final hx = -0.55 * s + i * 1.0 * s;
      final hy = 0.25 * s;
      _taper(c, [Offset(hx, hy), Offset(hx + 0.2 * s, hy + 0.38 * s), Offset(hx + 0.05 * s, hy + 0.66 * s)], (i == 0 ? 0.4 : 0.3) * s, 0.12 * s, _p);
      _s
        ..color = col
        ..strokeWidth = 0.05 * s;
      for (var j = 0; j < 3; j++) {
        final b0 = Offset(hx + 0.05 * s, hy + 0.66 * s);
        _path
          ..reset()
          ..moveTo(b0.dx, b0.dy)
          ..quadraticBezierTo(b0.dx + (0.1 + j * 0.06) * s, b0.dy + 0.04 * s, b0.dx + (0.12 + j * 0.08) * s, b0.dy + 0.16 * s);
        c.drawPath(_path, _s);
      }
    }
    // Back spines.
    for (var i = 0; i < 8; i++) {
      final x = -1.05 * s + i * 0.27 * s;
      final y = -0.38 * s - math.sin((i / 7) * math.pi) * 0.1 * s;
      _lens(c, Offset(x, y + 0.06 * s), const Offset(-0.45, -1), (0.3 + math.sin((i / 7) * math.pi) * 0.12) * s, 0.06 * s, _p);
    }
    // Necks and heads.
    for (var which = 0; which < 2; which++) {
      final head = _dragonHead(s, time, which, roar);
      final ang = _headAngle(which, roar, time);
      final base = Offset(0.95 * s, -0.25 * s + which * 0.22 * s);
      final ctrl = Offset((base.dx + head.dx) / 2 - 0.25 * s, (base.dy + head.dy) / 2 - 0.15 * s);
      final pts = <Offset>[];
      for (var i = 0; i <= 12; i++) {
        pts.add(_quad(base, ctrl, head, i / 12));
      }
      _taper(c, pts, 0.48 * s, 0.26 * s, _p);
      // Neck spines.
      for (var i = 1; i < 11; i += 2) {
        final d = pts[i + 1] - pts[i - 1];
        final n = Offset(d.dy, -d.dx) / math.max(d.distance, 0.001);
        final w = lerpD(0.48, 0.26, i / 12) * s;
        _lens(c, pts[i] + n * (w * 0.4), n - d / math.max(d.distance, 0.001) * 0.7, 0.17 * s, 0.04 * s, _p);
      }
      final mo = which == 0 ? mouthA : mouthB;
      c.save();
      c.translate(head.dx, head.dy);
      c.rotate(ang);
      // Wedge skull with brow.
      _path
        ..reset()
        ..moveTo(-0.2 * s, -0.18 * s)
        ..quadraticBezierTo(0.05 * s, -0.3 * s, 0.32 * s, -0.2 * s)
        ..quadraticBezierTo(0.5 * s, -0.12 * s, 0.68 * s, -0.04 * s)
        ..lineTo(0.66 * s, 0.04 * s)
        ..quadraticBezierTo(0.32 * s, 0.07 * s, -0.16 * s, 0.16 * s)
        ..close();
      c.drawPath(_path, _p);
      // Jaw.
      c.save();
      c.translate(-0.05 * s, 0.1 * s);
      c.rotate(mo * 0.55);
      _path
        ..reset()
        ..moveTo(-0.05 * s, -0.02 * s)
        ..lineTo(0.62 * s, -0.04 * s)
        ..lineTo(0.56 * s, 0.06 * s)
        ..quadraticBezierTo(0.2 * s, 0.12 * s, -0.08 * s, 0.08 * s)
        ..close();
      c.drawPath(_path, _p);
      if (!rimPass) {
        _p.color = fade(bone, alpha);
        for (var i = 0; i < 4; i++) {
          final x = 0.18 * s + i * 0.1 * s;
          _path
            ..reset()
            ..moveTo(x, -0.03 * s)
            ..lineTo(x + 0.025 * s, -0.1 * s)
            ..lineTo(x + 0.05 * s, -0.03 * s)
            ..close();
          c.drawPath(_path, _p);
        }
        _p.color = col;
      }
      c.restore();
      // Swept-back horns and cheek frill.
      _s
        ..color = col
        ..strokeWidth = 0.075 * s;
      _path
        ..reset()
        ..moveTo(0.05 * s, -0.2 * s)
        ..quadraticBezierTo(-0.3 * s, -0.45 * s, -0.62 * s, -0.36 * s)
        ..moveTo(0.18 * s, -0.22 * s)
        ..quadraticBezierTo(-0.05 * s, -0.6 * s, -0.4 * s, -0.66 * s);
      c.drawPath(_path, _s);
      for (var i = 0; i < 3; i++) {
        _lens(c, Offset(-0.05 * s, 0.02 * s + i * 0.05 * s), Offset(-1, 0.3 + i * 0.3), 0.24 * s, 0.04 * s, _p);
      }
      if (!rimPass) {
        _p.color = fade(bone, alpha);
        for (var i = 0; i < 4; i++) {
          final x = 0.2 * s + i * 0.11 * s;
          _path
            ..reset()
            ..moveTo(x, 0.02 * s)
            ..lineTo(x + 0.03 * s, 0.1 * s + mo * 0.03 * s)
            ..lineTo(x + 0.06 * s, 0.02 * s)
            ..close();
          c.drawPath(_path, _p);
        }
        if (mo > 0.08) {
          _p
            ..blendMode = BlendMode.plus
            ..color = fade(const Color(0xFFFF7A1A), 0.75 * alpha * mo);
          c.drawOval(Rect.fromCenter(center: Offset(0.42 * s, 0.12 * s + mo * 0.12 * s), width: 0.5 * s, height: 0.1 * s + mo * 0.22 * s), _p);
          _p.blendMode = BlendMode.srcOver;
        }
        // Nostril embers.
        _p
          ..blendMode = BlendMode.plus
          ..color = fade(const Color(0xFFFF5A1A), 0.5 * alpha * (0.6 + 0.4 * math.sin(time * 5 + which)));
        c.drawCircle(Offset(0.62 * s, -0.06 * s), 0.025 * s, _p);
        _p
          ..blendMode = BlendMode.srcOver
          ..color = col;
        _s
          ..color = fade(detail, alpha * 1.5)
          ..strokeWidth = 0.012 * s;
        c.drawLine(Offset(0.1 * s, -0.16 * s), Offset(0.45 * s, -0.1 * s), _s);
      }
      c.restore();
    }
    if (!rimPass) {
      // Belly plates and scale seams.
      _s
        ..color = fade(detail, alpha * 1.4)
        ..strokeWidth = 0.015 * s;
      for (var i = 0; i < 7; i++) {
        final x = -0.9 * s + i * 0.28 * s;
        _path
          ..reset()
          ..moveTo(x, 0.28 * s)
          ..quadraticBezierTo(x + 0.12 * s, 0.4 * s, x + 0.2 * s, 0.36 * s);
        c.drawPath(_path, _s);
      }
      final pulse = 0.6 + 0.4 * math.sin(time * 3.2);
      _s
        ..blendMode = BlendMode.plus
        ..strokeWidth = 0.035 * s
        ..color = fade(vein, 0.6 * alpha * pulse);
      _path
        ..reset()
        ..moveTo(-1.1 * s, 0.05 * s)
        ..lineTo(-0.4 * s, -0.16 * s)
        ..lineTo(0.3 * s, 0.02 * s)
        ..lineTo(0.95 * s, -0.22 * s)
        ..moveTo(-0.4 * s, -0.16 * s)
        ..lineTo(-0.2 * s, 0.24 * s);
      c.drawPath(_path, _s);
      _s.blendMode = BlendMode.srcOver;
      // Furnace glow in the chest.
      SoftSprite.draw(c, Offset(0.55 * s, 0.05 * s), 0.55 * s, fade(const Color(0xFFFF4A1A), 0.45 * alpha * pulse), blend: BlendMode.plus);
    }
    _p.color = col;
    _batWing(c, s, math.sin(flap), Offset(0.12 * s, -0.4 * s), 1.0, rimPass, alpha, time);
    c.restore();
  }

  static void _batWing(Canvas c, double s, double up, Offset shoulder, double scale, bool rimPass, double alpha, double time) {
    c.save();
    c.translate(shoulder.dx, shoulder.dy);
    final sy = up >= 0 ? -(0.3 + 0.7 * up) : (0.3 + 0.55 * (-up));
    c.scale(scale, sy * scale);
    final elbow = Offset(0.25 * s, 0.75 * s);
    final wrist = Offset(0.6 * s, 1.55 * s);
    final tips = [
      Offset(1.2 * s, 3.1 * s),
      Offset(0.35 * s, 3.35 * s),
      Offset(-0.6 * s, 3.05 * s),
      Offset(-1.35 * s, 2.3 * s),
    ];
    // Membrane (slightly translucent so the sky glows through).
    final memCol = _p.color;
    _p.color = rimPass ? memCol : fade(memCol, 0.88);
    _path
      ..reset()
      ..moveTo(0.15 * s, 0)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(wrist.dx, wrist.dy)
      ..lineTo(tips[0].dx, tips[0].dy);
    for (var i = 1; i < tips.length; i++) {
      final mid = Offset.lerp(tips[i - 1], tips[i], 0.5)! - Offset(0, 0.5 * s);
      _path.quadraticBezierTo(mid.dx, mid.dy, tips[i].dx, tips[i].dy);
    }
    _path
      ..quadraticBezierTo(-1.25 * s, 1.0 * s, -0.75 * s, 0.1 * s)
      ..close();
    c.drawPath(_path, _p);
    _p.color = memCol;
    // Arm and finger bones.
    _s
      ..color = memCol
      ..strokeWidth = 0.12 * s / scale;
    c.drawLine(Offset(0.15 * s, 0), elbow, _s);
    c.drawLine(elbow, wrist, _s);
    _s.strokeWidth = 0.055 * s / scale;
    for (final t in tips) {
      c.drawLine(wrist, t, _s);
    }
    // Wrist claw.
    _lens(c, wrist, const Offset(0.6, -0.3), 0.3 * s, 0.05 * s, _p);
    if (!rimPass) {
      final pulse = 0.5 + 0.5 * math.sin(time * 3);
      _s
        ..blendMode = BlendMode.plus
        ..strokeWidth = 0.02 * s / scale
        ..color = fade(vein, 0.5 * alpha * pulse);
      for (final t in tips) {
        c.drawLine(Offset.lerp(wrist, t, 0.1)!, Offset.lerp(wrist, t, 0.9)!, _s);
      }
      _s.blendMode = BlendMode.srcOver;
    }
    c.restore();
  }

  /// Returns the near hand position of the monster (model space, unscaled).
  static Offset monsterHand(double armF, double lean, double time) {
    final breathe = math.sin(time * 1.8) * 4;
    final shoulder = Offset(55 + lean * 20, -295 + breathe + lean * 25);
    final upper = lerpD(0.35, 3.0, armF);
    final fore = lerpD(0.15, 3.3, armF);
    final elbow = shoulder + Offset(math.sin(upper) * 95, math.cos(upper) * 95);
    return elbow + Offset(math.sin(fore) * 110, math.cos(fore) * 110);
  }
}
