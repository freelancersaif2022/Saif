import 'dart:math' as math;
import 'dart:ui';

import '../entities/player.dart';
import '../entities/projectiles.dart';
import '../game/amadan_game.dart';
import '../utils/asset_paths.dart';
import '../utils/math_utils.dart';

/// Moves pooled bullets in sub-steps and resolves hits against blocks,
/// enemies and the player.
class BulletSystem {
  BulletSystem(this.game);

  static const int capacity = 200;

  final AmadanGame game;
  final List<Bullet> pool = List<Bullet>.generate(capacity, (_) => Bullet());
  int _cursor = 0;

  void clear() {
    for (final b in pool) {
      b.active = false;
    }
  }

  Bullet? spawn({
    required bool fromPlayer,
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed,
    required double range,
    required double damage,
    required Color color,
    double headshotChance = 0,
    int pierce = 0,
    double width = 1,
  }) {
    for (var k = 0; k < capacity; k++) {
      final i = (_cursor + k) % capacity;
      final b = pool[i];
      if (b.active) continue;
      _cursor = (i + 1) % capacity;
      b
        ..active = true
        ..fromPlayer = fromPlayer
        ..x = x
        ..y = y
        ..z = z
        ..dx = math.cos(angle)
        ..dy = math.sin(angle)
        ..speed = speed
        ..travelled = 0
        ..range = range
        ..damage = damage
        ..headshotChance = headshotChance
        ..pierce = pierce
        ..lastHitId = -1
        ..width = width
        ..color = color;
      return b;
    }
    return null;
  }

  void update(double dt) {
    for (final b in pool) {
      if (!b.active) continue;
      final step = b.speed * dt;
      final n = math.max(1, (step / 20).ceil());
      final seg = step / n;
      for (var k = 0; k < n && b.active; k++) {
        final ox = b.x;
        final oy = b.y;
        b.x += b.dx * seg;
        b.y += b.dy * seg;
        b.travelled += seg;

        final blocker = game.map.bulletBlocker(b.x, b.y, b.z);
        if (blocker != null) {
          final ix = b.x - b.dx * 3;
          final iy = b.y - b.dy * 3;
          game.fx.impactWall(ix, iy, b.z);
          if (b.fromPlayer) {
            AudioCue.impact(game, ix, iy);
          }
          b.active = false;
          break;
        }

        if (b.fromPlayer) {
          if (_hitEnemies(b, ox, oy, seg)) break;
        } else {
          if (_hitPlayer(b, ox, oy, seg)) break;
        }

        if (b.travelled >= b.range) {
          if (b.fromPlayer && rng.nextDouble() < 0.5) {
            game.fx.impactGround(b.x, b.y);
          }
          b.active = false;
          break;
        }
      }
    }
  }

  bool _hitEnemies(Bullet b, double ox, double oy, double seg) {
    for (final e in game.director.pool) {
      if (!e.active || !e.alive || e.id == b.lastHitId) continue;
      final r = e.radius;
      final ex = e.x - ox;
      final ey = e.y - oy;
      if (ex.abs() > r + seg + 2 || ey.abs() > r + seg + 2) continue;
      final t = clampD(ex * b.dx + ey * b.dy, 0, seg);
      final px = ox + b.dx * t;
      final py = oy + b.dy * t;
      final lx = e.x - px;
      final ly = e.y - py;
      final lateral2 = lx * lx + ly * ly;
      if (lateral2 > r * r) continue;
      final lateral = math.sqrt(lateral2);
      final headshot = lateral < r * 0.34 && rng.nextDouble() < b.headshotChance;
      var dmg = b.damage;
      final falloffStart = b.range * 0.6;
      if (b.travelled > falloffStart) {
        dmg *= 1 - 0.4 * clampD((b.travelled - falloffStart) / (b.range - falloffStart), 0, 1);
      }
      if (headshot) dmg *= 2.0;
      game.director.damageEnemy(e, dmg, headshot, b.dx, b.dy, px, py);
      if (b.pierce > 0) {
        b.pierce -= 1;
        b.lastHitId = e.id;
        b.damage *= 0.7;
        continue;
      }
      b.active = false;
      return true;
    }
    return false;
  }

  bool _hitPlayer(Bullet b, double ox, double oy, double seg) {
    final p = game.player;
    if (!p.alive) return false;
    const r = Player.radius + 2;
    final ex = p.x - ox;
    final ey = p.y - oy;
    if (ex.abs() > r + seg + 2 || ey.abs() > r + seg + 2) return false;
    final t = clampD(ex * b.dx + ey * b.dy, 0, seg);
    final lx = p.x - (ox + b.dx * t);
    final ly = p.y - (oy + b.dy * t);
    if (lx * lx + ly * ly > r * r) return false;
    game.fx.impactBody(p.x - b.dx * 8, p.y - b.dy * 8, 44, b.dx, b.dy, false);
    game.damagePlayer(b.damage, b.x - b.dx * 200, b.y - b.dy * 200);
    b.active = false;
    return true;
  }
}

/// Distance-attenuated one-shot sounds triggered from gameplay systems.
class AudioCue {
  AudioCue._();

  static double volumeAt(AmadanGame game, double x, double y, {double radius = 1500}) {
    final d = math.sqrt(dist2(x, y, game.player.x, game.player.y));
    return clampD(1 - d / radius, 0, 1);
  }

  static void impact(AmadanGame game, double x, double y) {
    final v = volumeAt(game, x, y, radius: 900);
    if (v > 0.05) game.audio.play(Sfx.impact, volume: v * 0.5, minGapMs: 60);
  }
}
