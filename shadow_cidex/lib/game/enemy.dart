import 'dart:math' as math;
import 'dart:ui';

import '../audio.dart';
import '../core/utils.dart';
import '../render/humanoid.dart';
import 'battle.dart';
import 'level_data.dart';

class EnemyStats {
  const EnemyStats({
    required this.style,
    required this.hp,
    required this.speed,
    required this.damage,
    required this.range,
    required this.cooldown,
    required this.windup,
    required this.strike,
    required this.recover,
    required this.poise,
    required this.detect,
    required this.score,
    required this.knock,
  });

  final HumanoidStyle style;
  final double hp;
  final double speed;
  final double damage;
  final double range;
  final double cooldown;
  final double windup;
  final double strike;
  final double recover;
  final double poise;
  final double detect;
  final int score;
  final double knock;

  double get height => style.height;

  static EnemyStats of(EnemyKind k) {
    switch (k) {
      case EnemyKind.grunt:
        return const EnemyStats(
          style: HumanoidStyle(height: 122, bulk: 0.92, weapon: WeaponType.dagger, hood: true, eyeGlow: 0.9),
          hp: 45, speed: 215, damage: 8, range: 95, cooldown: 1.25, windup: 0.34, strike: 0.16, recover: 0.32,
          poise: 0, detect: 560, score: 100, knock: 220,
        );
      case EnemyKind.swordsman:
        return const EnemyStats(
          style: HumanoidStyle(height: 150, weapon: WeaponType.katana, eyeGlow: 1.0, bladeColor: Color(0xFF8A9AB0)),
          hp: 75, speed: 175, damage: 12, range: 122, cooldown: 1.5, windup: 0.44, strike: 0.18, recover: 0.38,
          poise: 0.1, detect: 600, score: 150, knock: 280,
        );
      case EnemyKind.heavy:
        return const EnemyStats(
          style: HumanoidStyle(height: 205, bulk: 1.42, weapon: WeaponType.axe, horns: true, shoulderPads: true, eyeGlow: 1.1, bladeColor: Color(0xFF7A8496)),
          hp: 190, speed: 108, damage: 21, range: 160, cooldown: 2.1, windup: 0.7, strike: 0.22, recover: 0.55,
          poise: 0.65, detect: 620, score: 300, knock: 420,
        );
      case EnemyKind.brute:
        return const EnemyStats(
          style: HumanoidStyle(height: 255, bulk: 1.68, weapon: WeaponType.greatsword, horns: true, shoulderPads: true, cape: true, eyeGlow: 1.25, bladeColor: Color(0xFF8A7070), bladeGlow: Color(0xFF801010)),
          hp: 320, speed: 88, damage: 30, range: 195, cooldown: 2.5, windup: 0.85, strike: 0.26, recover: 0.7,
          poise: 0.85, detect: 650, score: 450, knock: 560,
        );
      case EnemyKind.elite:
        return const EnemyStats(
          style: HumanoidStyle(height: 152, weapon: WeaponType.katana, headband: true, bandColor: Color(0xFFB01020), eyeGlow: 1.4, bladeColor: Color(0xFFFFB0B0), bladeGlow: Color(0xFFFF2020)),
          hp: 115, speed: 270, damage: 15, range: 128, cooldown: 0.95, windup: 0.28, strike: 0.16, recover: 0.28,
          poise: 0.2, detect: 760, score: 250, knock: 300,
        );
    }
  }
}

enum EState { spawning, idle, patrol, chase, windup, strike, recover, hurt, dying }

/// AI controlled shadow humanoid.
class Enemy implements Hittable {
  Enemy(this.b, this.kind, this.x, this.side) : stats = EnemyStats.of(kind) {
    final cfg = b.cfg;
    maxHp = stats.hp * cfg.hpMul;
    hp = maxHp;
    speed = stats.speed * cfg.speedMul * randRange(0.92, 1.08);
    damage = stats.damage * cfg.damageMul;
    cooldownBase = stats.cooldown * cfg.cooldownMul;
    windup = stats.windup * math.sqrt(cfg.cooldownMul);
    detect = stats.detect * cfg.detectMul;
    homeX = x;
    facing = b.player.x >= x ? 1 : -1;
    cooldown = randRange(0.4, 1.0);
    switch (side) {
      case SpawnSide.ground:
        alpha = 0;
        break;
      case SpawnSide.sky:
        y = -720;
        vy = 200;
        break;
      case SpawnSide.left:
      case SpawnSide.right:
        aggro = true;
        break;
    }
    pose.idle(0);
  }

  final Battle b;
  final EnemyKind kind;
  final EnemyStats stats;
  final SpawnSide side;
  double x;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double facing = 1;
  late double hp;
  late double maxHp;
  late double speed;
  late double damage;
  late double cooldownBase;
  late double windup;
  late double detect;
  double homeX = 0;
  double cooldown = 0;
  bool aggro = false;
  EState state = EState.spawning;
  double st = 0;
  double alpha = 1;
  double flash = 0;
  double walkPhase = 0;
  double _patrolTarget = 0;
  double _patrolWait = 0;
  int _variant = 0;
  bool _struck = false;
  double _stagger = 0;
  int _staggerChain = 0;
  double _lastHitT = 0;
  bool removed = false;
  bool _deathFx = false;
  final Pose pose = Pose();
  final Pose _target = Pose();
  final Skeleton skel = Skeleton();

  bool get isDead => state == EState.dying;
  bool get solid => state != EState.dying && state != EState.spawning;

  @override
  Rect get hurtBox {
    final h = stats.height;
    final w = h * 0.2 * stats.style.bulk;
    return Rect.fromLTRB(x - w, y - h * 0.97, x + w, y);
  }

  @override
  bool get canBeHit => state != EState.dying && !(state == EState.spawning && alpha < 0.5);

  // ------------------------------------------------------------------ AI

  void update(double dt) {
    st += dt;
    cooldown -= dt;
    flash = math.max(0, flash - dt * 6);
    _stagger = math.max(0, _stagger - dt * 25);
    final p = b.player;
    final dx = p.x - x;
    final adx = dx.abs();
    final dy = (p.y - y).abs();

    switch (state) {
      case EState.spawning:
        _updateSpawn(dt);
        break;
      case EState.idle:
      case EState.patrol:
        if (p.alive && adx < detect && dy < 320) {
          aggro = true;
        }
        if (aggro) {
          _set(EState.chase);
          break;
        }
        _patrol(dt);
        break;
      case EState.chase:
        if (!p.alive) {
          vx *= 0.9;
          if (st > 1) {
            aggro = false;
            _set(EState.patrol);
          }
          break;
        }
        facing = dx >= 0 ? 1 : -1;
        final inRange = adx < stats.range * 0.9 && dy < 150;
        if (adx > stats.range * 0.75) {
          final run = adx > 260;
          final target = facing * speed * (run ? 1.0 : 0.65);
          vx += (target - vx) * smoothK(8, dt);
        } else {
          vx += (0 - vx) * smoothK(10, dt);
        }
        if (dy >= 150 && adx < 90) vx *= 0.8;
        if (inRange && cooldown <= 0 && b.state == BattleState.playing) {
          _variant = kind == EnemyKind.heavy || kind == EnemyKind.brute ? (rng.nextDouble() < 0.6 ? 0 : 1) : rng.nextInt(3);
          _set(EState.windup);
        }
        break;
      case EState.windup:
        vx *= math.max(0, 1 - 10 * dt);
        if (st >= windup) {
          _set(EState.strike);
          _struck = false;
          vx = facing * (kind == EnemyKind.elite ? 360 : 200);
          b.sfx(kind == EnemyKind.brute || kind == EnemyKind.heavy ? Sfx.bossAttack : Sfx.swordSwing, x: x, volume: 0.55, gap: 60);
        }
        break;
      case EState.strike:
        vx *= math.max(0, 1 - 8 * dt);
        if (!_struck) {
          final hb = _attackBox();
          if (hb.overlaps(p.box) && p.alive) {
            _struck = true;
            p.damage(damage, x, knock: stats.knock, lift: stats.knock > 400 ? 380 : 0);
            b.fx.hitSparks(p.x, p.y - 80, facing, n: 8, color: const Color(0xFFFF5050));
            b.sfx(Sfx.swordHit, x: x, volume: 0.6, gap: 50);
          }
        }
        if (kind == EnemyKind.brute && st > stats.strike * 0.5 && !_struck && st - dt <= stats.strike * 0.5) {
          b.addShake(0.25);
          b.fx.dust(x + facing * stats.range * 0.8, 0, n: 8);
        }
        if (st >= stats.strike) _set(EState.recover);
        break;
      case EState.recover:
        vx *= math.max(0, 1 - 8 * dt);
        if (st >= stats.recover) {
          cooldown = cooldownBase * randRange(0.75, 1.35);
          _set(EState.chase);
        }
        break;
      case EState.hurt:
        vx *= math.max(0, 1 - 7 * dt);
        if (st > 0.24 + stats.poise * 0.15) _set(EState.chase);
        break;
      case EState.dying:
        vx *= math.max(0, 1 - 4 * dt);
        if (st > 0.55) {
          alpha = math.max(0, 1 - (st - 0.55) / 0.9);
          if (!_deathFx) {
            _deathFx = true;
            b.fx.disintegrate(hurtBox, n: 26);
          }
          b.fx.disintegrate(Rect.fromLTRB(x - stats.height * 0.45, y - stats.height * 0.35, x + stats.height * 0.45, y), n: 2);
        }
        if (st > 1.5) removed = true;
        break;
    }

    // Physics.
    vy += 2400 * dt;
    x += vx * dt;
    y += vy * dt;
    if (y >= 0) {
      if (vy > 600 && state == EState.spawning) {
        b.fx.dust(x, 0, n: 10, power: 1.1);
        b.sfx(Sfx.land, x: x, volume: 0.6);
        b.addShake(0.1);
      }
      y = 0;
      vy = 0;
    }
    x = clampD(x, 20, b.cfg.length - 20);
    _animate(dt);
  }

  void _set(EState s) {
    state = s;
    st = 0;
  }

  void _updateSpawn(double dt) {
    switch (side) {
      case SpawnSide.ground:
        alpha = clampD(st / 0.9, 0, 1);
        if (st < 0.9 && rng.nextDouble() < 0.6) {
          b.fx.shadowBurst(x + randRange(-30, 30), -randRange(0, 40), n: 2, spread: 0.8);
        }
        if (st >= 0.9) {
          aggro = true;
          _set(EState.chase);
        }
        break;
      case SpawnSide.sky:
        if (y >= 0 && st > 0.1) {
          aggro = true;
          _set(EState.chase);
        }
        break;
      case SpawnSide.left:
      case SpawnSide.right:
        _set(EState.chase);
        break;
    }
  }

  void _patrol(double dt) {
    if (_patrolWait > 0) {
      _patrolWait -= dt;
      vx *= 0.85;
      state = EState.idle;
      return;
    }
    state = EState.patrol;
    if ((x - _patrolTarget).abs() < 12 || _patrolTarget == 0) {
      _patrolTarget = homeX + randRange(-140, 140);
      _patrolWait = randRange(0.6, 1.6);
    }
    final dir = _patrolTarget > x ? 1.0 : -1.0;
    facing = dir;
    vx += (dir * speed * 0.35 - vx) * smoothK(6, dt);
  }

  Rect _attackBox() {
    final r = stats.range;
    final h = stats.height;
    return facing > 0 ? Rect.fromLTRB(x, y - h * 0.95, x + r, y) : Rect.fromLTRB(x - r, y - h * 0.95, x, y);
  }

  @override
  void receiveHit(double dmg, double dir, double knock, {bool heavy = false}) {
    if (!canBeHit) return;
    hp -= dmg;
    flash = 1;
    aggro = true;
    b.sfx(Sfx.enemyHit, x: x, volume: 0.7, gap: 40);
    b.spawnPickup(x, y - stats.height * 0.6, 0.04);
    if (hp <= 0) {
      hp = 0;
      _set(EState.dying);
      vx = dir * knock * 0.8 * (1 - stats.poise * 0.5);
      vy = -260;
      facing = -dir;
      b.sfx(Sfx.enemyDeath, x: x, volume: 0.8, gap: 60);
      b.onEnemyKilled(this);
      b.addShake(0.12 + stats.poise * 0.2);
      return;
    }
    _stagger += dmg;
    final resist = stats.poise;
    vx = dir * knock * (1 - resist);
    // Avoid endless stun-locks: after a few staggers in a row the enemy
    // shrugs off light hits and keeps fighting.
    final now = b.time;
    if (now - _lastHitT > 1.4) _staggerChain = 0;
    _lastHitT = now;
    final armored = _staggerChain >= 3 && !heavy && (state == EState.windup || state == EState.strike || state == EState.chase);
    if (_staggerChain >= 5) _staggerChain = 0;
    if (armored) {
      _staggerChain++;
      vx *= 0.3;
      return;
    }
    if (heavy || resist < 0.5 || _stagger > 45) {
      _staggerChain++;
      _stagger = 0;
      facing = -dir;
      _set(EState.hurt);
      if (heavy && resist < 0.6) {
        vy = -320;
      }
    }
  }

  // ------------------------------------------------------------------ animation

  void _animate(double dt) {
    var rate = 14.0;
    switch (state) {
      case EState.spawning:
        if (side == SpawnSide.sky) {
          _target.fall();
        } else {
          _target.idle(b.time + x);
          _target.torso = 0.5 * (1 - alpha);
        }
        break;
      case EState.idle:
        _target.idle(b.time + x * 0.01);
        break;
      case EState.patrol:
      case EState.chase:
        final sp = vx.abs();
        if (sp > 20) {
          walkPhase += dt * (4 + sp / 40);
          _target.walk(walkPhase, clampD(sp / 220, 0.3, 1), run: sp > 160);
        } else {
          _target.idle(b.time + x * 0.01);
          if ((b.player.y - y) < -150) _target.head = -0.4;
        }
        break;
      case EState.windup:
        final k = clampD(st / windup, 0, 1);
        if (_variant == 1) {
          _target.sweep(0);
          _target.torso = -0.25 * k;
        } else if (_variant == 2) {
          _target.thrust(0);
          _target.torso = -0.15 * k;
        } else {
          _target.windUp(k);
        }
        rate = 18;
        break;
      case EState.strike:
        final k = clampD(st / (stats.strike * 0.7), 0, 1);
        if (_variant == 1) {
          _target.sweep(k);
        } else if (_variant == 2) {
          _target.thrust(k);
        } else {
          _target.slashDown(k);
        }
        rate = 34;
        break;
      case EState.recover:
        _target.idle(b.time);
        _target.torso = 0.25;
        rate = 8;
        break;
      case EState.hurt:
        _target.hurt();
        rate = 28;
        break;
      case EState.dying:
        _target.collapsed(clampD(st / 0.5, 0, 1));
        _target.rot = -1.4 * easeOutCubic(clampD(st / 0.55, 0, 1));
        rate = 14;
        break;
    }
    pose.blend(_target, smoothK(rate, dt));
    skel.compute(pose, stats.style);
  }

  // ------------------------------------------------------------------ render

  static final Paint _p = Paint()..isAntiAlias = true;

  void render(Canvas c) {
    if (alpha <= 0.01) return;
    if (x < b.viewLeft - 300 || x > b.viewRight + 300) return;
    // Contact shadow.
    _p.color = fade(const Color(0x88000000), alpha * clampD(1 + y / 600, 0.2, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: stats.height * 0.5, height: 10), _p);
    // Emerging shadow pool.
    if (state == EState.spawning && side == SpawnSide.ground) {
      _p.color = fade(const Color(0xFF000000), 0.8 * (1 - alpha * 0.5));
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 140, height: 22), _p);
    }
    final telegraph = state == EState.windup ? clampD(st / windup, 0, 1) : 0.0;
    c.save();
    c.translate(x, y);
    c.scale(facing, 1);
    if (pose.rot != 0) c.rotate(pose.rot);
    if (state == EState.spawning && side == SpawnSide.ground) {
      c.clipRect(Rect.fromLTRB(-200, -400, 200, 2));
      c.translate(0, stats.height * (1 - alpha) * 0.6);
    }
    HumanoidPainter.draw(c, skel, pose, stats.style,
        time: b.time + x * 0.003, alpha: alpha, flash: flash, rimDx: facing, wind: 0.3, eyeBoost: telegraph * 1.5);
    c.restore();
    // Health bar.
    if (state != EState.dying && state != EState.spawning && (hp < maxHp || aggro)) {
      final w = 26 + stats.height * 0.22;
      final top = y - stats.height - 22;
      final r = Rect.fromLTWH(x - w / 2, top, w, 5);
      _p.color = const Color(0xAA000000);
      c.drawRect(r.inflate(1.5), _p);
      _p.color = const Color(0xFF3A0A0E);
      c.drawRect(r, _p);
      _p.color = Color.lerp(const Color(0xFFFF2A2A), const Color(0xFFFF8A3A), 1 - hp / maxHp)!;
      c.drawRect(Rect.fromLTWH(r.left, r.top, w * (hp / maxHp), 5), _p);
    }
  }
}
