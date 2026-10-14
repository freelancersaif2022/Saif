import 'dart:math' as math;
import 'dart:ui';

import '../core/utils.dart';

enum WeaponType { none, katana, dagger, axe, greatsword, claws, bow }

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
    this.hakama = false,
    this.armor = false,
    this.helmet = false,
    this.topknot = false,
    this.mask = false,
    this.scarf = false,
    this.saya = false,
    this.veins = const Color(0x00000000),
    this.detail = const Color(0x40A8C0E0),
    this.skeleton = false,
    this.crown = false,
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

  /// Wide samurai trousers.
  final bool hakama;

  /// Layered samurai armour plates (sode, kusazuri, chest plate).
  final bool armor;

  /// Kabuto helmet with crest.
  final bool helmet;
  final bool topknot;

  /// Cloth face mask (ninja).
  final bool mask;

  /// Long flowing neck scarf (needs cloth from a [HumanoidRig]).
  final bool scarf;

  /// Scabbard worn on the hip.
  final bool saya;

  /// Glowing energy veins (transparent = none).
  final Color veins;

  /// Inner highlight line colour (lapels, plate edges).
  final Color detail;

  /// Draws bones instead of a fleshed body.
  final bool skeleton;

  /// Spiked bone crown (skeleton king).
  final bool crown;

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
      case WeaponType.bow:
        return 40 * u;
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

  /// Relaxed stance with the sword in its scabbard, left hand on the saya.
  void sheathedIdle(double t) {
    final b = math.sin(t * 2.0) * 0.025;
    set(
      torso: 0.05 + b,
      head: -0.02 - b,
      bUpper: -0.05 + b,
      bFore: 1.25,
      fUpper: 0.14 + b * 0.5,
      fFore: 0.32,
      bThigh: -0.2,
      bShin: -0.3 - b,
      fThigh: 0.24,
      fShin: 0.02,
      weapon: 2.3,
    );
  }

  /// Low ninja sprint with both arms swept back.
  void ninjaRun(double phase, double amount) {
    walk(phase, amount, run: true);
    torso = 0.5;
    head = -0.36;
    bUpper = -1.15 + math.sin(phase) * 0.08;
    bFore = -0.95;
    fUpper = -1.25 + math.sin(phase + 1) * 0.08;
    fFore = -1.05;
    weapon = -1.0;
  }

  /// Quick-draw: hand to the hip handle then the blade sweeps forward.
  void quickDraw(double k) {
    final e = easeOutCubic(k);
    set(
      torso: lerpD(0.2, 0.12, e),
      head: -0.06,
      bUpper: lerpD(-0.05, 0.3, e),
      bFore: lerpD(1.2, 0.9, e),
      fUpper: lerpD(-0.2, 1.1, e),
      fFore: lerpD(1.4, 1.7, e),
      bThigh: -0.32,
      bShin: -0.5,
      fThigh: 0.45,
      fShin: 0.05,
      weapon: lerpD(-1.3, 2.0, e),
    );
  }

  /// Horizontal dash with the body low and forward.
  void dash() {
    set(
      torso: 0.62,
      head: -0.4,
      bUpper: -1.2,
      bFore: -0.9,
      fUpper: 1.3,
      fFore: 1.65,
      fThigh: 1.1,
      fShin: 0.2,
      bThigh: -0.9,
      bShin: -1.5,
      weapon: 1.85,
    );
  }

  /// Spinning rising slash used by the shadow power.
  void spinSlash(double k) {
    final a = k * math.pi * 2;
    set(
      torso: 0.1 + math.sin(a) * 0.2,
      head: -0.1,
      bUpper: -0.8,
      bFore: -0.2,
      fUpper: 1.6 + a,
      fFore: 1.7 + a,
      fThigh: 1.0,
      fShin: -0.4,
      bThigh: 0.4,
      bShin: -1.0,
      weapon: 1.8 + a,
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

/// Wind-driven trailing ribbon (scarf, headband tails, belt). Each point
/// eases toward a waving target so the cloth whips and lags behind motion.
class ClothChain {
  ClothChain(this.count, this.segment);
  final int count;
  final double segment;
  final List<Offset> pts = [];
  Offset _lastAnchor = Offset.zero;
  Offset _vel = Offset.zero;
  bool _init = false;

  void update(Offset anchor, double dt, Offset accel, double time, double flutter) {
    final h = dt.clamp(1 / 240, 1 / 30);
    if (!_init || (anchor - _lastAnchor).distance > segment * count * 3) {
      _init = true;
      _lastAnchor = anchor;
      _vel = Offset.zero;
      pts
        ..clear()
        ..addAll(List.generate(count, (i) => anchor + Offset(-segment * i, segment * i * 0.4)));
    }
    final v = (anchor - _lastAnchor) / h;
    _vel = Offset.lerp(_vel, v, 1 - math.exp(-h * 10))!;
    _lastAnchor = anchor;
    // Drag direction: wind plus the opposite of the character's motion.
    var drag = Offset(accel.dx - _vel.dx * 1.4, accel.dy - _vel.dy * 0.9);
    final dl = drag.distance;
    drag = dl < 0.001 ? const Offset(0, 1) : drag / dl;
    final perp = Offset(-drag.dy, drag.dx);
    final amp = segment * (0.35 + flutter * 0.0012);
    pts[0] = anchor;
    for (var i = 1; i < count; i++) {
      final t = i / (count - 1);
      final wave = math.sin(time * 8.5 - i * 0.75) * amp * t + math.sin(time * 4.1 - i * 0.4) * amp * 0.5 * t;
      final target = anchor + drag * (segment * i) + perp * wave;
      final k = 1 - math.exp(-h * (26 - 16 * t));
      pts[i] = Offset.lerp(pts[i], target, k)!;
      // Keep segment lengths sane.
      final d = pts[i] - pts[i - 1];
      final len = d.distance;
      if (len > segment * 1.25) pts[i] = pts[i - 1] + d * (segment * 1.25 / len);
    }
  }
}

/// Cloth points expressed in the character's local (facing +x) space.
class ClothSet {
  final List<Offset> scarf = [];
  final List<Offset> band1 = [];
  final List<Offset> band2 = [];
  final List<Offset> obi = [];
}

/// Pose, skeleton and simulated cloth for one animated character.
class HumanoidRig {
  HumanoidRig(this.style)
      : scarf = ClothChain(12, 5.0 * style.unit),
        band1 = ClothChain(7, 2.6 * style.unit),
        band2 = ClothChain(6, 2.3 * style.unit),
        obi = ClothChain(5, 3.0 * style.unit);

  final HumanoidStyle style;
  final Pose pose = Pose();
  final Pose target = Pose();
  final Skeleton skel = Skeleton();
  final ClothChain scarf;
  final ClothChain band1;
  final ClothChain band2;
  final ClothChain obi;
  final ClothSet cloth = ClothSet();

  void compute() => skel.compute(pose, style);

  /// Simulates cloth in world space; [x],[y] is the feet position.
  void updateCloth(double dt, double x, double y, double facing, double time, {double wind = 0.5}) {
    final u = style.unit;
    final k = skel;
    Offset w(Offset l) => Offset(x + l.dx * facing, y + l.dy);
    final accel = Offset(-facing * (300 + wind * 560) * u / 1.5, 520 * u / 1.5);
    final flutter = (220 + wind * 260) * u / 1.5;
    if (style.scarf) scarf.update(w(k.neck + Offset(-2.4 * u, 1.6 * u)), dt, accel, time, flutter);
    if (style.headband) {
      band1.update(w(k.head + Offset(-6.2 * u, -2.6 * u)), dt, accel, time + 0.7, flutter * 1.2);
      band2.update(w(k.head + Offset(-6.0 * u, -1.2 * u)), dt, accel, time + 1.9, flutter * 1.2);
    }
    obi.update(w(k.hip + Offset(-5.5 * u, -1.5 * u)), dt, accel * 0.8, time + 3.1, flutter * 0.8);
    void toLocal(ClothChain ch, List<Offset> out) {
      out.clear();
      for (final p in ch.pts) {
        out.add(Offset((p.dx - x) * facing, p.dy - y));
      }
    }

    toLocal(scarf, cloth.scarf);
    toLocal(band1, cloth.band1);
    toLocal(band2, cloth.band2);
    toLocal(obi, cloth.obi);
  }
}

/// Draws shadow humanoids with rim lighting, glowing eyes, armour and weapons.
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
  /// [sheathed] 1 = katana resting in its scabbard, 0 = held in hand.
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
    double sheathed = 0,
    ClothSet? cloth,
  }) {
    if (alpha <= 0.01) return;
    final u = s.unit;
    final inHand = sheathed < 0.5;
    // Fade the rim light much faster than the body so translucent
    // characters never look pale.
    final a2 = alpha * alpha;
    final rimA = s.rimStrength * a2 * a2;
    if (rimA > 0.02) {
      c.save();
      c.translate(rimDx * 1.3 * u, -1.1 * u);
      _figure(c, k, p, s, fade(s.rim, rimA), fade(s.rim, rimA * 0.7), time, wind, false, inHand, cloth);
      c.restore();
    }
    final f = flash.clamp(0.0, 1.0);
    final body = Color.lerp(s.body, const Color(0xFF4A5874), f * 0.4)!;
    final back = Color.lerp(Color.lerp(s.body, s.backTint, 0.55)!, const Color(0xFF4A5874), f * 0.35)!;
    _figure(c, k, p, s, fade(body, alpha), fade(back, alpha), time, wind, true, inHand, cloth);
    _details(c, k, p, s, time, alpha, eyeBoost, inHand);
  }

  static void _limb(Canvas c, Offset a, Offset b, double wa, double wb, Paint paint, {double bulge = 0}) {
    final d = b - a;
    final len = d.distance;
    if (len < 0.001) {
      c.drawCircle(a, wa / 2, paint);
      return;
    }
    final n = Offset(-d.dy / len, d.dx / len);
    final mid = a + d * 0.38;
    final wm = (wa + wb) / 2 + bulge;
    _path
      ..reset()
      ..moveTo(a.dx + n.dx * wa / 2, a.dy + n.dy * wa / 2)
      ..quadraticBezierTo(mid.dx + n.dx * wm / 2, mid.dy + n.dy * wm / 2, b.dx + n.dx * wb / 2, b.dy + n.dy * wb / 2)
      ..lineTo(b.dx - n.dx * wb / 2, b.dy - n.dy * wb / 2)
      ..quadraticBezierTo(mid.dx - n.dx * wm / 2, mid.dy - n.dy * wm / 2, a.dx - n.dx * wa / 2, a.dy - n.dy * wa / 2)
      ..close();
    c.drawPath(_path, paint);
    c.drawCircle(a, wa / 2, paint);
    c.drawCircle(b, wb / 2, paint);
  }

  static void _ribbon(Canvas c, List<Offset> pts, double w0, double w1, Paint paint) {
    final n = pts.length;
    if (n < 2) return;
    for (var i = 0; i < n - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final wa = lerpD(w0, w1, i / (n - 1));
      final wb = lerpD(w0, w1, (i + 1) / (n - 1));
      final d = b - a;
      final len = d.distance;
      if (len < 0.0001) continue;
      final nn = Offset(-d.dy / len, d.dx / len);
      _path
        ..reset()
        ..moveTo(a.dx + nn.dx * wa / 2, a.dy + nn.dy * wa / 2)
        ..lineTo(b.dx + nn.dx * wb / 2, b.dy + nn.dy * wb / 2)
        ..lineTo(b.dx - nn.dx * wb / 2, b.dy - nn.dy * wb / 2)
        ..lineTo(a.dx - nn.dx * wa / 2, a.dy - nn.dy * wa / 2)
        ..close();
      c.drawPath(_path, paint);
    }
    // Pointed tip.
    final a = pts[n - 2];
    final b = pts[n - 1];
    final d = b - a;
    final len = d.distance;
    if (len > 0.0001) {
      final nn = Offset(-d.dy / len, d.dx / len);
      _path
        ..reset()
        ..moveTo(b.dx + nn.dx * w1 / 2, b.dy + nn.dy * w1 / 2)
        ..lineTo(b.dx + d.dx / len * w1 * 1.6, b.dy + d.dy / len * w1 * 1.6)
        ..lineTo(b.dx - nn.dx * w1 / 2, b.dy - nn.dy * w1 / 2)
        ..close();
      c.drawPath(_path, paint);
    }
  }

  static void _procTails(Canvas c, Offset h, double u, double time, double wind, Paint paint, double scale) {
    for (var j = 0; j < 2; j++) {
      _path.reset();
      final pts = <Offset>[];
      for (var i = 0; i < 6; i++) {
        final t = i / 5;
        pts.add(h + Offset(-t * 15 * u * scale - wind * 5 * u * t, t * (2 + j * 4) * u + math.sin(time * 7 + i * 0.9 + j) * 2.4 * u * t));
      }
      _ribbon(c, pts, 2.0 * u, 0.9 * u, paint);
    }
  }

  static Offset _sayaMouth(Skeleton k, Pose p, double u) =>
      k.hip + Offset(math.cos(p.torso) * 5 * u + math.sin(p.torso) * 1 * u, -2.5 * u);

  static void _figure(Canvas c, Skeleton k, Pose p, HumanoidStyle s, Color main, Color back,
      double time, double wind, bool detailPass, bool inHand, ClothSet? cloth) {
    if (s.skeleton) {
      _bones(c, k, p, s, main, back, time, detailPass, inHand);
      return;
    }
    final u = s.unit;
    final bk = s.bulk;
    _p
      ..color = back
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver;

    // Scarf flowing behind everything.
    if (s.scarf && cloth != null && cloth.scarf.length > 2) {
      _p.color = detailPass ? Color.lerp(main, fade(s.bandColor, main.a), 0.45)! : back;
      _ribbon(c, cloth.scarf, 5.2 * u, 2.0 * u, _p);
      _p.color = back;
    }

    // Cape.
    if (s.cape) {
      final sway = math.sin(time * 2.4) * 4 * u + wind * 6 * u;
      final sh = k.shoulder;
      _path
        ..reset()
        ..moveTo(sh.dx + 2 * u, sh.dy - 1 * u)
        ..quadraticBezierTo(sh.dx - 12 * u, sh.dy + 18 * u, sh.dx - 18 * u - sway, k.hip.dy + 38 * u)
        ..lineTo(sh.dx - 13 * u - sway * 0.8, k.hip.dy + 42 * u + math.sin(time * 3.1) * 2 * u)
        ..lineTo(sh.dx - 8 * u - sway * 0.6, k.hip.dy + 39 * u + math.sin(time * 3.7) * 2 * u)
        ..lineTo(sh.dx - 2 * u - sway * 0.3, k.hip.dy + 41 * u)
        ..quadraticBezierTo(sh.dx + 4 * u, sh.dy + 18 * u, sh.dx + 5 * u, sh.dy + 2 * u)
        ..close();
      c.drawPath(_path, _p);
    }

    // Back leg and arm.
    _leg(c, k.hip, k.bKnee, k.bFoot, u, bk, s.hakama, _p);
    _limb(c, k.shoulder, k.bElbow, 7.2 * u * bk, 5.8 * u * bk, _p, bulge: 1.2 * u * bk);
    _limb(c, k.bElbow, k.bHand, 5.8 * u * bk, 4.2 * u * bk, _p, bulge: 1.0 * u * bk);
    c.drawCircle(k.bHand, 3.0 * u * bk, _p);

    // Scabbard on the hip.
    if (s.saya && s.weapon == WeaponType.katana) {
      final m = _sayaMouth(k, p, u);
      final dir = Offset(-math.cos(0.42 - p.torso * 0.5), math.sin(0.42 - p.torso * 0.5));
      final len = s.weaponLength * 0.95;
      _s
        ..color = back
        ..strokeWidth = 3.6 * u;
      c.drawLine(m, m + dir * len, _s);
      _s.strokeWidth = 2.6 * u;
      c.drawLine(m + dir * len, m + dir * (len + 2 * u), _s);
      if (!inHand) {
        // Handle sticking out forward with its guard.
        _s
          ..color = main
          ..strokeWidth = 2.8 * u;
        c.drawLine(m, m - dir * (12 * u), _s);
        c.drawOval(Rect.fromCenter(center: m - dir * (0.8 * u), width: 2.2 * u, height: 6.4 * u), _p..color = main);
      }
      _p.color = back;
    }

    // Belt tails.
    if (cloth != null && cloth.obi.length > 2) {
      _p.color = main;
      _ribbon(c, cloth.obi, 2.6 * u, 1.2 * u, _p);
    }

    _p.color = main;
    // Torso.
    c.save();
    c.translate(k.hip.dx, k.hip.dy);
    c.rotate(p.torso);
    final tl = 30 * u;
    final b = u * bk;
    _path
      ..reset()
      ..moveTo(-6.6 * b, 3 * u)
      ..lineTo(6.6 * b, 3 * u)
      ..quadraticBezierTo(7.2 * b, -tl * 0.3, 9.4 * b, -tl * 0.62)
      ..quadraticBezierTo(10.6 * b, -tl * 0.86, 7.2 * b, -tl * 0.99)
      ..lineTo(2.8 * u, -tl * 1.06)
      ..lineTo(-3.2 * u, -tl * 1.06)
      ..quadraticBezierTo(-9.4 * b, -tl * 1.02, -9.6 * b, -tl * 0.8)
      ..quadraticBezierTo(-7.4 * b, -tl * 0.4, -6.6 * b, 3 * u)
      ..close();
    c.drawPath(_path, _p);
    if (s.armor) {
      // Kusazuri skirt plates.
      for (var i = -1; i <= 1; i++) {
        c.save();
        c.translate(i * 5.2 * b, 1.5 * u);
        c.rotate(i * 0.12);
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-3.6 * b, 0, 7.2 * b, 12 * u), Radius.circular(1.5 * u)), _p);
        c.restore();
      }
    }
    if (s.shoulderPads && !s.armor) {
      c.drawOval(Rect.fromCenter(center: Offset(1 * u, -tl * 0.9), width: 20 * u * bk, height: 9 * u), _p);
    }
    if (detailPass) {
      _s
        ..color = fade(s.detail, main.a)
        ..strokeWidth = 0.7 * u;
      // Gi lapels and belt.
      _path
        ..reset()
        ..moveTo(-1.5 * u, -tl * 1.03)
        ..quadraticBezierTo(2.5 * u, -tl * 0.72, 5.5 * b, -tl * 0.45)
        ..moveTo(2.5 * u, -tl * 1.03)
        ..quadraticBezierTo(4.5 * u, -tl * 0.8, 6.8 * b, -tl * 0.62);
      c.drawPath(_path, _s);
      _s.strokeWidth = 1.1 * u;
      c.drawLine(Offset(-6.6 * b, -0.5 * u), Offset(6.8 * b, -0.5 * u), _s);
      c.drawLine(Offset(-6.6 * b, -3.2 * u), Offset(7.0 * b, -3.2 * u), _s);
      if (s.armor) {
        _s.strokeWidth = 0.8 * u;
        for (var i = 0; i < 4; i++) {
          final yy = -tl * (0.3 + i * 0.13);
          c.drawLine(Offset(-6.5 * b, yy), Offset(7.8 * b, yy - 0.6 * u), _s);
        }
        for (var i = -1; i <= 1; i++) {
          c.drawLine(Offset(i * 5.2 * b - 3 * b, 7 * u), Offset(i * 5.2 * b + 3 * b, 7 * u), _s);
        }
      }
    }
    c.restore();

    // Neck and head.
    _limb(c, k.neck - (k.head - k.neck) * 0.2, k.head, 5.2 * u * bk, 4.2 * u * bk, _p);
    _head(c, k, p, s, main, detailPass, time);

    // Front leg.
    _leg(c, k.hip, k.fKnee, k.fFoot, u, bk, s.hakama, _p);
    if (detailPass && s.hakama) {
      _s
        ..color = fade(s.detail, main.a * 0.8)
        ..strokeWidth = 0.6 * u;
      final d = k.fFoot - k.fKnee;
      c.drawLine(k.fKnee + Offset(1.5 * u, 0), k.fKnee + d * 0.9 + Offset(2.5 * u, 0), _s);
      c.drawLine(k.hip + Offset(2 * u, 2 * u), k.fKnee + Offset(-1 * u, 0), _s);
    }

    // Weapon held in hand.
    if (inHand) _weaponShape(c, k, s, main);

    // Front arm.
    _p.color = main;
    _limb(c, k.shoulder, k.fElbow, 7.6 * u * bk, 6.0 * u * bk, _p, bulge: 1.4 * u * bk);
    _limb(c, k.fElbow, k.fHand, 6.0 * u * bk, 4.6 * u * bk, _p, bulge: 1.2 * u * bk);
    c.drawCircle(k.fHand, 3.4 * u * bk, _p);
    c.drawCircle(k.shoulder, 5.0 * u * bk, _p);
    if (s.armor) {
      // Sode shoulder plates following the upper arm.
      final d = k.fElbow - k.shoulder;
      final ang = math.atan2(d.dy, d.dx) - math.pi / 2;
      c.save();
      c.translate(k.shoulder.dx, k.shoulder.dy);
      c.rotate(ang);
      for (var i = 0; i < 3; i++) {
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-0.5 * u, (i * 3.6 + 1) * u * bk), width: 12.5 * u * bk, height: 4.2 * u * bk), Radius.circular(1.6 * u)), _p);
      }
      if (detailPass) {
        _s
          ..color = fade(s.detail, main.a)
          ..strokeWidth = 0.6 * u;
        for (var i = 0; i < 3; i++) {
          final yy = (i * 3.6 + 2.8) * u * bk;
          c.drawLine(Offset(-6 * u * bk, yy), Offset(5 * u * bk, yy), _s);
        }
      }
      c.restore();
    } else if (detailPass) {
      // Forearm wraps.
      _s
        ..color = fade(s.detail, main.a * 0.8)
        ..strokeWidth = 0.6 * u;
      final d = k.fHand - k.fElbow;
      final n = Offset(-d.dy, d.dx) / math.max(d.distance, 0.001) * (2.6 * u * bk);
      for (var i = 0; i < 3; i++) {
        final q = k.fElbow + d * (0.45 + i * 0.15);
        c.drawLine(q - n, q + n + d * 0.05, _s);
      }
    }

    // Headband tails.
    if (s.headband) {
      _p.color = detailPass ? fade(s.bandColor, main.a) : main;
      if (cloth != null && cloth.band1.length > 2) {
        _ribbon(c, cloth.band1, 2.2 * u, 0.9 * u, _p);
        _ribbon(c, cloth.band2, 1.9 * u, 0.8 * u, _p);
      } else {
        _procTails(c, k.head + Offset(-5.5 * u, -2.5 * u), u, time, wind, _p, 1);
      }
      if (detailPass) {
        _s
          ..color = fade(s.bandColor, main.a)
          ..strokeWidth = 2.2 * u;
        c.drawArc(Rect.fromCircle(center: k.head, radius: 7 * u), math.pi * 1.05, math.pi * 0.9, false, _s);
      }
      _p.color = main;
    }
  }

  static void _bone(Canvas c, Offset a, Offset b, double w, Paint paint) {
    _limb(c, a, b, w, w * 0.8, paint);
    c.drawCircle(a, w * 0.85, paint);
    c.drawCircle(b, w * 0.75, paint);
  }

  /// Skeleton body: bones, ribcage, skull with deep sockets.
  static void _bones(Canvas c, Skeleton k, Pose p, HumanoidStyle s, Color main, Color back, double time, bool detailPass, bool inHand) {
    final u = s.unit;
    final bk = s.bulk;
    final w = 2.8 * u * bk;
    _p
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..color = back;
    if (s.cape) {
      final sh = k.shoulder;
      final sway = math.sin(time * 2.4) * 4 * u;
      _path
        ..reset()
        ..moveTo(sh.dx + 2 * u, sh.dy - 1 * u)
        ..quadraticBezierTo(sh.dx - 12 * u, sh.dy + 18 * u, sh.dx - 18 * u - sway, k.hip.dy + 38 * u)
        ..lineTo(sh.dx - 12 * u - sway, k.hip.dy + 30 * u)
        ..lineTo(sh.dx - 9 * u - sway, k.hip.dy + 40 * u)
        ..lineTo(sh.dx - 2 * u, k.hip.dy + 28 * u)
        ..quadraticBezierTo(sh.dx + 4 * u, sh.dy + 18 * u, sh.dx + 5 * u, sh.dy + 2 * u)
        ..close();
      c.drawPath(_path, _p);
    }
    // Back limbs.
    _bone(c, k.hip, k.bKnee, w * 1.1, _p);
    _bone(c, k.bKnee, k.bFoot, w, _p);
    _foot(c, k.bFoot, u * 0.8, _p);
    _bone(c, k.shoulder, k.bElbow, w * 0.95, _p);
    _bone(c, k.bElbow, k.bHand, w * 0.85, _p);
    _p.color = main;
    // Pelvis.
    c.drawOval(Rect.fromCenter(center: k.hip + Offset(0, 1 * u), width: 13 * u * bk, height: 6 * u), _p);
    // Spine.
    for (var i = 0; i < 8; i++) {
      final q = Offset.lerp(k.hip, k.neck, i / 7)!;
      c.drawCircle(q, 1.9 * u * bk, _p);
    }
    // Ribcage.
    c.save();
    c.translate(k.hip.dx, k.hip.dy);
    c.rotate(p.torso);
    final tl = 30 * u;
    _s
      ..color = main
      ..strokeWidth = 1.8 * u * bk;
    for (var i = 0; i < 5; i++) {
      final y = -tl * (0.5 + i * 0.1);
      final rw = (7.5 - (i - 2).abs() * 0.8) * u * bk;
      _path
        ..reset()
        ..moveTo(-1 * u, y)
        ..quadraticBezierTo(rw * 1.3, y + 2 * u, rw * 0.9, y + 5 * u)
        ..moveTo(-1 * u, y)
        ..quadraticBezierTo(-rw, y + 2 * u, -rw * 0.8, y + 4.5 * u);
      c.drawPath(_path, _s);
    }
    // Collar bones / shoulder plate.
    c.drawLine(Offset(-6 * u * bk, -tl * 0.96), Offset(7 * u * bk, -tl * 0.98), _s);
    if (s.armor) {
      c.drawOval(Rect.fromCenter(center: Offset(1 * u, -tl * 0.93), width: 22 * u * bk, height: 8 * u), _p);
    }
    c.restore();
    // Front leg.
    _bone(c, k.hip, k.fKnee, w * 1.15, _p);
    _bone(c, k.fKnee, k.fFoot, w * 1.05, _p);
    _foot(c, k.fFoot, u * 0.85, _p);
    // Skull.
    final h = k.head;
    c.save();
    c.translate(h.dx, h.dy);
    c.rotate(p.torso + p.head);
    _path
      ..reset()
      ..moveTo(-6.5 * u, 0)
      ..quadraticBezierTo(-6.8 * u, -8 * u, 0.5 * u, -8 * u)
      ..quadraticBezierTo(7.6 * u, -7.4 * u, 7.4 * u, 0)
      ..lineTo(6.2 * u, 3.5 * u)
      ..lineTo(1 * u, 4 * u)
      ..lineTo(-3 * u, 3 * u)
      ..close();
    c.drawPath(_path, _p);
    // Jaw.
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-0.5 * u, 3.6 * u, 7 * u, 3.2 * u), Radius.circular(1.2 * u)), _p);
    if (s.crown) {
      for (var i = 0; i < 5; i++) {
        final x = -5.5 * u + i * 2.8 * u;
        _path
          ..reset()
          ..moveTo(x - 1.2 * u, -7 * u)
          ..lineTo(x, -14 * u - (i == 2 ? 4 * u : 0))
          ..lineTo(x + 1.2 * u, -7 * u)
          ..close();
        c.drawPath(_path, _p);
      }
    }
    if (s.horns) {
      _s
        ..color = main
        ..strokeWidth = 2.6 * u;
      _path
        ..reset()
        ..moveTo(1 * u, -6 * u)
        ..quadraticBezierTo(9 * u, -12 * u, 6 * u, -20 * u)
        ..moveTo(-3 * u, -6 * u)
        ..quadraticBezierTo(-11 * u, -11 * u, -12 * u, -19 * u);
      c.drawPath(_path, _s);
    }
    if (detailPass) {
      // Dark sockets, nose and teeth.
      _p.color = fade(const Color(0xFF000000), main.a);
      c.drawOval(Rect.fromCenter(center: Offset(3.6 * u, -2.2 * u), width: 3.6 * u, height: 3.2 * u), _p);
      c.drawOval(Rect.fromCenter(center: Offset(-0.6 * u, -2.0 * u), width: 3.0 * u, height: 3.0 * u), _p);
      _path
        ..reset()
        ..moveTo(5.2 * u, 0.6 * u)
        ..lineTo(6.2 * u, 2.6 * u)
        ..lineTo(4.6 * u, 2.6 * u)
        ..close();
      c.drawPath(_path, _p);
      _s
        ..color = fade(const Color(0xFF000000), main.a)
        ..strokeWidth = 0.4 * u;
      for (var i = 0; i < 4; i++) {
        c.drawLine(Offset((0.6 + i * 1.6) * u, 3.6 * u), Offset((0.6 + i * 1.6) * u, 5.4 * u), _s);
      }
      _p.color = main;
    }
    c.restore();
    // Weapon and front arm.
    if (inHand) _weaponShape(c, k, s, main);
    _p.color = main;
    _bone(c, k.shoulder, k.fElbow, w, _p);
    _bone(c, k.fElbow, k.fHand, w * 0.9, _p);
    c.drawCircle(k.fHand, 2.4 * u * bk, _p);
  }

  static void _leg(Canvas c, Offset hip, Offset knee, Offset foot, double u, double bk, bool hakama, Paint paint) {
    if (hakama) {
      _limb(c, hip, knee, 12.5 * u * bk, 11.5 * u * bk, paint, bulge: 1.5 * u);
      _limb(c, knee, foot + Offset(0, -2.5 * u), 11.5 * u * bk, 14.5 * u * bk, paint);
      _foot(c, foot, u * bk, paint);
    } else {
      _limb(c, hip, knee, 11 * u * bk, 8.5 * u * bk, paint, bulge: 1.6 * u * bk);
      _limb(c, knee, foot, 8.5 * u * bk, 5.0 * u * bk, paint, bulge: 1.8 * u * bk);
      _foot(c, foot, u * bk, paint);
    }
  }

  static void _foot(Canvas c, Offset f, double u, Paint paint) {
    _path
      ..reset()
      ..moveTo(f.dx - 3.2 * u, f.dy)
      ..lineTo(f.dx - 3.2 * u, f.dy - 3.4 * u)
      ..quadraticBezierTo(f.dx + 2 * u, f.dy - 4.2 * u, f.dx + 6.8 * u, f.dy - 1.2 * u)
      ..lineTo(f.dx + 7.2 * u, f.dy)
      ..close();
    c.drawPath(_path, paint);
  }

  static void _head(Canvas c, Skeleton k, Pose p, HumanoidStyle s, Color main, bool detailPass, double time) {
    final u = s.unit;
    final h = k.head;
    final ha = p.torso + p.head;
    c.save();
    c.translate(h.dx, h.dy);
    c.rotate(ha);
    _p.color = main;
    // Skull and jaw.
    _path
      ..reset()
      ..moveTo(-6.8 * u, -1 * u)
      ..quadraticBezierTo(-7 * u, -7.5 * u, 0, -7.6 * u)
      ..quadraticBezierTo(6.8 * u, -7.4 * u, 7.2 * u, -0.8 * u)
      ..lineTo(7.6 * u, 1.6 * u)
      ..quadraticBezierTo(6.2 * u, 6.6 * u, 1.5 * u, 7.0 * u)
      ..quadraticBezierTo(-5.2 * u, 6.2 * u, -6.8 * u, -1 * u)
      ..close();
    c.drawPath(_path, _p);
    if (s.topknot && !s.helmet && !s.hood) {
      c.drawOval(Rect.fromCenter(center: Offset(-3.6 * u, -8.2 * u), width: 4.8 * u, height: 3.2 * u), _p);
      _s
        ..color = main
        ..strokeWidth = 1.6 * u;
      c.drawLine(Offset(-4.6 * u, -8.4 * u), Offset(-9.5 * u, -6.6 * u + math.sin(time * 6) * 0.6 * u), _s);
      // Spiky hair fringe.
      _path
        ..reset()
        ..moveTo(-6.5 * u, -4 * u)
        ..lineTo(-9.2 * u, -2.5 * u)
        ..lineTo(-6.8 * u, -1.2 * u)
        ..lineTo(-8.8 * u, 0.6 * u)
        ..lineTo(-6.5 * u, 0.8 * u)
        ..close();
      c.drawPath(_path, _p);
    }
    if (s.hood) {
      _path
        ..reset()
        ..moveTo(7.8 * u, 4 * u)
        ..quadraticBezierTo(9.4 * u, -9 * u, -1 * u, -10.4 * u)
        ..quadraticBezierTo(-9.4 * u, -9.4 * u, -13.5 * u, 2.4 * u)
        ..quadraticBezierTo(-9 * u, 10.5 * u, -3 * u, 11 * u)
        ..close();
      c.drawPath(_path, _p);
    }
    if (s.helmet) {
      // Kabuto dome and flaring neck guard.
      c.drawOval(Rect.fromCenter(center: Offset(-0.4 * u, -4.4 * u), width: 16.5 * u, height: 10 * u), _p);
      _path
        ..reset()
        ..moveTo(-7.5 * u, -3 * u)
        ..lineTo(-13 * u, 4.5 * u)
        ..lineTo(-9 * u, 5.5 * u)
        ..lineTo(-5 * u, 1 * u)
        ..close()
        ..moveTo(6.5 * u, -3 * u)
        ..lineTo(9.8 * u, -1.2 * u)
        ..lineTo(7.4 * u, 0.2 * u)
        ..close();
      c.drawPath(_path, _p);
      // Crest.
      _s
        ..color = detailPass ? fade(const Color(0xFF8A6A3A), main.a) : main
        ..strokeWidth = 1.6 * u;
      _path
        ..reset()
        ..moveTo(1 * u, -8.6 * u)
        ..quadraticBezierTo(5 * u, -13 * u, 4 * u, -19 * u)
        ..moveTo(0, -8.6 * u)
        ..quadraticBezierTo(-4 * u, -13 * u, -2.5 * u, -19.5 * u);
      c.drawPath(_path, _s);
    }
    if (s.horns) {
      _s
        ..color = main
        ..strokeWidth = 3 * u;
      _path
        ..reset()
        ..moveTo(2 * u, -6 * u)
        ..quadraticBezierTo(9 * u, -12 * u, 6 * u, -21 * u)
        ..moveTo(-3 * u, -6 * u)
        ..quadraticBezierTo(-11 * u, -11 * u, -12 * u, -20 * u);
      c.drawPath(_path, _s);
    }
    if (detailPass && s.mask) {
      _s
        ..color = fade(s.detail, main.a)
        ..strokeWidth = 0.6 * u;
      c.drawLine(Offset(-2 * u, 1.4 * u), Offset(7.4 * u, 1.0 * u), _s);
      c.drawLine(Offset(0.5 * u, 3.4 * u), Offset(6.4 * u, 3.6 * u), _s);
    }
    c.restore();
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
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1.4 * u, -9 * u, 2.8 * u, 12 * u), Radius.circular(u)), _p);
        c.drawOval(Rect.fromCenter(center: Offset(0, 3 * u), width: 6.4 * u, height: 2.0 * u), _p);
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
        _path
          ..reset()
          ..moveTo(-8 * u, 1.5 * u)
          ..quadraticBezierTo(0, 5 * u, 8 * u, 1.5 * u)
          ..lineTo(7 * u, 4.5 * u)
          ..quadraticBezierTo(0, 6.5 * u, -7 * u, 4.5 * u)
          ..close();
        c.drawPath(_path, _p);
        _path
          ..reset()
          ..moveTo(-3 * u, 4.5 * u)
          ..lineTo(3 * u, 4.5 * u)
          ..lineTo(3.6 * u, len * 0.55)
          ..lineTo(2.6 * u, len * 0.6)
          ..lineTo(3.4 * u, len * 0.86)
          ..lineTo(0, len)
          ..lineTo(-3.4 * u, len * 0.86)
          ..lineTo(-2.6 * u, len * 0.6)
          ..lineTo(-3.6 * u, len * 0.55)
          ..close();
        c.drawPath(_path, _p);
        break;
      case WeaponType.bow:
        _s
          ..color = col
          ..strokeWidth = 2.2 * u;
        _path
          ..reset()
          ..moveTo(0, -len * 0.5)
          ..quadraticBezierTo(len * 0.32, 0, 0, len * 0.5);
        c.drawPath(_path, _s);
        _s.strokeWidth = 0.5 * u;
        c.drawLine(Offset(0, -len * 0.5), Offset(-len * 0.12, 0), _s);
        c.drawLine(Offset(-len * 0.12, 0), Offset(0, len * 0.5), _s);
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

  static void _details(Canvas c, Skeleton k, Pose p, HumanoidStyle s, double time, double alpha, double eyeBoost, bool inHand) {
    final u = s.unit;
    // Blade edge highlight.
    if (inHand && (s.weapon == WeaponType.katana || s.weapon == WeaponType.greatsword || s.weapon == WeaponType.dagger || s.weapon == WeaponType.axe)) {
      final edgeStart = k.fHand + k.wDir * (s.weapon == WeaponType.axe ? s.weaponLength - 20 * u : 4 * u);
      final edgeEnd = k.wTip;
      if (s.bladeGlow.a > 0) {
        _s
          ..blendMode = BlendMode.plus
          ..color = fade(s.bladeGlow, alpha * 0.28)
          ..strokeWidth = 6 * u;
        c.drawLine(edgeStart, edgeEnd, _s);
        _s
          ..color = fade(s.bladeGlow, alpha * 0.45)
          ..strokeWidth = 2.4 * u;
        c.drawLine(edgeStart, edgeEnd, _s);
        _s.blendMode = BlendMode.srcOver;
      }
      _s
        ..color = fade(s.bladeColor, alpha * 0.9)
        ..strokeWidth = 0.7 * u;
      final nrm = Offset(-k.wDir.dy, k.wDir.dx) * (0.9 * u);
      c.drawLine(edgeStart + nrm, edgeEnd, _s);
      // Hamon glint travelling along the blade.
      final g = (time * 0.6) % 1.0;
      final gp = Offset.lerp(edgeStart, edgeEnd, g)!;
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(s.bladeColor, alpha * 0.5 * math.sin(g * math.pi));
      c.drawCircle(gp + nrm, 1.3 * u, _p);
      _p.blendMode = BlendMode.srcOver;
    }
    // Energy veins.
    if (s.veins.a > 0) {
      final pulse = 0.55 + 0.45 * math.sin(time * 3.2);
      _s
        ..blendMode = BlendMode.plus
        ..color = fade(s.veins, alpha * 0.55 * pulse)
        ..strokeWidth = 0.9 * u;
      final mid = Offset.lerp(k.hip, k.neck, 0.55)!;
      _path
        ..reset()
        ..moveTo(k.hip.dx + 1 * u, k.hip.dy - 2 * u)
        ..lineTo(mid.dx + 2 * u, mid.dy)
        ..lineTo(k.neck.dx + 1 * u, k.neck.dy + 3 * u)
        ..moveTo(mid.dx + 2 * u, mid.dy)
        ..lineTo(mid.dx + 6 * u, mid.dy - 5 * u)
        ..moveTo(k.shoulder.dx, k.shoulder.dy)
        ..lineTo(k.fElbow.dx, k.fElbow.dy)
        ..lineTo(k.fHand.dx, k.fHand.dy)
        ..moveTo(k.hip.dx, k.hip.dy)
        ..lineTo(k.fKnee.dx, k.fKnee.dy)
        ..lineTo(k.fFoot.dx, k.fFoot.dy - 3 * u);
      c.drawPath(_path, _s);
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(s.veins, alpha * 0.6 * pulse);
      c.drawCircle(mid + Offset(2 * u, 0), 2.6 * u, _p);
      _p.color = fade(s.veins, alpha * 0.18 * pulse);
      c.drawCircle(mid + Offset(2 * u, 0), 8 * u, _p);
      _p.blendMode = BlendMode.srcOver;
      _s.blendMode = BlendMode.srcOver;
    }
    // Glowing eyes.
    final g = (s.eyeGlow + eyeBoost) * alpha * (0.85 + 0.15 * math.sin(time * 6));
    if (g > 0.02) {
      final fwd = Offset(math.sin(p.torso + p.head + math.pi / 2), -math.cos(p.torso + p.head + math.pi / 2));
      final up = Offset(math.sin(p.torso + p.head), -math.cos(p.torso + p.head));
      final e = k.head + fwd * (4.4 * u) + up * (0.8 * u);
      _p
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.plus
        ..color = fade(s.eye, 0.14 * g);
      c.drawCircle(e, 7 * u, _p);
      _p.color = fade(s.eye, 0.32 * g);
      c.drawCircle(e, 3.2 * u, _p);
      _p.blendMode = BlendMode.srcOver;
      _p.color = fade(Color.lerp(s.eye, const Color(0xFFFFFFFF), 0.6)!, g.clamp(0.0, 1.0));
      _path
        ..reset()
        ..moveTo(e.dx - fwd.dx * 1.8 * u, e.dy - fwd.dy * 1.8 * u + 0.3 * u)
        ..lineTo(e.dx + fwd.dx * 1.9 * u - up.dx * 0.6 * u, e.dy + fwd.dy * 1.9 * u - up.dy * 0.6 * u)
        ..lineTo(e.dx + fwd.dx * 1.2 * u + up.dx * 0.4 * u, e.dy + fwd.dy * 1.2 * u + up.dy * 0.4 * u)
        ..close();
      c.drawPath(_path, _p);
      final e2 = e - fwd * (3.0 * u);
      _p.color = fade(s.eye, 0.55 * g.clamp(0.0, 1.0));
      c.drawOval(Rect.fromCenter(center: e2, width: 1.8 * u, height: 0.9 * u), _p);
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
        ..blendMode = BlendMode.srcOver
        ..color = fade(color, a * a * 0.5);
      c.drawPath(_path, _p);
      // Bright edge along the tip arc.
      _s
        ..blendMode = BlendMode.plus
        ..color = fade(color, a * a * 0.8)
        ..strokeWidth = 2.2;
      c.drawLine(tips[i], tips[i + 1], _s);
      _s.blendMode = BlendMode.srcOver;
    }
  }
}
