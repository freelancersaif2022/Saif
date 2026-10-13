import 'package:dragon_land/game/components/coin_component.dart';
import 'package:dragon_land/game/components/enemy_component.dart';
import 'package:dragon_land/game/components/obstacle_component.dart';
import 'package:dragon_land/game/dragon_land_game.dart';
import 'package:dragon_land/game/game_config.dart';
import 'package:dragon_land/models/dragon_model.dart';
import 'package:dragon_land/models/enemy_model.dart';
import 'package:dragon_land/models/player_progress_model.dart';
import 'package:dragon_land/services/audio_service.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a fully loaded game without a widget tree.
Future<DragonLandGame> makeGame(DragonDef d, {int seed = 1, void Function()? onOver}) async {
  final game = await initializeGame(
    () => DragonLandGame(dragonDef: d, settings: GameSettings(), audio: AudioService(enabled: false), seed: seed, onGameOver: onOver),
  );
  game.onGameResize(Vector2(1600, 720));
  return game;
}

/// A simple autopilot: jumps over hazards and gaps, attacks enemies and
/// uses abilities, so long simulated runs exercise every system.
void autopilot(DragonLandGame g, double t) {
  final d = g.dragon;
  final ahead = d.x + 40 + g.currentSpeed * 0.32;
  for (final gap in g.ground.gaps) {
    if (gap.x0 > d.x && gap.x0 < ahead) g.input.pressJump();
  }
  for (final o in g.obstacles.items) {
    if (o.x < d.x - 20 || o.x > ahead + 40) continue;
    if (o.kind == ObstacleKind.barrier) {
      if (d.energy > GameConfig.flightMinStart && !d.flying) g.input.pressFly();
      g.input.pressAttack();
    } else if (o.kind != ObstacleKind.pod) {
      g.input.pressJump();
    }
  }
  for (final e in g.enemies.items) {
    if (e.x > d.x && e.x < d.x + 700) g.input.pressAttack();
    if (!e.def.flying && e.x > d.x && e.x < ahead + 30) g.input.pressJump();
  }
  if (g.enemies.boss != null) g.input.pressAttack();
  if (t % 9 < 0.02) g.input.pressSpecial();
  if (t % 13 < 0.02) g.input.pressSprint();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final dragon in Dragons.all) {
    test('long endless run with ${dragon.name} stays stable', () async {
      var overs = 0;
      final g = await makeGame(dragon, seed: dragon.id.hashCode, onOver: () => overs++);
      expect(g.phase, RunPhase.playing);
      var t = 0.0;
      var maxEntities = 0;
      final seen = <Type>{};
      const dt = 1 / 60;
      final kindsSeen = <Object>{};
      // 4 simulated minutes (or until defeat, then revive once and continue)
      while (t < 240) {
        autopilot(g, t);
        g.update(dt);
        t += dt;
        for (final e in g.enemies.items) {
          kindsSeen.add(e.kind);
        }
        if (g.enemies.boss != null) kindsSeen.add('boss');
        for (final o in g.obstacles.items) {
          kindsSeen.add(o.kind);
        }
        for (final p in g.pickups.items) {
          kindsSeen.add(p.kind);
        }
        if (g.ground.gaps.isNotEmpty) kindsSeen.add('gap');
        final n = g.enemies.items.length + g.obstacles.items.length + g.pickups.items.length + g.projectiles.items.length;
        if (n > maxEntities) maxEntities = n;
        if (g.phase == RunPhase.over) {
          if (g.canRevive) {
            expect(g.revive(), isTrue);
            expect(g.dragon.health, GameConfig.maxHealth);
            expect(g.dragon.invulnerable, greaterThan(0));
          } else {
            break;
          }
        }
        seen.add(g.phase.runtimeType);
      }
      expect(g.stats.distanceMeters, greaterThan(300), reason: 'the dragon should travel a good distance');
      expect(g.stats.attacks, greaterThan(10));
      expect(g.stats.coins, greaterThan(20), reason: 'coins should be collected');
      expect(maxEntities, lessThan(400), reason: 'entities must not accumulate unboundedly');
      expect(g.particles.count, lessThanOrEqualTo(420));
      expect(overs, lessThanOrEqualTo(2));
      // the course must contain varied content
      expect(kindsSeen.length, greaterThan(8), reason: 'saw: $kindsSeen');
      // ignore: avoid_print
      print(
        '${dragon.name}: ${g.stats.distanceMeters} m, coins ${g.stats.coins}, enemies ${g.stats.enemiesDefeated}, '
        'bosses ${g.stats.bossesDefeated}, max entities $maxEntities, phase ${g.phase}, kinds ${kindsSeen.length}',
      );
      g.onRemove();
    });
  }

  test('idle dragon eventually loses all health and the run ends exactly once', () async {
    var overs = 0;
    final g = await makeGame(Dragons.ember, seed: 7, onOver: () => overs++);
    var t = 0.0;
    while (t < 400 && g.phase != RunPhase.over) {
      g.update(1 / 60);
      t += 1 / 60;
    }
    expect(g.phase, RunPhase.over);
    expect(g.dragon.health, 0);
    expect(overs, 1);
    // paused engine: further updates do not advance the run
    final d = g.stats.distanceUnits;
    g.update(1 / 60);
    expect(g.stats.distanceUnits, d);
    // only one revive per run
    expect(g.revive(), isTrue);
    expect(g.revive(), isFalse);
    g.onRemove();
  });

  test('a single sustained collision damages only once', () async {
    final g = await makeGame(Dragons.ember, seed: 3);
    g.obstacles.items.clear();
    g.enemies.items.clear();
    g.pickups.clear();
    g.ground.gaps.clear();
    final o = Obstacle(ObstacleKind.thorns, g.dragon.x, GameConfig.groundY);
    g.obstacles.items.add(o);
    final hp = g.dragon.health;
    // keep the obstacle glued to the dragon for 3 seconds
    for (var i = 0; i < 180; i++) {
      o.x = g.dragon.x;
      g.collisions.update(1 / 60);
      g.dragon.invulnerable = 0; // even without i-frames the same hazard hits once
    }
    expect(g.dragon.health, hp - 1);
    g.onRemove();
  });

  test('attacks damage enemies and reward once', () async {
    final g = await makeGame(Dragons.solar, seed: 4);
    g.enemies.items.clear();
    final e = Enemy(EnemyDef.stone, g.dragon.x + 300, GameConfig.groundY);
    g.enemies.items.add(e);
    final coins = g.stats.coins;
    g.damageEnemy(e, 10);
    g.damageEnemy(e, 10);
    expect(e.alive, isFalse);
    expect(g.stats.enemiesDefeated, 1);
    expect(g.stats.coins, coins + 6);
    g.onRemove();
  });

  test('coin pickup increases run coins once', () async {
    final g = await makeGame(Dragons.ember, seed: 5);
    final p = g.pickups.spawn(PickupKind.coin, 0, 0);
    final c = g.stats.coins;
    g.collect(p);
    g.collect(p);
    expect(g.stats.coins, c + 1);
    g.onRemove();
  });

  test('jump, fly and sprint change the dragon state', () async {
    final g = await makeGame(Dragons.aqua, seed: 6);
    g.obstacles.items.clear();
    g.enemies.items.clear();
    g.ground.gaps.clear();
    g.input.pressJump();
    g.update(1 / 60);
    g.update(1 / 60);
    expect(g.dragon.grounded, isFalse);
    expect(g.dragon.y, lessThan(GameConfig.groundY));
    for (var i = 0; i < 90; i++) {
      g.update(1 / 60);
    }
    expect(g.dragon.grounded, isTrue);
    g.input.pressFly();
    for (var i = 0; i < 60; i++) {
      g.update(1 / 60);
    }
    expect(g.dragon.flying, isTrue);
    expect(g.dragon.y, closeTo(GameConfig.flightCruiseY, 30));
    expect(g.dragon.energy, lessThan(g.dragon.maxEnergy));
    // flight ends when energy runs out
    for (var i = 0; i < 60 * 8; i++) {
      g.update(1 / 60);
    }
    expect(g.dragon.flying, isFalse);
    g.input.pressSprint();
    g.update(1 / 60);
    expect(g.dragon.sprinting, isTrue);
    for (var i = 0; i < 60 * 5; i++) {
      g.update(1 / 60);
    }
    expect(g.dragon.sprinting, isFalse, reason: 'stamina must run out');
    g.onRemove();
  });
}
