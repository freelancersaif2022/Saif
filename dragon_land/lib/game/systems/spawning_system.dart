import 'dart:math' as math;

import '../../config/economy_config.dart';
import '../../models/enemy_model.dart';
import '../components/coin_component.dart';
import '../components/enemy_component.dart';
import '../components/environment_component.dart';
import '../components/obstacle_component.dart';
import '../dragon_land_game.dart';
import '../game_config.dart';

/// Procedurally generates the endless course ahead of the player.
///
/// Content is laid out in patterns at a spawn cursor that scrolls with the
/// world. Every hazard pattern is followed by a clearance distance derived
/// from the current speed (so the player always has time to react and land),
/// gap widths are capped below the jump distance, and aerial hazards are
/// offset from ground hazards so each combination has a valid line through.
class SpawningSystem {
  SpawningSystem(this.game, {int? seed}) : _rng = math.Random(seed);

  final DragonLandGame game;
  final math.Random _rng;
  double _cursor = 0;
  double _nextBossMeters = GameConfig.firstBossMeters;
  int bossCount = 0;
  int _sinceChest = 0;
  int _sinceGate = 0;

  void reset() {
    _cursor = game.viewWidth * 0.75;
    _nextBossMeters = GameConfig.firstBossMeters;
    bossCount = 0;
    _sinceChest = 0;
    _sinceGate = 0;
    // gentle opening: a welcome coin trail
    _coinLine(_cursor, GameConfig.groundY - 50, 8);
    _cursor += 8 * 52 + 300;
  }

  /// Moves the cursor back so a revive starts with free space ahead.
  void pushCursor(double minAhead) {
    _cursor = math.max(_cursor, game.viewWidth + minAhead);
  }

  double _r(double a, double b) => a + _rng.nextDouble() * (b - a);
  bool _chance(double p) => _rng.nextDouble() < p;

  double get _speed => game.difficulty.speed;
  double get _level => game.difficulty.level;
  double get _meters => game.difficulty.meters;

  /// Horizontal distance covered by a full jump at the current base speed.
  double get _jumpDistance => _speed * (2 * GameConfig.jumpVelocity / GameConfig.gravity);

  /// Free space required after a hazard before the next one.
  double get _clearance => _speed * math.max(0.55, 0.95 - 0.35 * _level) + 140;

  void update(double scroll) {
    _cursor -= scroll;
    var guard = 0;
    while (_cursor < game.viewWidth + 320 && guard++ < 6) {
      _spawnNext();
    }
  }

  void _spawnNext() {
    final boss = game.enemies.boss;
    if (boss != null) {
      // Boss fight: only rewards so the player can focus on the golem.
      if (_chance(0.5)) {
        _coinArc(_cursor, GameConfig.groundY - 60, 7);
      } else {
        _coinLine(_cursor, GameConfig.flightCruiseY - 40, 6);
      }
      if (game.dragon.health < GameConfig.maxHealth && _chance(0.12)) {
        game.pickups.spawn(PickupKind.heart, _cursor + 200, GameConfig.groundY - 140);
      }
      _cursor += 520;
      return;
    }
    if (_meters >= _nextBossMeters) {
      _nextBossMeters += GameConfig.bossEveryMeters;
      game.startBoss(bossCount++);
      _cursor += 700;
      return;
    }

    final l = _level;
    final m = _meters;
    final weights = <_Pattern, double>{
      _Pattern.coins: 2.4 - l,
      _Pattern.airCoins: 0.9,
      _Pattern.thorns: 2.0,
      _Pattern.crystal: 1.3,
      _Pattern.boulder: m > 80 ? 1.2 : 0,
      _Pattern.slime: 2.0,
      _Pattern.gap: m > 150 ? 1.0 + l : 0,
      _Pattern.bat: m > 120 ? 1.0 + l : 0,
      _Pattern.stone: m > 300 ? 0.8 + l : 0,
      _Pattern.goblin: m > 500 ? 0.5 + l : 0,
      _Pattern.barrier: m > 400 ? 0.4 + 0.6 * l : 0,
      _Pattern.pod: m > 250 ? 0.6 + l : 0,
      _Pattern.combo: m > 700 ? 0.4 + 1.6 * l : 0,
      _Pattern.chest: _sinceChest > 14 ? 0.35 : 0,
      _Pattern.gate: _sinceGate > 10 ? 0.4 : 0,
      _Pattern.powerup: m > 200 ? 0.35 : 0,
    };
    final pattern = _pick(weights);
    _sinceChest++;
    _sinceGate++;
    switch (pattern) {
      case _Pattern.coins:
        final n = 6 + _rng.nextInt(5);
        switch (_rng.nextInt(3)) {
          case 0:
            _coinLine(_cursor, GameConfig.groundY - 50, n);
          case 1:
            _coinWave(_cursor, n);
          default:
            _coinArc(_cursor, GameConfig.groundY - 50, n);
        }
        if (_chance(0.08)) game.pickups.spawn(PickupKind.gem, _cursor + n * 52 + 60, GameConfig.groundY - 190);
        _cursor += n * 52 + 160;
      case _Pattern.airCoins:
        final n = 8 + _rng.nextInt(6);
        _coinLine(_cursor, GameConfig.flightCruiseY - 45, n);
        if (_chance(0.35)) {
          game.pickups.spawn(
            PickupKind.coinCluster,
            _cursor + n * 52 + 40,
            GameConfig.flightCruiseY - 45,
            value: EconomyConfig.coinClusterMin + _rng.nextInt(EconomyConfig.coinClusterMax - EconomyConfig.coinClusterMin + 1),
          );
        }
        if (_chance(0.15)) game.pickups.spawn(PickupKind.gem, _cursor + n * 52 + 120, GameConfig.flightCruiseY - 45);
        _cursor += n * 52 + 200;
      case _Pattern.thorns:
        _arcOver(_cursor, 5);
        _obstacle(ObstacleKind.thorns, _cursor + _jumpDistance * 0.5);
        _cursor += _jumpDistance + _clearance * 0.6;
      case _Pattern.crystal:
        _obstacle(ObstacleKind.crystal, _cursor + 40);
        _cursor += 120 + _clearance * 0.7;
      case _Pattern.boulder:
        _arcOver(_cursor, 5);
        _obstacle(ObstacleKind.boulder, _cursor + _jumpDistance * 0.5);
        _cursor += _jumpDistance + _clearance * 0.6;
      case _Pattern.slime:
        final n = _level > 0.3 && _chance(0.5) ? 2 : 1;
        for (var i = 0; i < n; i++) {
          _enemy(EnemyDef.slime, _cursor + i * (_jumpDistance + 220), GameConfig.groundY);
        }
        _coinLine(_cursor - 40, GameConfig.groundY - 210, 4);
        _cursor += n * (_jumpDistance + 220) + _clearance * 0.5;
      case _Pattern.gap:
        _gap(_cursor);
      case _Pattern.bat:
        final low = _chance(0.55);
        _enemy(EnemyDef.bat, _cursor + 60, low ? 545 : 380);
        if (!low) _coinLine(_cursor - 60, GameConfig.groundY - 50, 5);
        _cursor += 220 + _clearance * 0.7;
      case _Pattern.stone:
        _enemy(EnemyDef.stone, _cursor + 60, GameConfig.groundY);
        _cursor += 240 + _clearance;
      case _Pattern.goblin:
        final e = _enemy(EnemyDef.goblin, game.viewWidth + 140, GameConfig.groundY);
        e.warn = 1.1;
        _cursor += _clearance * 1.4;
      case _Pattern.barrier:
        // Telegraphed by a gold coin line high above it (fly over) — or destroy it.
        _obstacle(ObstacleKind.barrier, _cursor + 260);
        _coinLine(_cursor + 120, GameConfig.flightCruiseY - 60, 6);
        _cursor += 360 + _clearance * 1.1;
      case _Pattern.pod:
        _obstacle(ObstacleKind.pod, _cursor + 60, y: 420);
        _coinLine(_cursor - 80, GameConfig.groundY - 50, 4);
        _cursor += 200 + _clearance * 0.6;
      case _Pattern.combo:
        _combo();
      case _Pattern.chest:
        _sinceChest = 0;
        game.pickups.spawn(
          PickupKind.chest,
          _cursor + 80,
          GameConfig.groundY,
          value: EconomyConfig.treasureChestCoins + (m / 1000).floor() * EconomyConfig.treasureChestCoinsPerKm,
        );
        _cursor += 260;
      case _Pattern.gate:
        _sinceGate = 0;
        final air = _chance(0.4);
        game.pickups.spawn(PickupKind.gate, _cursor + 100, air ? GameConfig.flightCruiseY - 40 : 520);
        _coinLine(_cursor + 200, air ? GameConfig.flightCruiseY - 40 : GameConfig.groundY - 50, 6);
        _cursor += 560;
      case _Pattern.powerup:
        final heart = game.dragon.health < GameConfig.maxHealth && _chance(0.6);
        game.pickups.spawn(heart ? PickupKind.heart : PickupKind.magnet, _cursor + 60, GameConfig.groundY - 170);
        _cursor += 240;
    }
  }

  void _combo() {
    switch (_rng.nextInt(4)) {
      case 0:
        // gap followed (after landing room) by a low bat
        _gap(_cursor);
        _enemy(EnemyDef.bat, _cursor + 120, 545);
        _cursor += 240 + _clearance * 0.6;
      case 1:
        // thorns with a pod well before them: jump late
        _obstacle(ObstacleKind.pod, _cursor, y: 420);
        _obstacle(ObstacleKind.thorns, _cursor + 120 + _jumpDistance * 0.9);
        _cursor += 160 + _jumpDistance * 1.6 + _clearance;
      case 2:
        // stone monster guarded by bats overhead
        _enemy(EnemyDef.stone, _cursor + 60, GameConfig.groundY);
        _enemy(EnemyDef.bat, _cursor + 60 + _jumpDistance * 1.2, 380);
        _cursor += 160 + _jumpDistance * 1.2 + _clearance;
      default:
        // crystal then slime
        _obstacle(ObstacleKind.crystal, _cursor + 40);
        _enemy(EnemyDef.slime, _cursor + 120 + _jumpDistance + 160, GameConfig.groundY);
        _cursor += 300 + _jumpDistance + _clearance;
    }
  }

  void _gap(double start) {
    final maxW = math.min(380.0, _jumpDistance * 0.72);
    final w = _r(math.min(150, maxW), maxW);
    final x0 = start + 60;
    game.ground.gaps.add(GroundGap(x0, x0 + w));
    // coin arc that traces a jump over the chasm
    final n = 6;
    final airtime = 2 * GameConfig.jumpVelocity / GameConfig.gravity;
    final takeoff = x0 + w / 2 - _speed * airtime / 2;
    for (var i = 0; i < n; i++) {
      final t = airtime * (i + 0.5) / n;
      final h = GameConfig.jumpVelocity * t - 0.5 * GameConfig.gravity * t * t;
      game.pickups.spawn(PickupKind.coin, takeoff + _speed * t + 30, GameConfig.groundY - 55 - h);
    }
    _cursor = x0 + w + _clearance * 0.8;
  }

  void _arcOver(double start, int n) {
    final airtime = 2 * GameConfig.jumpVelocity / GameConfig.gravity;
    final span = _speed * airtime;
    for (var i = 0; i < n; i++) {
      final t = airtime * (i + 0.5) / n;
      final h = GameConfig.jumpVelocity * t - 0.5 * GameConfig.gravity * t * t;
      game.pickups.spawn(PickupKind.coin, start + span * (i + 0.5) / n + 30, GameConfig.groundY - 55 - h);
    }
  }

  void _coinLine(double start, double y, int n) {
    for (var i = 0; i < n; i++) {
      game.pickups.spawn(PickupKind.coin, start + i * 52, y);
    }
  }

  void _coinWave(double start, int n) {
    for (var i = 0; i < n; i++) {
      game.pickups.spawn(PickupKind.coin, start + i * 52, GameConfig.groundY - 70 - math.sin(i / (n - 1) * math.pi) * 70);
    }
  }

  void _coinArc(double start, double y, int n) {
    for (var i = 0; i < n; i++) {
      game.pickups.spawn(PickupKind.coin, start + i * 52, y - math.sin(i / (n - 1) * math.pi) * 150);
    }
  }

  void _obstacle(ObstacleKind k, double x, {double? y}) {
    game.obstacles.items.add(Obstacle(k, x, y ?? GameConfig.groundY));
  }

  Enemy _enemy(EnemyDef def, double x, double y) {
    final e = Enemy(def, x, y);
    game.enemies.items.add(e);
    return e;
  }

  _Pattern _pick(Map<_Pattern, double> w) {
    var total = 0.0;
    for (final v in w.values) {
      total += math.max(0, v);
    }
    var r = _rng.nextDouble() * total;
    for (final e in w.entries) {
      final v = math.max(0.0, e.value);
      if (r < v) return e.key;
      r -= v;
    }
    return _Pattern.coins;
  }
}

enum _Pattern { coins, airCoins, thorns, crystal, boulder, slime, gap, bat, stone, goblin, barrier, pod, combo, chest, gate, powerup }
