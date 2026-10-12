import 'dart:math' as math;
import 'dart:ui';

import '../audio.dart';
import '../core/utils.dart';
import 'battle.dart';
import 'enemy.dart';
import 'fx.dart';
import 'level_data.dart';

final Paint _paint = Paint()..isAntiAlias = true;
final Paint _stroke = Paint()
  ..isAntiAlias = true
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;
final Path _path = Path();

void _rock(Canvas c, double r, double rot, int seed, double alpha) {
  final rr = math.Random(seed);
  c.save();
  c.rotate(rot);
  _path.reset();
  const n = 9;
  for (var i = 0; i < n; i++) {
    final a = i / n * math.pi * 2;
    final d = r * (0.82 + rr.nextDouble() * 0.2);
    final p = Offset(math.cos(a) * d, math.sin(a) * d);
    if (i == 0) {
      _path.moveTo(p.dx, p.dy);
    } else {
      _path.lineTo(p.dx, p.dy);
    }
  }
  _path.close();
  _paint.color = fade(const Color(0xFF1C1E24), alpha);
  c.drawPath(_path, _paint);
  _stroke
    ..color = fade(const Color(0x667F96B8), alpha)
    ..strokeWidth = 2;
  c.drawPath(_path, _stroke);
  _stroke
    ..color = fade(const Color(0xFF0A0B0E), alpha)
    ..strokeWidth = 2.5;
  c.drawLine(Offset(-r * 0.4, -r * 0.2), Offset(r * 0.1, r * 0.15), _stroke);
  c.drawLine(Offset(r * 0.1, r * 0.15), Offset(r * 0.25, r * 0.55), _stroke);
  c.drawLine(Offset(r * 0.2, -r * 0.5), Offset(r * 0.45, -r * 0.1), _stroke);
  c.restore();
}

// ============================================================== hazards

abstract class Hazard {
  Hazard(this.b, this.x, this.y);
  final Battle b;
  double x;
  double y;
  bool dead = false;
  bool get behind => false;
  bool get smashable => false;
  void shatter() {}
  void update(double dt);
  void render(Canvas c);
}

/// Large boulder rolling across the ground. Jump over it or smash it.
class RollingStone extends Hazard {
  RollingStone(Battle b, this.dir, this.radius)
      : super(b, dir < 0 ? b.viewRight + radius + 40 : b.viewLeft - radius - 40, -radius) {
    speed = randRange(320, 470) * b.cfg.speedMul.clamp(1.0, 1.4);
    _seed = rng.nextInt(99999);
  }

  final double dir;
  final double radius;
  late double speed;
  late int _seed;
  double warn = 1.1;
  double rot = 0;
  double _bump = 0;
  final Set<Object> _hit = {};
  bool _started = false;

  @override
  bool get smashable => warn <= 0 && radius < 55;

  @override
  void shatter() {
    if (dead) return;
    dead = true;
    b.fx.debris(x, 0, n: 16);
    b.fx.dust(x, 0, n: 10, power: 1.2);
    b.sfx(Sfx.stoneImpact, x: x, volume: 0.8);
    b.addShake(0.3);
    b.addScore(50);
  }

  @override
  void update(double dt) {
    if (warn > 0) {
      warn -= dt;
      x = dir < 0 ? b.viewRight + radius + 40 : b.viewLeft - radius - 40;
      if (warn <= 0 && !_started) {
        _started = true;
        b.sfx(Sfx.stoneRoll, volume: 0.8, gap: 400);
      }
      return;
    }
    x += dir * speed * dt;
    rot += dir * speed * dt / radius;
    _bump += dt * speed / 60;
    y = -radius - (math.sin(_bump) * 0.5 + 0.5) * 6;
    if (rng.nextDouble() < 0.4) b.fx.dust(x - dir * radius * 0.6, 0, n: 1, power: 0.7);
    final p = b.player;
    final pr = p.box;
    final nearest = Offset(clampD(x, pr.left, pr.right), clampD(y, pr.top, pr.bottom));
    if ((nearest - Offset(x, y)).distance < radius * 0.92 && !_hit.contains(p) && p.alive) {
      _hit.add(p);
      p.damage(18 * b.cfg.damageMul, x - dir * 50, knock: 420, lift: 420);
      b.sfx(Sfx.stoneImpact, x: x, volume: 0.8);
    }
    for (final e in b.enemies) {
      if (!e.canBeHit || _hit.contains(e)) continue;
      if ((e.x - x).abs() < radius + 10 && e.y > -radius * 1.5) {
        _hit.add(e);
        e.receiveHit(40, dir, 380, heavy: true);
      }
    }
    if (x < -300 || x > b.cfg.length + 300) dead = true;
  }

  @override
  void render(Canvas c) {
    if (warn > 0) {
      // Edge warning chevrons.
      final ex = dir < 0 ? b.viewRight - 60 : b.viewLeft + 60;
      final a = 0.5 + 0.5 * math.sin(b.time * 18);
      _paint.color = fade(const Color(0xFFFF3A2A), a);
      for (var i = 0; i < 2; i++) {
        final ox = ex - dir * i * 26;
        _path
          ..reset()
          ..moveTo(ox, -80)
          ..lineTo(ox - dir * 24, -60)
          ..lineTo(ox, -40)
          ..lineTo(ox + dir * 6, -40)
          ..lineTo(ox - dir * 18, -60)
          ..lineTo(ox + dir * 6, -80)
          ..close();
        c.drawPath(_path, _paint);
      }
      return;
    }
    _paint.color = const Color(0x77000000);
    c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: radius * 2, height: 10), _paint);
    c.save();
    c.translate(x, y);
    _rock(c, radius, rot, _seed, 1);
    c.restore();
  }
}

/// Rock that falls from the sky after a ground warning marker.
class FallingStone extends Hazard {
  FallingStone(Battle b, double tx) : super(b, tx, -1000) {
    radius = randRange(28, 44);
    _seed = rng.nextInt(99999);
  }

  late double radius;
  late int _seed;
  double t = 0;
  double vy = 0;
  bool landed = false;
  double rest = 0;
  static const double fallStart = 0.35;

  @override
  void update(double dt) {
    t += dt;
    if (landed) {
      rest += dt;
      if (rest > 0.8) dead = true;
      return;
    }
    if (t < fallStart) return;
    vy += 1900 * dt;
    y += vy * dt;
    if (y >= -radius) {
      y = -radius;
      landed = true;
      b.fx.debris(x, 0, n: 10);
      b.fx.dust(x, 0, n: 10, power: 1.2);
      b.ring(x, -2, 110, 0.4, const Color(0xFF9AA8C0), 4);
      b.addShake(0.35);
      b.sfx(Sfx.stoneImpact, x: x, volume: 0.9, gap: 80);
      final p = b.player;
      if ((p.x - x).abs() < radius + 50 && p.y > -radius * 2.5 && p.alive) {
        p.damage(22 * b.cfg.damageMul, x, knock: 380, lift: 300);
      }
      for (final e in b.enemies) {
        if (e.canBeHit && (e.x - x).abs() < radius + 40) e.receiveHit(45, e.x >= x ? 1 : -1, 300, heavy: true);
      }
    }
  }

  @override
  void render(Canvas c) {
    if (!landed) {
      // Ground warning.
      final k = clampD((y + 1000) / (1000 - radius), 0, 1);
      final pulse = 0.5 + 0.5 * math.sin(b.time * 20);
      _paint.color = fade(const Color(0xFFFF3020), 0.25 + 0.3 * pulse);
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: (radius + 50) * 2 * (0.5 + 0.5 * k), height: 14), _paint);
      _paint.color = fade(const Color(0xFF000000), 0.4 + 0.4 * k);
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: radius * 2 * (0.3 + 0.7 * k), height: 9), _paint);
    }
    if (y < -900) return;
    final a = landed ? clampD(1 - (rest - 0.4) / 0.4, 0, 1) : 1.0;
    if (!landed) {
      _stroke
        ..color = const Color(0x339AA8C0)
        ..strokeWidth = radius * 0.8;
      c.drawLine(Offset(x, y - radius * 3), Offset(x, y), _stroke);
    }
    c.save();
    c.translate(x, y);
    _rock(c, radius, t * 2, _seed, a);
    c.restore();
  }
}

/// Shadow thorn trap that periodically erupts from the ground.
class SpikeTrap {
  SpikeTrap(this.b, this.def);
  final Battle b;
  final SpikeDef def;
  static const double period = 3.6;
  double _hitCd = 0;
  bool _wasUp = false;

  double get _phase => (b.time + def.phase) % period;
  double get height {
    final p = _phase;
    if (p < 2.0) return 0;
    if (p < 2.6) return 10 + math.sin(b.time * 40) * 3;
    if (p < 2.75) return lerpD(10, 70, (p - 2.6) / 0.15);
    if (p < 3.45) return 70;
    return lerpD(70, 0, (p - 3.45) / 0.15);
  }

  void update(double dt) {
    _hitCd = math.max(0, _hitCd - dt);
    final h = height;
    final up = h > 40;
    if (up && !_wasUp && def.x > b.viewLeft - 100 && def.x < b.viewRight + 100) {
      b.sfx(Sfx.spikeTrap, x: def.x, volume: 0.6, gap: 200);
    }
    _wasUp = up;
    if (!up || _hitCd > 0) return;
    final p = b.player;
    if (p.alive && p.x > def.x - 10 && p.x < def.x + def.width + 10 && p.y > -h + 10) {
      _hitCd = 0.8;
      p.damage(14 * b.cfg.damageMul, p.x - p.facing * 10, knock: 200, lift: 520);
    }
  }

  void render(Canvas c) {
    if (def.x + def.width < b.viewLeft - 50 || def.x > b.viewRight + 50) return;
    _paint.color = const Color(0xFF040406);
    c.drawRect(Rect.fromLTWH(def.x - 6, -3, def.width + 12, 7), _paint);
    final h = height;
    if (h <= 0.5) return;
    final n = (def.width / 18).floor();
    for (var i = 0; i < n; i++) {
      final sx = def.x + 9 + i * 18.0;
      final hh = h * (0.75 + 0.25 * math.sin(i * 2.3));
      _path
        ..reset()
        ..moveTo(sx - 8, 0)
        ..lineTo(sx + math.sin(i * 1.7) * 3, -hh)
        ..lineTo(sx + 8, 0)
        ..close();
      _paint.color = const Color(0xFF07070A);
      c.drawPath(_path, _paint);
      _paint.color = fade(const Color(0xFFFF2A2A), h > 40 ? 0.9 : 0.5);
      c.drawCircle(Offset(sx + math.sin(i * 1.7) * 3, -hh + 2), 2.2, _paint);
    }
  }
}

/// Glowing health orb dropped by enemies.
class HealthPickup {
  HealthPickup(this.b, this.x, this.y)
      : vx = randRange(-80, 80),
        vy = -380;

  final Battle b;
  double x;
  double y;
  double vx;
  double vy;
  double life = 12;
  bool dead = false;
  bool grounded = false;

  void update(double dt) {
    life -= dt;
    if (life <= 0) {
      dead = true;
      return;
    }
    if (!grounded) {
      final prev = y;
      vy += 1600 * dt;
      x += vx * dt;
      y += vy * dt;
      final land = vy > 0 ? b.landingY(x, 10, prev, y) : null;
      if (land != null) {
        y = land;
        grounded = true;
      }
    }
    final p = b.player;
    if (p.alive && (p.x - x).abs() < 42 && y > p.y - 160 && y < p.y + 20) {
      dead = true;
      p.heal(30);
      b.fx.heal(p.x, p.y - 80);
      b.ring(p.x, p.y - 70, 70, 0.4, const Color(0xFFFF5A6A), 3, flat: 1);
      b.sfx(Sfx.pickupHealth, volume: 0.8);
      b.addScore(25);
    }
  }

  void render(Canvas c) {
    if (life < 3 && (life * 8).floor() % 2 == 0) return;
    final bob = grounded ? math.sin(b.time * 3 + x) * 6 - 22 : 0.0;
    final cy = y + bob;
    final pulse = 0.85 + 0.15 * math.sin(b.time * 6);
    _paint
      ..blendMode = BlendMode.plus
      ..color = fade(const Color(0xFFFF3050), 0.18 * pulse);
    c.drawCircle(Offset(x, cy), 30, _paint);
    _paint.color = fade(const Color(0xFFFF5068), 0.35 * pulse);
    c.drawCircle(Offset(x, cy), 16, _paint);
    _paint.blendMode = BlendMode.srcOver;
    // Crystal heart shape.
    c.save();
    c.translate(x, cy);
    c.scale(0.9 + 0.1 * pulse);
    _path
      ..reset()
      ..moveTo(0, 10)
      ..cubicTo(-16, -2, -10, -16, 0, -8)
      ..cubicTo(10, -16, 16, -2, 0, 10)
      ..close();
    _paint.color = const Color(0xFFE0203A);
    c.drawPath(_path, _paint);
    _paint.color = const Color(0xAAFFC0C8);
    c.drawCircle(const Offset(-4, -6), 2.5, _paint);
    c.restore();
    if (rng.nextDouble() < 0.15) {
      b.particles.spawn(px: x + randRange(-12, 12), py: cy, pvy: -40, plife: 0.8, psize: 1.8, pcolor: const Color(0xFFFF6070), pkind: PKind.glow);
    }
  }
}

// ============================================================== projectiles

abstract class Projectile {
  Projectile(this.b, this.x, this.y);
  final Battle b;
  double x;
  double y;
  bool dead = false;
  bool get destructible => true;
  void destroy() {
    dead = true;
    b.fx.shadowBurst(x, y, n: 8);
  }

  void update(double dt);
  void render(Canvas c);
}

/// Shadow bomb dropped by the eagle.
class ShadowBomb extends Projectile {
  ShadowBomb(super.b, super.x, super.y, this.vx, this.vy, {this.damage = 18, this.radius = 115});
  double vx;
  double vy;
  final double damage;
  final double radius;
  double rot = 0;

  @override
  void update(double dt) {
    final prev = y;
    vy += 1350 * dt;
    x += vx * dt;
    y += vy * dt;
    rot += dt * 6;
    if (rng.nextDouble() < 0.6) {
      b.particles.spawn(px: x, py: y, pvx: randRange(-20, 20), pvy: randRange(-30, 0), plife: 0.5, psize: randRange(4, 8), pgrow: 14, pcolor: const Color(0xCC0B0C12));
    }
    final land = vy > 0 ? b.landingY(x, 10, prev, y) : null;
    final p = b.player;
    final direct = p.alive && p.box.inflate(6).contains(Offset(x, y));
    if (land != null || direct) {
      if (land != null) y = land;
      explode();
    }
  }

  void explode() {
    dead = true;
    b.sfx(Sfx.bombExplode, x: x, volume: 0.9, gap: 60);
    b.addShake(0.45);
    b.ring(x, y - 4, radius * 1.3, 0.45, const Color(0xFFFF5A2A), 6);
    b.fx.energy(x, y - 20, n: 26, color: const Color(0xFFFF6A2A), speed: 380);
    b.fx.shadowBurst(x, y - 30, n: 18, spread: 1.4);
    b.fx.debris(x, y, n: 8);
    final p = b.player;
    final c = p.box.center;
    if (p.alive && (c - Offset(x, y)).distance < radius + 40) {
      p.damage(damage * b.cfg.damageMul.clamp(1.0, 2.0), x, knock: 380, lift: 380);
    }
  }

  @override
  void render(Canvas c) {
    c.save();
    c.translate(x, y);
    c.rotate(rot);
    _paint
      ..blendMode = BlendMode.plus
      ..color = const Color(0x44FF3A1A);
    c.drawCircle(Offset.zero, 24, _paint);
    _paint.blendMode = BlendMode.srcOver;
    _paint.color = const Color(0xFF07080B);
    c.drawCircle(Offset.zero, 14, _paint);
    for (var i = 0; i < 4; i++) {
      c.rotate(math.pi / 2);
      _path
        ..reset()
        ..moveTo(-4, -12)
        ..lineTo(0, -21)
        ..lineTo(4, -12)
        ..close();
      c.drawPath(_path, _paint);
    }
    _paint.color = const Color(0xFFFF4020);
    c.drawCircle(Offset.zero, 4 + math.sin(b.time * 25) * 1.5, _paint);
    c.restore();
  }
}

/// Ground shockwave that travels along the floor. Jump over it.
class GroundWave extends Projectile {
  GroundWave(Battle b, double x, this.dir, {this.speed = 560, this.height = 70, this.damage = 16, this.life = 2.2, this.color = const Color(0xFF8A5CFF)})
      : super(b, x, 0);
  final double dir;
  final double speed;
  final double height;
  final double damage;
  double life;
  final Color color;
  bool _hit = false;

  @override
  bool get destructible => false;

  @override
  void update(double dt) {
    life -= dt;
    x += dir * speed * dt;
    if (life <= 0 || x < -100 || x > b.cfg.length + 100) {
      dead = true;
      return;
    }
    if (rng.nextDouble() < 0.9) {
      b.particles.spawn(px: x + randRange(-20, 20), py: -randRange(0, height * 0.6), pvx: -dir * randRange(30, 90), pvy: -randRange(60, 160), plife: randRange(0.3, 0.6), psize: randRange(5, 10), pgrow: 10, pcolor: const Color(0xDD0B0C12));
      b.particles.spawn(px: x, py: -randRange(0, height * 0.8), pvx: -dir * 60, pvy: -randRange(40, 120), plife: 0.4, psize: 2.5, pcolor: color, pkind: PKind.glow);
    }
    final p = b.player;
    if (!_hit && p.alive && (p.x - x).abs() < 34 && p.y > -height * 0.75) {
      _hit = true;
      p.damage(damage * b.cfg.damageMul.clamp(1.0, 2.0), x - dir * 40, knock: 360, lift: 420);
    }
  }

  @override
  void render(Canvas c) {
    final k = clampD(life / 0.4, 0, 1);
    _path
      ..reset()
      ..moveTo(x - dir * 70, 0)
      ..quadraticBezierTo(x - dir * 20, -height * 1.1, x + dir * 22, -height * 0.2)
      ..lineTo(x + dir * 26, 0)
      ..close();
    _paint
      ..blendMode = BlendMode.srcOver
      ..color = fade(const Color(0xFF07070C), 0.92 * k);
    c.drawPath(_path, _paint);
    _stroke
      ..blendMode = BlendMode.plus
      ..color = fade(color, 0.8 * k)
      ..strokeWidth = 3;
    c.drawPath(_path, _stroke);
    _stroke.blendMode = BlendMode.srcOver;
  }
}

/// Spinning cross-shaped shadow blade.
class CrossBlade extends Projectile {
  CrossBlade(super.b, super.x, super.y, this.dir, {this.speed = 560, this.damage = 18});
  final double dir;
  final double speed;
  final double damage;
  double rot = 0;
  double life = 4;

  @override
  void update(double dt) {
    life -= dt;
    x += dir * speed * dt;
    rot += dt * 14 * dir;
    if (life <= 0 || x < -200 || x > b.cfg.length + 200) dead = true;
    final p = b.player;
    if (p.alive && p.box.inflate(22).contains(Offset(x, y))) {
      dead = true;
      p.damage(damage, x - dir * 30, knock: 320);
      b.fx.hitSparks(x, y, dir, n: 10, color: const Color(0xFFFF4A6A));
    }
    if (rng.nextDouble() < 0.7) {
      b.particles.spawn(px: x, py: y, pvx: -dir * 50, pvy: randRange(-20, 20), plife: 0.35, psize: randRange(5, 9), pgrow: 12, pcolor: const Color(0xBB0B0C12));
    }
  }

  @override
  void render(Canvas c) {
    c.save();
    c.translate(x, y);
    c.rotate(rot);
    _paint
      ..blendMode = BlendMode.plus
      ..color = const Color(0x33FF2A4A);
    c.drawCircle(Offset.zero, 40, _paint);
    _paint.blendMode = BlendMode.srcOver;
    for (var i = 0; i < 4; i++) {
      _path
        ..reset()
        ..moveTo(0, 0)
        ..lineTo(-7, -8)
        ..lineTo(0, -40)
        ..lineTo(7, -8)
        ..close();
      _paint.color = const Color(0xFF06060A);
      c.drawPath(_path, _paint);
      _stroke
        ..color = const Color(0xCCFF3A5A)
        ..strokeWidth = 1.6;
      c.drawPath(_path, _stroke);
      c.rotate(math.pi / 2);
    }
    _paint.color = const Color(0xFFFF6A80);
    c.drawCircle(Offset.zero, 4, _paint);
    c.restore();
  }
}

/// Arcing orb of shadow energy that bursts on impact.
class ShadowOrb extends Projectile {
  ShadowOrb(super.b, super.x, super.y, this.vx, this.vy, {this.damage = 16});
  double vx;
  double vy;
  final double damage;

  @override
  void update(double dt) {
    final prev = y;
    vy += 1100 * dt;
    x += vx * dt;
    y += vy * dt;
    b.particles.spawn(px: x, py: y, pvx: randRange(-20, 20), pvy: randRange(-20, 20), plife: 0.4, psize: 4, pcolor: const Color(0xFF9A6AFF), pkind: PKind.glow);
    final land = vy > 0 ? b.landingY(x, 10, prev, y) : null;
    final p = b.player;
    if (land != null || (p.alive && p.box.inflate(10).contains(Offset(x, y)))) {
      dead = true;
      b.ring(x, land ?? y, 100, 0.35, const Color(0xFF9A6AFF), 5);
      b.fx.energy(x, (land ?? y) - 10, n: 18, color: const Color(0xFF9A6AFF), speed: 300);
      b.sfx(Sfx.bombExplode, x: x, volume: 0.55, gap: 60);
      b.addShake(0.2);
      if (p.alive && (p.box.center - Offset(x, land ?? y)).distance < 105) {
        p.damage(damage, x, knock: 300, lift: 300);
      }
    }
  }

  @override
  void render(Canvas c) {
    _paint
      ..blendMode = BlendMode.plus
      ..color = const Color(0x557A4AFF);
    c.drawCircle(Offset(x, y), 26, _paint);
    _paint.blendMode = BlendMode.srcOver;
    _paint.color = const Color(0xFF08060E);
    c.drawCircle(Offset(x, y), 12, _paint);
    _paint.color = const Color(0xFFC8A8FF);
    c.drawCircle(Offset(x, y), 4, _paint);
  }
}

/// Cross-shaped shadow eruption at a marked location.
class CrossSigil extends Projectile {
  CrossSigil(Battle b, double tx, {this.delay = 0.9, this.damage = 24}) : super(b, tx, -120);
  final double delay;
  final double damage;
  double t = 0;
  bool _hit = false;
  bool _erupted = false;
  static const double active = 0.5;

  @override
  bool get destructible => false;

  @override
  void update(double dt) {
    t += dt;
    if (t >= delay && !_erupted) {
      _erupted = true;
      b.sfx(Sfx.monsterCross, x: x, volume: 0.85, gap: 60);
      b.addShake(0.4);
      b.ring(x, -4, 220, 0.5, const Color(0xFFFF2A4A), 7);
      b.fx.energy(x, -120, n: 30, color: const Color(0xFFFF2A4A), speed: 480);
    }
    if (_erupted && !_hit && t < delay + active) {
      final p = b.player.box;
      final vBar = Rect.fromLTRB(x - 36, -440, x + 36, 0);
      final hBar = Rect.fromLTRB(x - 200, -150, x + 200, -96);
      if (b.player.alive && (p.overlaps(vBar) || p.overlaps(hBar))) {
        _hit = true;
        b.player.damage(damage, x, knock: 420, lift: 360);
      }
    }
    if (t > delay + active + 0.35) dead = true;
  }

  @override
  void render(Canvas c) {
    if (t < delay) {
      final k = t / delay;
      final pulse = 0.5 + 0.5 * math.sin(b.time * 22);
      _stroke
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFFFF2A4A), 0.4 + 0.5 * k * pulse)
        ..strokeWidth = 3;
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 140, height: 22), _stroke);
      c.drawLine(Offset(x - 60, -8), Offset(x + 60, 8), _stroke);
      c.drawLine(Offset(x - 60, 8), Offset(x + 60, -8), _stroke);
      _stroke.color = fade(const Color(0xFFFF2A4A), 0.15 * k);
      _stroke.strokeWidth = 50 * k;
      c.drawLine(Offset(x, 0), Offset(x, -440), _stroke);
      _stroke.blendMode = BlendMode.srcOver;
      return;
    }
    final e = t - delay;
    final k = e < active ? 1.0 : clampD(1 - (e - active) / 0.35, 0, 1);
    final grow = clampD(e / 0.08, 0, 1);
    final vBar = Rect.fromLTRB(x - 36 * grow, -440 * grow, x + 36 * grow, 0);
    final hBar = Rect.fromLTRB(x - 200 * grow, -150, x + 200 * grow, -96);
    _paint
      ..blendMode = BlendMode.srcOver
      ..color = fade(const Color(0xFF06050A), 0.95 * k);
    c.drawRect(vBar, _paint);
    c.drawRect(hBar, _paint);
    _paint
      ..blendMode = BlendMode.plus
      ..color = fade(const Color(0xFFFF2A4A), 0.55 * k);
    c.drawRect(vBar.deflate(14 * grow), _paint);
    c.drawRect(hBar.deflate(10 * grow), _paint);
    _paint.color = fade(const Color(0xFFFF8090), 0.5 * k);
    c.drawRect(Rect.fromLTRB(x - 4, -440 * grow, x + 4, 0), _paint);
    c.drawRect(Rect.fromLTRB(x - 200 * grow, -125, x + 200 * grow, -121), _paint);
    _paint.blendMode = BlendMode.srcOver;
  }
}

/// Helper used by bosses to damage any enemies caught in an explosion.
void damageEnemiesInRadius(Battle b, double x, double r, double dmg) {
  for (final Enemy e in b.enemies) {
    if (e.canBeHit && (e.x - x).abs() < r) e.receiveHit(dmg, e.x >= x ? 1 : -1, 300, heavy: true);
  }
}
