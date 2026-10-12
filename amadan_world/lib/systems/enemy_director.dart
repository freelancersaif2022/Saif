import 'dart:math' as math;
import 'dart:ui';

import '../entities/enemy.dart';
import '../entities/soldier_rig.dart';
import '../game/amadan_game.dart';
import '../utils/asset_paths.dart';
import '../utils/image_store.dart';
import '../utils/math_utils.dart';
import '../weapons/weapon_data.dart';
import 'battle_map.dart';
import 'bullet_system.dart';

/// Spawns, drives and recycles enemies, including the boss encounters.
class EnemyDirector {
  EnemyDirector(this.game) : pool = List<Enemy>.generate(capacity, (i) => Enemy(i)) {
    specs = _buildSpecs();
  }

  static const int capacity = 24;

  final AmadanGame game;
  final List<Enemy> pool;
  late final Map<EnemyKind, EnemySpec> specs;
  double spawnTimer = 2.0;
  Enemy? boss;
  double _heartbeat = 0;

  int get aliveCount {
    var n = 0;
    for (final e in pool) {
      if (e.active && e.alive) n++;
    }
    return n;
  }

  void reset() {
    for (final e in pool) {
      e.active = false;
      e.alive = false;
    }
    spawnTimer = 2.0;
    boss = null;
    _heartbeat = 0;
  }

  Map<EnemyKind, EnemySpec> _buildSpecs() {
    final desert = ImageStore.tryGet(AssetPaths.camoDesert);
    final urban = ImageStore.tryGet(AssetPaths.camoUrban);
    final dark = ImageStore.tryGet(AssetPaths.camoDark);
    final bossCamo = ImageStore.tryGet(AssetPaths.camoBoss);
    return <EnemyKind, EnemySpec>{
      EnemyKind.rifleman: EnemySpec(
        kind: EnemyKind.rifleman,
        hp: 70,
        speed: 105,
        damage: 6,
        fireInterval: 1.6,
        burst: 3,
        burstGap: 0.13,
        range: 560,
        preferredDistance: 380,
        spread: 0.075,
        bulletSpeed: 1050,
        points: 100,
        scale: 1.0,
        weapon: WeaponModel.enemyRifle,
        tracer: const Color(0xFFFF8A4A),
        look: RigLook(
          uniform: const Color(0xFF8A7656),
          vest: const Color(0xFF5E5340),
          skin: const Color(0xFFB98A68),
          helmet: const Color(0xFF6B5E45),
          gear: const Color(0xFF4A4232),
          boots: const Color(0xFF2A2420),
          gloves: const Color(0xFF3A3028),
          headGear: HeadGear.helmet,
          camo: desert,
        ),
      ),
      EnemyKind.rusher: EnemySpec(
        kind: EnemyKind.rusher,
        hp: 50,
        speed: 165,
        damage: 4,
        fireInterval: 0.95,
        burst: 4,
        burstGap: 0.08,
        range: 330,
        preferredDistance: 170,
        spread: 0.12,
        bulletSpeed: 1000,
        points: 120,
        scale: 0.96,
        weapon: WeaponModel.smg,
        tracer: const Color(0xFFFF9A5A),
        look: RigLook(
          uniform: const Color(0xFF5A5C62),
          vest: const Color(0xFF2E3034),
          skin: const Color(0xFFA67C5E),
          helmet: const Color(0xFF26282C),
          gear: const Color(0xFF2E3034),
          boots: const Color(0xFF1C1C1E),
          gloves: const Color(0xFF1E1E20),
          headGear: HeadGear.balaclava,
          camo: urban,
          backpack: false,
        ),
      ),
      EnemyKind.heavy: EnemySpec(
        kind: EnemyKind.heavy,
        hp: 200,
        speed: 68,
        damage: 9,
        fireInterval: 2.2,
        burst: 6,
        burstGap: 0.1,
        range: 600,
        preferredDistance: 420,
        spread: 0.09,
        bulletSpeed: 1000,
        points: 220,
        scale: 1.16,
        weapon: WeaponModel.heavyGun,
        tracer: const Color(0xFFFF7040),
        look: RigLook(
          uniform: const Color(0xFF3E3A34),
          vest: const Color(0xFF2A2724),
          skin: const Color(0xFF9C7458),
          helmet: const Color(0xFF34312C),
          gear: const Color(0xFF26231F),
          boots: const Color(0xFF181614),
          gloves: const Color(0xFF201D1A),
          headGear: HeadGear.heavyHelmet,
          camo: dark,
          bulk: 1.25,
        ),
      ),
      EnemyKind.marksman: EnemySpec(
        kind: EnemyKind.marksman,
        hp: 55,
        speed: 90,
        damage: 15,
        fireInterval: 2.9,
        burst: 1,
        burstGap: 0.1,
        range: 860,
        preferredDistance: 620,
        spread: 0.03,
        bulletSpeed: 1500,
        points: 160,
        scale: 1.0,
        weapon: WeaponModel.sniper,
        tracer: const Color(0xFFFFC080),
        look: RigLook(
          uniform: const Color(0xFF6E6A50),
          vest: const Color(0xFF4C4A38),
          skin: const Color(0xFFC09070),
          helmet: const Color(0xFF5A2A26),
          gear: const Color(0xFF3C3A2C),
          boots: const Color(0xFF241F1A),
          gloves: const Color(0xFF2E2A22),
          headGear: HeadGear.beret,
          camo: desert,
        ),
      ),
      EnemyKind.boss: EnemySpec(
        kind: EnemyKind.boss,
        hp: 2600,
        speed: 78,
        damage: 6,
        fireInterval: 1.0,
        burst: 1,
        burstGap: 0.1,
        range: 700,
        preferredDistance: 360,
        spread: 0.14,
        bulletSpeed: 1150,
        points: 5000,
        scale: 1.6,
        weapon: WeaponModel.minigun,
        tracer: const Color(0xFFFF5030),
        look: RigLook(
          uniform: const Color(0xFF4A1E1A),
          vest: const Color(0xFF1C1A1A),
          skin: const Color(0xFF8C6650),
          helmet: const Color(0xFF181818),
          gear: const Color(0xFF2A1614),
          boots: const Color(0xFF121212),
          gloves: const Color(0xFF161414),
          headGear: HeadGear.bossMask,
          camo: bossCamo,
          bulk: 1.35,
          visor: const Color(0xFFFF3A22),
        ),
      ),
    };
  }

  // ------------------------------------------------------------------ spawning

  void update(double dt) {
    if (game.phase == GamePhase.playing) {
      _spawnLogic(dt);
    }
    for (final e in pool) {
      if (!e.active) continue;
      if (e.alive) {
        if (e.isBoss) {
          _updateBoss(e, dt);
        } else {
          _updateSoldier(e, dt);
        }
      } else {
        _updateDead(e, dt);
      }
    }
  }

  void _spawnLogic(double dt) {
    final s = game.session;
    final maxAlive = s.bossActive ? 3 : math.min(15, 3 + (s.level * 1.4).round());
    final interval = math.max(0.75, 2.7 - s.level * 0.17);
    spawnTimer -= dt;
    if (spawnTimer > 0) return;
    spawnTimer = interval * randRange(0.75, 1.3);
    if (aliveCount >= maxAlive) return;
    _spawnSoldier(_pickKind(s.level));
  }

  EnemyKind _pickKind(int level) {
    var wRifle = 50.0;
    final wRush = level >= 1 ? 26.0 : 0.0;
    final wMark = level >= 2 ? 14.0 + level : 0.0;
    final wHeavy = level >= 3 ? 8.0 + level * 1.5 : 0.0;
    if (level > 5) wRifle = 40;
    final total = wRifle + wRush + wMark + wHeavy;
    var r = rng.nextDouble() * total;
    if ((r -= wRifle) < 0) return EnemyKind.rifleman;
    if ((r -= wRush) < 0) return EnemyKind.rusher;
    if ((r -= wMark) < 0) return EnemyKind.marksman;
    return EnemyKind.heavy;
  }

  Enemy? _free() {
    for (final e in pool) {
      if (!e.active) return e;
    }
    return null;
  }

  bool _findSpawnPoint(double minD, double maxD, double radius) {
    final p = game.player;
    for (var attempt = 0; attempt < 14; attempt++) {
      final front = rng.nextDouble() < 0.7;
      final angle = front ? -math.pi / 2 + randRange(-1.15, 1.15) : rng.nextDouble() * twoPi;
      final d = randRange(minD, maxD);
      final x = p.x + math.cos(angle) * d;
      final y = p.y + math.sin(angle) * d;
      if (game.map.isFree(x, y, radius + 6)) {
        _spawnX = x;
        _spawnY = y;
        return true;
      }
    }
    return false;
  }

  double _spawnX = 0;
  double _spawnY = 0;

  void _spawnSoldier(EnemyKind kind, {double? nearX, double? nearY}) {
    final e = _free();
    if (e == null) return;
    final spec = specs[kind]!;
    if (nearX != null && nearY != null) {
      var placed = false;
      for (var i = 0; i < 10 && !placed; i++) {
        final a = rng.nextDouble() * twoPi;
        final x = nearX + math.cos(a) * randRange(90, 160);
        final y = nearY + math.sin(a) * randRange(90, 160);
        if (game.map.isFree(x, y, 22)) {
          _spawnX = x;
          _spawnY = y;
          placed = true;
        }
      }
      if (!placed) return;
    } else {
      final far = kind == EnemyKind.marksman;
      if (!_findSpawnPoint(far ? 1000 : 880, far ? 1350 : 1220, 18 * spec.scale)) return;
    }
    final level = game.session.level;
    e.activate(spec, _spawnX, _spawnY, 1 + (level - 1) * 0.08, 1 + (level - 1) * 0.05);
    e.pose.facing = math.atan2(game.player.y - e.y, game.player.x - e.x);
    game.fx.spawnDust(e.x, e.y);
    if (rng.nextDouble() < 0.35) {
      final v = AudioCue.volumeAt(game, e.x, e.y, radius: 1500);
      game.audio.play(Sfx.enemyAlert, volume: v * 0.6, minGapMs: 900);
    }
  }

  void spawnBoss() {
    final e = _free() ?? pool.firstWhere((x) => !x.alive, orElse: () => pool.first);
    final spec = specs[EnemyKind.boss]!;
    if (!_findSpawnPoint(820, 1000, 30)) {
      _spawnX = game.player.x;
      _spawnY = (game.player.y - 900).clamp(BattleMap.margin + 40, BattleMap.size - BattleMap.margin - 40).toDouble();
      if (!game.map.isFree(_spawnX, _spawnY, 30)) {
        _spawnY = game.map.startY - 400;
        _spawnX = game.map.startX;
      }
    }
    final bossCount = game.session.bossesDefeated;
    e.activate(spec, _spawnX, _spawnY, 1 + bossCount * 0.45 + (game.session.level - 1) * 0.03,
        1 + bossCount * 0.15);
    e.pose.facing = math.atan2(game.player.y - e.y, game.player.x - e.x);
    boss = e;
    game.fx.spawnDust(e.x, e.y);
    game.fx.explosion(e.x, e.y, 0.6);
    game.audio.play(Sfx.bossRoar, volume: 1.0, minGapMs: 0);
    game.shake(10);
  }

  // ------------------------------------------------------------------ targeting

  /// Nearest visible living enemy within [range]; optionally limited to a
  /// cone of half-angle [cone] around [dirAngle].
  Enemy? findTarget(double px, double py, double range, {double? dirAngle, double cone = 0.7}) {
    Enemy? best;
    var bestScore = double.infinity;
    final r2 = range * range;
    for (final e in pool) {
      if (!e.active || !e.alive || e.spawnFade < 0.5 || !e.hasLos) continue;
      final d2 = dist2(px, py, e.x, e.y);
      if (d2 > r2) continue;
      var score = d2;
      if (dirAngle != null) {
        final a = math.atan2(e.y - py, e.x - px);
        final diff = wrapAngle(a - dirAngle).abs();
        if (diff > cone) continue;
        score *= 1 + diff * 1.5;
      }
      if (score < bestScore) {
        bestScore = score;
        best = e;
      }
    }
    return best;
  }

  // ------------------------------------------------------------------ damage

  void damageEnemy(Enemy e, double damage, bool headshot, double dirX, double dirY, double hx, double hy) {
    if (!e.alive) return;
    e.hp -= damage;
    e.hitFlash = 1;
    e.barTimer = 2.5;
    e.pose.hit = e.isBoss ? 0.35 : 1;
    if (!e.isBoss) {
      e.vx += dirX * 90;
      e.vy += dirY * 90;
    }
    e.losTimer = 0;
    final z = (headshot ? 64.0 : 44.0) * e.spec.scale;
    game.fx.impactBody(hx, hy, z, dirX, dirY, headshot);
    final killed = e.hp <= 0;
    game.registerHit(e.x, e.y, 44 * e.spec.scale, killed, headshot);
    game.audio.play(Sfx.hit, volume: 0.55, minGapMs: 45);
    if (killed) {
      _kill(e, headshot);
    }
  }

  void _kill(Enemy e, bool headshot) {
    e.alive = false;
    e.hp = 0;
    e.deathTimer = 0;
    e.burstLeft = 0;
    e.killedByHeadshot = headshot;
    e.pose.recoil = 0;
    e.pose.reload = -1;
    game.fx.deathPuff(e.x, e.y);
    game.audio.play(Sfx.enemyDeath, volume: AudioCue.volumeAt(game, e.x, e.y) * 0.8, minGapMs: 80);
    if (e.isBoss) {
      boss = null;
      game.fx.explosion(e.x, e.y, 1.3);
      game.audio.play(Sfx.explosion, volume: 1.0, minGapMs: 0);
      game.audio.play(Sfx.bossRoar, volume: 0.8, minGapMs: 0);
      game.shake(16);
      game.addCrater(e.x, e.y, 260);
    }
    game.onEnemyKilled(e, headshot);
  }

  // ------------------------------------------------------------------ soldier AI

  void _updateDead(Enemy e, double dt) {
    e.deathTimer += dt;
    e.pose.time += dt;
    e.pose.death = clampD(e.deathTimer / (e.isBoss ? 1.3 : 0.85), 0, 1);
    e.pose.hit = approach(e.pose.hit, 0, dt * 3);
    e.hitFlash = approach(e.hitFlash, 0, dt * 6);
    e.vx *= math.max(0.0, 1 - dt * 6);
    e.vy *= math.max(0.0, 1 - dt * 6);
    e.x += e.vx * dt;
    e.y += e.vy * dt;
    if (e.deathTimer > 4.4) {
      e.active = false;
    }
  }

  void _updateSoldier(Enemy e, double dt) {
    final p = game.player;
    final spec = e.spec;
    e.pose.time += dt;
    e.spawnFade = math.min(1.0, e.spawnFade + dt * 1.5);
    final dx = p.x - e.x;
    final dy = p.y - e.y;
    final dist = math.sqrt(dx * dx + dy * dy) + 1e-6;
    final nx = dx / dist;
    final ny = dy / dist;

    e.losTimer -= dt;
    if (e.losTimer <= 0) {
      e.hasLos = !game.map.sightBlocked(e.x, e.y, p.x, p.y);
      e.losTimer = 0.22 + rng.nextDouble() * 0.2;
    }
    final playerActive = p.alive && game.phase == GamePhase.playing;
    e.engaging = playerActive && e.hasLos && dist < spec.range && e.spawnFade > 0.8;

    var mx = 0.0;
    var my = 0.0;
    var speedFactor = 0.0;
    final bursting = e.burstLeft > 0;
    if (!playerActive) {
      speedFactor = 0;
    } else if (e.engaging) {
      final pd = spec.preferredDistance;
      if (dist > pd * 1.1) {
        mx = nx;
        my = ny;
        speedFactor = spec.kind == EnemyKind.rusher ? 1.0 : 0.55;
      } else if (dist < pd * 0.7) {
        mx = -nx;
        my = -ny;
        speedFactor = 0.6;
      } else {
        mx = -ny * e.strafeDir;
        my = nx * e.strafeDir;
        speedFactor = spec.kind == EnemyKind.rusher ? 0.7 : 0.38;
      }
      e.strafeTimer -= dt;
      if (e.strafeTimer <= 0) {
        e.strafeDir = -e.strafeDir;
        e.strafeTimer = randRange(1.2, 2.8);
      }
      if (bursting && spec.kind == EnemyKind.heavy) speedFactor = 0;
      if (bursting && spec.kind == EnemyKind.marksman) speedFactor = 0;
    } else {
      mx = nx;
      my = ny;
      speedFactor = 1;
    }

    if (speedFactor > 0) {
      _avoid(e, mx, my, dx, dy, dt);
      mx = _steerX;
      my = _steerY;
    }

    // Separation from nearby allies.
    var sx = 0.0;
    var sy = 0.0;
    for (final o in pool) {
      if (identical(o, e) || !o.active || !o.alive) continue;
      final ox = e.x - o.x;
      final oy = e.y - o.y;
      final min = e.radius + o.radius + 14;
      final d2 = ox * ox + oy * oy;
      if (d2 < min * min && d2 > 1e-4) {
        final d = math.sqrt(d2);
        final push = (min - d) / min;
        sx += ox / d * push;
        sy += oy / d * push;
      }
    }

    final speed = spec.speed * e.speedMul;
    final tvx = mx * speed * speedFactor + sx * 120;
    final tvy = my * speed * speedFactor + sy * 120;
    e.vx = approach(e.vx, tvx, 700 * dt);
    e.vy = approach(e.vy, tvy, 700 * dt);
    _moveActor(e, dt);

    final moveSpeed = math.sqrt(e.vx * e.vx + e.vy * e.vy);
    double desired;
    if (e.engaging || bursting) {
      desired = math.atan2(dy, dx);
    } else if (moveSpeed > 12) {
      desired = math.atan2(e.vy, e.vx);
    } else {
      desired = e.pose.facing;
    }
    e.pose.facing = turnToward(e.pose.facing, desired, 7.5 * dt);
    _animate(e, dt, moveSpeed);

    final aligned = wrapAngle(math.atan2(dy, dx) - e.pose.facing).abs() < 0.35;
    if (e.engaging && aligned) {
      if (e.burstLeft > 0) {
        e.burstTimer -= dt;
        if (e.burstTimer <= 0) {
          _shoot(e, dist);
          e.burstLeft -= 1;
          e.burstTimer = spec.burstGap;
        }
      } else {
        e.fireTimer -= dt;
        if (e.fireTimer <= 0) {
          e.burstLeft = spec.burst;
          e.burstTimer = 0;
          e.fireTimer = spec.fireInterval * randRange(0.8, 1.25);
        }
      }
    } else {
      e.burstLeft = 0;
      if (e.fireTimer < 0.45) e.fireTimer = 0.45;
    }
  }

  double _steerX = 0;
  double _steerY = 0;

  void _avoid(Enemy e, double mx, double my, double tx, double ty, double dt) {
    _steerX = mx;
    _steerY = my;
    if (e.avoidTimer > 0) e.avoidTimer -= dt;
    final probeX = e.x + mx * 64;
    final probeY = e.y + my * 64;
    final idx = game.map.probe(probeX, probeY, e.radius * 0.9);
    if (idx < 0) {
      if (e.avoidTimer <= 0) e.avoidSign = 0;
      return;
    }
    final b = game.map.boxes[idx];
    if (e.avoidSign == 0) {
      final cross = mx * (b.cy - e.y) - my * (b.cx - e.x);
      e.avoidSign = cross > 0 ? -1 : 1;
      if (rng.nextDouble() < 0.15) e.avoidSign = -e.avoidSign;
    }
    e.avoidTimer = 0.9;
    final s = e.avoidSign.toDouble();
    var ax = -my * s;
    var ay = mx * s;
    ax = ax * 1.0 + mx * 0.25;
    ay = ay * 1.0 + my * 0.25;
    final l = math.sqrt(ax * ax + ay * ay) + 1e-6;
    _steerX = ax / l;
    _steerY = ay / l;
  }

  void _moveActor(Enemy e, double dt) {
    final nx = e.x + e.vx * dt;
    final ny = e.y + e.vy * dt;
    final hit = game.map.resolveCircle(nx, ny, e.radius);
    e.x = game.map.outX;
    e.y = game.map.outY;
    if (hit && e.avoidSign != 0 && e.avoidTimer <= 0.2) {
      e.avoidSign = -e.avoidSign;
      e.avoidTimer = 0.9;
    }
    // Keep a little space from the player.
    final p = game.player;
    final pdx = e.x - p.x;
    final pdy = e.y - p.y;
    final min = e.radius + 20;
    final d2 = pdx * pdx + pdy * pdy;
    if (d2 < min * min && d2 > 1e-4) {
      final d = math.sqrt(d2);
      e.x = p.x + pdx / d * min;
      e.y = p.y + pdy / d * min;
    }
  }

  void _animate(Enemy e, double dt, double moveSpeed) {
    final pose = e.pose;
    pose.move = clampD(moveSpeed / 120, 0, 1);
    pose.walkPhase += moveSpeed * dt * 0.075 / e.spec.scale;
    pose.aim = approach(pose.aim, (e.engaging || e.burstLeft > 0) ? 1 : 0, dt * 4);
    pose.recoil = approach(pose.recoil, 0, dt * 7);
    pose.hit = approach(pose.hit, 0, dt * 4);
    e.hitFlash = approach(e.hitFlash, 0, dt * 7);
    if (e.barTimer > 0) e.barTimer -= dt;
    e.stepAcc += moveSpeed * dt;
    if (e.stepAcc > 160 && moveSpeed > 120) {
      e.stepAcc = 0;
      game.fx.dustKick(e.x, e.y, 14);
    }
  }

  void _shoot(Enemy e, double dist) {
    final p = game.player;
    final spec = e.spec;
    var spread = spec.spread + (p.sprinting ? 0.06 : 0) + clampD(dist / 2500, 0, 0.08);
    if (p.aiming) spread += 0.01;
    final base = math.atan2(p.y - e.y, p.x - e.x);
    final angle = base + randRange(-spread, spread);
    final reach = spec.weapon.length * spec.scale;
    final mx = e.x + math.cos(base) * reach;
    final my = e.y + math.sin(base) * reach;
    final mz = 46 * spec.scale;
    game.bullets.spawn(
      fromPlayer: false,
      x: mx,
      y: my,
      z: mz,
      angle: angle,
      speed: spec.bulletSpeed,
      range: spec.range * 1.3,
      damage: spec.damage * e.damageMul,
      color: spec.tracer,
      width: spec.kind == EnemyKind.boss ? 2.0 : 1.2,
    );
    game.fx.muzzleFlash(mx, my, mz, base, spec.kind == EnemyKind.boss ? 1.6 : 0.85);
    e.pose.recoil = 1;
    final v = AudioCue.volumeAt(game, e.x, e.y, radius: 1500);
    if (spec.kind == EnemyKind.boss) {
      game.audio.play(Sfx.bossShot, volume: v * 0.75, minGapMs: 90);
    } else {
      game.audio.play(Sfx.enemyShot, volume: v * 0.55, minGapMs: 55);
    }
  }

  // ------------------------------------------------------------------ boss AI

  static const int _bChase = 0;
  static const int _bMinigun = 1;
  static const int _bGrenade = 2;
  static const int _bWindup = 3;
  static const int _bCharge = 4;

  void _updateBoss(Enemy e, double dt) {
    final p = game.player;
    e.pose.time += dt;
    e.spawnFade = math.min(1.0, e.spawnFade + dt * 1.2);
    final dx = p.x - e.x;
    final dy = p.y - e.y;
    final dist = math.sqrt(dx * dx + dy * dy) + 1e-6;
    final nx = dx / dist;
    final ny = dy / dist;
    e.losTimer -= dt;
    if (e.losTimer <= 0) {
      e.hasLos = !game.map.sightBlocked(e.x, e.y, p.x, p.y);
      e.losTimer = 0.2;
    }
    final playerActive = p.alive && game.phase == GamePhase.playing;

    final wasCritical = e.critical;
    e.critical = e.hp < e.maxHp * 0.25;
    if (e.critical && !wasCritical) {
      game.audio.play(Sfx.bossRoar, volume: 1.0, minGapMs: 0);
      game.shake(8);
      game.showBanner('BOSS CRITICAL', warning: true);
    }
    e.speedMul = e.critical ? 1.35 : 1.0;
    if (e.critical && playerActive) {
      _heartbeat -= dt;
      if (_heartbeat <= 0) {
        _heartbeat = 0.72;
        game.audio.play(Sfx.heartbeat, volume: 0.9, minGapMs: 0);
        game.dangerPulse = 1;
      }
    }

    if (e.summonStage == 0 && e.hp < e.maxHp * 0.6) {
      e.summonStage = 1;
      _spawnSoldier(EnemyKind.rifleman, nearX: e.x, nearY: e.y);
      _spawnSoldier(EnemyKind.rusher, nearX: e.x, nearY: e.y);
      game.audio.play(Sfx.bossRoar, volume: 0.8, minGapMs: 0);
    } else if (e.summonStage == 1 && e.hp < e.maxHp * 0.3) {
      e.summonStage = 2;
      _spawnSoldier(EnemyKind.heavy, nearX: e.x, nearY: e.y);
      _spawnSoldier(EnemyKind.rusher, nearX: e.x, nearY: e.y);
    }

    var mx = 0.0;
    var my = 0.0;
    var speedFactor = 0.0;
    var faceTarget = true;
    final cdScale = e.critical ? 0.55 : 1.0;

    if (!playerActive) {
      e.bossState = _bChase;
    } else {
      switch (e.bossState) {
        case _bChase:
          if (dist > 360 || !e.hasLos) {
            mx = nx;
            my = ny;
            speedFactor = 1;
          } else {
            mx = -ny * e.strafeDir;
            my = nx * e.strafeDir;
            speedFactor = 0.5;
          }
          e.strafeTimer -= dt;
          if (e.strafeTimer <= 0) {
            e.strafeDir = -e.strafeDir;
            e.strafeTimer = randRange(1.5, 3);
          }
          e.bossCooldown -= dt;
          if (e.bossCooldown <= 0 && e.spawnFade > 0.9) {
            final roll = rng.nextDouble();
            if (dist < 650 && roll < 0.33) {
              e.bossState = _bWindup;
              e.bossTimer = 0.65;
              game.audio.play(Sfx.bossRoar, volume: 0.7, minGapMs: 0);
            } else if (e.hasLos && dist < 760 && roll < 0.72) {
              e.bossState = _bMinigun;
              e.bossTimer = 1.7;
              e.burstTimer = 0.25;
            } else {
              e.bossState = _bGrenade;
              e.bossTimer = 0.9;
              _throwGrenades(e);
            }
          }
          break;
        case _bMinigun:
          e.bossTimer -= dt;
          e.burstTimer -= dt;
          if (e.burstTimer <= 0 && e.hasLos) {
            e.burstTimer = e.critical ? 0.075 : 0.1;
            _shoot(e, dist);
          }
          if (e.bossTimer <= 0) {
            e.bossState = _bChase;
            e.bossCooldown = 2.2 * cdScale;
          }
          break;
        case _bGrenade:
          e.bossTimer -= dt;
          if (e.bossTimer <= 0) {
            e.bossState = _bChase;
            e.bossCooldown = 2.4 * cdScale;
          }
          break;
        case _bWindup:
          e.bossTimer -= dt;
          e.hitFlash = math.max(e.hitFlash, 0.35 + 0.35 * math.sin(e.pose.time * 30));
          if (e.bossTimer <= 0) {
            e.bossState = _bCharge;
            e.bossTimer = 0.9;
            e.chargeX = nx;
            e.chargeY = ny;
            e.chargeHit = false;
            game.shake(5);
          }
          break;
        case _bCharge:
          e.bossTimer -= dt;
          faceTarget = false;
          mx = e.chargeX;
          my = e.chargeY;
          speedFactor = 7.2;
          if (!e.chargeHit && dist < e.radius + 30) {
            e.chargeHit = true;
            game.damagePlayer(26 * e.damageMul, e.x, e.y);
            game.knockPlayer(e.chargeX * 160, e.chargeY * 160);
            game.shake(12);
          }
          if (e.bossTimer <= 0) {
            e.bossState = _bChase;
            e.bossCooldown = 2.0 * cdScale;
          }
          break;
      }
    }

    if (speedFactor > 0 && e.bossState != _bCharge) {
      _avoid(e, mx, my, dx, dy, dt);
      mx = _steerX;
      my = _steerY;
    }
    final speed = e.spec.speed * e.speedMul;
    final tvx = mx * speed * speedFactor;
    final tvy = my * speed * speedFactor;
    final accel = e.bossState == _bCharge ? 4000.0 : 500.0;
    e.vx = approach(e.vx, tvx, accel * dt);
    e.vy = approach(e.vy, tvy, accel * dt);
    final bx = e.x + e.vx * dt;
    final by = e.y + e.vy * dt;
    final collided = game.map.resolveCircle(bx, by, e.radius);
    e.x = game.map.outX;
    e.y = game.map.outY;
    if (collided && e.bossState == _bCharge) {
      e.bossState = _bChase;
      e.bossCooldown = 1.6 * cdScale;
      e.vx = 0;
      e.vy = 0;
      game.shake(9);
      game.fx.impactWall(e.x + e.chargeX * e.radius, e.y + e.chargeY * e.radius, 50);
      game.fx.spawnDust(e.x, e.y);
    }
    final pdx = e.x - p.x;
    final pdy = e.y - p.y;
    final min = e.radius + 18;
    final pd2 = pdx * pdx + pdy * pdy;
    if (pd2 < min * min && pd2 > 1e-4) {
      final d = math.sqrt(pd2);
      e.x = p.x + pdx / d * min;
      e.y = p.y + pdy / d * min;
    }

    final moveSpeed = math.sqrt(e.vx * e.vx + e.vy * e.vy);
    final desired = faceTarget ? math.atan2(dy, dx) : math.atan2(e.chargeY, e.chargeX);
    e.pose.facing = turnToward(e.pose.facing, desired, 5 * dt);
    e.engaging = playerActive && e.hasLos;
    _animate(e, dt, math.min(moveSpeed, 200.0));
    e.pose.sprint = approach(e.pose.sprint, e.bossState == _bCharge ? 1 : 0, dt * 6);
    if (e.bossState == _bCharge && moveSpeed > 200) {
      e.stepAcc += moveSpeed * dt;
      if (e.stepAcc > 70) {
        e.stepAcc = 0;
        game.fx.dustKick(e.x, e.y, 30);
      }
    }
  }

  void _throwGrenades(Enemy e) {
    final p = game.player;
    final count = e.critical ? 4 : 3;
    for (var i = 0; i < count; i++) {
      final a = rng.nextDouble() * twoPi;
      final r = i == 0 ? 0.0 : randRange(90, 200);
      final lead = i == 0 ? 0.5 : 0.0;
      game.launchGrenade(
        e.x,
        e.y,
        p.x + p.vx * lead + math.cos(a) * r,
        p.y + p.vy * lead + math.sin(a) * r,
        0.95 + i * 0.18,
        30 * e.damageMul,
      );
    }
  }
}
