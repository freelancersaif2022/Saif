import 'dart:math' as math;
import 'dart:ui';

import '../core/utils.dart';

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

  static Color _body(double alpha, double flash) =>
      fade(Color.lerp(shadow, const Color(0xFF3E4A62), flash.clamp(0.0, 1.0) * 0.6)!, alpha);

  static void glowEye(Canvas c, Offset e, double r, double g, {Color color = redEye}) {
    if (g <= 0.01) return;
    _p
      ..style = PaintingStyle.fill
      ..color = fade(color, 0.12 * g);
    c.drawCircle(e, r * 4.0, _p);
    _p.color = fade(color, 0.32 * g);
    c.drawCircle(e, r * 1.9, _p);
    _p.color = fade(Color.lerp(color, const Color(0xFFFFFFFF), 0.5)!, g.clamp(0.0, 1.0));
    c.drawOval(Rect.fromCenter(center: e, width: r * 2.0, height: r * 1.0), _p);
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
    _eagleShape(c, s, flap, talons, fade(rim, 0.5 * alpha), true, rimDx, time);
    _eagleShape(c, s, flap, talons, _body(alpha, flash), false, rimDx, time);
    glowEye(c, Offset(1.22 * s, -0.4 * s), 0.07 * s, eyeGlow * alpha);
  }

  static void _eagleShape(Canvas c, double s, double flap, double talons, Color col, bool rimPass, double rimDx, double time) {
    c.save();
    if (rimPass) c.translate(rimDx * 0.03 * s, -0.03 * s);
    _p
      ..style = PaintingStyle.fill
      ..color = col;
    final wingUp = math.sin(flap);
    // Far wing (slightly behind and lagging).
    _wing(c, s, math.sin(flap - 0.35) * 0.95, Offset(-0.05 * s, -0.32 * s), col, 0.85);
    // Tail fan.
    for (var i = -2; i <= 2; i++) {
      final a = i * 0.13 + math.sin(time * 3 + i) * 0.03;
      _path
        ..reset()
        ..moveTo(-0.9 * s, -0.05 * s)
        ..lineTo(-1.55 * s, (a * 2.2 - 0.05) * s - 0.05 * s)
        ..lineTo(-1.6 * s, (a * 2.2 + 0.05) * s)
        ..lineTo(-0.85 * s, 0.12 * s)
        ..close();
      c.drawPath(_path, _p);
    }
    // Body.
    _path
      ..reset()
      ..moveTo(1.15 * s, -0.42 * s)
      ..cubicTo(0.7 * s, -0.62 * s, -0.4 * s, -0.48 * s, -1.0 * s, -0.12 * s)
      ..cubicTo(-1.1 * s, 0.05 * s, -0.6 * s, 0.38 * s, 0.1 * s, 0.4 * s)
      ..cubicTo(0.7 * s, 0.38 * s, 1.05 * s, 0.05 * s, 1.15 * s, -0.42 * s)
      ..close();
    c.drawPath(_path, _p);
    // Head and hooked beak.
    c.drawCircle(Offset(1.18 * s, -0.42 * s), 0.27 * s, _p);
    _path
      ..reset()
      ..moveTo(1.36 * s, -0.55 * s)
      ..quadraticBezierTo(1.72 * s, -0.56 * s, 1.78 * s, -0.32 * s)
      ..quadraticBezierTo(1.74 * s, -0.22 * s, 1.66 * s, -0.24 * s)
      ..quadraticBezierTo(1.62 * s, -0.36 * s, 1.4 * s, -0.3 * s)
      ..close();
    c.drawPath(_path, _p);
    // Neck ruff feathers.
    for (var i = 0; i < 5; i++) {
      final x = 0.75 * s + i * 0.08 * s;
      _path
        ..reset()
        ..moveTo(x, -0.25 * s)
        ..lineTo(x - 0.16 * s, -0.02 * s)
        ..lineTo(x + 0.05 * s, -0.12 * s)
        ..close();
      c.drawPath(_path, _p);
    }
    // Legs and talons.
    final lx = 0.25 * s + talons * 0.45 * s;
    final ly = 0.75 * s - talons * 0.15 * s;
    _s
      ..color = col
      ..strokeWidth = 0.09 * s;
    c.drawLine(Offset(0.15 * s, 0.25 * s), Offset(lx, ly), _s);
    _s.strokeWidth = 0.045 * s;
    for (var i = -1; i <= 1; i++) {
      _path
        ..reset()
        ..moveTo(lx, ly)
        ..quadraticBezierTo(lx + (0.12 + i * 0.06) * s, ly + 0.05 * s, lx + (0.16 + i * 0.1) * s, ly + 0.17 * s);
      c.drawPath(_path, _s);
    }
    // Near wing.
    _wing(c, s, wingUp, Offset(0.1 * s, -0.3 * s), col, 1.0);
    c.restore();
  }

  static void _wing(Canvas c, double s, double up, Offset shoulder, Color col, double scale) {
    // up: 1 = fully raised, -1 = fully lowered.
    c.save();
    c.translate(shoulder.dx, shoulder.dy);
    final sy = up >= 0 ? -(0.25 + 0.75 * up) : (0.25 + 0.6 * (-up));
    c.scale(scale, sy * scale);
    _p.color = col;
    _path
      ..reset()
      ..moveTo(0.25 * s, 0)
      ..cubicTo(0.45 * s, 0.6 * s, 0.4 * s, 1.3 * s, 0.1 * s, 1.75 * s)
      ..lineTo(-0.35 * s, 2.9 * s);
    // Primary feathers along the trailing edge, from the tip back to the body.
    const feathers = 9;
    for (var i = 0; i < feathers; i++) {
      final t = i / (feathers - 1);
      final bx = lerpD(-0.35 * s, -0.95 * s, t);
      final by = lerpD(2.9 * s, 0.25 * s, t);
      final nx = lerpD(-0.62 * s, -1.02 * s, t);
      final ny = lerpD(2.55 * s, 0.05 * s, t);
      _path.lineTo(bx, by);
      _path.lineTo(nx, ny);
    }
    _path
      ..lineTo(-0.6 * s, 0)
      ..close();
    c.drawPath(_path, _p);
    c.restore();
  }

  // ---------------------------------------------------------------- ELEPHANT

  /// Elephant with feet on the origin. [k] scales the base 260px tall model.
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
    _elephantShape(c, walk, trunk, fade(rim, 0.45 * alpha), true, rimDx, time);
    _elephantShape(c, walk, trunk, _body(alpha, flash), false, rimDx, time);
    glowEye(c, const Offset(196, -212), 6, eyeGlow * alpha);
    c.restore();
  }

  static void _elephantShape(Canvas c, double walk, double trunk, Color col, bool rimPass, double rimDx, double time) {
    c.save();
    if (rimPass) c.translate(rimDx * 3, -3);
    final farCol = rimPass ? col : Color.lerp(col, const Color(0xFF151A26), 0.4)!;
    _p
      ..style = PaintingStyle.fill
      ..color = farCol;
    // Far legs.
    _leg(c, const Offset(-95, -120), walk + math.pi, 46);
    _leg(c, const Offset(95, -120), walk, 46);
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
      ..moveTo(-170, -130)
      ..cubicTo(-200, -210, -120, -275, -30, -270)
      ..cubicTo(60, -280, 120, -262, 150, -225)
      ..lineTo(160, -150)
      ..cubicTo(120, -95, 60, -100, 0, -98)
      ..cubicTo(-80, -96, -150, -95, -170, -130)
      ..close();
    c.drawPath(_path, _p);
    // Head dome.
    c.drawCircle(const Offset(178, -205), 58, _p);
    c.drawCircle(const Offset(160, -245), 34, _p);
    // Trunk.
    final sway = math.sin(time * 1.8) * 14 + trunk * 60;
    final p0 = const Offset(215, -185);
    final p1 = Offset(260 + sway * 0.3, -120);
    final p2 = Offset(232 + sway, -18 - trunk * 120);
    final pts = <Offset>[];
    for (var i = 0; i <= 10; i++) {
      pts.add(_quad(p0, p1, p2, i / 10));
    }
    _taper(c, pts, 40, 13, _p);
    // Tusks.
    _s
      ..color = rimPass ? col : fade(const Color(0xFF8E877C), col.a)
      ..strokeWidth = 9;
    _path
      ..reset()
      ..moveTo(205, -158)
      ..quadraticBezierTo(262, -130, 292, -170);
    c.drawPath(_path, _s);
    // Ear.
    _p.color = col;
    final ef = math.sin(time * 2.2) * 8;
    _path
      ..reset()
      ..moveTo(150, -255)
      ..cubicTo(95 - ef, -285, 70 - ef, -200, 95 - ef, -150)
      ..cubicTo(110, -130, 140, -150, 150, -170)
      ..close();
    c.drawPath(_path, _p);
    if (!rimPass) {
      _s
        ..color = fade(const Color(0xFF1A2030), col.a)
        ..strokeWidth = 3;
      c.drawPath(_path, _s);
    }
    // Near legs.
    _p.color = col;
    _leg(c, const Offset(-120, -120), walk, 52);
    _leg(c, const Offset(120, -120), walk + math.pi, 52);
    c.restore();
  }

  static void _leg(Canvas c, Offset top, double phase, double w) {
    final swing = math.sin(phase) * 0.22;
    final lift = math.max(0.0, math.cos(phase)) * 14;
    final knee = top + Offset(math.sin(swing) * 60, 60 - lift * 0.3);
    final foot = Offset(top.dx + math.sin(swing) * 95, -lift);
    _taper(c, [top, knee, foot], w, w * 0.9, _p);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: foot + const Offset(0, -6), width: w * 1.1, height: 16), const Radius.circular(6)), _p);
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
    _ratShape(c, run, crouch, fade(rim, 0.45 * alpha), true, rimDx, time);
    _ratShape(c, run, crouch, _body(alpha, flash), false, rimDx, time);
    glowEye(c, Offset(158, -128 + crouch * 30), 5, eyeGlow * alpha);
    c.restore();
  }

  static void _ratShape(Canvas c, double run, double crouch, Color col, bool rimPass, double rimDx, double time) {
    c.save();
    if (rimPass) c.translate(rimDx * 3, -3);
    final dy = crouch * 30;
    _p
      ..style = PaintingStyle.fill
      ..color = col;
    // Tail.
    final pts = <Offset>[];
    for (var i = 0; i <= 14; i++) {
      final t = i / 14;
      pts.add(Offset(-130 - t * 280, -70 + dy * 0.5 + math.sin(time * 4 + t * 5) * 22 * t - t * 30));
    }
    _taper(c, pts, 18, 3, _p);
    // Legs (far).
    final far = Color.lerp(col, const Color(0xFF151A26), rimPass ? 0 : 0.4)!;
    _p.color = far;
    _ratLeg(c, Offset(-80, -70 + dy), run + math.pi, true);
    _ratLeg(c, Offset(70, -70 + dy), run, false);
    _p.color = col;
    // Body.
    _path
      ..reset()
      ..moveTo(-150, -60 + dy)
      ..cubicTo(-170, -150 + dy, -60, -200 + dy, 30, -175 + dy)
      ..cubicTo(90, -165 + dy, 120, -150 + dy, 140, -120 + dy)
      ..lineTo(120, -60 + dy)
      ..cubicTo(40, -40 + dy, -80, -40 + dy, -150, -60 + dy)
      ..close();
    c.drawPath(_path, _p);
    // Back spines.
    for (var i = 0; i < 8; i++) {
      final x = -120.0 + i * 26;
      final y = -150 + dy - math.sin((i / 7) * math.pi) * 40;
      _path
        ..reset()
        ..moveTo(x - 10, y + 12)
        ..lineTo(x + 2, y - 26 - math.sin(time * 6 + i) * 3)
        ..lineTo(x + 12, y + 12)
        ..close();
      c.drawPath(_path, _p);
    }
    // Head and snout.
    _path
      ..reset()
      ..moveTo(110, -155 + dy)
      ..cubicTo(150, -165 + dy, 190, -120 + dy, 225, -92 + dy)
      ..lineTo(222, -82 + dy)
      ..cubicTo(180, -70 + dy, 140, -70 + dy, 110, -85 + dy)
      ..close();
    c.drawPath(_path, _p);
    c.drawCircle(Offset(118, -170 + dy), 26, _p);
    c.drawCircle(Offset(95, -165 + dy), 22, _p);
    // Teeth.
    if (!rimPass) {
      _p.color = fade(const Color(0xFF8E877C), col.a);
      _path
        ..reset()
        ..moveTo(205, -84 + dy)
        ..lineTo(211, -66 + dy)
        ..lineTo(215, -84 + dy)
        ..close()
        ..moveTo(195, -82 + dy)
        ..lineTo(200, -68 + dy)
        ..lineTo(204, -82 + dy)
        ..close();
      c.drawPath(_path, _p);
      _p.color = col;
      // Whiskers.
      _s
        ..color = fade(const Color(0xFF2A3040), col.a)
        ..strokeWidth = 1.5;
      for (var i = 0; i < 3; i++) {
        c.drawLine(Offset(215, -92 + dy), Offset(265, -110 + dy + i * 14), _s);
      }
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
    final knee = top + Offset(math.sin(sw) * 30 + (hind ? -20 : 10), 30 - lift * 0.4);
    final foot = Offset(top.dx + math.sin(sw) * 50, -lift);
    _taper(c, [top, knee, foot], hind ? 36 : 26, 10, _p);
    _s
      ..color = _p.color
      ..strokeWidth = 4;
    for (var i = 0; i < 3; i++) {
      c.drawLine(foot, foot + Offset(10.0 + i * 5, 4), _s);
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
    _monsterShape(c, walk, armF, armB, lean, fade(rim, 0.45 * alpha), true, rimDx, time);
    _monsterShape(c, walk, armF, armB, lean, _body(alpha, flash), false, rimDx, time);
    final hy = -300 + math.sin(time * 1.8) * 4 + lean * 30;
    glowEye(c, Offset(140 + lean * 30, hy - 6), 5.5, eyeGlow * alpha);
    glowEye(c, Offset(122 + lean * 30, hy - 4), 4.5, eyeGlow * alpha * 0.8);
    c.restore();
  }

  static void _monsterShape(Canvas c, double walk, double armF, double armB, double lean, Color col, bool rimPass, double rimDx, double time) {
    c.save();
    if (rimPass) c.translate(rimDx * 4, -4);
    final breathe = math.sin(time * 1.8) * 4;
    final far = Color.lerp(col, const Color(0xFF151A26), rimPass ? 0 : 0.4)!;
    _p
      ..style = PaintingStyle.fill
      ..color = far;
    // Far arm.
    _arm(c, Offset(-40 + lean * 20, -300 + breathe + lean * 25), armB, walk + math.pi, 0.9);
    // Legs.
    final s1 = math.sin(walk) * 0.25;
    final s2 = math.sin(walk + math.pi) * 0.25;
    _taper(c, [const Offset(-40, -170), Offset(-50 + s2 * 80, -85), Offset(-45 + s2 * 120, -6 - math.max(0, math.cos(walk + math.pi)) * 12)], 62, 44, _p);
    _p.color = col;
    _taper(c, [const Offset(35, -170), Offset(45 + s1 * 80, -85), Offset(50 + s1 * 120, -6 - math.max(0, math.cos(walk)) * 12)], 66, 46, _p);
    // Torso.
    c.save();
    c.translate(0, -170);
    c.rotate(lean * 0.25);
    _path
      ..reset()
      ..moveTo(-75, 10)
      ..cubicTo(-120, -60, -110, -170 + breathe, -30, -215 + breathe)
      ..cubicTo(30, -235 + breathe, 110, -190 + breathe, 120, -130 + breathe)
      ..cubicTo(125, -70, 90, -10, 70, 10)
      ..close();
    c.drawPath(_path, _p);
    // Spikes on the back.
    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      final bx = lerpD(-95, 40, t);
      final by = lerpD(-110, -228, t) + breathe;
      _path
        ..reset()
        ..moveTo(bx - 12, by + 10)
        ..lineTo(bx - 28 - i * 2, by - 40 - i * 3)
        ..lineTo(bx + 10, by)
        ..close();
      c.drawPath(_path, _p);
    }
    c.restore();
    // Head with horns.
    final hx = 122 + lean * 30;
    final hy = -300 + breathe + lean * 30;
    c.drawOval(Rect.fromCenter(center: Offset(hx, hy), width: 70, height: 58), _p);
    _s
      ..color = col
      ..strokeWidth = 12;
    _path
      ..reset()
      ..moveTo(hx - 10, hy - 22)
      ..quadraticBezierTo(hx - 50, hy - 70, hx - 20, hy - 110)
      ..moveTo(hx + 18, hy - 22)
      ..quadraticBezierTo(hx + 50, hy - 60, hx + 40, hy - 100);
    c.drawPath(_path, _s);
    // Maw.
    if (!rimPass) {
      _p.color = fade(const Color(0xFF7A0E0E), col.a * 0.8);
      c.drawOval(Rect.fromCenter(center: Offset(hx + 18, hy + 16), width: 30, height: 10 + math.max(0, armF) * 8), _p);
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
    _taper(c, [shoulder, elbow], 62 * scale, 46 * scale, _p);
    _taper(c, [elbow, hand], 46 * scale, 38 * scale, _p);
    c.drawCircle(hand, 30 * scale, _p);
    _s
      ..color = _p.color
      ..strokeWidth = 9 * scale;
    final dir = Offset(math.sin(fore), math.cos(fore));
    final side = Offset(-dir.dy, dir.dx);
    for (var i = -1; i <= 1; i++) {
      final b = hand + side * (i * 16.0 * scale) + dir * (16 * scale);
      final t = b + dir * (34 * scale) + side * (i * 6.0 * scale) + Offset(8 * scale, 0);
      _path
        ..reset()
        ..moveTo(b.dx, b.dy)
        ..quadraticBezierTo(b.dx + dir.dx * 30 * scale, b.dy + dir.dy * 30 * scale, t.dx, t.dy);
      c.drawPath(_path, _s);
    }
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
