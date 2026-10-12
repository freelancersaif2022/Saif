import 'dart:math' as math;

import '../entities/enemy.dart';
import '../entities/player.dart';
import '../game/amadan_game.dart';
import '../utils/asset_paths.dart';
import '../utils/math_utils.dart';
import '../weapons/weapon_data.dart';

/// Translates touch input into player movement, aiming, firing and reloading.
class PlayerController {
  PlayerController(this.game);

  final AmadanGame game;
  double _emptyTimer = 0;

  static const double walkSpeed = 178;
  static const double sprintSpeed = 292;
  static const double aimSpeed = 112;

  void update(double dt) {
    final p = game.player;
    final input = game.input;
    final w = p.weapon;
    final spec = w.spec;
    p.pose.time += dt;
    if (_emptyTimer > 0) _emptyTimer -= dt;

    if (input.consumeAimToggle()) {
      p.aiming = !p.aiming;
      if (p.aiming) {
        p.sprinting = false;
        p.target = game.director.findTarget(p.x, p.y, spec.range);
        p.retargetTimer = 0.4;
      } else {
        p.target = null;
      }
      game.audio.play(Sfx.uiClick, volume: 0.35, minGapMs: 0);
      game.setAimingFlag(p.aiming);
    }
    if (input.consumeReload()) {
      _tryReload();
    }

    // Maintain the aim lock.
    if (p.aiming) {
      p.retargetTimer -= dt;
      final t = p.target;
      final invalid = t == null ||
          !t.active ||
          !t.alive ||
          !t.hasLos ||
          dist2(p.x, p.y, t.x, t.y) > spec.range * spec.range * 1.2;
      if (invalid || p.retargetTimer <= 0) {
        if (invalid) {
          p.target = game.director.findTarget(p.x, p.y, spec.range);
        }
        p.retargetTimer = 0.5;
      }
    }

    // Movement.
    var mx = input.moveX;
    var my = input.moveY;
    var mag = math.sqrt(mx * mx + my * my);
    if (mag > 1) {
      mx /= mag;
      my /= mag;
      mag = 1;
    }
    final moving = mag > 0.08;
    var wantsSprint = input.sprint && moving && !input.fire;
    if (wantsSprint && !p.sprinting && p.stamina < 0.15) wantsSprint = false;
    if (wantsSprint && p.stamina <= 0) wantsSprint = false;
    if (wantsSprint && !p.sprinting) {
      p.aiming = false;
      p.target = null;
      game.setAimingFlag(false);
    }
    p.sprinting = wantsSprint;

    if (p.sprinting) {
      p.stamina = math.max(0.0, p.stamina - 0.24 * dt);
      p.staminaDelay = 0.9;
      if (p.stamina <= 0) p.sprinting = false;
    } else {
      if (p.staminaDelay > 0) {
        p.staminaDelay -= dt;
      } else {
        p.stamina = math.min(1.0, p.stamina + 0.2 * dt);
      }
    }

    var speed = p.sprinting ? sprintSpeed : (p.aiming ? aimSpeed : walkSpeed);
    if (w.reloading && !p.sprinting) speed *= 0.85;
    final tvx = moving ? mx / mag * speed * math.max(mag, p.sprinting ? 0.8 : 0.0) : 0.0;
    final tvy = moving ? my / mag * speed * math.max(mag, p.sprinting ? 0.8 : 0.0) : 0.0;
    p.vx = approach(p.vx, tvx, 1500 * dt);
    p.vy = approach(p.vy, tvy, 1500 * dt);
    game.map.resolveCircle(p.x + p.vx * dt, p.y + p.vy * dt, Player.radius);
    p.x = game.map.outX;
    p.y = game.map.outY;

    // Aiming direction.
    final moveAngle = moving ? math.atan2(my, mx) : p.pose.facing;
    Enemy? aimEnemy = p.aiming ? p.target : null;
    if (aimEnemy == null && input.fire) {
      aimEnemy = game.director.findTarget(p.x, p.y, spec.range, dirAngle: moveAngle, cone: 0.8);
    }
    if (aimEnemy != null) {
      p.aimAngle = math.atan2(aimEnemy.y - p.y, aimEnemy.x - p.x);
    } else {
      p.aimAngle = moveAngle;
    }
    final desired = p.aimAngle;
    p.pose.facing = turnToward(p.pose.facing, desired, (p.sprinting ? 9 : 13) * dt);

    // Weapon.
    p.sinceFire += dt;
    if (w.update(dt)) {
      game.ammoChanged();
    }
    if (input.fire && !p.sprinting) {
      if (w.ammo <= 0 && !w.reloading) {
        if (_emptyTimer <= 0) {
          game.audio.play(Sfx.empty, volume: 0.6, minGapMs: 200);
          _emptyTimer = 0.4;
        }
        _tryReload();
      } else if (w.canFire) {
        final aligned = wrapAngle(p.aimAngle - p.pose.facing).abs() < 0.45;
        if (aligned) _fire(p, spec, moving);
      }
    }

    // Animation.
    final moveSpeed = math.sqrt(p.vx * p.vx + p.vy * p.vy);
    final pose = p.pose;
    pose.move = clampD(moveSpeed / walkSpeed, 0, 1);
    pose.walkPhase += moveSpeed * dt * 0.072;
    pose.sprint = approach(pose.sprint, p.sprinting ? 1 : 0, dt * 5);
    pose.aim = approach(pose.aim, (p.aiming || p.sinceFire < 0.9) ? 1 : 0, dt * 6);
    pose.recoil = approach(pose.recoil, 0, dt * 7);
    pose.reload = w.reloading ? w.reloadProgress : -1;
    pose.hit = approach(pose.hit, 0, dt * 4);
    p.hitFlash = approach(p.hitFlash, 0, dt * 6);

    p.stepAcc += moveSpeed * dt;
    if (p.stepAcc > (p.sprinting ? 75 : 150) && moveSpeed > 60) {
      p.stepAcc = 0;
      game.fx.dustKick(p.x - p.vx * 0.05, p.y - p.vy * 0.05, p.sprinting ? 18 : 11);
    }

    p.sinceDamage += dt;
    if (p.sinceDamage > 6 && p.hp < Player.maxHp) {
      p.hp = math.min(Player.maxHp, p.hp + 3 * dt);
    }
    p.displayHp = approach(p.displayHp, p.hp, dt * (p.displayHp > p.hp ? 45 : 200));
  }

  void updateDead(double dt) {
    final p = game.player;
    p.deathTimer += dt;
    p.pose.time += dt;
    p.pose.death = clampD(p.deathTimer / 0.9, 0, 1);
    p.pose.recoil = 0;
    p.pose.reload = -1;
    p.pose.move = approach(p.pose.move, 0, dt * 4);
    p.vx *= math.max(0.0, 1 - dt * 5);
    p.vy *= math.max(0.0, 1 - dt * 5);
    p.hitFlash = approach(p.hitFlash, 0, dt * 3);
    p.displayHp = approach(p.displayHp, 0, dt * 60);
  }

  void _tryReload() {
    final p = game.player;
    if (p.weapon.startReload()) {
      p.sprinting = false;
      game.audio.play(Sfx.reload, volume: 0.8, minGapMs: 0);
      game.ammoChanged();
    }
  }

  void _fire(Player p, WeaponSpec spec, bool moving) {
    final w = p.weapon;
    w.consume();
    game.ammoChanged();
    p.sinceFire = 0;
    p.pose.recoil = 1;
    var spread = (p.aiming ? spec.aimSpread : spec.hipSpread) + w.bloom * (p.aiming ? 0.35 : 1);
    if (moving) spread += p.aiming ? 0.006 : 0.018;
    final angle = p.aimAngle;
    final reach = spec.model.length + 6;
    final mx = p.x + math.cos(angle) * reach + math.cos(angle + math.pi / 2) * 3;
    final my = p.y + math.sin(angle) * reach + math.sin(angle + math.pi / 2) * 3;
    const mz = 47.0;
    for (var i = 0; i < spec.pellets; i++) {
      final jitter = spec.pellets > 1 ? randRange(-spread, spread) : (rng.nextDouble() + rng.nextDouble() - 1) * spread;
      game.bullets.spawn(
        fromPlayer: true,
        x: mx,
        y: my,
        z: mz,
        angle: angle + jitter,
        speed: spec.bulletSpeed * randRange(0.96, 1.04),
        range: spec.range * (spec.pellets > 1 ? randRange(0.85, 1.0) : 1.0),
        damage: spec.damage,
        color: spec.tracerColor,
        headshotChance: spec.headshotChance,
        pierce: spec.pierce,
        width: spec.type == WeaponType.sniper ? 2.2 : 1.4,
      );
    }
    final power = spec.type == WeaponType.shotgun
        ? 1.5
        : spec.type == WeaponType.sniper
            ? 1.6
            : spec.type == WeaponType.smg
                ? 0.85
                : 1.0;
    game.fx.muzzleFlash(mx, my, mz, angle, power);
    game.audio.play(spec.sound, volume: 0.8, minGapMs: 25);
    game.shake(spec.shake * 0.55);
    if (w.ammo <= 0) {
      _tryReload();
    }
  }
}
