import 'dart:math' as math;
import 'dart:ui';

import '../models/enemy_model.dart';

/// Procedural cartoon enemies. All are drawn facing left (toward the player)
/// with the origin at the bottom centre of their bounding box. [phase] is an
/// animation phase in 0..1 that loops.
class EnemyArt {
  EnemyArt._();

  static final Paint _f = Paint()..isAntiAlias = true;
  static final Paint _s = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3;

  static const _ink = Color(0xFF2A1636);

  static void paint(Canvas c, EnemyKind kind, double phase, {double action = 0}) {
    _s
      ..color = _ink
      ..strokeWidth = 3;
    switch (kind) {
      case EnemyKind.slime:
        _slime(c, phase);
      case EnemyKind.bat:
        _bat(c, phase);
      case EnemyKind.stone:
        _stone(c, phase);
      case EnemyKind.goblin:
        _goblin(c, phase);
      case EnemyKind.boss:
        _boss(c, phase, action);
    }
  }

  static void _eyes(Canvas c, Offset l, Offset r, double size, {Color iris = const Color(0xFF2A1636), bool angry = true}) {
    for (final e in [l, r]) {
      _f.color = const Color(0xFFFFFFFF);
      c.drawOval(Rect.fromCenter(center: e, width: size, height: size * 1.15), _f);
      _s.strokeWidth = 2.2;
      c.drawOval(Rect.fromCenter(center: e, width: size, height: size * 1.15), _s);
      _f.color = iris;
      c.drawCircle(e + Offset(-size * 0.15, size * 0.05), size * 0.28, _f);
      _f.color = const Color(0xFFFFFFFF);
      c.drawCircle(e + Offset(-size * 0.25, -size * 0.12), size * 0.1, _f);
    }
    if (angry) {
      _s.strokeWidth = 3;
      c.drawLine(l + Offset(-size * 0.6, -size * 0.75), l + Offset(size * 0.5, -size * 0.45), _s);
      c.drawLine(r + Offset(-size * 0.5, -size * 0.45), r + Offset(size * 0.6, -size * 0.75), _s);
    }
    _s.strokeWidth = 3;
  }

  // ------------------------------------------------------------------ slime
  static void _slime(Canvas c, double phase) {
    final t = phase * math.pi * 2;
    final sy = 1 + math.sin(t) * 0.12;
    final sx = 1 / sy;
    c.save();
    c.scale(sx, sy);
    final body = Path()
      ..moveTo(-43, 0)
      ..cubicTo(-46, -40, -24, -66, 2, -66)
      ..cubicTo(30, -66, 46, -40, 43, 0)
      ..cubicTo(30, 4, -30, 4, -43, 0)
      ..close();
    _f.shader = Gradient.radial(
      const Offset(-10, -44),
      60,
      const [Color(0xFFE59BFF), Color(0xFFB45CFF), Color(0xFF7A2FD6)],
      const [0.0, 0.5, 1.0],
    );
    c.drawPath(body, _f);
    _f.shader = null;
    c.drawPath(body, _s);
    _f.color = const Color(0x88FFFFFF);
    c.drawOval(const Rect.fromLTWH(-26, -56, 18, 10), _f);
    c.drawCircle(const Offset(-30, -40), 3, _f);
    _eyes(c, const Offset(-18, -34), const Offset(6, -34), 15);
    // mouth with fang
    _s.strokeWidth = 2.6;
    c.drawPath(
      Path()
        ..moveTo(-18, -16)
        ..quadraticBezierTo(-6, -10, 6, -16),
      _s,
    );
    _f.color = const Color(0xFFFFFFFF);
    c.drawPath(
      Path()
        ..moveTo(-12, -14)
        ..lineTo(-9, -8)
        ..lineTo(-6, -13)
        ..close(),
      _f,
    );
    c.restore();
  }

  // -------------------------------------------------------------------- bat
  static void _bat(Canvas c, double phase) {
    final t = phase * math.pi * 2;
    final flap = math.sin(t);
    c.save();
    c.translate(0, -32);
    for (final side in [-1.0, 1.0]) {
      c.save();
      c.scale(side, 1);
      c.rotate(-flap * 0.55);
      final wing = Path()
        ..moveTo(6, -4)
        ..lineTo(26, -24)
        ..lineTo(48, -18)
        ..quadraticBezierTo(44, -6, 50, 4)
        ..quadraticBezierTo(38, 0, 34, 10)
        ..quadraticBezierTo(24, 2, 14, 10)
        ..close();
      _f.shader = Gradient.linear(const Offset(10, -20), const Offset(40, 10), const [Color(0xFF8E5BD6), Color(0xFF4A2A85)]);
      c.drawPath(wing, _f);
      _f.shader = null;
      c.drawPath(wing, _s);
      c.restore();
    }
    // ears
    _f.color = const Color(0xFF5B3A8C);
    for (final x in [-12.0, 12.0]) {
      final ear = Path()
        ..moveTo(x - 8, -14)
        ..lineTo(x + (x < 0 ? -4 : 4), -32)
        ..lineTo(x + 6, -12)
        ..close();
      c.drawPath(ear, _f);
      c.drawPath(ear, _s);
    }
    final body = Rect.fromCenter(center: Offset.zero, width: 40, height: 36);
    _f.shader = Gradient.radial(const Offset(-6, -8), 26, const [Color(0xFF8D63CF), Color(0xFF4F2F86)]);
    c.drawOval(body, _f);
    _f.shader = null;
    c.drawOval(body, _s);
    _eyes(c, const Offset(-8, -4), const Offset(8, -4), 11, iris: const Color(0xFFE0A800));
    _f.color = const Color(0xFFFFFFFF);
    for (final x in [-5.0, 3.0]) {
      c.drawPath(
        Path()
          ..moveTo(x, 7)
          ..lineTo(x + 2, 13)
          ..lineTo(x + 4, 7)
          ..close(),
        _f,
      );
    }
    c.restore();
  }

  // ------------------------------------------------------------ stone golem
  static void _stone(Canvas c, double phase) {
    final t = phase * math.pi * 2;
    final step = math.sin(t);
    // legs
    _f.color = const Color(0xFF6E6A80);
    for (final x in [-26.0, 22.0]) {
      final lift = (x < 0 ? step : -step).clamp(0.0, 1.0) * 8;
      final leg = Rect.fromLTWH(x - 16, -30 - lift, 32, 30);
      c.drawRRect(RRect.fromRectAndRadius(leg, const Radius.circular(10)), _f);
      c.drawRRect(RRect.fromRectAndRadius(leg, const Radius.circular(10)), _s);
    }
    // body
    c.save();
    c.translate(0, math.sin(t * 2) * 2);
    final body = Path()
      ..moveTo(-56, -30)
      ..lineTo(-62, -80)
      ..lineTo(-40, -118)
      ..lineTo(0, -128)
      ..lineTo(44, -114)
      ..lineTo(60, -76)
      ..lineTo(52, -28)
      ..close();
    _f.shader = Gradient.linear(const Offset(0, -128), const Offset(0, -30), const [Color(0xFFB9B5C9), Color(0xFF7C778F)]);
    c.drawPath(body, _f);
    _f.shader = null;
    c.drawPath(body, _s);
    // moss
    _f.color = const Color(0xFF5CC45A);
    c.drawPath(
      Path()
        ..moveTo(-40, -118)
        ..lineTo(0, -128)
        ..lineTo(44, -114)
        ..quadraticBezierTo(30, -100, 18, -108)
        ..quadraticBezierTo(6, -96, -6, -108)
        ..quadraticBezierTo(-22, -98, -40, -118)
        ..close(),
      _f,
    );
    // cracks
    _s.strokeWidth = 2;
    c.drawPath(
      Path()
        ..moveTo(26, -60)
        ..lineTo(36, -70)
        ..lineTo(34, -82),
      _s,
    );
    c.drawPath(
      Path()
        ..moveTo(-40, -50)
        ..lineTo(-30, -58),
      _s,
    );
    _s.strokeWidth = 3;
    // glowing eyes
    for (final e in [const Offset(-24, -84), const Offset(4, -84)]) {
      _f.color = const Color(0x66FF9A1F);
      c.drawCircle(e, 11, _f);
      _f.color = const Color(0xFFFFC53D);
      c.drawOval(Rect.fromCenter(center: e, width: 14, height: 9), _f);
    }
    _s.strokeWidth = 4;
    c.drawLine(const Offset(-34, -98), const Offset(-14, -92), _s);
    c.drawLine(const Offset(-6, -92), const Offset(14, -98), _s);
    c.drawLine(const Offset(-24, -60), const Offset(4, -60), _s);
    _s.strokeWidth = 3;
    c.restore();
    // arms
    for (final side in [-1.0, 1.0]) {
      c.save();
      c.translate(side * 58, -88);
      c.rotate(side * 0.2 + (side < 0 ? step : -step) * 0.35);
      final arm = Rect.fromCenter(center: const Offset(0, 22), width: 30, height: 54);
      _f.color = const Color(0xFF8E8AA2);
      c.drawRRect(RRect.fromRectAndRadius(arm, const Radius.circular(14)), _f);
      c.drawRRect(RRect.fromRectAndRadius(arm, const Radius.circular(14)), _s);
      c.restore();
    }
  }

  // ----------------------------------------------------------- goblin rider
  static void _goblin(Canvas c, double phase) {
    final t = phase * math.pi * 2;
    final bounce = math.sin(t * 2).abs() * 5;
    // boar legs
    for (var i = 0; i < 4; i++) {
      final x = -40.0 + i * 24;
      final a = math.sin(t + i * 1.6) * 0.6;
      c.save();
      c.translate(x, -32);
      c.rotate(a);
      _f.color = i.isEven ? const Color(0xFF6B4026) : const Color(0xFF7E4E2F);
      final leg = RRect.fromRectAndRadius(const Rect.fromLTWH(-6, 0, 12, 30), const Radius.circular(5));
      c.drawRRect(leg, _f);
      c.drawRRect(leg, _s);
      c.restore();
    }
    c.save();
    c.translate(0, -bounce);
    // boar body
    final boar = Rect.fromCenter(center: const Offset(0, -50), width: 112, height: 50);
    _f.shader = Gradient.linear(const Offset(0, -75), const Offset(0, -25), const [Color(0xFFA9714A), Color(0xFF6E4127)]);
    c.drawOval(boar, _f);
    _f.shader = null;
    c.drawOval(boar, _s);
    // bristles
    _f.color = const Color(0xFF4E2C18);
    for (var i = 0; i < 5; i++) {
      c.drawPath(
        Path()
          ..moveTo(-20.0 + i * 12, -72)
          ..lineTo(-14.0 + i * 12, -84)
          ..lineTo(-8.0 + i * 12, -72)
          ..close(),
        _f,
      );
    }
    // boar head
    final head = Rect.fromCenter(center: const Offset(-52, -52), width: 46, height: 38);
    _f.color = const Color(0xFF9A6440);
    c.drawOval(head, _f);
    c.drawOval(head, _s);
    _f.color = const Color(0xFFE7A0A0);
    final snout = Rect.fromCenter(center: const Offset(-74, -48), width: 18, height: 16);
    c.drawOval(snout, _f);
    c.drawOval(snout, _s);
    _f.color = const Color(0xFFFFF4D6);
    c.drawPath(
      Path()
        ..moveTo(-66, -40)
        ..quadraticBezierTo(-76, -36, -80, -50)
        ..lineTo(-74, -40)
        ..close(),
      _f,
    );
    _f.color = const Color(0xFFC61F1F);
    c.drawCircle(const Offset(-56, -60), 4, _f);
    // goblin
    _f.color = const Color(0xFF5E9E3A);
    final torso = RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -104, 30, 34), const Radius.circular(10));
    _f.color = const Color(0xFF8B5A2B);
    c.drawRRect(torso, _f);
    c.drawRRect(torso, _s);
    final gHead = Rect.fromCenter(center: const Offset(6, -118), width: 34, height: 30);
    _f.color = const Color(0xFF79C24C);
    // ears
    for (final dir in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(6 + dir * 12, -122)
        ..lineTo(6 + dir * 30, -130)
        ..lineTo(6 + dir * 14, -112)
        ..close();
      c.drawPath(ear, _f);
      c.drawPath(ear, _s);
    }
    c.drawOval(gHead, _f);
    c.drawOval(gHead, _s);
    // helmet
    _f.color = const Color(0xFF9BA3B5);
    c.drawPath(
      Path()
        ..moveTo(-12, -122)
        ..quadraticBezierTo(6, -146, 24, -122)
        ..close(),
      _f,
    );
    c.drawPath(
      Path()
        ..moveTo(-12, -122)
        ..quadraticBezierTo(6, -146, 24, -122)
        ..close(),
      _s,
    );
    _eyes(c, const Offset(-2, -116), const Offset(10, -116), 8, iris: const Color(0xFFD22F2F));
    // spear
    _s
      ..strokeWidth = 4
      ..color = const Color(0xFF6B4026);
    c.drawLine(const Offset(20, -96), const Offset(-70, -92), _s);
    _s
      ..color = _ink
      ..strokeWidth = 3;
    _f.color = const Color(0xFFDDE3EE);
    final tip = Path()
      ..moveTo(-70, -98)
      ..lineTo(-88, -92)
      ..lineTo(-70, -86)
      ..close();
    c.drawPath(tip, _f);
    c.drawPath(tip, _s);
    c.restore();
  }

  // ----------------------------------------------------------- crystal golem
  /// [action]: 0 idle, 0..1 slam wind-up/strike, negative = throw.
  static void _boss(Canvas c, double phase, double action) {
    final t = phase * math.pi * 2;
    final breathe = math.sin(t) * 3;
    // legs
    for (final x in [-60.0, 50.0]) {
      final leg = RRect.fromRectAndRadius(Rect.fromLTWH(x - 28, -64, 56, 64), const Radius.circular(18));
      _f.color = const Color(0xFF5E5878);
      c.drawRRect(leg, _f);
      c.drawRRect(leg, _s);
    }
    c.save();
    c.translate(0, breathe);
    // crystals on the back
    final crystalCols = [const Color(0xFF5CF2E6), const Color(0xFFC792FF), const Color(0xFF7FB8FF)];
    for (var i = 0; i < 5; i++) {
      final x = 20.0 + i * 18;
      final h = 60.0 + (i % 3) * 22;
      final p = Path()
        ..moveTo(x - 14, -200 + i * 10)
        ..lineTo(x + 6, -200 + i * 10 - h)
        ..lineTo(x + 18, -196 + i * 10)
        ..close();
      _f.color = crystalCols[i % 3];
      c.drawPath(p, _f);
      _f.color = const Color(0x66FFFFFF);
      c.drawPath(
        Path()
          ..moveTo(x - 6, -200 + i * 10)
          ..lineTo(x + 6, -200 + i * 10 - h)
          ..lineTo(x + 2, -198 + i * 10)
          ..close(),
        _f,
      );
      c.drawPath(p, _s);
    }
    // torso
    final body = Path()
      ..moveTo(-110, -70)
      ..lineTo(-118, -170)
      ..lineTo(-70, -238)
      ..lineTo(10, -252)
      ..lineTo(90, -220)
      ..lineTo(116, -150)
      ..lineTo(100, -64)
      ..close();
    _f.shader = Gradient.linear(const Offset(0, -250), const Offset(0, -60), const [Color(0xFF9C95BD), Color(0xFF5A5478)]);
    c.drawPath(body, _f);
    _f.shader = null;
    _s.strokeWidth = 4;
    c.drawPath(body, _s);
    // glowing core
    final pulse = 0.6 + 0.4 * math.sin(t * 2);
    _f.color = Color.fromRGBO(92, 242, 230, 0.35 * pulse);
    c.drawCircle(const Offset(-6, -130), 38, _f);
    final core = Path()
      ..moveTo(-6, -162)
      ..lineTo(18, -130)
      ..lineTo(-6, -98)
      ..lineTo(-30, -130)
      ..close();
    _f.color = Color.lerp(const Color(0xFF2FD9C8), const Color(0xFFBFFFF8), pulse)!;
    c.drawPath(core, _f);
    c.drawPath(core, _s);
    // face
    for (final e in [const Offset(-70, -196), const Offset(-28, -200)]) {
      _f.color = const Color(0x88FF4FD8);
      c.drawCircle(e, 15, _f);
      _f.color = const Color(0xFFFFE1FA);
      c.drawOval(Rect.fromCenter(center: e, width: 20, height: 12), _f);
    }
    c.drawLine(const Offset(-88, -218), const Offset(-56, -208), _s);
    c.drawLine(const Offset(-42, -210), const Offset(-12, -222), _s);
    final roar = action < 0 ? (-action).clamp(0.0, 1.0) : 0.0;
    _f.color = const Color(0xFF2A1636);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-74, -176, 50, 8 + roar * 18), const Radius.circular(6)), _f);
    _f.color = const Color(0xFFFFFFFF);
    for (var i = 0; i < 4; i++) {
      c.drawPath(
        Path()
          ..moveTo(-70.0 + i * 12, -176)
          ..lineTo(-64.0 + i * 12, -168)
          ..lineTo(-58.0 + i * 12, -176)
          ..close(),
        _f,
      );
    }
    // arms: the front arm raises for slams
    final slam = action > 0 ? action : 0.0;
    final raise = slam < 0.6 ? slam / 0.6 : 1 - (slam - 0.6) / 0.4;
    for (final side in [1.0, -1.0]) {
      c.save();
      c.translate(side < 0 ? -112 : 100, -190);
      final ang = side < 0 ? (0.3 + raise * 2.4 + math.sin(t) * 0.06) : (-0.2 + math.sin(t + 1) * 0.08);
      c.rotate(ang);
      final arm = RRect.fromRectAndRadius(const Rect.fromLTWH(-26, -6, 52, 110), const Radius.circular(24));
      _f.color = side < 0 ? const Color(0xFF8D86B0) : const Color(0xFF6E688F);
      c.drawRRect(arm, _f);
      c.drawRRect(arm, _s);
      final fist = Rect.fromCenter(center: const Offset(0, 112), width: 70, height: 56);
      c.drawOval(fist, _f);
      c.drawOval(fist, _s);
      _f.color = crystalCols[0];
      c.drawPath(
        Path()
          ..moveTo(-10, 98)
          ..lineTo(0, 76)
          ..lineTo(10, 98)
          ..close(),
        _f,
      );
      c.restore();
    }
    _s.strokeWidth = 3;
    c.restore();
  }
}
