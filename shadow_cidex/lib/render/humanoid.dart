import 'dart:math' as math;
import 'dart:ui';

import '../core/utils.dart';

enum WeaponType { none, katana, dagger, axe, greatsword, claws }

/// Visual description of a shadow humanoid.
class HumanoidStyle {
  const HumanoidStyle({
    this.height = 150,
    this.bulk = 1.0,
    this.body = const Color(0xFF06070B),
    this.backTint = const Color(0xFF151A26),
    this.rim = const Color(0xFF7F9CC4),
    this.rimStrength = 0.55,
    this.eye = const Color(0xFFFF2A2A),
    this.eyeGlow = 1.0,
    this.weapon = WeaponType.katana,
    this.headband = false,
    this.bandColor = const Color(0xFF2A0508),
    this.hood = false,
    this.horns = false,
    this.cape = false,
    this.shoulderPads = false,
    this.bladeColor = const Color(0xFF9DB3CC),
    this.bladeGlow = const Color(0x00000000),
  });

  final double height;
  final double bulk;
  final Color body;
  final Color backTint;
  final Color rim;
  final double rimStrength;
  final Color eye;
  final double eyeGlow;
  final WeaponType weapon;
  final bool headband;
  final Color bandColor;
  final bool hood;
  final bool horns;
  final bool cape;
  final bool shoulderPads;
  final Color bladeColor;
  final Color bladeGlow;

  double get unit => height / 100;

  double get weaponLength {
    final u = unit;
    switch (weapon) {
      case WeaponType.katana:
        return 48 * u;
      case WeaponType.dagger:
        return 19 * u;
      case WeaponType.axe:
        return 44 * u;
      case WeaponType.greatsword:
        return 66 * u;
      case WeaponType.claws:
        return 9 * u;
      case WeaponType.none:
        return 0;
    }
  }
}

/// Joint angles. Limb angles are absolute, measured from straight down,
/// positive values rotate toward the facing direction.
class Pose {
  Pose();

  double torso = 0.06;
  double head = 0;
  double bUpper = 0.25;
  double bFore = 0.9;
  double fUpper = 0.45;
  double fFore = 1.3;
  double bThigh = -0.28;
  double bShin = -0.42;
  double fThigh = 0.32;
  double fShin = -0.02;
  double weapon = 2.3;
  double rot = 0;

  void set({
    double torso = 0.06,
    double head = 0,
    double bUpper = 0.25,
    double bFore = 0.9,
    double fUpper = 0.45,
    double fFore = 1.3,
    double bThigh = -0.28,
    double bShin = -0.42,
    double fThigh = 0.32,
    double fShin = -0.02,
    double weapon = 2.3,
    double rot = 0,
  }) {
    this.torso = torso;
    this.head = head;
    this.bUpper = bUpper;
    this.bFore = bFore;
    this.fUpper = fUpper;
    this.fFore = fFore;
    this.bThigh = bThigh;
    this.bShin = bShin;
    this.fThigh = fThigh;
    this.fShin = fShin;
    this.weapon = weapon;
    this.rot = rot;
  }

  void copyFrom(Pose o) {
    torso = o.torso;
    head = o.head;
    bUpper = o.bUpper;
    bFore = o.bFore;
    fUpper = o.fUpper;
    fFore = o.fFore;
    bThigh = o.bThigh;
    bShin = o.bShin;
    fThigh = o.fThigh;
    fShin = o.fShin;
    weapon = o.weapon;
    rot = o.rot;
  }

  /// Moves this pose toward [t] by factor [k] (0..1).
  void blend(Pose t, double k) {
    torso += (t.torso - torso) * k;
    head += (t.head - head) * k;
    bUpper += (t.bUpper - bUpper) * k;
    bFore += (t.bFore - bFore) * k;
    fUpper += (t.fUpper - fUpper) * k;
    fFore += (t.fFore - fFore) * k;
    bThigh += (t.bThigh - bThigh) * k;
    bShin += (t.bShin - bShin) * k;
    fThigh += (t.fThigh - fThigh) * k;
    fShin += (t.fShin - fShin) * k;
    weapon += (t.weapon - weapon) * k;
    rot += (t.rot - rot) * k;
  }

  // ---- Shared pose library -------------------------------------------------

  void idle(double t, {double breath = 1}) {
    final b = math.sin(t * 2.2) * 0.03 * breath;
    set(
      torso: 0.08 + b,
      head: -0.04 - b,
      bUpper: 0.35 + b,
      bFore: 1.05,
      fUpper: 0.55 + b,
      fFore: 1.45,
      bThigh: -0.3,
      bShin: -0.46 - b,
      fThigh: 0.36,
      fShin: 0.0,
      weapon: 2.35 + b,
    );
  }

  void walk(double phase, double amount, {bool run = false}) {
    final a = run ? 0.75 : 0.5;
    final s = math.sin(phase);
    final s2 = math.sin(phase + math.pi);
    final bendF = 0.1 + (run ? 0.9 : 0.55) * math.max(0, math.cos(phase));
    final bendB = 0.1 + (run ? 0.9 : 0.55) * math.max(0, math.cos(phase + math.pi));
    final bob = math.sin(phase * 2) * 0.03;
    set(
      torso: (run ? 0.26 : 0.12) + bob,
      head: run ? -0.14 : -0.06,
      bUpper: (run ? 0.1 : 0.2) + s * 0.45 * amount,
      bFore: (run ? 1.3 : 0.9) + s * 0.3 * amount,
      fUpper: run ? 0.9 : 0.6,
      fFore: run ? 1.75 : 1.5,
      fThigh: s * a * amount,
      fShin: s * a * amount - bendF * amount,
      bThigh: s2 * a * amount,
      bShin: s2 * a * amount - bendB * amount,
      weapon: run ? 1.95 : 2.2,
    );
  }

  void jump() {
    set(
      torso: 0.18,
      head: -0.1,
      bUpper: -0.4,
      bFore: 0.4,
      fUpper: 0.9,
      fFore: 1.9,
      fThigh: 1.2,
      fShin: -0.1,
      bThigh: 0.2,
      bShin: -0.9,
      weapon: 2.6,
    );
  }

  void fall() {
    set(
      torso: 0.05,
      head: 0.05,
      bUpper: -0.9,
      bFore: -0.5,
      fUpper: 1.4,
      fFore: 2.1,
      fThigh: 0.45,
      fShin: 0.1,
      bThigh: -0.35,
      bShin: -0.6,
      weapon: 2.8,
    );
  }

  void hurt() {
    set(
      torso: -0.32,
      head: -0.3,
      bUpper: -0.6,
      bFore: -0.2,
      fUpper: -0.2,
      fFore: 0.6,
      fThigh: 0.45,
      fShin: 0.1,
      bThigh: -0.15,
      bShin: -0.4,
      weapon: 1.2,
    );
  }

  /// Overhead wind-up before a strike.
  void windUp(double k) {
    set(
      torso: -0.12 * k,
      head: 0,
      bUpper: -0.2,
      bFore: 0.3,
      fUpper: lerpD(0.5, 2.7, k),
      fFore: lerpD(1.4, 3.3, k),
      fThigh: 0.45,
      fShin: 0.0,
      bThigh: -0.35,
      bShin: -0.5,
      weapon: lerpD(2.3, 3.9, k),
    );
  }

  /// Downward diagonal slash, [k] is progress 0..1.
  void slashDown(double k) {
    final e = easeOutCubic(k);
    set(
      torso: lerpD(-0.1, 0.38, e),
      head: lerpD(0, 0.1, e),
      bUpper: lerpD(-0.2, -0.7, e),
      bFore: lerpD(0.3, -0.2, e),
      fUpper: lerpD(2.6, 1.0, e),
      fFore: lerpD(3.2, 1.35, e),
      fThigh: lerpD(0.4, 0.7, e),
      fShin: lerpD(0.0, 0.2, e),
      bThigh: lerpD(-0.35, -0.55, e),
      bShin: lerpD(-0.5, -0.75, e),
      weapon: lerpD(3.9, 0.95, e),
    );
  }

  /// Rising slash.
  void slashUp(double k) {
    final e = easeOutCubic(k);
    set(
      torso: lerpD(0.35, -0.08, e),
      head: lerpD(0.1, -0.15, e),
      bUpper: lerpD(-0.6, -0.1, e),
      bFore: lerpD(-0.2, 0.5, e),
      fUpper: lerpD(0.6, 2.7, e),
      fFore: lerpD(0.9, 3.0, e),
      fThigh: lerpD(0.6, 0.35, e),
      fShin: lerpD(0.15, 0.0, e),
      bThigh: lerpD(-0.5, -0.3, e),
      bShin: lerpD(-0.7, -0.45, e),
      weapon: lerpD(0.6, 3.6, e),
    );
  }

  /// Forward thrust.
  void thrust(double k) {
    final e = easeOutCubic(k);
    set(
      torso: lerpD(0.0, 0.42, e),
      head: lerpD(0, 0.12, e),
      bUpper: lerpD(0.2, -0.9, e),
      bFore: lerpD(0.6, -0.5, e),
      fUpper: lerpD(0.9, 1.55, e),
      fFore: lerpD(1.9, 1.6, e),
      fThigh: lerpD(0.4, 0.95, e),
      fShin: lerpD(0.0, 0.35, e),
      bThigh: lerpD(-0.3, -0.7, e),
      bShin: lerpD(-0.45, -0.95, e),
      weapon: lerpD(2.0, 1.58, e),
    );
  }

  /// Horizontal sweep.
  void sweep(double k) {
    final e = easeOutCubic(k);
    set(
      torso: lerpD(-0.2, 0.3, e),
      head: 0,
      bUpper: lerpD(0.6, -0.5, e),
      bFore: lerpD(1.0, 0.0, e),
      fUpper: lerpD(-0.3, 1.7, e),
      fFore: lerpD(0.2, 1.65, e),
      fThigh: 0.55,
      fShin: 0.12,
      bThigh: -0.45,
      bShin: -0.7,
      weapon: lerpD(-0.6, 1.75, e),
    );
  }

  /// Planted pose used after a heavy smash.
  void smashImpact() {
    set(
      torso: 0.62,
      head: 0.2,
      bUpper: -0.9,
      bFore: -0.4,
      fUpper: 0.7,
      fFore: 0.55,
      fThigh: 1.15,
      fShin: 0.15,
      bThigh: -0.75,
      bShin: -1.45,
      weapon: 0.05,
    );
  }

  /// Hands resting on a sword planted in the ground (splash pose).
  void planted(double t) {
    final b = math.sin(t * 1.6) * 0.02;
    set(
      torso: 0.02 + b,
      head: 0.06,
      bUpper: 0.32,
      bFore: 0.15 - b,
      fUpper: 0.38,
      fFore: 0.05 - b,
      fThigh: 0.2,
      fShin: 0.02,
      bThigh: -0.2,
      bShin: -0.25,
      weapon: 0.0,
    );
  }

  void collapsed(double k) {
    final e = easeInCubic(k);
    set(
      torso: lerpD(0.2, 0.9, e),
      head: lerpD(0.2, 0.5, e),
      bUpper: lerpD(0.4, -0.2, e),
      bFore: lerpD(0.6, 0.2, e),
      fUpper: lerpD(0.6, 1.2, e),
      fFore: lerpD(1.0, 1.0, e),
      fThigh: lerpD(0.6, 1.5, e),
      fShin: lerpD(-0.3, -0.2, e),
      bThigh: lerpD(0.2, 1.4, e),
      bShin: lerpD(-0.8, -0.6, e),
      weapon: lerpD(1.0, 1.6, e),
      rot: 0,
    );
  }
}

/// World positions of each joint, relative to the feet origin.
class Skeleton {
  Offset hip = Offset.zero;
  Offset neck = Offset.zero;
  Offset head = Offset.zero;
  Offset shoulder = Offset.zero;
  Offset bElbow = Offset.zero;
  Offset bHand = Offset.zero;
  Offset fElbow = Offset.zero;
  Offset fHand = Offset.zero;
  Offset bKnee = Offset.zero;
  Offset bFoot = Offset.zero;
  Offset fKnee = Offset.zero;
  Offset fFoot = Offset.zero;
  Offset wBase = Offset.zero;
  Offset wTip = Offset.zero;
  Offset wDir = const Offset(0, 1);

  static Offset _dir(double a, double l) => Offset(math.sin(a) * l, math.cos(a) * l);

  void compute(Pose p, HumanoidStyle s) {
    final u = s.unit;
    final th = 24 * u;
    final sh = 24 * u;
    final dropF = math.cos(p.fThigh) * th + math.cos(p.fShin) * sh;
    final dropB = math.cos(p.bThigh) * th + math.cos(p.bShin) * sh;
    final hy = -math.max(math.max(dropF, dropB), 20 * u);
    hip = Offset(0, hy);
    fKnee = hip + _dir(p.fThigh, th);
    fFoot = fKnee + _dir(p.fShin, sh);
    bKnee = hip + _dir(p.bThigh, th);
    bFoot = bKnee + _dir(p.bShin, sh);
    final tl = 30 * u;
    neck = hip + Offset(math.sin(p.torso) * tl, -math.cos(p.torso) * tl);
    shoulder = hip + Offset(math.sin(p.torso) * tl * 0.88, -math.cos(p.torso) * tl * 0.88);
    final ha = p.torso + p.head;
    head = neck + Offset(math.sin(ha) * 7.6 * u, -math.cos(ha) * 7.6 * u);
    bElbow = shoulder + _dir(p.bUpper, 16 * u * s.bulk.clamp(1.0, 1.15));
    bHand = bElbow + _dir(p.bFore, 15 * u);
    fElbow = shoulder + _dir(p.fUpper, 16 * u * s.bulk.clamp(1.0, 1.15));
    fHand = fElbow + _dir(p.fFore, 15 * u);
    wDir = _dir(p.weapon, 1);
    wBase = fHand - wDir * (6 * u);
    wTip = fHand + wDir * s.weaponLength;
  }
}

/// Draws shadow humanoids with rim lighting, glowing eyes and weapons.
class HumanoidPainter {
  HumanoidPainter._();

  static final Paint _p = Paint()..isAntiAlias = true;
  static final Paint _s = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final Path _path = Path();

  /// Draws a humanoid with feet at the origin facing +x.
  /// [rimDx] is the local x offset of the rim light (multiply by facing).
  static void draw(
    Canvas c,
    Skeleton k,
    Pose p,
    HumanoidStyle s, {
    double time = 0,
    double alpha = 1,
    double flash = 0,
    double rimDx = 1,
    double wind = 0,
    double eyeBoost = 0,
  }) {
    if (alpha <= 0.01) return;
    final u = s.unit;
    final rimA = s.rimStrength * alpha;
    if (rimA > 0.02) {
      c.save();
      c.translate(rimDx * 1.3 * u, -1.1 * u);
      _figure(c, k, p, s, fade(s.rim, rimA), fade(s.rim, rimA * 0.7), time, wind, false);
      c.restore();
    }
    final body = Color.lerp(s.body, const Color(0xFF5A6884), flash.clamp(0.0, 1.0) * 0.6)!;
    final back = Color.lerp(Color.lerp(s.body, s.backTint, 0.55)!, const Color(0xFF5A6884), flash.clamp(0.0, 1.0) * 0.5)!;
    _figure(c, k, p, s, fade(body, alpha), fade(back, alpha), time, wind, true);
    _details(c, k, p, s, time, alpha, eyeBoost);
  }

  static void _limb(Canvas c, Offset a, Offset b, double wa, double wb, Paint paint) {
    final d = b - a;
    final len = d.distance;
    if (len < 0.001) {
      c.drawCircle(a, wa / 2, paint);
      return;
    }
    final n = Offset(-d.dy / len, d.dx / len);
    _path
      ..reset()
      ..moveTo(a.dx + n.dx * wa / 2, a.dy + n.dy * wa / 2)
      ..lineTo(b.dx + n.dx * wb / 2, b.dy + n.dy * wb / 2)
      ..lineTo(b.dx - n.dx * wb / 2, b.dy - n.dy * wb / 2)
      ..lineTo(a.dx - n.dx * wa / 2, a.dy - n.dy * wa / 2)
      ..close();
    c.drawPath(_path, paint);
    c.drawCircle(a, wa / 2, paint);
    c.drawCircle(b, wb / 2, paint);
  }

  static void _figure(Canvas c, Skeleton k, Pose p, HumanoidStyle s, Color main, Color back,
      double time, double wind, bool detailPass) {
    final u = s.unit;
    final bk = s.bulk;
    _p.color = back;
    _p.style = PaintingStyle.fill;

    // Cape behind everything.
    if (s.cape) {
      final sway = math.sin(time * 2.4) * 4 * u + wind * 6 * u;
      final sh = k.shoulder;
      _path
        ..reset()
        ..moveTo(sh.dx + 2 * u, sh.dy - 1 * u)
        ..quadraticBezierTo(sh.dx - 10 * u, sh.dy + 18 * u, sh.dx - 16 * u - sway, k.hip.dy + 36 * u)
        ..lineTo(sh.dx - 8 * u - sway * 0.6, k.hip.dy + 40 * u + math.sin(time * 3.1) * 2 * u)
        ..lineTo(sh.dx - 1 * u - sway * 0.3, k.hip.dy + 34 * u)
        ..quadraticBezierTo(sh.dx + 4 * u, sh.dy + 18 * u, sh.dx + 5 * u, sh.dy + 2 * u)
        ..close();
      c.drawPath(_path, _p);
    }

    // Back leg and arm.
    _limb(c, k.hip, k.bKnee, 10.5 * u * bk, 8 * u * bk, _p);
    _limb(c, k.bKnee, k.bFoot, 8 * u * bk, 5 * u * bk, _p);
    _foot(c, k.bFoot, u * bk, _p);
    _limb(c, k.shoulder, k.bElbow, 7 * u * bk, 5.6 * u * bk, _p);
    _limb(c, k.bElbow, k.bHand, 5.6 * u * bk, 4.2 * u * bk, _p);

    _p.color = main;
    // Torso.
    c.save();
    c.translate(k.hip.dx, k.hip.dy);
    c.rotate(p.torso);
    final tl = 30 * u;
    _path
      ..reset()
      ..moveTo(-6 * u * bk, 3 * u)
      ..lineTo(6 * u * bk, 3 * u)
      ..quadraticBezierTo(10.5 * u * bk, -tl * 0.5, 8 * u * bk, -tl * 0.92)
      ..quadraticBezierTo(4 * u, -tl * 1.05, 0, -tl * 1.04)
      ..quadraticBezierTo(-5 * u * bk, -tl * 1.02, -7.5 * u * bk, -tl * 0.85)
      ..quadraticBezierTo(-8.5 * u * bk, -tl * 0.45, -6 * u * bk, 3 * u)
      ..close();
    c.drawPath(_path, _p);
    if (s.shoulderPads) {
      c.drawOval(Rect.fromCenter(center: Offset(1 * u, -tl * 0.9), width: 20 * u * bk, height: 9 * u), _p);
    }
    c.restore();

    // Neck and head.
    _limb(c, k.neck - (k.head - k.neck) * 0.2, k.head, 5 * u * bk, 4 * u * bk, _p);
    c.drawCircle(k.head, 7 * u, _p);
    // Jaw towards the front.
    c.drawOval(Rect.fromCenter(center: k.head + Offset(2.4 * u, 2.6 * u), width: 9 * u, height: 7 * u), _p);
    if (s.hood) {
      final h = k.head;
      _path
        ..reset()
        ..moveTo(h.dx + 7.5 * u, h.dy + 4 * u)
        ..quadraticBezierTo(h.dx + 9 * u, h.dy - 9 * u, h.dx - 1 * u, h.dy - 10 * u)
        ..quadraticBezierTo(h.dx - 9 * u, h.dy - 9 * u, h.dx - 13 * u, h.dy + 2 * u)
        ..quadraticBezierTo(h.dx - 9 * u, h.dy + 10 * u, h.dx - 3 * u, h.dy + 11 * u)
        ..close();
      c.drawPath(_path, _p);
    }
    if (s.horns) {
      final h = k.head;
      _s
        ..color = main
        ..strokeWidth = 3 * u;
      _path
        ..reset()
        ..moveTo(h.dx + 2 * u, h.dy - 5 * u)
        ..quadraticBezierTo(h.dx + 9 * u, h.dy - 12 * u, h.dx + 6 * u, h.dy - 20 * u)
        ..moveTo(h.dx - 3 * u, h.dy - 5 * u)
        ..quadraticBezierTo(h.dx - 11 * u, h.dy - 11 * u, h.dx - 12 * u, h.dy - 19 * u);
      c.drawPath(_path, _s);
    }

    // Belt sash.
    if (s.headband) {
      _s
        ..color = main
        ..strokeWidth = 2.2 * u;
      final hp = k.hip + Offset(-4 * u, -2 * u);
      final w = math.sin(time * 5) * 2 * u;
      _path
        ..reset()
        ..moveTo(hp.dx, hp.dy)
        ..quadraticBezierTo(hp.dx - 6 * u, hp.dy + 6 * u, hp.dx - 9 * u - wind * 4 * u, hp.dy + 13 * u + w);
      c.drawPath(_path, _s);
    }

    // Front leg.
    _limb(c, k.hip, k.fKnee, 11 * u * bk, 8.5 * u * bk, _p);
    _limb(c, k.fKnee, k.fFoot, 8.5 * u * bk, 5.2 * u * bk, _p);
    _foot(c, k.fFoot, u * bk, _p);

    // Weapon (behind the front arm).
    _weaponShape(c, k, s, main);

    // Front arm.
    _p.color = main;
    _limb(c, k.shoulder, k.fElbow, 7.5 * u * bk, 6 * u * bk, _p);
    _limb(c, k.fElbow, k.fHand, 6 * u * bk, 4.6 * u * bk, _p);
    c.drawCircle(k.fHand, 3.4 * u * bk, _p);

    // Headband tails.
    if (s.headband) {
      final h = k.head + Offset(-5.5 * u, -2.5 * u);
      final w1 = math.sin(time * 7.0) * 2.4 * u;
      final w2 = math.sin(time * 7.0 + 1.3) * 3.2 * u;
      _s
        ..color = detailPass ? fade(s.bandColor, main.a) : main
        ..strokeWidth = 2.0 * u;
      _path
        ..reset()
        ..moveTo(h.dx, h.dy)
        ..quadraticBezierTo(h.dx - 8 * u, h.dy + w1, h.dx - 15 * u - wind * 6 * u, h.dy + 2 * u + w2)
        ..moveTo(h.dx, h.dy + 1 * u)
        ..quadraticBezierTo(h.dx - 7 * u, h.dy + 4 * u + w2, h.dx - 13 * u - wind * 5 * u, h.dy + 7 * u + w1);
      c.drawPath(_path, _s);
      if (detailPass) {
        _s.strokeWidth = 2.2 * u;
        c.drawArc(Rect.fromCircle(center: k.head, radius: 7 * u), math.pi * 1.05, math.pi * 0.9, false, _s);
      }
    }
  }

  static void _foot(Canvas c, Offset f, double u, Paint paint) {
    c.drawOval(Rect.fromLTWH(f.dx - 3 * u, f.dy - 3.2 * u, 10 * u, 4.2 * u), paint);
  }

  static void _weaponShape(Canvas c, Skeleton k, HumanoidStyle s, Color col) {
    if (s.weapon == WeaponType.none) return;
    final u = s.unit;
    c.save();
    c.translate(k.fHand.dx, k.fHand.dy);
    c.rotate(math.atan2(-k.wDir.dx, k.wDir.dy));
    _p.color = col;
    final len = s.weaponLength;
    switch (s.weapon) {
      case WeaponType.katana:
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1.4 * u, -8 * u, 2.8 * u, 11 * u), Radius.circular(u)), _p);
        c.drawOval(Rect.fromCenter(center: Offset(0, 3 * u), width: 6 * u, height: 1.8 * u), _p);
        _path
          ..reset()
          ..moveTo(-1.2 * u, 3.5 * u)
          ..lineTo(1.4 * u, 3.5 * u)
          ..quadraticBezierTo(2.6 * u, len * 0.6, 0.6 * u, len)
          ..quadraticBezierTo(-0.6 * u, len * 0.6, -1.2 * u, 3.5 * u)
          ..close();
        c.drawPath(_path, _p);
        break;
      case WeaponType.dagger:
        c.drawRect(Rect.fromLTWH(-1.2 * u, -5 * u, 2.4 * u, 7 * u), _p);
        c.drawRect(Rect.fromLTWH(-3 * u, 1.5 * u, 6 * u, 1.4 * u), _p);
        _path
          ..reset()
          ..moveTo(-1.5 * u, 3 * u)
          ..lineTo(1.5 * u, 3 * u)
          ..lineTo(0, len)
          ..close();
        c.drawPath(_path, _p);
        break;
      case WeaponType.axe:
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1.6 * u, -8 * u, 3.2 * u, len + 8 * u), Radius.circular(u)), _p);
        _path
          ..reset()
          ..moveTo(1.5 * u, len - 16 * u)
          ..quadraticBezierTo(12 * u, len - 20 * u, 15 * u, len - 24 * u)
          ..quadraticBezierTo(10 * u, len - 8 * u, 15 * u, len + 4 * u)
          ..quadraticBezierTo(10 * u, len, 1.5 * u, len - 3 * u)
          ..close()
          ..moveTo(-1.5 * u, len - 14 * u)
          ..lineTo(-7 * u, len - 11 * u)
          ..lineTo(-1.5 * u, len - 6 * u)
          ..close();
        c.drawPath(_path, _p);
        break;
      case WeaponType.greatsword:
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1.7 * u, -12 * u, 3.4 * u, 15 * u), Radius.circular(u)), _p);
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-7 * u, 2 * u, 14 * u, 2.6 * u), Radius.circular(u)), _p);
        _path
          ..reset()
          ..moveTo(-3 * u, 4.5 * u)
          ..lineTo(3 * u, 4.5 * u)
          ..lineTo(3.4 * u, len * 0.85)
          ..lineTo(0, len)
          ..lineTo(-3.4 * u, len * 0.85)
          ..close();
        c.drawPath(_path, _p);
        break;
      case WeaponType.claws:
        _s
          ..color = col
          ..strokeWidth = 1.6 * u;
        for (var i = -1; i <= 1; i++) {
          _path
            ..reset()
            ..moveTo(i * 2.0 * u, 1 * u)
            ..quadraticBezierTo(i * 3.5 * u + 2 * u, len * 0.6, i * 2.5 * u + 4 * u, len);
          c.drawPath(_path, _s);
        }
        break;
      case WeaponType.none:
        break;
    }
    c.restore();
  }

  static void _details(Canvas c, Skeleton k, Pose p, HumanoidStyle s, double time, double alpha, double eyeBoost) {
    final u = s.unit;
    // Blade edge highlight.
    if (s.weapon == WeaponType.katana || s.weapon == WeaponType.greatsword || s.weapon == WeaponType.dagger || s.weapon == WeaponType.axe) {
      final edgeStart = k.fHand + k.wDir * (s.weapon == WeaponType.axe ? s.weaponLength - 20 * u : 4 * u);
      final edgeEnd = k.wTip;
      if (s.bladeGlow.a > 0) {
        _s
          ..color = fade(s.bladeGlow, alpha * 0.35)
          ..strokeWidth = 5 * u;
        c.drawLine(edgeStart, edgeEnd, _s);
      }
      _s
        ..color = fade(s.bladeColor, alpha * 0.85)
        ..strokeWidth = 0.7 * u;
      final nrm = Offset(-k.wDir.dy, k.wDir.dx) * (0.9 * u);
      c.drawLine(edgeStart + nrm, edgeEnd, _s);
    }
    // Glowing eyes.
    final g = (s.eyeGlow + eyeBoost) * alpha * (0.85 + 0.15 * math.sin(time * 6));
    if (g > 0.02) {
      final fwd = Offset(math.sin(p.torso + p.head + math.pi / 2), -math.cos(p.torso + p.head + math.pi / 2));
      final up = Offset(math.sin(p.torso + p.head), -math.cos(p.torso + p.head));
      final e = k.head + fwd * (4.2 * u) + up * (0.6 * u);
      _p
        ..style = PaintingStyle.fill
        ..color = fade(s.eye, 0.12 * g);
      c.drawCircle(e, 7 * u, _p);
      _p.color = fade(s.eye, 0.3 * g);
      c.drawCircle(e, 3.4 * u, _p);
      _p.color = fade(Color.lerp(s.eye, const Color(0xFFFFFFFF), 0.55)!, g.clamp(0.0, 1.0));
      c.drawOval(Rect.fromCenter(center: e, width: 3.2 * u, height: 1.3 * u), _p);
      final e2 = e - fwd * (2.6 * u);
      _p.color = fade(s.eye, 0.6 * g.clamp(0.0, 1.0));
      c.drawOval(Rect.fromCenter(center: e2, width: 1.8 * u, height: 1.0 * u), _p);
    }
  }

  /// Draws a motion trail polygon for a swinging blade.
  static void drawTrail(Canvas c, List<Offset> bases, List<Offset> tips, Color color) {
    final n = math.min(bases.length, tips.length);
    if (n < 2) return;
    for (var i = 0; i < n - 1; i++) {
      final a = (i + 1) / n;
      _path
        ..reset()
        ..moveTo(bases[i].dx, bases[i].dy)
        ..lineTo(tips[i].dx, tips[i].dy)
        ..lineTo(tips[i + 1].dx, tips[i + 1].dy)
        ..lineTo(bases[i + 1].dx, bases[i + 1].dy)
        ..close();
      _p
        ..style = PaintingStyle.fill
        ..color = fade(color, a * a * 0.55);
      c.drawPath(_path, _p);
    }
  }
}
