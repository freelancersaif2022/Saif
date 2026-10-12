import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import '../utils/math_utils.dart';
import 'projection.dart';

/// Cells inside `fx_atlas.png` (128 px each).
class FxCell {
  FxCell._();

  static const int smoke = 0;
  static const int fire = 1;
  static const int flash = 2;
  static const int glow = 3;
  static const int dust = 4;
  static const int chunk = 5;
  static const int ring = 6;
  static const int streak = 7;
}

class Particle {
  bool active = false;
  int index = 0;
  double x = 0;
  double y = 0;
  double z = 0;
  double vx = 0;
  double vy = 0;
  double vz = 0;
  double life = 0;
  double maxLife = 1;
  double size = 10;
  double grow = 0;
  double rot = 0;
  double spin = 0;
  double drag = 0;
  double gravity = 0;
  double alpha = 1;
  double fadeIn = 0;
  int cell = 0;
  int r = 255;
  int g = 255;
  int b = 255;
  bool additive = false;
  bool bounce = false;
}

/// Pooled particle system rendered with two `drawRawAtlas` batches
/// (alpha-blended and additive). A hard cap keeps memory flat forever.
class EffectsSystem {
  EffectsSystem(this.atlas) {
    for (var i = 0; i < maxParticles; i++) {
      _particles[i].index = i;
      _free.add(maxParticles - 1 - i);
    }
    _addPaint.blendMode = BlendMode.plus;
  }

  static const int maxParticles = 380;

  final ui.Image atlas;
  final List<Particle> _particles = List<Particle>.generate(maxParticles, (_) => Particle());
  final List<int> _free = <int>[];

  final Float32List _nTr = Float32List(maxParticles * 4);
  final Float32List _nRc = Float32List(maxParticles * 4);
  final Int32List _nCol = Int32List(maxParticles);
  final Float32List _aTr = Float32List(maxParticles * 4);
  final Float32List _aRc = Float32List(maxParticles * 4);
  final Int32List _aCol = Int32List(maxParticles);

  final Paint _normalPaint = Paint()..filterQuality = FilterQuality.low;
  final Paint _addPaint = Paint()..filterQuality = FilterQuality.low;

  int get activeCount => maxParticles - _free.length;

  void clear() {
    _free.clear();
    for (var i = maxParticles - 1; i >= 0; i--) {
      _particles[i].active = false;
      _free.add(i);
    }
  }

  Particle? _spawn({
    required double x,
    required double y,
    required double z,
    required int cell,
    required double life,
    required double size,
    double vx = 0,
    double vy = 0,
    double vz = 0,
    double grow = 0,
    double drag = 0,
    double gravity = 0,
    double alpha = 1,
    double fadeIn = 0,
    int r = 255,
    int g = 255,
    int b = 255,
    bool additive = false,
    bool bounce = false,
    double spin = 0,
    int reserve = 0,
  }) {
    if (_free.length <= reserve) return null;
    final p = _particles[_free.removeLast()];
    p
      ..active = true
      ..x = x
      ..y = y
      ..z = z
      ..vx = vx
      ..vy = vy
      ..vz = vz
      ..life = life
      ..maxLife = life
      ..size = size
      ..grow = grow
      ..drag = drag
      ..gravity = gravity
      ..alpha = alpha
      ..fadeIn = fadeIn
      ..cell = cell
      ..r = r
      ..g = g
      ..b = b
      ..additive = additive
      ..bounce = bounce
      ..rot = rng.nextDouble() * twoPi
      ..spin = spin;
    return p;
  }

  void update(double dt) {
    for (final p in _particles) {
      if (!p.active) continue;
      p.life -= dt;
      if (p.life <= 0) {
        p.active = false;
        _free.add(p.index);
        continue;
      }
      if (p.drag > 0) {
        final k = math.max(0.0, 1 - p.drag * dt);
        p.vx *= k;
        p.vy *= k;
        p.vz *= k;
      }
      p.vz -= p.gravity * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.z += p.vz * dt;
      if (p.z < 0) {
        if (p.bounce && p.vz < -40) {
          p.z = 0;
          p.vz = -p.vz * 0.35;
          p.vx *= 0.5;
          p.vy *= 0.5;
          p.spin *= 0.5;
        } else {
          p.z = 0;
          p.vz = 0;
          if (p.bounce) {
            p.vx *= 0.8;
            p.vy *= 0.8;
            p.spin = 0;
          }
        }
      }
      p.size += p.grow * dt;
      p.rot += p.spin * dt;
    }
  }

  void render(Canvas canvas, Projection proj) {
    var nn = 0;
    var na = 0;
    for (final p in _particles) {
      if (!p.active) continue;
      if (!proj.project(p.x, p.y, p.z)) continue;
      final px = p.size * proj.scale;
      if (px < 0.6) continue;
      final sx = proj.sx;
      final sy = proj.sy;
      if (sx < -px || sx > proj.width + px || sy < -px || sy > proj.height + px) continue;
      final age = p.maxLife - p.life;
      var a = p.alpha;
      final lifeT = p.life / p.maxLife;
      if (lifeT < 0.35) a *= lifeT / 0.35;
      if (p.fadeIn > 0 && age < p.fadeIn) a *= age / p.fadeIn;
      if (a <= 0.01) continue;
      final scale = px / 128;
      final scos = math.cos(p.rot) * scale;
      final ssin = math.sin(p.rot) * scale;
      final tx = sx - scos * 64 + ssin * 64;
      final ty = sy - ssin * 64 - scos * 64;
      final color = ((a * 255).round().clamp(0, 255) << 24) | (p.r << 16) | (p.g << 8) | p.b;
      final left = p.cell * 128.0;
      if (p.additive) {
        final o = na * 4;
        _aTr[o] = scos;
        _aTr[o + 1] = ssin;
        _aTr[o + 2] = tx;
        _aTr[o + 3] = ty;
        _aRc[o] = left;
        _aRc[o + 1] = 0;
        _aRc[o + 2] = left + 128;
        _aRc[o + 3] = 128;
        _aCol[na] = color;
        na++;
      } else {
        final o = nn * 4;
        _nTr[o] = scos;
        _nTr[o + 1] = ssin;
        _nTr[o + 2] = tx;
        _nTr[o + 3] = ty;
        _nRc[o] = left;
        _nRc[o + 1] = 0;
        _nRc[o + 2] = left + 128;
        _nRc[o + 3] = 128;
        _nCol[nn] = color;
        nn++;
      }
    }
    if (nn > 0) {
      canvas.drawRawAtlas(
        atlas,
        Float32List.sublistView(_nTr, 0, nn * 4),
        Float32List.sublistView(_nRc, 0, nn * 4),
        Int32List.sublistView(_nCol, 0, nn),
        BlendMode.modulate,
        null,
        _normalPaint,
      );
    }
    if (na > 0) {
      canvas.drawRawAtlas(
        atlas,
        Float32List.sublistView(_aTr, 0, na * 4),
        Float32List.sublistView(_aRc, 0, na * 4),
        Int32List.sublistView(_aCol, 0, na),
        BlendMode.modulate,
        null,
        _addPaint,
      );
    }
  }

  // ------------------------------------------------------------- emitters

  void muzzleFlash(double x, double y, double z, double angle, double power) {
    _spawn(x: x, y: y, z: z, cell: FxCell.flash, life: 0.055, size: 26 * power, additive: true, r: 255, g: 220, b: 160);
    _spawn(x: x, y: y, z: z, cell: FxCell.glow, life: 0.09, size: 70 * power, additive: true, alpha: 0.55, r: 255, g: 170, b: 80);
    _spawn(
      x: x + math.cos(angle) * 6,
      y: y + math.sin(angle) * 6,
      z: z,
      cell: FxCell.smoke,
      life: 0.5,
      size: 10 * power,
      grow: 30,
      vx: math.cos(angle) * 60,
      vy: math.sin(angle) * 60,
      vz: 18,
      drag: 3,
      alpha: 0.3,
      r: 200,
      g: 196,
      b: 190,
      reserve: 60,
    );
  }

  void impactWall(double x, double y, double z) {
    _spawn(x: x, y: y, z: z, cell: FxCell.streak, life: 0.09, size: 26, additive: true, r: 255, g: 210, b: 140);
    _spawn(x: x, y: y, z: z, cell: FxCell.dust, life: 0.7, size: 16, grow: 34, vz: 14, drag: 2, alpha: 0.6, r: 170, g: 160, b: 146, reserve: 50);
    for (var i = 0; i < 2; i++) {
      _spawn(
        x: x,
        y: y,
        z: z,
        cell: FxCell.chunk,
        life: 0.8,
        size: 3.5,
        vx: randRange(-80, 80),
        vy: randRange(-30, 60),
        vz: randRange(60, 160),
        gravity: 520,
        bounce: true,
        spin: randRange(-14, 14),
        r: 150,
        g: 146,
        b: 138,
        reserve: 80,
      );
    }
  }

  void impactGround(double x, double y) {
    _spawn(x: x, y: y, z: 2, cell: FxCell.dust, life: 0.8, size: 14, grow: 40, vz: 26, drag: 2, alpha: 0.65, r: 132, g: 112, b: 90, reserve: 60);
    _spawn(
      x: x,
      y: y,
      z: 2,
      cell: FxCell.chunk,
      life: 0.6,
      size: 3,
      vx: randRange(-40, 40),
      vy: randRange(-40, 40),
      vz: randRange(80, 160),
      gravity: 520,
      bounce: true,
      spin: randRange(-12, 12),
      r: 110,
      g: 92,
      b: 72,
      reserve: 90,
    );
  }

  void impactBody(double x, double y, double z, double dirX, double dirY, bool headshot) {
    _spawn(
      x: x,
      y: y,
      z: z,
      cell: FxCell.streak,
      life: headshot ? 0.16 : 0.1,
      size: headshot ? 40 : 26,
      additive: true,
      r: 255,
      g: headshot ? 120 : 200,
      b: headshot ? 90 : 160,
    );
    _spawn(
      x: x,
      y: y,
      z: z,
      cell: FxCell.dust,
      life: 0.5,
      size: 12,
      grow: 30,
      vx: dirX * 70,
      vy: dirY * 70,
      vz: 10,
      drag: 3,
      alpha: 0.6,
      r: 120,
      g: 52,
      b: 44,
      reserve: 50,
    );
  }

  void explosion(double x, double y, double power) {
    _spawn(x: x, y: y, z: 30, cell: FxCell.glow, life: 0.35, size: 420 * power, additive: true, alpha: 0.9, r: 255, g: 160, b: 70);
    _spawn(x: x, y: y, z: 4, cell: FxCell.ring, life: 0.45, size: 60, grow: 900 * power, additive: true, alpha: 0.7, r: 255, g: 220, b: 180);
    for (var i = 0; i < 9; i++) {
      final a = rng.nextDouble() * twoPi;
      final sp = randRange(40, 170) * power;
      _spawn(
        x: x,
        y: y,
        z: randRange(10, 40),
        cell: FxCell.fire,
        life: randRange(0.35, 0.7),
        size: randRange(60, 110) * power,
        grow: 60,
        vx: math.cos(a) * sp,
        vy: math.sin(a) * sp,
        vz: randRange(40, 160),
        drag: 3,
        additive: true,
        r: 255,
        g: 220,
        b: 180,
        spin: randRange(-2, 2),
      );
    }
    for (var i = 0; i < 10; i++) {
      final a = rng.nextDouble() * twoPi;
      final sp = randRange(20, 110) * power;
      _spawn(
        x: x,
        y: y,
        z: randRange(20, 60),
        cell: FxCell.smoke,
        life: randRange(1.6, 2.8),
        size: randRange(70, 120) * power,
        grow: 60,
        vx: math.cos(a) * sp,
        vy: math.sin(a) * sp,
        vz: randRange(30, 90),
        drag: 1.2,
        alpha: 0.75,
        fadeIn: 0.15,
        r: 70,
        g: 64,
        b: 60,
        spin: randRange(-0.6, 0.6),
        reserve: 30,
      );
    }
    for (var i = 0; i < 12; i++) {
      final a = rng.nextDouble() * twoPi;
      final sp = randRange(120, 380) * power;
      _spawn(
        x: x,
        y: y,
        z: 10,
        cell: FxCell.chunk,
        life: randRange(0.9, 1.6),
        size: randRange(4, 9),
        vx: math.cos(a) * sp,
        vy: math.sin(a) * sp,
        vz: randRange(180, 420),
        gravity: 640,
        bounce: true,
        spin: randRange(-16, 16),
        r: 96,
        g: 86,
        b: 76,
        reserve: 40,
      );
    }
    for (var i = 0; i < 8; i++) {
      final a = rng.nextDouble() * twoPi;
      final sp = randRange(200, 420) * power;
      _spawn(
        x: x,
        y: y,
        z: 20,
        cell: FxCell.glow,
        life: randRange(0.4, 0.9),
        size: 9,
        vx: math.cos(a) * sp,
        vy: math.sin(a) * sp,
        vz: randRange(120, 320),
        gravity: 500,
        additive: true,
        r: 255,
        g: 190,
        b: 90,
        reserve: 60,
      );
    }
  }

  void fireTick(double x, double y, double z, double intensity) {
    _spawn(
      x: x + randRange(-16, 16) * intensity,
      y: y + randRange(-8, 8),
      z: z + randRange(0, 8),
      cell: FxCell.fire,
      life: randRange(0.45, 0.8),
      size: randRange(34, 58) * intensity,
      grow: -18,
      vx: randRange(-8, 8),
      vz: randRange(50, 90),
      additive: true,
      r: 255,
      g: 230,
      b: 200,
      spin: randRange(-0.5, 0.5),
      reserve: 70,
    );
  }

  void smokePuff(double x, double y, double z, double intensity, {bool column = false}) {
    final shade = (randRange(40, 70)).round();
    _spawn(
      x: x + randRange(-14, 14),
      y: y + randRange(-6, 6),
      z: z + 20,
      cell: FxCell.smoke,
      life: column ? randRange(4.5, 6.5) : randRange(1.8, 2.8),
      size: randRange(50, 80) * intensity,
      grow: column ? 46 : 30,
      vx: randRange(14, 30),
      vy: randRange(-6, 6),
      vz: column ? randRange(60, 90) : randRange(30, 50),
      alpha: column ? 0.55 : 0.5,
      fadeIn: 0.6,
      r: shade,
      g: shade - 4,
      b: shade - 6,
      spin: randRange(-0.3, 0.3),
      reserve: column ? 110 : 90,
    );
  }

  void dustKick(double x, double y, double size) {
    _spawn(x: x, y: y, z: 2, cell: FxCell.dust, life: 0.7, size: size, grow: 26, vz: 10, drag: 2, alpha: 0.4, r: 130, g: 112, b: 92, reserve: 120);
  }

  void spawnDust(double x, double y) {
    for (var i = 0; i < 5; i++) {
      final a = rng.nextDouble() * twoPi;
      _spawn(
        x: x + math.cos(a) * 14,
        y: y + math.sin(a) * 14,
        z: 6,
        cell: FxCell.dust,
        life: 1.0,
        size: 26,
        grow: 40,
        vx: math.cos(a) * 50,
        vy: math.sin(a) * 50,
        vz: 18,
        drag: 2,
        alpha: 0.5,
        r: 140,
        g: 122,
        b: 100,
        reserve: 80,
      );
    }
  }

  void ember(double x, double y, double z) {
    _spawn(
      x: x,
      y: y,
      z: z,
      cell: FxCell.glow,
      life: randRange(1.6, 3.0),
      size: randRange(2.4, 4.2),
      vx: randRange(-20, 30),
      vy: randRange(-10, 10),
      vz: randRange(20, 50),
      additive: true,
      fadeIn: 0.3,
      r: 255,
      g: 150,
      b: 60,
      reserve: 140,
    );
  }

  void healBurst(double x, double y) {
    for (var i = 0; i < 6; i++) {
      final a = i / 6 * twoPi;
      _spawn(
        x: x + math.cos(a) * 18,
        y: y + math.sin(a) * 18,
        z: 20,
        cell: FxCell.glow,
        life: 0.8,
        size: 16,
        vz: 70,
        additive: true,
        r: 120,
        g: 255,
        b: 150,
      );
    }
  }

  void deathPuff(double x, double y) {
    for (var i = 0; i < 4; i++) {
      final a = rng.nextDouble() * twoPi;
      _spawn(
        x: x + math.cos(a) * 20,
        y: y + math.sin(a) * 20,
        z: 4,
        cell: FxCell.dust,
        life: 1.2,
        size: 30,
        grow: 36,
        vx: math.cos(a) * 30,
        vy: math.sin(a) * 30,
        vz: 12,
        drag: 2,
        alpha: 0.55,
        r: 120,
        g: 104,
        b: 86,
        reserve: 60,
      );
    }
  }
}
