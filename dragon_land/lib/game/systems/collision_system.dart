import 'dart:math' as math;
import 'dart:ui';

import '../components/coin_component.dart';
import '../components/enemy_component.dart';
import '../components/obstacle_component.dart';
import '../components/projectile_component.dart';
import '../dragon_land_game.dart';
import '../game_config.dart';

/// Axis-aligned overlap tests between the dragon, pickups, obstacles,
/// enemies, the boss and projectiles. Every damaging contact is guarded by
/// per-entity flags/cooldowns so a sustained overlap applies damage once.
class CollisionSystem {
  CollisionSystem(this.game);

  final DragonLandGame game;

  void update(double dt) {
    final d = game.dragon;
    if (d.dead) return;
    final hb = d.hitbox;
    _pickups(hb, dt);
    _obstacles(hb);
    _enemies(hb);
    _boss(hb);
    _playerProjectiles();
    _hostileProjectiles(hb);
  }

  // ---------------------------------------------------------------- pickups
  void _pickups(Rect hb, double dt) {
    final magnet = game.magnetTime > 0 || game.dragon.waterShield > 0;
    final center = hb.center;
    for (final p in game.pickups.items) {
      if (p.collected) continue;
      final isCoin = p.kind == PickupKind.coin || p.kind == PickupKind.coinCluster || p.kind == PickupKind.gem;
      if (magnet && isCoin) {
        final dx = center.dx - p.x, dy = center.dy - p.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < GameConfig.magnetRadius) p.attracted = true;
        if (p.attracted && dist > 1) {
          final s = math.min(dist, 1400 * dt);
          p.x += dx / dist * s;
          p.y += dy / dist * s;
        }
      }
      if (p.kind == PickupKind.gate) {
        final dx = center.dx - p.x, dy = center.dy - p.y;
        if (dx * dx + dy * dy < 75 * 75) game.passGate(p);
        continue;
      }
      if (hb.overlaps(p.hitbox)) game.collect(p);
    }
  }

  // -------------------------------------------------------------- obstacles
  void _obstacles(Rect hb) {
    final d = game.dragon;
    for (final o in game.obstacles.items) {
      if (o.destroyed || o.hitPlayer) continue;
      if (!hb.overlaps(o.hitbox)) continue;
      if (d.dash > 0 || d.waterShield > 0) {
        if (o.destructible) {
          game.destroyObstacle(o, rewarded: true);
        } else {
          o.hitPlayer = true; // phase / bubble straight through thorns
        }
        continue;
      }
      if (d.natureHits > 0) {
        o.hitPlayer = true;
        game.consumeNatureShield();
        game.destroyObstacle(o, rewarded: true);
        continue;
      }
      if (!d.canBeHurt) continue;
      o.hitPlayer = true;
      game.hurtPlayer(o.damage, at: Offset(hb.right, hb.center.dy));
      if (o.kind == ObstacleKind.boulder || o.kind == ObstacleKind.crystal || o.kind == ObstacleKind.pod) {
        game.destroyObstacle(o, rewarded: false);
      }
    }
  }

  // ---------------------------------------------------------------- enemies
  void _enemies(Rect hb) {
    final d = game.dragon;
    for (final e in game.enemies.items) {
      if (!e.alive || e.dying > 0 || e.warn > 0) continue;
      final eb = e.hitbox;
      if (!hb.overlaps(eb)) continue;
      // stomp: falling onto a ground enemy's head
      if (!d.flying && !d.grounded && d.vy > 150 && hb.bottom < eb.top + 34 && !e.def.flying) {
        game.damageEnemy(e, 1);
        d.vy = -760;
        continue;
      }
      if (e.contactCooldown > 0) continue;
      e.contactCooldown = 0.8;
      if (d.dash > 0) {
        game.damageEnemy(e, 4);
        continue;
      }
      if (d.waterShield > 0) {
        game.damageEnemy(e, 1);
        continue;
      }
      if (d.natureHits > 0) {
        game.consumeNatureShield();
        game.damageEnemy(e, 2);
        continue;
      }
      if (d.canBeHurt) {
        game.hurtPlayer(e.def.damage, at: Offset(hb.right, hb.center.dy));
      }
    }
  }

  void _boss(Rect hb) {
    final b = game.enemies.boss;
    final d = game.dragon;
    if (b == null || !b.alive || b.action == BossAction.entering) return;
    if (!hb.overlaps(b.hitbox) || b.contactCooldown > 0) return;
    b.contactCooldown = 1.0;
    if (d.dash > 0) {
      game.damageBoss(4);
    } else if (d.canBeHurt && d.natureHits <= 0) {
      game.hurtPlayer(1, at: hb.centerRight);
    } else if (d.natureHits > 0) {
      game.consumeNatureShield();
      game.damageBoss(2);
    }
  }

  // ------------------------------------------------------------ projectiles
  void _playerProjectiles() {
    for (final pr in game.projectiles.items) {
      if (!pr.active || pr.hostile) continue;
      final box = pr.hitbox;
      for (final e in game.enemies.items) {
        if (!e.alive || e.dying > 0 || e.warn > 0 || e.x > game.viewWidth + 40) continue;
        if (pr.hits.contains(e) || !box.overlaps(e.hitbox)) continue;
        pr.hits.add(e);
        game.damageEnemy(e, pr.damage);
        if (pr.pierce-- <= 0) {
          game.projectileImpact(pr);
          break;
        }
      }
      if (!pr.active) continue;
      for (final o in game.obstacles.items) {
        if (o.destroyed || o.x > game.viewWidth + 40) continue;
        if (!o.destructible && pr.kind != ProjectileKind.fireWave) continue;
        if (pr.hits.contains(o) || !box.overlaps(o.hitbox)) continue;
        pr.hits.add(o);
        game.damageObstacle(o, pr.kind == ProjectileKind.fireWave ? 99 : pr.damage);
        if (pr.pierce-- <= 0) {
          game.projectileImpact(pr);
          break;
        }
      }
      if (!pr.active) continue;
      final b = game.enemies.boss;
      if (b != null && b.alive && b.action != BossAction.entering && !pr.hits.contains(b) && box.overlaps(b.hitbox)) {
        pr.hits.add(b);
        game.damageBoss(pr.damage);
        if (pr.pierce-- <= 0) game.projectileImpact(pr);
      }
    }
  }

  void _hostileProjectiles(Rect hb) {
    final d = game.dragon;
    for (final pr in game.projectiles.items) {
      if (!pr.active || !pr.hostile) continue;
      if (pr.kind == ProjectileKind.rock && pr.y >= GameConfig.groundY - 16 && game.ground.solidAt(pr.x)) {
        game.projectileImpact(pr);
        continue;
      }
      if (!hb.overlaps(pr.hitbox)) continue;
      if (d.shielded || d.invulnerable > 0) {
        if (d.shielded) game.projectileImpact(pr);
        continue;
      }
      if (d.natureHits > 0) {
        game.consumeNatureShield();
        game.projectileImpact(pr);
        continue;
      }
      game.hurtPlayer(pr.damage, at: Offset(pr.x, pr.y));
      game.projectileImpact(pr);
    }
  }
}
