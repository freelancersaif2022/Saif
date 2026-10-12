import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import '../weapons/weapon_data.dart';

enum HeadGear { helmet, balaclava, beret, heavyHelmet, bossMask }

/// Visual identity of a soldier: colours, camo texture and gear.
class RigLook {
  const RigLook({
    required this.uniform,
    required this.vest,
    required this.skin,
    required this.helmet,
    required this.gear,
    required this.boots,
    required this.gloves,
    required this.headGear,
    this.camo,
    this.backpack = true,
    this.bulk = 1.0,
    this.visor = const Color(0xFF111316),
  });

  final Color uniform;
  final Color vest;
  final Color skin;
  final Color helmet;
  final Color gear;
  final Color boots;
  final Color gloves;
  final HeadGear headGear;
  final ui.Image? camo;
  final bool backpack;
  final double bulk;
  final Color visor;
}

/// Animation inputs for one soldier plus the resulting muzzle position.
class RigPose {
  double facing = 0;
  double walkPhase = 0;
  double move = 0;
  double sprint = 0;
  double aim = 0;
  double recoil = 0;
  double reload = -1;
  double hit = 0;
  double death = 0;
  double time = 0;

  void reset() {
    facing = -math.pi / 2;
    walkPhase = 0;
    move = 0;
    sprint = 0;
    aim = 0;
    recoil = 0;
    reload = -1;
    hit = 0;
    death = 0;
    time = 0;
  }
}

class _J {
  double a = 0;
  double b = 0;
  double c = 0;
  double x = 0;
  double y = 0;
  double d = 0;

  void set(double na, double nb, double nc) {
    a = na;
    b = nb;
    c = nc;
  }

  void lerpTo(_J p, _J q, double t) {
    a = p.a + (q.a - p.a) * t;
    b = p.b + (q.b - p.b) * t;
    c = p.c + (q.c - p.c) * t;
  }
}

class _Seg {
  int j0 = 0;
  int j1 = 0;
  double w = 0;
  int mat = 0;
  double depth = 0;
}

// Joint indices.
const int _pelvis = 0;
const int _chest = 1;
const int _neck = 2;
const int _head = 3;
const int _shL = 4;
const int _elL = 5;
const int _hnL = 6;
const int _shR = 7;
const int _elR = 8;
const int _hnR = 9;
const int _hipL = 10;
const int _knL = 11;
const int _ftL = 12;
const int _hipR = 13;
const int _knR = 14;
const int _ftR = 15;
const int _gRear = 16;
const int _gMuzzle = 17;
const int _magTop = 18;
const int _magBot = 19;
const int _scA = 20;
const int _scB = 21;
const int _pkTop = 22;
const int _pkBot = 23;
const int _toeL = 24;
const int _toeR = 25;
const int _vestLo = 26;
const int _foreA = 27;
const int _foreB = 28;
const int _tmp = 29;
const int _tmp2 = 30;
const int _tmp3 = 31;
const int _jointCount = 32;

// Materials.
const int _mUniform = 0;
const int _mVest = 1;
const int _mSkin = 2;
const int _mBoots = 3;
const int _mGloves = 4;
const int _mGear = 5;
const int _mMetal = 6;
const int _mFurniture = 7;

/// Draws a fully articulated soldier with a pseudo-3D skeleton. The skeleton is
/// posed in 3D (forward, right, up), rotated to the facing angle and projected
/// onto a slightly tilted billboard so limbs overlap correctly from any angle.
///
/// All drawing happens in local units (feet at the origin, about 74 units
/// tall); callers translate and scale the canvas beforehand.
class SoldierRenderer {
  SoldierRenderer();

  static const double tilt = 0.36;

  final List<_J> _j = List<_J>.generate(_jointCount, (_) => _J());
  final List<_Seg> _segPool = List<_Seg>.generate(40, (_) => _Seg());
  final List<_Seg> _order = <_Seg>[];
  int _segCount = 0;

  final Paint _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final Paint _base = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final Paint _high = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _layer = Paint();
  final Map<ui.Image, Paint> _camoPaints = <ui.Image, Paint>{};

  static final Float64List _camoMatrix = Float64List.fromList(<double>[
    0.22, 0, 0, 0, //
    0, 0.22, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 1, //
  ]);

  // Muzzle offset (world units) relative to the actor's feet, from the last pose.
  double muzzleX = 0;
  double muzzleY = 0;
  double muzzleZ = 0;

  static int _byDepth(_Seg x, _Seg y) => x.depth.compareTo(y.depth);

  Paint _camoPaint(ui.Image image) {
    return _camoPaints.putIfAbsent(image, () {
      return Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..shader = ui.ImageShader(image, TileMode.repeated, TileMode.repeated, _camoMatrix);
    });
  }

  void _add(int j0, int j1, double w, int mat, [double bias = 0]) {
    if (_segCount >= _segPool.length) return;
    final s = _segPool[_segCount++];
    s.j0 = j0;
    s.j1 = j1;
    s.w = w;
    s.mat = mat;
    s.depth = (_j[j0].d + _j[j1].d) * 0.5 + bias;
  }

  /// Poses the skeleton in local 3D space and projects it.
  void computePose(RigPose p, WeaponModel wm) {
    final j = _j;
    final t = p.time;
    final mv = p.move.clamp(0.0, 1.0);
    final sprint = p.sprint.clamp(0.0, 1.0);
    final aim = (p.aim * (1 - sprint)).clamp(0.0, 1.0);
    final ph = p.walkPhase;
    final stride = (6.5 + 5.5 * mv + 5 * sprint) * mv;
    final lift = (3.2 + 3.2 * sprint) * mv;
    final breath = math.sin(t * 2.1) * 0.45 * (1 - mv);
    final bob = -math.sin(ph).abs() * 1.4 * mv;
    final hit = p.hit.clamp(0.0, 1.0);

    final pelvisC = 36.0 + bob + breath * 0.3;
    final lean = 0.05 + 0.08 * mv + 0.24 * sprint - 0.38 * hit + 0.04 * aim;
    final sl = math.sin(lean);
    final cl = math.cos(lean);
    j[_pelvis].set(0, 0, pelvisC);
    j[_chest].set(sl * 18, 0, pelvisC + cl * 18 + breath);
    j[_neck].set(j[_chest].a + sl * 5.5, 0, j[_chest].c + cl * 5.5);
    j[_head].set(j[_neck].a + sl * 5.5 - hit * 2.5, hit * 1.5, j[_neck].c + cl * 5.2);
    j[_vestLo].set(sl * 6.5, 0, pelvisC + cl * 6.5);

    final twist = aim * 2.2;
    j[_shL].set(j[_chest].a + twist, -8.6, j[_chest].c - 1.6);
    j[_shR].set(j[_chest].a - twist, 8.6, j[_chest].c - 1.6);
    j[_hipL].set(0, -4.8, pelvisC - 1);
    j[_hipR].set(0, 4.8, pelvisC - 1);

    final stanceL = 3.5 * aim * (1 - mv);
    final stanceR = -2.5 * aim * (1 - mv);
    final sp = math.sin(ph);
    final cp = math.cos(ph);
    final liftL = math.max(0.0, cp) * lift;
    final liftR = math.max(0.0, -cp) * lift;
    j[_ftL].set(sp * stride + stanceL, -6.2, 1.6 + liftL);
    j[_ftR].set(-sp * stride + stanceR, 6.2, 1.6 + liftR);
    j[_toeL].set(j[_ftL].a + 5, -6.4, j[_ftL].c - 1.1);
    j[_toeR].set(j[_ftR].a + 5, 6.4, j[_ftR].c - 1.1);
    j[_knL].set((j[_hipL].a + j[_ftL].a) * 0.5 + 3.8 + liftL * 0.5, -5.6,
        (j[_hipL].c + j[_ftL].c) * 0.5 + 0.6);
    j[_knR].set((j[_hipR].a + j[_ftR].a) * 0.5 + 3.8 + liftR * 0.5, 5.6,
        (j[_hipR].c + j[_ftR].c) * 0.5 + 0.6);

    // Weapon placement: blend low-ready, shouldered and sprint carry.
    final ch = j[_chest];
    var ra = ch.a + 1 + 2 * aim;
    var rb = 7.0 - 1.6 * aim;
    var rc = ch.c - 10 + 7.6 * aim;
    var da = 0.8 + 0.2 * aim;
    var db = -0.45 + 0.33 * aim;
    var dc = -0.42 + 0.42 * aim;
    if (sprint > 0) {
      ra += (ch.a + 2 - ra) * sprint;
      rb += (7.5 - rb) * sprint;
      rc += (ch.c - 9 - rc) * sprint;
      da += (0.3 - da) * sprint;
      db += (-0.8 - db) * sprint;
      dc += (0.45 - dc) * sprint;
    }
    final reloading = p.reload >= 0;
    if (reloading) {
      final k = math.sin(p.reload.clamp(0.0, 1.0) * math.pi);
      db -= 0.25 * k;
      dc += 0.28 * k;
      ra -= 2 * k;
      rc -= 1.5 * k;
    }
    final rec = p.recoil.clamp(0.0, 1.0);
    ra -= rec * 3.2;
    dc += rec * 0.32;
    var dl = math.sqrt(da * da + db * db + dc * dc);
    if (dl < 1e-6) dl = 1;
    da /= dl;
    db /= dl;
    dc /= dl;
    final len = wm.length;
    j[_gRear].set(ra, rb, rc);
    j[_gMuzzle].set(ra + da * len, rb + db * len, rc + dc * len);
    j[_hnR].set(ra + da * len * wm.gripAt, rb + db * len * wm.gripAt, rc + dc * len * wm.gripAt - 1.0);
    final fa = ra + da * len * wm.foreAt;
    final fb = rb + db * len * wm.foreAt;
    final fc = rc + dc * len * wm.foreAt;
    j[_foreA].set(ra + da * len * (wm.foreAt - 0.14), rb + db * len * (wm.foreAt - 0.14),
        rc + dc * len * (wm.foreAt - 0.14) - 0.6);
    j[_foreB].set(ra + da * len * (wm.foreAt + 0.12), rb + db * len * (wm.foreAt + 0.12),
        rc + dc * len * (wm.foreAt + 0.12) - 0.6);
    final ma = ra + da * len * wm.magAt;
    final mb = rb + db * len * wm.magAt;
    final mc = rc + dc * len * wm.magAt;
    j[_magTop].set(ma, mb, mc);
    j[_magBot].set(ma + da * 1.6, mb, mc - wm.magLength);
    j[_scA].set(ra + da * len * 0.24, rb + db * len * 0.24, rc + dc * len * 0.24 + 2.8);
    j[_scB].set(ra + da * len * 0.52, rb + db * len * 0.52, rc + dc * len * 0.52 + 2.8);

    // Left hand: on the foregrip, or running the magazine change.
    j[_hnL].set(fa, fb, fc - 1.0);
    if (reloading) {
      final r = p.reload.clamp(0.0, 1.0);
      final pouch = j[_tmp]..set(j[_pelvis].a + 4, -6.5, pelvisC + 2);
      final magGrip = j[_tmp2]..set(ma, mb, mc - wm.magLength - 0.5);
      final grip = j[_tmp3]..set(fa, fb, fc - 1.0);
      final hand = j[_hnL];
      if (r < 0.25) {
        hand.lerpTo(grip, magGrip, r / 0.25);
      } else if (r < 0.5) {
        hand.lerpTo(magGrip, pouch, (r - 0.25) / 0.25);
      } else if (r < 0.75) {
        hand.lerpTo(pouch, magGrip, (r - 0.5) / 0.25);
      } else {
        hand.lerpTo(magGrip, grip, (r - 0.75) / 0.25);
      }
      if (r >= 0.25 && r < 0.75 && wm.magLength > 0) {
        j[_magTop].set(hand.a, hand.b, hand.c + 1.5);
        j[_magBot].set(hand.a + 1.2, hand.b, hand.c + 1.5 - wm.magLength);
      }
    }
    final eL = j[_elL];
    eL.set((j[_shL].a + j[_hnL].a) * 0.5 - 2.5, (j[_shL].b + j[_hnL].b) * 0.5 - 4.2,
        (j[_shL].c + j[_hnL].c) * 0.5 - 4.2);
    final eR = j[_elR];
    eR.set((j[_shR].a + j[_hnR].a) * 0.5 - 3.2, (j[_shR].b + j[_hnR].b) * 0.5 + 4.0,
        (j[_shR].c + j[_hnR].c) * 0.5 - 4.6);

    j[_pkTop].set(ch.a - 6.2, 0, ch.c - 0.5);
    j[_pkBot].set(j[_pelvis].a - 5.4, 0, pelvisC + 5.5);

    // Death: rotate the whole body backward around the feet.
    final death = p.death.clamp(0.0, 1.0);
    if (death > 0) {
      final e = death * death * (3 - 2 * death);
      final phi = e * 1.48;
      final cs = math.cos(phi);
      final sn = math.sin(phi);
      for (var i = 0; i < _jointCount; i++) {
        if (i == _gRear || i == _gMuzzle || i == _magTop || i == _magBot ||
            i == _scA || i == _scB || i == _foreA || i == _foreB) {
          continue;
        }
        final q = j[i];
        final na = q.a * cs - q.c * sn;
        final nc = q.a * sn + q.c * cs;
        q.a = na;
        q.c = math.max(nc, 1.2 + (i == _head ? 3.5 : 0.0));
      }
      // The weapon drops to the ground beside the body.
      final w = e;
      final ga = 6.0;
      final gb = 13.0;
      void drop(int idx, double along, double up) {
        final q = j[idx];
        final ta = ga + along * 0.85;
        final tb = gb - along * 0.35;
        final tc = 1.6 + up;
        q.a += (ta - q.a) * w;
        q.b += (tb - q.b) * w;
        q.c += (tc - q.c) * w;
      }

      drop(_gRear, 0, 0);
      drop(_gMuzzle, len, 0);
      drop(_foreA, len * (wm.foreAt - 0.14), 0);
      drop(_foreB, len * (wm.foreAt + 0.12), 0);
      drop(_magTop, len * wm.magAt, 0);
      drop(_magBot, len * wm.magAt, -0.5);
      drop(_scA, len * 0.24, 2.0);
      drop(_scB, len * 0.52, 2.0);
    }

    // Project into billboard space.
    final cf = math.cos(p.facing);
    final sf = math.sin(p.facing);
    for (var i = 0; i < _jointCount; i++) {
      final q = j[i];
      final wx = q.a * cf - q.b * sf;
      final wy = q.a * sf + q.b * cf;
      q.x = wx;
      q.y = -q.c + wy * tilt;
      q.d = wy;
    }
    final m = j[_gMuzzle];
    muzzleX = m.a * cf - m.b * sf;
    muzzleY = m.a * sf + m.b * cf;
    muzzleZ = m.c;
  }

  Color _matColor(int mat, RigLook look, WeaponModel wm) {
    switch (mat) {
      case _mUniform:
        return look.uniform;
      case _mVest:
        return look.vest;
      case _mSkin:
        return look.skin;
      case _mBoots:
        return look.boots;
      case _mGloves:
        return look.gloves;
      case _mGear:
        return look.gear;
      case _mMetal:
        return wm.metal;
      default:
        return wm.furniture;
    }
  }

  /// Poses and draws the soldier. [flash] (0..1) whitens the body for hit
  /// feedback, [alpha] fades the whole figure.
  void draw(
    Canvas canvas,
    RigPose p,
    RigLook look,
    WeaponModel wm, {
    bool detailed = true,
    double flash = 0,
    double alpha = 1,
  }) {
    computePose(p, wm);
    final j = _j;
    final bulk = look.bulk;
    _segCount = 0;

    _add(_hipL, _knL, 6.6 * bulk, _mUniform);
    _add(_knL, _ftL, 5.7 * bulk, _mUniform);
    _add(_ftL, _toeL, 4.6 * bulk, _mBoots, 0.05);
    _add(_hipR, _knR, 6.6 * bulk, _mUniform);
    _add(_knR, _ftR, 5.7 * bulk, _mUniform);
    _add(_ftR, _toeR, 4.6 * bulk, _mBoots, 0.05);
    _add(_hipL, _hipR, 7.4 * bulk, _mUniform, -0.2);
    _add(_pelvis, _chest, 12.6 * bulk, _mUniform);
    _add(_vestLo, _chest, 14.6 * bulk, _mVest, 0.02);
    if (look.backpack) {
      _add(_pkTop, _pkBot, 9.5 * bulk, _mGear);
    }
    _add(_shL, _elL, 5.3 * bulk, _mUniform);
    _add(_elL, _hnL, 4.7 * bulk, _mUniform);
    _add(_hnL, _hnL, 4.4 * bulk, _mGloves, 0.1);
    _add(_shR, _elR, 5.3 * bulk, _mUniform);
    _add(_elR, _hnR, 4.7 * bulk, _mUniform);
    _add(_hnR, _hnR, 4.4 * bulk, _mGloves, 0.1);
    _add(_neck, _head, 4.6 * bulk, _mSkin, -0.1);
    _add(_gRear, _gMuzzle, wm.thickness, _mMetal, 0.15);
    _add(_foreA, _foreB, wm.thickness + 1.4, _mFurniture, 0.18);
    if (wm.magLength > 0) {
      _add(_magTop, _magBot, 2.8, _mMetal, 0.12);
    }
    if (wm.scope) {
      _add(_scA, _scB, 2.8, _mMetal, 0.2);
    }

    _order
      ..clear()
      ..addAll(_segPool.take(_segCount));
    _order.sort(_byDepth);

    final useLayer = alpha < 0.99;
    if (useLayer) {
      _layer.color = Color.fromRGBO(255, 255, 255, alpha.clamp(0.0, 1.0));
      canvas.saveLayer(const Rect.fromLTRB(-95, -125, 95, 30), _layer);
    }

    final headDepth = j[_head].d;
    var headDrawn = false;
    final camo = look.camo;
    for (final s in _order) {
      if (!headDrawn && s.depth > headDepth + 0.3) {
        _drawHead(canvas, p, look, detailed, flash);
        headDrawn = true;
      }
      final a = j[s.j0];
      final b = j[s.j1];
      final p0 = Offset(a.x, a.y);
      final p1 = Offset(b.x, b.y);
      var color = _matColor(s.mat, look, wm);
      if (flash > 0) {
        color = Color.lerp(color, const Color(0xFFFFFFFF), flash * 0.75)!;
      }
      if (detailed) {
        _outline
          ..strokeWidth = s.w + 1.5
          ..color = const Color(0xA0000000);
        canvas.drawLine(p0, p1, _outline);
      }
      Paint paint = _base;
      if (camo != null && flash <= 0 && (s.mat == _mUniform)) {
        paint = _camoPaint(camo);
      } else {
        _base.color = color;
      }
      paint.strokeWidth = s.w;
      canvas.drawLine(p0, p1, paint);
      if (detailed) {
        final hw = s.w * 0.36;
        _high
          ..strokeWidth = hw
          ..color = s.mat == _mMetal ? const Color(0x55D8E0E8) : const Color(0x30FFFFFF);
        final off = Offset(-s.w * 0.16, -s.w * 0.2);
        canvas.drawLine(p0 + off, p1 + off, _high);
      }
    }
    if (!headDrawn) {
      _drawHead(canvas, p, look, detailed, flash);
    }
    if (useLayer) {
      canvas.restore();
    }
  }

  void _drawHead(Canvas canvas, RigPose p, RigLook look, bool detailed, double flash) {
    final h = _j[_head];
    final bulk = look.bulk;
    final r = 5.1 * math.sqrt(bulk);
    final center = Offset(h.x, h.y);
    final cf = math.cos(p.facing);
    final sf = math.sin(p.facing);
    final toward = sf;
    final faceOff = Offset(cf * 2.6, sf * SoldierRenderer.tilt * 2.6 + 1.2);

    Color tint(Color c) => flash > 0 ? Color.lerp(c, const Color(0xFFFFFFFF), flash * 0.75)! : c;

    if (detailed) {
      _fill.color = const Color(0xA0000000);
      canvas.drawCircle(center, r + 0.9, _fill);
    }
    final skin = look.headGear == HeadGear.balaclava ? const Color(0xFF1E1F21) : look.skin;
    _fill.color = tint(skin);
    canvas.drawCircle(center, r, _fill);

    if (toward > -0.25) {
      _fill.color = tint(look.headGear == HeadGear.balaclava
          ? const Color(0xFF2A2B2E)
          : Color.lerp(look.skin, const Color(0xFFFFFFFF), 0.08)!);
      canvas.drawCircle(center + faceOff, r * 0.62, _fill);
    }

    switch (look.headGear) {
      case HeadGear.helmet:
      case HeadGear.balaclava:
        _drawHelmet(canvas, center, r, 1.1, tint(look.helmet), detailed, toward);
        break;
      case HeadGear.heavyHelmet:
        _drawHelmet(canvas, center, r, 1.22, tint(look.helmet), detailed, toward);
        break;
      case HeadGear.beret:
        _fill.color = tint(look.helmet);
        canvas.drawOval(
            Rect.fromCenter(center: center + Offset(-cf * 0.8, -r * 0.62), width: r * 2.3, height: r * 1.1),
            _fill);
        break;
      case HeadGear.bossMask:
        _drawHelmet(canvas, center, r, 1.24, tint(look.helmet), detailed, toward);
        break;
    }

    if (toward > -0.25) {
      final eyeCenter = center + faceOff + Offset(0, -r * 0.18);
      final half = r * (0.35 + 0.35 * toward.abs());
      final eyePaint = _base
        ..strokeWidth = look.headGear == HeadGear.bossMask ? 1.9 : 1.5
        ..color = look.headGear == HeadGear.bossMask
            ? const Color(0xFFFF3A22)
            : look.headGear == HeadGear.heavyHelmet
                ? const Color(0xFF0E1012)
                : look.visor;
      canvas.drawLine(eyeCenter - Offset(half, 0), eyeCenter + Offset(half, 0), eyePaint);
      if (look.headGear == HeadGear.bossMask && detailed) {
        _base
          ..strokeWidth = 4.2
          ..color = const Color(0x55FF4020);
        canvas.drawLine(eyeCenter - Offset(half, 0), eyeCenter + Offset(half, 0), _base);
      }
    }
  }

  void _drawHelmet(
      Canvas canvas, Offset center, double r, double scale, Color color, bool detailed, double toward) {
    final hr = r * scale;
    final c = center + Offset(0, -r * 0.14);
    _fill.color = color;
    if (toward < -0.25) {
      // Seen from behind the shell covers most of the head.
      canvas.drawCircle(c + Offset(0, -r * 0.05), hr * 0.98, _fill);
    } else {
      canvas.drawArc(Rect.fromCircle(center: c, radius: hr), math.pi, math.pi, true, _fill);
    }
    if (detailed) {
      _fill.color = const Color(0x38FFFFFF);
      canvas.drawCircle(c + Offset(-hr * 0.32, -hr * 0.5), hr * 0.32, _fill);
      _base
        ..strokeWidth = 1.5
        ..color = Color.lerp(color, const Color(0xFF000000), 0.45)!;
      canvas.drawLine(c + Offset(-hr * 1.04, 0), c + Offset(hr * 1.04, 0), _base);
    }
  }
}
