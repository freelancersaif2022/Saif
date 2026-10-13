import 'dart:math' as math;
import 'dart:ui';

import '../models/dragon_model.dart';

/// Animation state for one rendered dragon frame.
class DragonPose {
  double time = 0;

  /// Leg cycle phase (0..1) and how much running motion is applied (0..1).
  double runPhase = 0;
  double runAmount = 0;

  /// Wing flap phase (radians) and spread (0 = folded, 1 = fully spread).
  double flapPhase = 0;
  double wingSpread = 0.25;
  double flapAmount = 0.15;

  /// 0 = eyes open, 1 = closed.
  double blink = 0;
  double mouthOpen = 0;

  /// Whole-body tilt in radians (positive = nose down).
  double tilt = 0;

  /// Vertical squash (1 = none, <1 squashed, >1 stretched).
  double squash = 1;

  /// Legs tucked for jumping / flying (0..1).
  double tuck = 0;

  /// White hit flash (0..1).
  double flash = 0;

  /// Element glow intensity (abilities, lobby selection).
  double glow = 0;
  bool dizzy = false;
  double breath = 0;

  /// Head turned slightly toward the viewer when happy (lobby reaction).
  double happy = 0;
}

/// Procedural cartoon dragon renderer.
///
/// Draws in local coordinates: origin between the feet, facing +x, ~190 units
/// from tail tip to snout and ~170 units tall with spread wings.
class DragonArt {
  DragonArt._();

  static final Paint _fill = Paint()..isAntiAlias = true;
  static final Paint _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  static Color _darken(Color c, double t) => Color.lerp(c, const Color(0xFF1A0E22), t)!;
  static Color _lighten(Color c, double t) => Color.lerp(c, const Color(0xFFFFFFFF), t)!;

  static void paint(Canvas canvas, DragonDef d, DragonPose p, {double scale = 1}) {
    canvas.save();
    canvas.scale(scale);
    if (p.flash > 0.01) {
      canvas.saveLayer(const Rect.fromLTWH(-200, -260, 420, 300), Paint());
    }
    final outline = _darken(d.bodyDark, 0.55);
    _stroke
      ..color = outline
      ..strokeWidth = 3.2;

    final breathe = math.sin(p.breath) * 0.025;
    canvas.translate(0, 0);
    canvas.scale(1 / math.sqrt(p.squash), p.squash);
    canvas.rotate(p.tilt);

    if (d.element == DragonElement.solar) _solarCorona(canvas, d, p);
    if (d.element == DragonElement.shadow) _shadowAura(canvas, d, p, behind: true);

    // far wing
    _wing(canvas, d, p, far: true, outline: outline);
    _tail(canvas, d, p, outline);
    // far legs
    _leg(canvas, d, p, hip: const Offset(-22, -34), phase: 0.5, far: true, outline: outline, back: true);
    _leg(canvas, d, p, hip: const Offset(24, -36), phase: 0.0, far: true, outline: outline, back: false);
    // body
    canvas.save();
    canvas.translate(0, -62);
    canvas.scale(1 + breathe, 1 + breathe);
    _body(canvas, d, outline);
    canvas.restore();
    _spikes(canvas, d, p, outline);
    // near legs
    _leg(canvas, d, p, hip: const Offset(-26, -32), phase: 0.0, far: false, outline: outline, back: true);
    _head(canvas, d, p, outline);
    _leg(canvas, d, p, hip: const Offset(22, -34), phase: 0.5, far: false, outline: outline, back: false);
    _wing(canvas, d, p, far: false, outline: outline);

    if (d.element == DragonElement.shadow) _shadowAura(canvas, d, p, behind: false);
    if (p.glow > 0.01) _elementGlow(canvas, d, p);

    if (p.flash > 0.01) {
      canvas.drawPaint(
        Paint()
          ..blendMode = BlendMode.srcATop
          ..color = Color.fromRGBO(255, 255, 255, (p.flash * 0.85).clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  // ------------------------------------------------------------------ body
  static void _body(Canvas c, DragonDef d, Color outline) {
    final body = Path()
      ..moveTo(-52, 4)
      ..cubicTo(-62, -30, -30, -48, 4, -44)
      ..cubicTo(38, -42, 56, -22, 50, 8)
      ..cubicTo(46, 34, 12, 42, -14, 38)
      ..cubicTo(-40, 34, -50, 22, -52, 4)
      ..close();
    _fill.shader = Gradient.radial(const Offset(-8, -26), 70, [_lighten(d.body, 0.35), d.body, d.bodyDark], const [0.0, 0.55, 1.0]);
    c.drawPath(body, _fill);
    _fill.shader = null;
    // belly plate
    final belly = Path()
      ..moveTo(-24, 30)
      ..cubicTo(-10, 12, 20, -2, 42, -6)
      ..cubicTo(50, 10, 40, 30, 14, 37)
      ..cubicTo(-2, 40, -18, 38, -24, 30)
      ..close();
    _fill.color = d.belly;
    c.drawPath(belly, _fill);
    _stroke.strokeWidth = 1.6;
    _stroke.color = _darken(d.belly, 0.25);
    for (var i = 0; i < 4; i++) {
      final t = i / 4.0;
      c.drawLine(Offset(-12 + t * 46, 33 - t * 30), Offset(-2 + t * 48, 38 - t * 28), _stroke);
    }
    _stroke
      ..strokeWidth = 3.2
      ..color = outline;
    c.drawPath(body, _stroke);
    // highlight
    _fill.color = const Color(0x55FFFFFF);
    c.drawOval(const Rect.fromLTWH(-30, -38, 34, 14), _fill);
  }

  static void _spikes(Canvas c, DragonDef d, DragonPose p, Color outline) {
    _fill.color = d.accent;
    _stroke.strokeWidth = 2.4;
    const pts = [Offset(-44, -86), Offset(-28, -100), Offset(-10, -106), Offset(8, -104)];
    for (var i = 0; i < pts.length; i++) {
      final b = pts[i];
      final s = 9.0 - i * 0.6;
      final path = Path()
        ..moveTo(b.dx - s, b.dy + 4)
        ..lineTo(b.dx - 2, b.dy - s * 1.5)
        ..lineTo(b.dx + s, b.dy + 2)
        ..close();
      c.drawPath(path, _fill);
      c.drawPath(path, _stroke);
    }
    _stroke.strokeWidth = 3.2;
  }

  // ------------------------------------------------------------------- legs
  static void _leg(
    Canvas c,
    DragonDef d,
    DragonPose p, {
    required Offset hip,
    required double phase,
    required bool far,
    required Color outline,
    required bool back,
  }) {
    final cycle = (p.runPhase + phase) * math.pi * 2;
    final swing = math.sin(cycle) * 0.75 * p.runAmount;
    final lift = math.max(0.0, math.cos(cycle)) * 10 * p.runAmount;
    final tuckAngle = p.tuck * (back ? 0.9 : -0.6);
    c.save();
    c.translate(hip.dx, hip.dy);
    c.rotate(swing + tuckAngle);
    final col = far ? _darken(d.body, 0.25) : d.body;
    final thigh = Rect.fromCenter(center: const Offset(0, 10), width: 26, height: 34);
    _fill.shader = Gradient.linear(const Offset(-10, 0), const Offset(10, 30), [_lighten(col, 0.2), col]);
    c.drawOval(thigh, _fill);
    _fill.shader = null;
    c.drawOval(thigh, _stroke);
    // foot
    final footY = 30.0 - lift * 0.4 - p.tuck * 8;
    final foot = Rect.fromCenter(center: Offset(6, footY), width: 30, height: 14);
    _fill.color = far ? _darken(d.bodyDark, 0.15) : d.bodyDark;
    c.drawOval(foot, _fill);
    c.drawOval(foot, _stroke);
    // claws
    _fill.color = d.horn;
    for (var i = 0; i < 3; i++) {
      c.drawCircle(Offset(14 + i * 4.0, footY + 3), 2.6, _fill);
    }
    c.restore();
  }

  // ------------------------------------------------------------------- tail
  static void _tail(Canvas c, DragonDef d, DragonPose p, Color outline) {
    const n = 14;
    final pts = <Offset>[];
    final widths = <double>[];
    final wave = 0.25 + 0.75 * p.runAmount;
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      final x = -40 - t * 86;
      final y = -50 + t * 6 - math.sin(t * 2.2) * 26 + math.sin(p.time * 5 - t * 4) * 9 * t * wave;
      pts.add(Offset(x, y));
      widths.add(20 * (1 - t) + 4);
    }
    final left = <Offset>[];
    final right = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final a = pts[math.max(0, i - 1)];
      final b = pts[math.min(n, i + 1)];
      final dir = b - a;
      final len = dir.distance == 0 ? 1.0 : dir.distance;
      final nx = -dir.dy / len, ny = dir.dx / len;
      final w = widths[i] / 2;
      left.add(pts[i] + Offset(nx * w, ny * w));
      right.add(pts[i] - Offset(nx * w, ny * w));
    }
    final path = Path()..moveTo(left.first.dx, left.first.dy);
    for (final o in left.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    for (final o in right.reversed) {
      path.lineTo(o.dx, o.dy);
    }
    path.close();
    _fill.shader = Gradient.linear(const Offset(0, -80), const Offset(0, -20), [d.body, d.bodyDark]);
    c.drawPath(path, _fill);
    _fill.shader = null;
    c.drawPath(path, _stroke);
    // tail tip
    final tip = pts.last;
    final prev = pts[n - 2];
    final ang = math.atan2(tip.dy - prev.dy, tip.dx - prev.dx);
    c.save();
    c.translate(tip.dx, tip.dy);
    c.rotate(ang);
    switch (d.element) {
      case DragonElement.fire:
        _flameTip(c, p.time);
      case DragonElement.water:
        final fin = Path()
          ..moveTo(0, 0)
          ..cubicTo(8, -22, 22, -20, 24, -8)
          ..cubicTo(18, -2, 18, 2, 24, 8)
          ..cubicTo(22, 20, 8, 22, 0, 0)
          ..close();
        _fill.color = d.accent;
        c.drawPath(fin, _fill);
        c.drawPath(fin, _stroke);
      case DragonElement.nature:
        _leafShape(c, const Offset(0, 0), 26, 0, d.wing, outline);
      case DragonElement.shadow:
      case DragonElement.solar:
        final spade = Path()
          ..moveTo(-2, 0)
          ..lineTo(8, -12)
          ..lineTo(26, 0)
          ..lineTo(8, 12)
          ..close();
        _fill.color = d.element == DragonElement.solar ? d.accent : d.accent;
        c.drawPath(spade, _fill);
        c.drawPath(spade, _stroke);
    }
    c.restore();
  }

  static void _flameTip(Canvas c, double t) {
    final f = 1 + math.sin(t * 18) * 0.12;
    final outer = Path()
      ..moveTo(-2, -8)
      ..cubicTo(10, -18 * f, 20, -10, 30 * f, -2)
      ..cubicTo(22, 2, 22, 6, 28 * f, 12)
      ..cubicTo(14, 14, 4, 10, -2, 8)
      ..close();
    _fill.color = const Color(0xFFFF5A1F);
    c.drawPath(outer, _fill);
    final inner = Path()
      ..moveTo(0, -4)
      ..cubicTo(8, -10, 14, -4, 20 * f, 0)
      ..cubicTo(12, 4, 8, 6, 0, 4)
      ..close();
    _fill.color = const Color(0xFFFFE066);
    c.drawPath(inner, _fill);
  }

  static void _leafShape(Canvas c, Offset at, double len, double angle, Color col, Color outline) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.45, len, 0)
      ..quadraticBezierTo(len * 0.5, len * 0.45, 0, 0)
      ..close();
    _fill.color = col;
    c.drawPath(leaf, _fill);
    final sw = _stroke.strokeWidth;
    _stroke.strokeWidth = 2;
    c.drawPath(leaf, _stroke);
    c.drawLine(Offset.zero, Offset(len * 0.85, 0), _stroke);
    _stroke.strokeWidth = sw;
    c.restore();
  }

  // ------------------------------------------------------------------- head
  static void _head(Canvas c, DragonDef d, DragonPose p, Color outline) {
    c.save();
    final bob = math.sin(p.breath) * 1.5 + math.sin(p.runPhase * math.pi * 4) * 2 * p.runAmount;
    c.translate(0, bob);
    // neck
    final neck = Path()
      ..moveTo(10, -90)
      ..cubicTo(18, -112, 40, -116, 46, -100)
      ..cubicTo(50, -84, 40, -66, 26, -58)
      ..lineTo(8, -70)
      ..close();
    _fill.color = d.body;
    c.drawPath(neck, _fill);
    _fill.color = d.belly;
    c.drawPath(
      Path()
        ..moveTo(30, -62)
        ..cubicTo(42, -72, 48, -86, 46, -98)
        ..lineTo(52, -94)
        ..cubicTo(52, -78, 44, -64, 34, -58)
        ..close(),
      _fill,
    );

    // far horn
    _horn(c, d, const Offset(36, -142), -0.5, far: true, outline: outline);

    // jaw (lower) — drawn before the head so it tucks underneath
    final mo = p.mouthOpen;
    c.save();
    c.translate(60, -102);
    c.rotate(mo * 0.45);
    final jaw = Path()
      ..moveTo(-12, 0)
      ..cubicTo(6, 16, 34, 16, 46, 6)
      ..lineTo(40, -2)
      ..close();
    _fill.color = d.bodyDark;
    c.drawPath(jaw, _fill);
    if (mo > 0.05) {
      _fill.color = const Color(0xFFB8304A);
      c.drawPath(
        Path()
          ..moveTo(-6, 0)
          ..cubicTo(8, 10, 30, 10, 40, 2)
          ..lineTo(36, -2)
          ..close(),
        _fill,
      );
    }
    c.drawPath(jaw, _stroke);
    c.restore();

    // cranium + snout
    final head = Path()
      ..moveTo(22, -116)
      ..cubicTo(18, -146, 52, -158, 72, -138)
      ..cubicTo(80, -130, 84, -124, 96, -122)
      ..cubicTo(112, -119, 116, -104, 106, -98)
      ..cubicTo(92, -92, 70, -96, 58, -98)
      ..cubicTo(40, -98, 24, -100, 22, -116)
      ..close();
    _fill.shader = Gradient.radial(const Offset(48, -136), 52, [_lighten(d.body, 0.35), d.body, d.bodyDark], const [0.0, 0.6, 1.0]);
    c.drawPath(head, _fill);
    _fill.shader = null;
    c.drawPath(head, _stroke);

    // mouth line / open mouth
    if (mo > 0.05) {
      _fill.color = const Color(0xFF7A1630);
      c.drawPath(
        Path()
          ..moveTo(58, -100)
          ..quadraticBezierTo(84, -96 + mo * 8, 104, -99)
          ..quadraticBezierTo(84, -88 + mo * 14, 58, -100)
          ..close(),
        _fill,
      );
      _fill.color = const Color(0xFFFFFFFF);
      c.drawPath(
        Path()
          ..moveTo(92, -98)
          ..lineTo(96, -91)
          ..lineTo(99, -98.5)
          ..close(),
        _fill,
      );
    } else {
      _stroke.strokeWidth = 2.4;
      c.drawPath(
        Path()
          ..moveTo(64, -101)
          ..quadraticBezierTo(84, -96 - p.happy * 4, 102, -100),
        _stroke,
      );
      _stroke.strokeWidth = 3.2;
    }

    // nostril
    _fill.color = outline;
    c.drawOval(Rect.fromCenter(center: const Offset(102, -115), width: 6, height: 4), _fill);

    // cheek blush
    _fill.color = const Color(0x55FF6F91);
    c.drawOval(Rect.fromCenter(center: const Offset(66, -110), width: 18, height: 9), _fill);

    // element crest
    switch (d.element) {
      case DragonElement.water:
        final frill = Path()
          ..moveTo(26, -126)
          ..lineTo(8, -136)
          ..lineTo(22, -112)
          ..lineTo(4, -114)
          ..lineTo(24, -100)
          ..close();
        _fill.color = d.accent;
        c.drawPath(frill, _fill);
        c.drawPath(frill, _stroke);
      case DragonElement.nature:
        _leafShape(c, const Offset(40, -150), 22, -2.2, d.wing, outline);
      default:
        break;
    }

    // eye
    _eye(c, d, p, outline);
    // near horn
    _horn(c, d, const Offset(46, -146), -0.25, far: false, outline: outline);
    c.restore();
  }

  static void _eye(Canvas c, DragonDef d, DragonPose p, Color outline) {
    const center = Offset(58, -126);
    if (p.dizzy) {
      _stroke.strokeWidth = 3;
      c.drawLine(center + const Offset(-7, -7), center + const Offset(7, 7), _stroke);
      c.drawLine(center + const Offset(-7, 7), center + const Offset(7, -7), _stroke);
      _stroke.strokeWidth = 3.2;
      return;
    }
    final open = (1 - p.blink).clamp(0.08, 1.0);
    final white = Rect.fromCenter(center: center, width: 24, height: 28 * open);
    _fill.color = const Color(0xFFFFFFFF);
    c.drawOval(white, _fill);
    _stroke.strokeWidth = 2.4;
    c.drawOval(white, _stroke);
    if (open > 0.3) {
      final glowing = d.element == DragonElement.shadow || d.element == DragonElement.solar;
      if (glowing) {
        _fill.color = d.eye.withValues(alpha: 0.45);
        c.drawCircle(center + const Offset(4, 1), 11, _fill);
      }
      _fill.color = d.eye;
      c.drawOval(Rect.fromCenter(center: center + const Offset(4, 1), width: 13, height: 16 * open), _fill);
      _fill.color = const Color(0xFF0D0A12);
      c.drawOval(Rect.fromCenter(center: center + const Offset(5, 1), width: 7, height: 10 * open), _fill);
      _fill.color = const Color(0xFFFFFFFF);
      c.drawCircle(center + const Offset(1.5, -4), 3.2, _fill);
      c.drawCircle(center + const Offset(7.5, 4), 1.4, _fill);
    }
    // brow
    _stroke.strokeWidth = 3;
    c.drawLine(center + Offset(-10, -17 + p.happy * 2), center + Offset(9, -19 - p.happy * 2), _stroke);
    _stroke.strokeWidth = 3.2;
  }

  static void _horn(Canvas c, DragonDef d, Offset base, double angle, {required bool far, required Color outline}) {
    c.save();
    c.translate(base.dx, base.dy);
    c.rotate(angle * 0.6);
    c.scale(1.2);
    final col = far ? _darken(d.horn, 0.2) : d.horn;
    Path path;
    switch (d.hornStyle) {
      case HornStyle.curved:
        path = Path()
          ..moveTo(-10, 5)
          ..cubicTo(-12, -12, -16, -24, -30, -32)
          ..cubicTo(-14, -26, 0, -14, 10, 2)
          ..close();
      case HornStyle.crystal:
        path = Path()
          ..moveTo(-7, 4)
          ..lineTo(-14, -18)
          ..lineTo(-8, -32)
          ..lineTo(0, -16)
          ..lineTo(7, 2)
          ..close();
      case HornStyle.sharp:
        path = Path()
          ..moveTo(-9, 5)
          ..cubicTo(-10, -16, -20, -32, -38, -42)
          ..cubicTo(-18, -28, 0, -12, 9, 2)
          ..close();
      case HornStyle.leafy:
        path = Path()
          ..moveTo(-9, 5)
          ..cubicTo(-10, -10, -14, -20, -24, -26)
          ..cubicTo(-8, -20, 2, -8, 9, 2)
          ..close();
      case HornStyle.crown:
        path = Path()
          ..moveTo(-8, 4)
          ..lineTo(-14, -24)
          ..lineTo(-6, -14)
          ..lineTo(-2, -34)
          ..lineTo(3, -14)
          ..lineTo(10, -22)
          ..lineTo(8, 2)
          ..close();
    }
    _fill.shader = Gradient.linear(const Offset(0, 4), const Offset(0, -34), [col, _lighten(col, 0.5)]);
    c.drawPath(path, _fill);
    _fill.shader = null;
    _stroke.strokeWidth = 2.4;
    c.drawPath(path, _stroke);
    _stroke.strokeWidth = 3.2;
    if (d.hornStyle == HornStyle.crystal || d.hornStyle == HornStyle.crown) {
      _fill.color = const Color(0x88FFFFFF);
      c.drawCircle(const Offset(-6, -14), 2.5, _fill);
    }
    c.restore();
  }

  // ------------------------------------------------------------------ wings
  static void _wing(Canvas c, DragonDef d, DragonPose p, {required bool far, required Color outline}) {
    final flap = math.sin(p.flapPhase + (far ? 0.35 : 0)) * p.flapAmount;
    final spread = p.wingSpread;
    final angle = -0.15 - spread * 0.25 + flap * 1.1;
    final sy = 0.55 + spread * 0.45;
    c.save();
    c.translate(far ? 4 : -4, far ? -96 : -92);
    c.rotate(angle);
    c.scale(far ? 1.1 : 1.25, 1.2 * sy * (1 + flap * 0.25));
    final membrane = Path()
      ..moveTo(0, 0)
      ..lineTo(-22, -58)
      ..lineTo(-78, -80)
      ..quadraticBezierTo(-74, -56, -86, -40)
      ..quadraticBezierTo(-66, -36, -66, -14)
      ..quadraticBezierTo(-46, -18, -38, 4)
      ..quadraticBezierTo(-20, -4, 0, 0)
      ..close();
    final wc = far ? _darken(d.wing, 0.25) : d.wing;
    final wd = far ? _darken(d.wingDark, 0.2) : d.wingDark;
    _fill.shader = Gradient.linear(const Offset(-20, -60), const Offset(-60, 0), [_lighten(wc, 0.15), wc, wd], const [0.0, 0.5, 1.0]);
    c.drawPath(membrane, _fill);
    _fill.shader = null;
    _stroke.strokeWidth = 2.8;
    c.drawPath(membrane, _stroke);
    // bones
    _stroke
      ..color = far ? _darken(d.bodyDark, 0.3) : d.bodyDark
      ..strokeWidth = 4.5;
    c.drawLine(Offset.zero, const Offset(-22, -58), _stroke);
    c.drawLine(const Offset(-22, -58), const Offset(-78, -80), _stroke);
    _stroke.strokeWidth = 2.5;
    c.drawLine(const Offset(-22, -58), const Offset(-86, -40), _stroke);
    c.drawLine(const Offset(-22, -58), const Offset(-66, -14), _stroke);
    c.drawLine(const Offset(-22, -58), const Offset(-38, 4), _stroke);
    _stroke
      ..color = outline
      ..strokeWidth = 3.2;
    // claw at the wing elbow
    _fill.color = d.horn;
    c.drawCircle(const Offset(-22, -60), 4, _fill);
    if (d.element == DragonElement.nature && !far) {
      _leafShape(c, const Offset(-78, -80), 18, -2.6, _lighten(d.wing, 0.2), outline);
      _leafShape(c, const Offset(-86, -40), 16, -2.9, _lighten(d.wing, 0.1), outline);
    }
    if (d.element == DragonElement.solar && !far) {
      _fill.color = const Color(0x66FFF6B0);
      c.drawPath(membrane, _fill..blendMode = BlendMode.plus);
      _fill.blendMode = BlendMode.srcOver;
    }
    c.restore();
  }

  // ---------------------------------------------------------- element fx
  static void _solarCorona(Canvas c, DragonDef d, DragonPose p) {
    c.save();
    c.translate(10, -90);
    c.rotate(p.time * 0.4);
    _fill
      ..color = const Color(0x55FFC93C)
      ..blendMode = BlendMode.srcOver;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * math.pi * 2;
      final r1 = 70.0, r2 = 100.0 + math.sin(p.time * 3 + i) * 8;
      final path = Path()
        ..moveTo(math.cos(a - 0.08) * r1, math.sin(a - 0.08) * r1)
        ..lineTo(math.cos(a) * r2, math.sin(a) * r2)
        ..lineTo(math.cos(a + 0.08) * r1, math.sin(a + 0.08) * r1)
        ..close();
      c.drawPath(path, _fill);
    }
    _fill.blendMode = BlendMode.srcOver;
    c.restore();
  }

  static void _shadowAura(Canvas c, DragonDef d, DragonPose p, {required bool behind}) {
    _fill.blendMode = BlendMode.plus;
    for (var i = 0; i < 6; i++) {
      final a = p.time * (behind ? 1.2 : -1.6) + i * 1.05;
      final r = 70 + math.sin(p.time * 2 + i) * 14;
      final pos = Offset(math.cos(a) * r * 1.2, -80 + math.sin(a) * r * 0.6);
      if ((math.sin(a) > 0) == behind) continue;
      _fill.color = d.accent.withValues(alpha: 0.35);
      c.drawCircle(pos, 5 + (i % 3) * 2.0, _fill);
    }
    _fill.blendMode = BlendMode.srcOver;
  }

  static void _elementGlow(Canvas c, DragonDef d, DragonPose p) {
    _fill
      ..shader = Gradient.radial(const Offset(10, -80), 120, [d.glow.withValues(alpha: 0.45 * p.glow), d.glow.withValues(alpha: 0)])
      ..blendMode = BlendMode.plus;
    c.drawCircle(const Offset(10, -80), 120, _fill);
    _fill
      ..shader = null
      ..blendMode = BlendMode.srcOver;
  }
}
