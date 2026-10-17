import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/genome.dart';
import '../models/element.dart';

/// Paints a fully shaded monster from its [Genome].
///
/// [t] is a looping 0..1 animation phase, [blink] 0 (open) .. 1 (closed),
/// [flash] 0..1 white hit-flash.
class MonsterPainter extends CustomPainter {
  MonsterPainter(this.g, {this.t = 0, this.blink = 0, this.flash = 0, this.shadow = true, this.facingLeft = false});

  final Genome g;
  final double t;
  final double blink;
  final double flash;
  final bool shadow;
  final bool facingLeft;

  static Color _shade(Color c, double amount) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    if (facingLeft) {
      canvas.translate(s, 0);
      canvas.scale(-1, 1);
    }

    final breath = sin(t * 2 * pi);
    final cx = s * 0.5;
    final cy = s * 0.57 + breath * s * 0.006;
    final stageScale = const [1.0, 0.86, 0.94, 1.0][g.stage];
    final r = s * 0.25 * stageScale;
    final rx = r * g.bodyWidth;
    final ry = r * g.bodyHeight * (1 + breath * 0.012);
    final groundY = cy + ry * 1.18;

    // 1. Ground shadow
    if (shadow) {
      final sp = Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, groundY + s * 0.02), width: rx * 2.1, height: s * 0.07), sp);
    }

    // 2. Aura for evolved monsters
    if (g.stage >= 2) {
      final pulse = 0.5 + 0.5 * sin(t * 2 * pi * 2);
      final ap = Paint()
        ..shader = ui.Gradient.radial(Offset(cx, cy - r * 0.1), r * (1.75 + 0.08 * pulse), [
          g.element.color.withValues(alpha: (g.stage == 3 ? 0.42 : 0.26) + 0.08 * pulse),
          g.element.color.withValues(alpha: 0),
        ]);
      canvas.drawCircle(Offset(cx, cy - r * 0.1), r * (1.75 + 0.08 * pulse), ap);
    }

    _tail(canvas, cx, cy, rx, ry, s);
    _spikes(canvas, cx, cy, rx, ry);
    _legs(canvas, cx, cy, rx, ry, groundY);

    // 3. Body
    final body = _bodyPath(cx, cy, rx, ry);
    final bodyPaint = Paint()..shader = ui.Gradient.radial(Offset(cx - rx * 0.35, cy - ry * 0.45), max(rx, ry) * 1.6, [_shade(g.skin, 0.2), g.skin, g.skinDark], [0.0, 0.45, 1.0]);
    canvas.drawPath(body, bodyPaint);

    canvas.save();
    canvas.clipPath(body);
    _pattern(canvas, cx, cy, rx, ry);
    // Belly
    final bellyRect = Rect.fromCenter(center: Offset(cx, cy + ry * 0.42), width: rx * 1.05, height: ry * 1.0);
    canvas.drawOval(bellyRect, Paint()..shader = ui.Gradient.radial(bellyRect.center - Offset(0, ry * 0.15), bellyRect.width * 0.6, [g.belly, _shade(g.belly, -0.18).withValues(alpha: 0.85)]));
    // Belly plates
    final plate = Paint()
      ..color = _shade(g.belly, -0.28).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025;
    for (var i = 1; i <= 3; i++) {
      final y = bellyRect.top + bellyRect.height * (0.25 + i * 0.16);
      final w = bellyRect.width * (0.42 - (i - 2).abs() * 0.04);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, y - r * 0.08), width: w * 2, height: r * 0.2), 0.2, pi - 0.4, false, plate);
    }
    // Bottom occlusion shading
    canvas.drawRect(
      Rect.fromLTRB(cx - rx * 1.2, cy - ry * 1.2, cx + rx * 1.2, cy + ry * 1.2),
      Paint()..shader = ui.Gradient.linear(Offset(cx, cy), Offset(cx, cy + ry * 1.1), [Colors.transparent, Colors.black.withValues(alpha: 0.38)]),
    );
    // Specular highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - rx * 0.42, cy - ry * 0.55), width: rx * 0.5, height: ry * 0.26),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
    );
    canvas.restore();

    // Rim light
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..shader = ui.Gradient.linear(Offset(cx + rx, cy - ry), Offset(cx - rx, cy + ry), [g.element.color.withValues(alpha: 0.85), Colors.transparent]),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.018
        ..color = g.skinDark.withValues(alpha: 0.9),
    );

    _arms(canvas, cx, cy, rx, ry);
    if (g.ears) _ears(canvas, cx, cy, rx, ry);
    _horns(canvas, cx, cy, rx, ry, r);
    if (g.stage >= 2) _chestGem(canvas, cx, cy, ry, r);
    canvas.save();
    canvas.clipPath(body);
    _eyes(canvas, cx, cy, rx, ry, r);
    canvas.restore();
    _mouth(canvas, cx, cy, rx, ry, r);
    _elementFx(canvas, cx, cy, rx, ry, r, s);

    if (flash > 0) {
      canvas.drawPath(body, Paint()..color = Colors.white.withValues(alpha: 0.75 * flash));
    }
    canvas.restore();
  }

  Path _bodyPath(double cx, double cy, double rx, double ry) {
    final p = Path();
    const steps = 72;
    for (var i = 0; i <= steps; i++) {
      final a = i / steps * 2 * pi;
      final wobble = 1 + g.lobeDepth * sin(g.lobes * a + g.lobePhase);
      // Wider "shoulders", slightly flatter base: reads as a creature, not a ball.
      final shoulder = 1 + 0.035 * pow(sin(a * 2).abs(), 2) * (sin(a) < 0 ? 1 : 0.3);
      final base = sin(a) > 0 ? 1.0 + 0.06 * sin(a) : 1.0;
      final x = cx + rx * cos(a) * wobble * shoulder;
      final y = cy + ry * sin(a) * wobble * base;
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    return p..close();
  }

  void _pattern(Canvas canvas, double cx, double cy, double rx, double ry) {
    final rnd = Random(g.lobes * 1000 + (g.lobePhase * 1000).round());
    final paint = Paint()..color = g.skinDark.withValues(alpha: 0.35);
    switch (g.pattern) {
      case 1: // spots
        for (var i = 0; i < 9; i++) {
          final a = rnd.nextDouble() * 2 * pi;
          final d = 0.45 + rnd.nextDouble() * 0.5;
          final o = Offset(cx + cos(a) * rx * d, cy + sin(a) * ry * d - ry * 0.15);
          canvas.drawCircle(o, rx * (0.05 + rnd.nextDouble() * 0.07), paint);
        }
      case 2: // stripes
        paint
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = rx * 0.07;
        for (var i = -2; i <= 2; i++) {
          final x = cx + i * rx * 0.36;
          final path = Path()
            ..moveTo(x - rx * 0.1, cy - ry * 1.1)
            ..quadraticBezierTo(x + rx * 0.12, cy - ry * 0.7, x, cy - ry * 0.35);
          canvas.drawPath(path, paint);
        }
      case 3: // scales
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = rx * 0.018;
        for (var row = 0; row < 4; row++) {
          for (var col = -4; col <= 4; col++) {
            final o = Offset(cx + col * rx * 0.22 + (row.isOdd ? rx * 0.11 : 0), cy - ry * 0.9 + row * ry * 0.17);
            canvas.drawArc(Rect.fromCircle(center: o, radius: rx * 0.11), 0, pi, false, paint);
          }
        }
      default:
        break;
    }
  }

  void _tail(Canvas canvas, double cx, double cy, double rx, double ry, double s) {
    final sway = sin(t * 2 * pi) * 0.12;
    final p0 = Offset(cx + rx * 0.55, cy + ry * 0.55);
    final p1 = Offset(cx + rx * (1.35 + g.tailLength * 0.2), cy + ry * (0.9 + sway));
    final p2 = Offset(cx + rx * (1.15 + g.tailLength * 0.45), cy - ry * (0.15 + g.tailLength * 0.35 + sway));
    const n = 26;
    Offset q(double u) {
      final a = Offset.lerp(p0, p1, u)!;
      final b = Offset.lerp(p1, p2, u)!;
      return Offset.lerp(a, b, u)!;
    }

    final left = <Offset>[];
    final right = <Offset>[];
    for (var i = 0; i < n; i++) {
      final u = i / (n - 1);
      final w = rx * (0.22 * (1 - u) + 0.03);
      final c = q(u);
      final d = q(min(1, u + 0.02)) - q(max(0, u - 0.02));
      final nrm = Offset(-d.dy, d.dx) / max(0.0001, d.distance);
      left.add(c + nrm * w);
      right.add(c - nrm * w);
    }
    final tail = Path()..moveTo(left.first.dx, left.first.dy);
    for (final p in left.skip(1)) {
      tail.lineTo(p.dx, p.dy);
    }
    for (final p in right.reversed) {
      tail.lineTo(p.dx, p.dy);
    }
    tail.close();
    canvas.drawPath(tail, Paint()..shader = ui.Gradient.linear(p0, p2, [g.skinDark, g.skin, _shade(g.skin, -0.08)], const [0.0, 0.55, 1.0]));
    final ridge = Paint()
      ..color = g.skinDark.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = rx * 0.02
      ..strokeCap = StrokeCap.round;
    for (var i = 4; i < n - 3; i += 4) {
      canvas.drawLine(Offset.lerp(left[i], right[i], 0.15)!, Offset.lerp(left[i], right[i], 0.85)!, ridge);
    }
    canvas.drawPath(
      tail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rx * 0.018
        ..color = g.skinDark,
    );
    // Tail tip spike
    final tip = q(1);
    final dir = (tip - q(0.9));
    final dn = dir / dir.distance;
    final perp = Offset(-dn.dy, dn.dx);
    final spike = Path()
      ..moveTo(tip.dx + perp.dx * rx * 0.1, tip.dy + perp.dy * rx * 0.1)
      ..lineTo(tip.dx + dn.dx * rx * 0.3, tip.dy + dn.dy * rx * 0.3)
      ..lineTo(tip.dx - perp.dx * rx * 0.1, tip.dy - perp.dy * rx * 0.1)
      ..close();
    canvas.drawPath(spike, Paint()..shader = ui.Gradient.linear(tip, tip + dn * rx * 0.3, [g.accent, _shade(g.accent, 0.25)]));
  }

  void _spikes(Canvas canvas, double cx, double cy, double rx, double ry) {
    final n = g.spikes.clamp(0, 11);
    if (n == 0) return;
    for (var i = 0; i < n; i++) {
      final u = n == 1 ? 0.5 : i / (n - 1);
      final a = -pi + 0.55 + u * (pi - 1.1); // across the back/top
      final baseL = Offset(cx + cos(a - 0.11) * rx * 0.96, cy + sin(a - 0.11) * ry * 0.96);
      final baseR = Offset(cx + cos(a + 0.11) * rx * 0.96, cy + sin(a + 0.11) * ry * 0.96);
      final len = (0.22 + 0.14 * sin(u * pi)) * ry * (1 + (g.stage - 1) * 0.15);
      final tip = Offset(cx + cos(a) * (rx + len), cy + sin(a) * (ry + len));
      final path = Path()
        ..moveTo(baseL.dx, baseL.dy)
        ..quadraticBezierTo((baseL.dx + tip.dx) / 2 - 2, (baseL.dy + tip.dy) / 2, tip.dx, tip.dy)
        ..lineTo(baseR.dx, baseR.dy)
        ..close();
      canvas.drawPath(path, Paint()..shader = ui.Gradient.linear(Offset.lerp(baseL, baseR, 0.5)!, tip, [g.skinDark, g.accent, _shade(g.accent, 0.3)], [0, 0.6, 1]));
    }
  }

  void _legs(Canvas canvas, double cx, double cy, double rx, double ry, double groundY) {
    for (final side in [-1.0, 1.0]) {
      final lx = cx + side * rx * 0.5;
      final rect = Rect.fromLTRB(lx - rx * 0.24, cy + ry * 0.55, lx + rx * 0.24, groundY);
      final leg = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(rx * 0.2),
        topRight: Radius.circular(rx * 0.2),
        bottomLeft: Radius.circular(rx * 0.12),
        bottomRight: Radius.circular(rx * 0.12),
      );
      canvas.drawRRect(leg, Paint()..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [g.skin, g.skinDark]));
      // Toe claws
      for (var k = -1; k <= 1; k++) {
        final bx = lx + k * rx * 0.13;
        final claw = Path()
          ..moveTo(bx - rx * 0.05, groundY - rx * 0.02)
          ..quadraticBezierTo(bx, groundY + rx * 0.09, bx + rx * 0.06, groundY + rx * 0.03)
          ..close();
        canvas.drawPath(claw, Paint()..color = const Color(0xFFF2EBDD));
      }
    }
  }

  void _arms(Canvas canvas, double cx, double cy, double rx, double ry) {
    final wave = sin(t * 2 * pi + 1) * 0.08;
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      final shoulder = Offset(cx + side * rx * 0.94, cy + ry * 0.02);
      canvas.translate(shoulder.dx, shoulder.dy);
      canvas.rotate(side * (0.75 + wave));
      final w = rx * 0.22 * g.armSize;
      final h = ry * 0.62 * g.armSize;
      final arm = RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2, 0, w, h), Radius.circular(w / 2));
      canvas.drawRRect(arm, Paint()..shader = ui.Gradient.linear(Offset(-w / 2, 0), Offset(w / 2, h), [_shade(g.skin, 0.06), g.skinDark]));
      canvas.drawRRect(
        arm,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rx * 0.015
          ..color = g.skinDark,
      );
      for (var k = -1; k <= 1; k++) {
        final claw = Path()
          ..moveTo(k * w * 0.28 - w * 0.08, h - w * 0.1)
          ..lineTo(k * w * 0.32, h + w * 0.42)
          ..lineTo(k * w * 0.28 + w * 0.1, h - w * 0.1)
          ..close();
        canvas.drawPath(claw, Paint()..color = const Color(0xFFF4EEE2));
      }
      canvas.restore();
    }
  }

  void _ears(Canvas canvas, double cx, double cy, double rx, double ry) {
    for (final side in [-1.0, 1.0]) {
      final base = Offset(cx + side * rx * 0.72, cy - ry * 0.62);
      final ear = Path()
        ..moveTo(base.dx - side * rx * 0.15, base.dy + ry * 0.05)
        ..quadraticBezierTo(base.dx + side * rx * 0.45, base.dy - ry * 0.15, base.dx + side * rx * 0.55, base.dy - ry * 0.55)
        ..quadraticBezierTo(base.dx + side * rx * 0.05, base.dy - ry * 0.25, base.dx + side * rx * 0.1, base.dy + ry * 0.12)
        ..close();
      canvas.drawPath(ear, Paint()..shader = ui.Gradient.linear(base, base + Offset(side * rx * 0.5, -ry * 0.5), [g.skin, g.accent]));
    }
  }

  void _horns(Canvas canvas, double cx, double cy, double rx, double ry, double r) {
    if (g.hornType == 0) return;
    const bone = [Color(0xFFFFF6E5), Color(0xFFD9C6A3), Color(0xFF8C7556)];
    final len = r * 0.55 * g.hornLength;
    for (final side in [-1.0, 1.0]) {
      final base = Offset(cx + side * rx * 0.42, cy - ry * 0.86);
      final paint = Paint()..shader = ui.Gradient.linear(base, base + Offset(side * len * 0.6, -len), bone.reversed.toList(), const [0.0, 0.5, 1.0]);
      switch (g.hornType) {
        case 1: // curved ram/demon horn
          final p = Path()
            ..moveTo(base.dx - side * r * 0.1, base.dy + r * 0.06)
            ..cubicTo(base.dx + side * len * 0.2, base.dy - len * 0.7, base.dx + side * len * 0.9, base.dy - len * 0.9, base.dx + side * len * 1.0, base.dy - len * 0.35)
            ..cubicTo(base.dx + side * len * 0.75, base.dy - len * 0.65, base.dx + side * len * 0.3, base.dy - len * 0.4, base.dx + side * r * 0.12, base.dy + r * 0.05)
            ..close();
          canvas.drawPath(p, paint);
          // ridges
          final ridge = Paint()
            ..color = bone[2].withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.012;
          for (var i = 1; i <= 3; i++) {
            final u = i / 4;
            final c = Offset(base.dx + side * len * (0.15 + u * 0.55), base.dy - len * (0.25 + u * 0.4));
            canvas.drawLine(c - Offset(side * r * 0.04, -r * 0.05), c + Offset(side * r * 0.05, -r * 0.03), ridge);
          }
        case 2: // straight spike horn
          final p = Path()
            ..moveTo(base.dx - r * 0.09, base.dy + r * 0.05)
            ..quadraticBezierTo(base.dx + side * len * 0.1, base.dy - len * 0.6, base.dx + side * len * 0.35, base.dy - len * 1.15)
            ..quadraticBezierTo(base.dx + side * len * 0.25, base.dy - len * 0.5, base.dx + r * 0.09, base.dy + r * 0.05)
            ..close();
          canvas.drawPath(p, paint);
        case 3: // antlers
          final st = Paint()
            ..shader = paint.shader
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = r * 0.07;
          final top = base + Offset(side * len * 0.45, -len * 1.0);
          canvas.drawLine(base, top, st);
          st.strokeWidth = r * 0.05;
          canvas.drawLine(Offset.lerp(base, top, 0.45)!, Offset.lerp(base, top, 0.45)! + Offset(side * len * 0.45, -len * 0.15), st);
          canvas.drawLine(Offset.lerp(base, top, 0.75)!, Offset.lerp(base, top, 0.75)! + Offset(-side * len * 0.15, -len * 0.35), st);
      }
    }
  }

  void _chestGem(Canvas canvas, double cx, double cy, double ry, double r) {
    final c = Offset(cx, cy + ry * 0.12);
    final glow = 0.6 + 0.4 * sin(t * 2 * pi * 2);
    canvas.drawCircle(
      c,
      r * 0.16,
      Paint()
        ..color = g.element.color.withValues(alpha: 0.5 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );
    final gem = Path()
      ..moveTo(c.dx, c.dy - r * 0.1)
      ..lineTo(c.dx + r * 0.075, c.dy)
      ..lineTo(c.dx, c.dy + r * 0.1)
      ..lineTo(c.dx - r * 0.075, c.dy)
      ..close();
    canvas.drawPath(gem, Paint()..shader = ui.Gradient.linear(c - Offset(0, r * 0.1), c + Offset(0, r * 0.1), [Colors.white, g.element.color, g.element.deep], const [0.0, 0.5, 1.0]));
  }

  List<Offset> _eyeOffsets(double cx, double ey, double rx) {
    final sp = rx * 0.36;
    return switch (g.eyeCount) {
      1 => [Offset(cx, ey)],
      2 => [Offset(cx - sp, ey), Offset(cx + sp, ey)],
      3 => [Offset(cx - sp * 1.1, ey + rx * 0.03), Offset(cx, ey - rx * 0.12), Offset(cx + sp * 1.1, ey + rx * 0.03)],
      _ => [Offset(cx - sp, ey), Offset(cx + sp, ey), Offset(cx - sp * 0.7, ey - rx * 0.24), Offset(cx + sp * 0.7, ey - rx * 0.24)],
    };
  }

  void _eyes(Canvas canvas, double cx, double cy, double rx, double ry, double r) {
    final ey = cy - ry * 0.32;
    final positions = _eyeOffsets(cx, ey, rx);
    for (var i = 0; i < positions.length; i++) {
      final o = positions[i];
      final small = g.eyeCount == 4 && i >= 2;
      final er = r * (g.eyeCount == 1 ? 0.27 : 0.17) * g.eyeSize * (small ? 0.7 : 1);
      // Socket shadow
      canvas.drawCircle(o + Offset(0, er * 0.12), er * 1.2, Paint()..color = g.skinDark.withValues(alpha: 0.7));
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.scale(1, max(0.08, 1 - blink));
      // Sclera
      canvas.drawCircle(Offset.zero, er, Paint()..shader = ui.Gradient.radial(Offset(-er * 0.3, -er * 0.3), er * 1.3, [Colors.white, const Color(0xFFE6E1D6), const Color(0xFFB8AF9F)], [0, 0.6, 1]));
      // Iris glow
      final irisR = er * 0.62;
      final look = Offset(er * 0.12, er * 0.05);
      canvas.drawCircle(
        look,
        irisR * 1.15,
        Paint()
          ..color = g.eyeGlow.withValues(alpha: 0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, er * 0.15),
      );
      canvas.drawCircle(look, irisR, Paint()..shader = ui.Gradient.radial(look, irisR, [_shade(g.eyeGlow, 0.2), g.eyeGlow, _shade(g.eyeGlow, -0.3)], [0, 0.55, 1]));
      // Slit pupil
      canvas.drawOval(Rect.fromCenter(center: look, width: irisR * 0.38, height: irisR * 1.55), Paint()..color = const Color(0xFF0B0710));
      // Highlights
      canvas.drawCircle(look + Offset(-irisR * 0.45, -irisR * 0.5), er * 0.17, Paint()..color = Colors.white.withValues(alpha: 0.95));
      canvas.drawCircle(look + Offset(irisR * 0.35, irisR * 0.45), er * 0.07, Paint()..color = Colors.white.withValues(alpha: 0.7));
      canvas.restore();
      // Upper lid (gives an intense, predatory look)
      final lidSlant = (o.dx < cx ? 1 : (o.dx > cx ? -1 : 0)) * er * 0.35;
      final lid = Path()
        ..moveTo(o.dx - er * 1.25, o.dy - er * 0.55 - lidSlant)
        ..quadraticBezierTo(o.dx, o.dy - er * 1.45, o.dx + er * 1.25, o.dy - er * 0.55 + lidSlant)
        ..lineTo(o.dx + er * 1.25, o.dy - er * 1.4)
        ..lineTo(o.dx - er * 1.25, o.dy - er * 1.4)
        ..close();
      canvas.drawPath(lid, Paint()..shader = ui.Gradient.linear(o - Offset(0, er * 1.4), o - Offset(0, er * 0.5), [g.skin.withValues(alpha: 0), g.skinDark]));
      // Brow ridge
      canvas.drawLine(
        Offset(o.dx - er * 1.15, o.dy - er * 0.7 - lidSlant * 1.3),
        Offset(o.dx + er * 1.15, o.dy - er * 0.7 + lidSlant * 1.3),
        Paint()
          ..color = g.skinDark
          ..strokeWidth = er * 0.28
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _mouth(Canvas canvas, double cx, double cy, double rx, double ry, double r) {
    final open = 0.5 + 0.5 * (0.5 + 0.5 * sin(t * 2 * pi));
    final mw = rx * 0.62 * g.mouthWidth;
    final my = cy + ry * 0.12;
    final mh = ry * (0.22 + 0.08 * open);
    final mouth = Path()
      ..moveTo(cx - mw, my - mh * 0.15)
      ..quadraticBezierTo(cx, my + mh * 0.35, cx + mw, my - mh * 0.15)
      ..quadraticBezierTo(cx + mw * 0.6, my + mh * 1.3, cx, my + mh * 1.35)
      ..quadraticBezierTo(cx - mw * 0.6, my + mh * 1.3, cx - mw, my - mh * 0.15)
      ..close();
    canvas.drawPath(mouth, Paint()..shader = ui.Gradient.linear(Offset(cx, my), Offset(cx, my + mh * 1.3), [const Color(0xFF2A0610), const Color(0xFF5E0F1E)]));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + mw * 0.1, my + mh * 1.2), width: mw * 0.9, height: mh * 0.8), Paint()..color = const Color(0xFFE0546E));
    canvas.restore();
    // Fangs
    final fangPaint = Paint()..shader = ui.Gradient.linear(Offset(cx, my), Offset(cx, my + mh), [Colors.white, const Color(0xFFE8DFCB)]);
    final n = g.fangs;
    for (var i = 0; i < n; i++) {
      final u = n == 1 ? 0.5 : i / (n - 1);
      final x = cx - mw * 0.62 + u * mw * 1.24;
      final topY = my - mh * 0.15 + (mh * 0.5) * (1 - pow((x - cx) / mw, 2)).toDouble() * 0.45;
      final big = i == 0 || i == n - 1;
      final fl = mh * (big ? 0.75 : 0.42);
      final fw = mw * (big ? 0.13 : 0.09);
      final f = Path()
        ..moveTo(x - fw, topY)
        ..quadraticBezierTo(x - fw * 0.2, topY + fl * 0.7, x, topY + fl)
        ..quadraticBezierTo(x + fw * 0.2, topY + fl * 0.7, x + fw, topY)
        ..close();
      canvas.drawPath(f, fangPaint);
    }
    // Lower tusks
    for (final side in [-1.0, 1.0]) {
      final x = cx + side * mw * 0.45;
      final by = my + mh * 1.2;
      final f = Path()
        ..moveTo(x - mw * 0.08, by)
        ..lineTo(x + side * mw * 0.04, by - mh * 0.55)
        ..lineTo(x + mw * 0.08, by)
        ..close();
      canvas.drawPath(f, fangPaint);
    }
    // Lip line
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.02
        ..color = g.skinDark,
    );
  }

  void _elementFx(Canvas canvas, double cx, double cy, double rx, double ry, double r, double s) {
    final rnd = Random(g.element.index * 31 + g.stage);
    switch (g.element) {
      case BeastElement.inferno:
        for (var i = 0; i < 3 + g.stage; i++) {
          final u = (i + 0.5) / (3 + g.stage);
          final a = -pi + 0.7 + u * (pi - 1.4);
          final flick = sin(t * 2 * pi * 3 + i * 1.7);
          final base = Offset(cx + cos(a) * rx * 0.92, cy + sin(a) * ry * 0.92);
          final h = r * (0.32 + 0.08 * flick);
          final f = Path()
            ..moveTo(base.dx - r * 0.09, base.dy)
            ..quadraticBezierTo(base.dx - r * 0.12, base.dy - h * 0.6, base.dx + flick * r * 0.04, base.dy - h)
            ..quadraticBezierTo(base.dx + r * 0.12, base.dy - h * 0.6, base.dx + r * 0.09, base.dy)
            ..close();
          canvas.drawPath(
            f,
            Paint()
              ..shader = ui.Gradient.linear(base, base - Offset(0, h), const [Color(0xFFFF3D00), Color(0xFFFF9100), Color(0xFFFFE57F)], [0, 0.5, 1])
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.012),
          );
        }
        _embers(canvas, cx, cy, r, const Color(0xFFFFA726), rnd);
      case BeastElement.frost:
        for (final side in [-1.0, 1.0]) {
          for (var k = 0; k < 2 + g.stage; k++) {
            final base = Offset(cx + side * rx * (0.65 + k * 0.1), cy - ry * (0.55 - k * 0.12));
            final len = r * (0.2 + rnd.nextDouble() * 0.16);
            final ang = -pi / 2 + side * (0.5 + k * 0.25);
            final tip = base + Offset(cos(ang), sin(ang)) * len;
            final perp = Offset(-sin(ang), cos(ang)) * r * 0.045;
            final shard = Path()
              ..moveTo(base.dx + perp.dx, base.dy + perp.dy)
              ..lineTo(tip.dx, tip.dy)
              ..lineTo(base.dx - perp.dx, base.dy - perp.dy)
              ..close();
            canvas.drawPath(shard, Paint()..shader = ui.Gradient.linear(base, tip, [const Color(0xFF7FD6FF), Colors.white.withValues(alpha: 0.95)]));
          }
        }
        _embers(canvas, cx, cy, r, Colors.white, rnd);
      case BeastElement.storm:
        final p = Paint()
          ..color = const Color(0xFFFFF59D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.025
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.solid, r * 0.02);
        final phase = (t * 6).floor();
        for (var i = 0; i < 2 + g.stage; i++) {
          if ((phase + i) % 3 == 0) continue;
          final a = rnd.nextDouble() * 2 * pi;
          var o = Offset(cx + cos(a) * rx * 1.05, cy + sin(a) * ry * 1.05);
          final bolt = Path()..moveTo(o.dx, o.dy);
          for (var k = 0; k < 4; k++) {
            o += Offset(cos(a) * r * 0.08 + (rnd.nextDouble() - 0.5) * r * 0.12, sin(a) * r * 0.08 + (rnd.nextDouble() - 0.5) * r * 0.12);
            bolt.lineTo(o.dx, o.dy);
          }
          canvas.drawPath(bolt, p);
        }
      case BeastElement.tide:
        // Dorsal fin + bubbles
        final fin = Path()
          ..moveTo(cx - rx * 0.25, cy - ry * 0.95)
          ..quadraticBezierTo(cx + rx * 0.05, cy - ry * 1.7, cx + rx * 0.35, cy - ry * 1.55)
          ..quadraticBezierTo(cx + rx * 0.2, cy - ry * 1.2, cx + rx * 0.3, cy - ry * 0.93)
          ..close();
        canvas.drawPath(fin, Paint()..shader = ui.Gradient.linear(Offset(cx, cy - ry), Offset(cx, cy - ry * 1.6), [g.skinDark, g.accent.withValues(alpha: 0.9)]));
        for (var i = 0; i < 6; i++) {
          final u = (t + i / 6) % 1.0;
          final x = cx + (rnd.nextDouble() - 0.5) * rx * 2.4;
          final y = cy + ry * 0.6 - u * ry * 2.2;
          canvas.drawCircle(
            Offset(x, y),
            r * (0.025 + rnd.nextDouble() * 0.03),
            Paint()
              ..color = const Color(0xFFB3F0FF).withValues(alpha: 0.6 * (1 - u))
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.012,
          );
        }
      case BeastElement.terra:
        for (final side in [-1.0, 1.0]) {
          final c = Offset(cx + side * rx * 0.9, cy - ry * 0.22);
          final rock = Path();
          for (var k = 0; k < 6; k++) {
            final a = k / 6 * 2 * pi;
            final rr = r * (0.16 + rnd.nextDouble() * 0.06) * (1 + (g.stage - 1) * 0.15);
            final pt = c + Offset(cos(a) * rr, sin(a) * rr * 0.75);
            k == 0 ? rock.moveTo(pt.dx, pt.dy) : rock.lineTo(pt.dx, pt.dy);
          }
          rock.close();
          canvas.drawPath(rock, Paint()..shader = ui.Gradient.linear(c - Offset(r * 0.15, r * 0.15), c + Offset(r * 0.15, r * 0.15), [const Color(0xFFB7AA92), const Color(0xFF5B4E3C)]));
          canvas.drawPath(
            rock,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.012
              ..color = const Color(0xFF3B3226),
          );
        }
      case BeastElement.shadow:
        for (var i = 0; i < 5 + g.stage * 2; i++) {
          final u = (t * 0.7 + i / (5 + g.stage * 2)) % 1.0;
          final x = cx + (rnd.nextDouble() - 0.5) * rx * 2.2 + sin(u * 6 + i) * r * 0.08;
          final y = cy + ry * 0.3 - u * ry * 1.9;
          canvas.drawCircle(
            Offset(x, y),
            r * (0.08 + 0.08 * u),
            Paint()
              ..color = const Color(0xFF6A1BFF).withValues(alpha: 0.28 * (1 - u))
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
          );
        }
    }
  }

  void _embers(Canvas canvas, double cx, double cy, double r, Color c, Random rnd) {
    for (var i = 0; i < 6; i++) {
      final u = (t + i / 6) % 1.0;
      final x = cx + (rnd.nextDouble() - 0.5) * r * 2.6;
      final y = cy - u * r * 2.2;
      canvas.drawCircle(Offset(x, y), r * 0.02 * (1 - u) + 0.6, Paint()..color = c.withValues(alpha: 0.8 * (1 - u)));
    }
  }

  @override
  bool shouldRepaint(covariant MonsterPainter old) => old.g != g || old.t != t || old.blink != blink || old.flash != flash || old.facingLeft != facingLeft;
}
