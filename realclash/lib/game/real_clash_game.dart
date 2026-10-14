import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart' show FlameGame;
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/services.dart' show HapticFeedback;

import '../core/audio_manager.dart';
import '../core/storage.dart';
import '../graphics/particles.dart';
import '../graphics/scene.dart';
import 'entities.dart';

enum GameState { menu, playing, paused, over }

class _Item {
  double z = 0;
  int kind = 0;
  Object? o;
}

class RealClashGame extends FlameGame {
  static const double zSpawn = 84;
  static const int maxSoldiers = 170;
  static const double baseStopZ = 36;
  static const List<double> troopHp = <double>[2.0, 4.0, 7.0, 6.0];
  static const List<double> troopDmg = <double>[1.0, 1.4, 2.0, 3.0];
  static const List<double> troopSpeed = <double>[22.0, 21.0, 18.0, 24.0];
  static const List<String> _overlayNames = <String>['menu', 'hud', 'pause', 'over', 'shop', 'settings'];

  final SceneRenderer scene = SceneRenderer();
  final Particles fx = Particles();
  final math.Random rnd = math.Random();
  final SaveData save = SaveData.instance;
  final AudioManager audio = AudioManager.I;

  GameState state = GameState.menu;
  bool get demo => state == GameState.menu;

  // HUD notifiers
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> hearts = ValueNotifier<int>(3);
  final ValueNotifier<int> runCoins = ValueNotifier<int>(0);
  final ValueNotifier<int> armyCount = ValueNotifier<int>(0);
  final ValueNotifier<int> highScore = ValueNotifier<int>(SaveData.instance.highScore);
  final ValueNotifier<String> banner = ValueNotifier<String>('');

  bool leftHeld = false;
  bool rightHeld = false;
  bool lastRunBest = false;
  int lastRunCoins = 0;
  int lastRunScore = 0;

  // world
  final List<Soldier> soldiers = <Soldier>[];
  final List<Soldier> _queue = <Soldier>[];
  final List<Enemy> enemies = <Enemy>[];
  final List<Gate> gates = <Gate>[];
  final List<Obstacle> obstacles = <Obstacle>[];
  final List<Coin> coins = <Coin>[];
  final List<Corpse> corpses = <Corpse>[];
  final List<Missile> missiles = <Missile>[];
  BaseFort? base;

  final List<_Item> _pool = <_Item>[];
  final List<_Item> _items = <_Item>[];

  double gameTime = 0;
  double runTime = 0;
  double scroll = 0;
  double worldSpeed = 6;
  double difficulty = 1;
  int _score = 0;
  int _runCoins = 0;
  int _nextMilestone = 1000;

  // cannon
  double cannonX = 0;
  double cannonVx = 0;
  double lift = 0;
  double liftV = 0;
  double recoil = 0;
  double flash = 0;
  double invuln = 0;
  double shake = 0;
  double _fireT = 0.5;

  // timers
  double _tEnemy = 2.5;
  double _tGate = 2.0;
  double _tObs = 6.0;
  double _tCoin = 4.0;
  double _tEnc = 30.0;
  double _stepT = 0;
  double bannerT = 0;
  double celebrate = 0;
  double _overDelay = 0;
  double _lastGateFx = 0;
  int _gateId = 1;
  int _enc = 0;
  int _lastHaptic = 0;
  String _shopFrom = 'menu';
  String _settingsFrom = 'menu';

  RealClashGame() {
    _resetWorld();
  }

  // ------------------------------------------------------------ flow

  void showOverlay(String? name) {
    for (final o in _overlayNames) {
      overlays.remove(o);
    }
    if (name != null) overlays.add(name);
  }

  void _resetWorld() {
    soldiers.clear();
    _queue.clear();
    enemies.clear();
    gates.clear();
    obstacles.clear();
    coins.clear();
    corpses.clear();
    missiles.clear();
    base = null;
    fx.clear();
    runTime = 0;
    scroll = 0;
    difficulty = 1;
    cannonX = 0;
    cannonVx = 0;
    lift = 0;
    liftV = 0;
    recoil = 0;
    flash = 0;
    invuln = 0;
    shake = 0;
    _fireT = 0.5;
    _tEnemy = 2.5;
    _tGate = 2.0;
    _tObs = 6.0;
    _tCoin = 4.0;
    _tEnc = 30.0;
    _stepT = 0;
    celebrate = 0;
    bannerT = 0;
    _enc = 0;
    _overDelay = 0;
    _score = 0;
    _runCoins = 0;
    _nextMilestone = 1000;
    leftHeld = false;
    rightHeld = false;
    banner.value = '';
    score.value = 0;
    runCoins.value = 0;
    armyCount.value = 0;
    hearts.value = 3;
  }

  void startGame() {
    _resetWorld();
    state = GameState.playing;
    invuln = 1.0;
    highScore.value = save.highScore;
    showOverlay('hud');
    audio.playMusic('music_battle');
    audio.sfx('click');
  }

  void toMenu() {
    _resetWorld();
    state = GameState.menu;
    highScore.value = save.highScore;
    showOverlay('menu');
    audio.playMusic('music_menu');
  }

  void pauseGame() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    leftHeld = false;
    rightHeld = false;
    audio.pauseMusic();
    showOverlay('pause');
  }

  void resumeGame() {
    if (state != GameState.paused) return;
    state = GameState.playing;
    showOverlay('hud');
    audio.resumeMusic();
  }

  void openShop() {
    _shopFrom = state == GameState.over ? 'over' : 'menu';
    showOverlay('shop');
  }

  void closeShop() {
    showOverlay(_shopFrom);
  }

  void openSettings() {
    _settingsFrom = state == GameState.paused ? 'pause' : 'menu';
    showOverlay('settings');
  }

  void closeSettings() {
    showOverlay(_settingsFrom);
  }

  void _gameOver() {
    if (state != GameState.playing) return;
    state = GameState.over;
    leftHeld = false;
    rightHeld = false;
    lastRunScore = _score;
    lastRunCoins = _runCoins;
    lastRunBest = _score > save.highScore;
    if (lastRunBest) save.highScore = _score;
    highScore.value = save.highScore;
    save.coins += _runCoins;
    save.save();
    audio.stopMusic();
    audio.sfx('defeat');
    audio.sfx('explosion');
    final p = _cannonScreen();
    fx.explosion(p.dx, p.dy - cam.w * 0.1, scale: 2.0);
    fx.explosion(p.dx - 30, p.dy - cam.w * 0.05, scale: 1.4);
    shake = 22;
    _haptic(2);
    _overDelay = 1.0;
  }

  // ------------------------------------------------------------ helpers

  Cam get cam => scene.cam;

  void _haptic(int level) {
    if (demo) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHaptic < 90) return;
    _lastHaptic = now;
    try {
      if (level >= 2) {
        HapticFeedback.heavyImpact();
      } else if (level == 1) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  void _sfx(String n, {double v = 1.0, int gap = 0}) {
    if (demo) return;
    audio.sfx(n, volume: v, minGapMs: gap);
  }

  ui.Offset _scr(double x, double z, [double hPx = 0]) {
    return ui.Offset(cam.sx(x, z), cam.sy(z) - hPx * cam.scale(z));
  }

  ui.Offset _cannonScreen() {
    return ui.Offset(cam.sx(cannonX, 0), cam.sy(0) - lift * cam.w * 0.11);
  }

  ui.Offset _muzzle() {
    final s = cam.w * 0.0026;
    return ui.Offset(cam.sx(cannonX, 0), cam.sy(0) - lift * cam.w * 0.11 - (56 + 108 + 8) * s + recoil * 18 * s);
  }

  void _banner(String t) {
    banner.value = t;
    bannerT = 2.6;
  }

  void _addScore(int n) {
    if (demo) return;
    _score += n;
    score.value = _score;
    if (_score >= _nextMilestone) {
      _nextMilestone += 1000;
      _addCoins(25);
      _banner('REWARD  +25 COINS');
      _sfx('coin');
    }
  }

  void _addCoins(int n) {
    if (demo) return;
    final bonus = 1.0 + 0.1 * save.up[3];
    _runCoins += math.max(n, (n * bonus).round());
    runCoins.value = _runCoins;
  }

  // ------------------------------------------------------------ input

  void jump() {
    if (state != GameState.playing) return;
    if (lift <= 0.001) {
      liftV = 4.6;
      lift = 0.002;
      audio.sfx('jump', volume: 0.8);
    }
  }

  // ------------------------------------------------------------ update

  @override
  void update(double dt) {
    super.update(dt);
    var d = dt;
    if (d > 0.05) d = 0.05;
    if (d < 0) d = 0;
    if (state == GameState.paused) return;
    gameTime += d;
    fx.update(d);
    if (shake > 0) shake = math.max(0.0, shake - d * 45);
    if (state == GameState.playing || state == GameState.menu) {
      _step(d);
    } else if (state == GameState.over) {
      scroll += d * 1.5;
      recoil = math.max(0.0, recoil - d * 4);
      if (_overDelay > 0) {
        _overDelay -= d;
        if (_overDelay <= 0) showOverlay('over');
      }
    }
    if (bannerT > 0) {
      bannerT -= d;
      if (bannerT <= 0) banner.value = '';
    }
  }

  void _step(double dt) {
    final demoMode = demo;
    if (!demoMode) runTime += dt;
    difficulty = demoMode ? 1.3 : 1.0 + runTime / 40.0;
    worldSpeed = demoMode ? 6.0 : 7.0 + math.min(difficulty, 5.0) * 0.6;
    scroll += worldSpeed * dt;
    if (celebrate > 0) celebrate -= dt;
    if (invuln > 0) invuln -= dt;

    // cannon movement
    double target = 0;
    if (demoMode) {
      Enemy? best;
      for (final e in enemies) {
        if (!e.alive) continue;
        if (best == null || e.z < best.z) best = e;
      }
      if (best != null) {
        target = clampD((best.x - cannonX) * 3.0, -1.0, 1.0);
      } else {
        target = clampD((math.sin(gameTime * 0.6) * 0.5 - cannonX) * 2.0, -1.0, 1.0);
      }
    } else {
      if (leftHeld) target -= 1;
      if (rightHeld) target += 1;
    }
    cannonVx += (target * 1.9 - cannonVx) * math.min(1.0, dt * 11);
    cannonX = clampD(cannonX + cannonVx * dt, -0.84, 0.84);

    if (lift > 0 || liftV > 0) {
      liftV -= 13 * dt;
      lift += liftV * dt;
      if (lift <= 0) {
        lift = 0;
        liftV = 0;
        final p = _cannonScreen();
        fx.smoke(p.dx, p.dy, size: 10, n: 3, rise: 20);
      }
    }
    recoil = math.max(0.0, recoil - dt * 5.5);
    flash = math.max(0.0, flash - dt);

    // fire
    final interval = math.max(0.15, 0.42 - 0.035 * save.up[0]);
    _fireT -= dt;
    if (_fireT <= 0) {
      _fire();
      _fireT += interval;
      if (_fireT < -0.1) _fireT = interval;
    }

    _director(dt);
    _updateSoldiers(dt);
    _updateEnemies(dt);
    _updateWorldObjects(dt);
    _updateBase(dt);

    // corpses
    for (final c in corpses) {
      c.life -= dt;
      c.vy -= 900 * dt;
      c.y += c.vy * dt;
      if (c.y < 0) {
        c.y = 0;
        c.vy = 0;
        c.vx *= 0.8;
        c.vr *= 0.8;
      }
      c.x += c.vx * dt * 0.001;
      c.rot += c.vr * dt;
    }
    corpses.removeWhere((c) => c.life <= 0);

    soldiers.removeWhere((s) => !s.alive);
    enemies.removeWhere((e) => !e.alive);
    gates.removeWhere((g) => !g.alive);
    obstacles.removeWhere((o) => !o.alive);
    coins.removeWhere((c) => !c.alive);
    if (armyCount.value != soldiers.length) armyCount.value = soldiers.length;

    // footsteps
    _stepT -= dt;
    if (_stepT <= 0 && soldiers.length > 3) {
      _stepT = 0.28;
      _sfx('footstep', v: math.min(1.0, soldiers.length / 50.0) * 0.55, gap: 150);
    }

    // score over time
    if (!demoMode) {
      _timeScore += dt * 4.0;
      if (_timeScore >= 1.0) {
        final n = _timeScore.floor();
        _timeScore -= n;
        _addScore(n);
      }
    }
  }

  double _timeScore = 0;

  // ------------------------------------------------------------ firing

  void _fire() {
    final shots = 1 + save.up[2];
    final t = save.selectedTroop.clamp(0, 3).toInt();
    final lvl = save.up[1];
    final hp = troopHp[t] + 0.4 * lvl;
    final dm = troopDmg[t] + 0.12 * lvl;
    for (var i = 0; i < shots; i++) {
      if (soldiers.length >= maxSoldiers) break;
      final off = (i - (shots - 1) / 2.0) * 0.085;
      soldiers.add(Soldier(
        x: clampD(cannonX + off + (rnd.nextDouble() - 0.5) * 0.02, -0.97, 0.97),
        z: 1.4,
        hp: hp,
        dmg: dm,
        speed: troopSpeed[t] * (0.96 + rnd.nextDouble() * 0.08),
        phase: rnd.nextDouble() * 6,
        type: t,
      ));
    }
    recoil = 1.0;
    flash = 0.12;
    final m = _muzzle();
    fx.muzzle(m.dx, m.dy, 1.0);
    shake = math.max(shake, 3.5);
    _sfx('shoot', v: 0.75, gap: 90);
    _haptic(0);
  }

  // ------------------------------------------------------------ director

  void _director(double dt) {
    final d = difficulty;

    _tEnemy -= dt;
    if (_tEnemy <= 0) {
      if (enemies.length < 80) _spawnFormation();
      var iv = math.max(1.7, 4.6 - d * 0.35) + rnd.nextDouble() * 0.8;
      if (base != null) iv *= 1.8;
      _tEnemy = demo ? 3.5 : iv;
    }

    _tGate -= dt;
    if (_tGate <= 0) {
      _spawnGatePair();
      _tGate = demo ? 6.0 : math.max(5.0, 8.0 - d * 0.3) + rnd.nextDouble() * 1.5;
    }

    _tObs -= dt;
    if (_tObs <= 0) {
      _spawnObstacle();
      _tObs = demo ? 7.0 : math.max(2.2, 5.5 - d * 0.4) + rnd.nextDouble();
    }

    _tCoin -= dt;
    if (_tCoin <= 0) {
      _spawnCoins();
      _tCoin = 5.0 + rnd.nextDouble() * 3.0;
    }

    if (!demo) {
      _tEnc -= dt;
      if (_tEnc <= 0) {
        final bossAlive = enemies.any((e) => e.alive && e.kind == 2);
        if (base != null || bossAlive) {
          _tEnc = 5.0;
        } else {
          _enc++;
          if (_enc.isOdd) {
            _spawnBase();
          } else {
            _spawnBoss();
          }
          _tEnc = math.max(25.0, 45.0 - d * 2.0);
        }
      }
    }
  }

  void _spawnEnemy(double x, double z, int kind) {
    final d = difficulty;
    final ws = worldSpeed;
    double hp;
    double dmg;
    double speed;
    double halfW;
    double halfZ;
    double lat;
    if (kind == 0) {
      hp = 2.0 + (d - 1) * 0.35;
      dmg = 1.0;
      speed = ws + 1.8 + rnd.nextDouble() * 0.8 + math.min(d, 6.0) * 0.25;
      halfW = 0.11;
      halfZ = 0.6;
      lat = 0.9;
    } else if (kind == 1) {
      hp = 5.0 + (d - 1) * 0.7;
      dmg = 2.0;
      speed = ws + 1.2 + rnd.nextDouble() * 0.5;
      halfW = 0.14;
      halfZ = 0.7;
      lat = 0.6;
    } else {
      hp = 34.0 + _enc * 10.0 + (d - 1) * 6.0;
      dmg = 3.0;
      speed = ws + 0.6;
      halfW = 0.34;
      halfZ = 1.4;
      lat = 0.35;
    }
    enemies.add(Enemy(
      x: clampD(x, -0.93, 0.93),
      z: z,
      hp: hp,
      speed: speed,
      dmg: dmg,
      phase: rnd.nextDouble() * 6,
      lat: lat,
      flank: (rnd.nextDouble() - 0.5) * 0.3,
      halfW: halfW,
      halfZ: halfZ,
      kind: kind,
    ));
  }

  void _spawnFormation() {
    final d = difficulty;
    final n = math.min(4 + (d * 2.2).floor(), 36);
    final pattern = rnd.nextInt(4);
    final cx = rnd.nextDouble() * 1.3 - 0.65;
    final bruteChance = d < 1.8 ? 0.0 : math.min(0.04 + (d - 1.8) * 0.04, 0.35);
    int kindOf() => rnd.nextDouble() < bruteChance ? 1 : 0;
    if (pattern == 0) {
      final cols = math.min(n, 8);
      for (var i = 0; i < n; i++) {
        final row = i ~/ cols;
        final col = i % cols;
        final rem = n - row * cols;
        final cnt = rem < cols ? rem : cols;
        _spawnEnemy(cx + (col - (cnt - 1) / 2.0) * 0.12, zSpawn + row * 1.8, kindOf());
      }
    } else if (pattern == 1) {
      var r = 0;
      var inRow = 0;
      for (var i = 0; i < n; i++) {
        _spawnEnemy(cx + (inRow - r / 2.0) * 0.13, zSpawn + r * 1.6, kindOf());
        inRow++;
        if (inRow > r) {
          r++;
          inRow = 0;
        }
      }
    } else if (pattern == 2) {
      for (var i = 0; i < n; i++) {
        _spawnEnemy(cx + (i.isEven ? -0.09 : 0.09), zSpawn + (i ~/ 2) * 1.8, kindOf());
      }
    } else {
      for (var i = 0; i < n; i++) {
        _spawnEnemy(rnd.nextDouble() * 1.6 - 0.8, zSpawn + rnd.nextDouble() * 9.0, kindOf());
      }
    }
    _sfx('voice_battle', v: 0.45, gap: 1800);
  }

  void _spawnGatePair() {
    final d = difficulty;
    final id = _gateId++;
    int pick() {
      final p = rnd.nextDouble();
      if (d > 3 && p < 0.15) return 4;
      if (p < 0.55) return 2;
      return 3;
    }

    if (rnd.nextDouble() < 0.2) {
      gates.add(Gate(id: id, x: 0, z: zSpawn, w: 0.95, bad: false, value: 2));
      return;
    }
    final badChance = 0.15 + 0.05 * math.min(d, 5.0);
    final leftGood = rnd.nextBool();
    final otherBad = rnd.nextDouble() < badChance;
    final a = pick();
    final b = pick();
    gates.add(Gate(id: id, x: -0.5, z: zSpawn, w: 0.46, bad: leftGood ? false : otherBad, value: leftGood ? a : b));
    gates.add(Gate(id: id + 1000000, x: 0.5, z: zSpawn, w: 0.46, bad: leftGood ? otherBad : false, value: leftGood ? b : a));
  }

  void _spawnObstacle() {
    final d = difficulty;
    final groups = (d > 2.5 && rnd.nextBool()) ? 2 : 1;
    for (var g = 0; g < groups; g++) {
      final r = rnd.nextDouble();
      final x = rnd.nextDouble() * 1.5 - 0.75;
      final z = zSpawn + g * 3.0;
      if (r < 0.4) {
        obstacles.add(Obstacle(x: x, z: z, hw: 0.14, kind: 0, hp: 4.0 + d * 0.3));
      } else if (r < 0.7) {
        obstacles.add(Obstacle(x: x, z: z, hw: 0.22 + rnd.nextDouble() * 0.15, kind: 1, hp: 6.0));
      } else {
        obstacles.add(Obstacle(x: x, z: z, hw: 0.09, kind: 2, hp: 1.0));
      }
    }
  }

  void _spawnCoins() {
    final x = rnd.nextDouble() * 1.4 - 0.7;
    final n = 5 + rnd.nextInt(4);
    for (var i = 0; i < n; i++) {
      coins.add(Coin(x: x, z: zSpawn + i * 2.2, spin: rnd.nextDouble() * 6));
    }
  }

  void _spawnBase() {
    final hp = 40.0 + _enc * 18.0 + difficulty * 6.0;
    base = BaseFort(z: zSpawn + 6, hp: hp);
    _banner('ENEMY BASE');
    _sfx('boss_roar', v: 0.6);
    _haptic(1);
  }

  void _spawnBoss() {
    _spawnEnemy(rnd.nextDouble() * 0.8 - 0.4, zSpawn, 2);
    _banner('BOSS INCOMING');
    _sfx('boss_roar', v: 1.0);
    _haptic(2);
  }

  // ------------------------------------------------------------ soldiers

  Enemy? _nearestEnemy(Soldier s) {
    Enemy? best;
    double bestScore = 1e9;
    for (final e in enemies) {
      if (!e.alive) continue;
      final dz = e.z - s.z;
      if (dz < -0.5 || dz > 14) continue;
      final sc = (e.x - s.x).abs() + dz * 0.05;
      if (sc < bestScore) {
        bestScore = sc;
        best = e;
      }
    }
    return best;
  }

  void _killSoldier(Soldier s, {bool fling = true}) {
    s.alive = false;
    if (fling && corpses.length < 36) {
      corpses.add(Corpse(
        x: s.x,
        z: s.z,
        vy: 220 + rnd.nextDouble() * 140,
        vx: (rnd.nextDouble() - 0.5) * 300,
        vr: (rnd.nextDouble() - 0.5) * 14,
        life: 0.8,
        style: s.type,
        size: 0.19,
      ));
    }
  }

  void _updateSoldiers(double dt) {
    _queue.clear();
    final b = base;
    for (final s in soldiers) {
      if (!s.alive) continue;
      s.cd -= dt;
      s.fight -= dt;
      if (s.hop > 0) s.hop = math.max(0.0, s.hop - dt * 2.5);
      s.aiT -= dt;
      if (s.aiT <= 0) {
        s.aiT = 0.18 + rnd.nextDouble() * 0.1;
        s.tgt = _nearestEnemy(s);
      }
      final t = s.tgt;
      if (t != null && t.alive) {
        s.x += clampD(t.x - s.x, -0.4, 0.4) * 4.0 * dt;
      }
      s.x += math.sin(gameTime * 3 + s.phase) * 0.05 * dt;
      s.x = clampD(s.x, -0.97, 0.97);
      s.z += (s.fight > 0 ? s.speed * 0.12 : s.speed) * dt;
      if (s.z > 92) {
        s.alive = false;
        continue;
      }

      // gates
      for (final g in gates) {
        if (!g.alive || g.id == s.gateId) continue;
        if ((g.z - s.z).abs() < 1.0 && (s.x - g.x).abs() < g.w) {
          s.gateId = g.id;
          g.flash = 0.3;
          if (g.bad) {
            if (rnd.nextBool()) _killSoldier(s);
            _gateFx(g, true);
          } else {
            s.hop = 1.0;
            final extra = g.value - 1;
            for (var k = 0; k < extra; k++) {
              if (soldiers.length + _queue.length >= maxSoldiers) break;
              final ns = Soldier(
                x: clampD(s.x + (rnd.nextDouble() - 0.5) * 0.18, -0.97, 0.97),
                z: s.z + 0.3 + rnd.nextDouble() * 0.9,
                hp: s.hp,
                dmg: s.dmg,
                speed: s.speed * (0.95 + rnd.nextDouble() * 0.1),
                phase: rnd.nextDouble() * 6,
                type: s.type,
              );
              ns.gateId = g.id;
              ns.hop = 1.0;
              _queue.add(ns);
            }
            _gateFx(g, false);
          }
          break;
        }
      }
      if (!s.alive) continue;

      // coins
      for (final c in coins) {
        if (!c.alive) continue;
        if ((c.z - s.z).abs() < 1.2 && (c.x - s.x).abs() < 0.12) {
          c.alive = false;
          _collectCoin(c);
        }
      }

      // obstacles
      for (final o in obstacles) {
        if (!o.alive) continue;
        if ((o.z - s.z).abs() < 0.9 && (o.x - s.x).abs() < o.hw + 0.04) {
          if (o.kind == 0) {
            o.hp -= s.dmg;
            o.hitFlash = 0.1;
            final p = _scr(s.x, s.z, 16);
            fx.spark(p.dx, p.dy, n: 4, color: 0xE0B070, speed: 160);
            _sfx('hit', v: 0.5, gap: 80);
            s.alive = false;
            if (o.hp <= 0) _destroyCrate(o);
          } else if (o.kind == 1) {
            o.hp -= 0.5;
            o.hitFlash = 0.1;
            _killSoldier(s);
            if (o.hp <= 0) o.alive = false;
          } else {
            _explodeBarrel(o);
            _killSoldier(s, fling: false);
          }
          break;
        }
      }
      if (!s.alive) continue;

      // enemy base
      if (b != null && s.z >= b.z - 1.4 && s.x.abs() < 1.15) {
        b.hp -= s.dmg;
        b.hitFlash = 0.1;
        final p = _scr(s.x, b.z - 1.0, 20);
        fx.spark(p.dx, p.dy, n: 5, speed: 200);
        _sfx('hit', v: 0.6, gap: 70);
        s.alive = false;
        if (b.hp <= 0) {
          _destroyBase();
        }
        continue;
      }

      // enemies
      for (final e in enemies) {
        if (!e.alive) continue;
        final dz = e.z - s.z;
        if (dz > e.halfZ + 0.5 || dz < -(e.halfZ + 0.5)) continue;
        if ((e.x - s.x).abs() > e.halfW) continue;
        s.fight = 0.25;
        e.slow = 0.25;
        if (s.cd <= 0) {
          s.cd = 0.32;
          e.hp -= s.dmg;
          e.hitFlash = 0.1;
          s.hp -= e.dmg;
          final p = _scr(s.x, s.z, 22);
          fx.spark(p.dx, p.dy, n: 4, speed: 200);
          _sfx('hit', v: 0.55, gap: 70);
          if (s.hp <= 0) _killSoldier(s);
          if (e.hp <= 0) _killEnemy(e);
        }
        break;
      }
    }
    if (_queue.isNotEmpty) {
      soldiers.addAll(_queue);
      _queue.clear();
    }
  }

  void _gateFx(Gate g, bool bad) {
    if (gameTime - _lastGateFx < 0.1) return;
    _lastGateFx = gameTime;
    final sc = cam.scale(g.z);
    final p = ui.Offset(cam.sx(g.x, g.z), cam.sy(g.z) - cam.w * 0.12 * sc);
    fx.spark(p.dx, p.dy, n: 6, color: bad ? 0xFF6060 : 0x70C8FF, speed: 160 * sc + 40);
    _sfx(bad ? 'hit' : 'gate', v: 0.8, gap: 120);
  }

  void _collectCoin(Coin c) {
    final p = _scr(c.x, c.z, 14);
    fx.coinSparkle(p.dx, p.dy);
    _addCoins(1);
    _addScore(2);
    _sfx('coin', v: 0.6, gap: 60);
  }

  void _killEnemy(Enemy e) {
    if (!e.alive) return;
    e.alive = false;
    final style = 4 + e.kind;
    final sc = cam.scale(e.z);
    final p = _scr(e.x, e.z, 20);
    if (e.kind == 2) {
      fx.explosion(p.dx, p.dy, scale: 2.4);
      shake = 16;
      _addScore(400);
      _addCoins(30);
      _banner('BOSS DEFEATED');
      _sfx('explosion');
      _sfx('victory', v: 0.7);
      _haptic(2);
      celebrate = 3.0;
    } else {
      fx.spark(p.dx, p.dy, n: 6, speed: 220);
      fx.smoke(p.dx, p.dy, size: 8 * sc + 4, n: 1, rise: 30);
      _addScore(e.kind == 1 ? 25 : 10);
      if (rnd.nextDouble() < 0.12) {
        _addCoins(1);
        fx.coinSparkle(p.dx, p.dy - 10);
      }
      _sfx('voice_hurt', v: 0.4, gap: 260);
    }
    if (corpses.length < 36) {
      corpses.add(Corpse(
        x: e.x,
        z: e.z,
        vy: 260 + rnd.nextDouble() * 160,
        vx: (rnd.nextDouble() - 0.5) * 320,
        vr: (rnd.nextDouble() - 0.5) * 16,
        life: 0.85,
        style: style,
        size: e.kind == 2 ? 0.52 : (e.kind == 1 ? 0.235 : 0.19),
      ));
    }
  }

  void _destroyCrate(Obstacle o) {
    o.alive = false;
    final p = _scr(o.x, o.z, 18);
    fx.debris(p.dx, p.dy, 0x9A6234, n: 9);
    fx.smoke(p.dx, p.dy, size: 10, n: 2);
    _addScore(20);
    _addCoins(2);
    fx.coinSparkle(p.dx, p.dy - 12);
    _sfx('hit', v: 0.8, gap: 80);
  }

  void _explodeBarrel(Obstacle o) {
    if (!o.alive) return;
    o.alive = false;
    final p = _scr(o.x, o.z, 14);
    final sc = cam.scale(o.z);
    fx.explosion(p.dx, p.dy, scale: 0.9 + sc * 0.8);
    shake = math.max(shake, 8);
    _sfx('explosion', v: 0.9, gap: 120);
    _haptic(1);
    for (final e in enemies) {
      if (!e.alive) continue;
      if ((e.x - o.x).abs() < 0.7 && (e.z - o.z).abs() < 5.0) {
        e.hp -= 8;
        e.hitFlash = 0.12;
        if (e.hp <= 0) _killEnemy(e);
      }
    }
    for (final s in soldiers) {
      if (!s.alive) continue;
      if ((s.x - o.x).abs() < 0.45 && (s.z - o.z).abs() < 2.5) _killSoldier(s);
    }
    _addScore(15);
  }

  // ------------------------------------------------------------ enemies

  void _updateEnemies(double dt) {
    for (final e in enemies) {
      if (!e.alive) continue;
      e.hitFlash = math.max(0.0, e.hitFlash - dt);
      e.slow = math.max(0.0, e.slow - dt);
      e.aiT -= dt;
      if (e.aiT <= 0) {
        e.aiT = 0.3 + rnd.nextDouble() * 0.2;
        double best = 9.0;
        double tx = cannonX + e.flank;
        for (final s in soldiers) {
          if (!s.alive) continue;
          final dz = e.z - s.z;
          if (dz < -1 || dz > 7) continue;
          final dx = (s.x - e.x).abs();
          if (dx < best && dx < 0.5) {
            best = dx;
            tx = s.x;
          }
        }
        e.tx = tx;
      }
      e.x += clampD(e.tx - e.x, -1.0, 1.0) * e.lat * dt;
      e.x = clampD(e.x, -0.97, 0.97);
      e.z -= e.speed * (e.slow > 0 ? 0.35 : 1.0) * dt;

      if (e.z < 1.1) {
        if ((e.x - cannonX).abs() < 0.32 + e.halfW * 0.5) {
          e.alive = false;
          final p = _cannonScreen();
          fx.explosion(p.dx, p.dy - cam.w * 0.08, scale: e.kind == 2 ? 1.8 : 0.9);
          _hurt();
        } else if (e.z < -4) {
          e.alive = false;
        }
      }
    }
  }

  void _hurt() {
    if (demo || invuln > 0 || state != GameState.playing) return;
    hearts.value = hearts.value - 1;
    invuln = 1.6;
    shake = 18;
    audio.sfx('damage');
    audio.sfx('voice_hurt', volume: 0.7);
    _haptic(2);
    final p = _cannonScreen();
    fx.explosion(p.dx, p.dy - cam.w * 0.1, scale: 1.2);
    if (hearts.value <= 0) _gameOver();
  }

  // ------------------------------------------------------------ objects

  void _updateWorldObjects(double dt) {
    final ws = worldSpeed;
    for (final g in gates) {
      g.z -= ws * dt;
      g.flash = math.max(0.0, g.flash - dt);
      if (g.z < -3) g.alive = false;
    }
    for (final c in coins) {
      c.z -= ws * dt;
      c.spin += dt * 5;
      if (c.z < -3) {
        c.alive = false;
      } else if (c.z < 1.4 && c.z > -1.0 && (c.x - cannonX).abs() < 0.26) {
        c.alive = false;
        _collectCoin(c);
      }
    }
    for (final o in obstacles) {
      if (!o.alive) continue;
      o.z -= ws * dt;
      o.hitFlash = math.max(0.0, o.hitFlash - dt);
      if (o.z < -5) {
        o.alive = false;
        continue;
      }
      if (o.z < 1.0 && o.z > -1.2 && (o.x - cannonX).abs() < o.hw + 0.15) {
        if (o.kind == 0) {
          o.alive = false;
          final p = _cannonScreen();
          fx.debris(p.dx, p.dy - 20, 0x9A6234, n: 8);
          _hurt();
        } else if (o.kind == 2) {
          _explodeBarrel(o);
          _hurt();
        } else if (!o.touched) {
          o.touched = true;
          if (lift < 0.3) {
            _hurt();
            final p = _cannonScreen();
            fx.spark(p.dx, p.dy, n: 8, speed: 240);
          }
        }
      }
    }
    for (var i = missiles.length - 1; i >= 0; i--) {
      final m = missiles[i];
      m.t -= dt;
      if (m.t <= 0) {
        final p = _scr(m.tx, 0.8);
        fx.explosion(p.dx, p.dy - 8, scale: 1.3);
        shake = math.max(shake, 10);
        _sfx('explosion', v: 0.8);
        if ((cannonX - m.tx).abs() < 0.3 && lift < 0.5) _hurt();
        missiles.removeAt(i);
      }
    }
  }

  void _updateBase(double dt) {
    final b = base;
    if (b == null) return;
    b.hitFlash = math.max(0.0, b.hitFlash - dt);
    if (!b.arrived) {
      b.z -= 14 * dt;
      if (b.z <= baseStopZ) {
        b.z = baseStopZ;
        b.arrived = true;
      }
      return;
    }
    b.spawnT -= dt;
    if (b.spawnT <= 0) {
      b.spawnT = 2.4;
      if (enemies.length < 70) {
        for (var i = 0; i < 3; i++) {
          _spawnEnemy(rnd.nextDouble() * 1.4 - 0.7, b.z - 1.2 - rnd.nextDouble() * 1.2, 0);
        }
      }
    }
    b.fireT -= dt;
    if (b.fireT <= 0) {
      b.fireT = 6.5;
      missiles.add(Missile(tx: cannonX, t: 1.4));
      _sfx('base_cannon', v: 0.9);
    }
  }

  void _destroyBase() {
    final b = base;
    if (b == null) return;
    base = null;
    final sc = cam.scale(b.z);
    final p = ui.Offset(cam.sx(0, b.z), cam.sy(b.z) - cam.w * 0.12 * sc);
    fx.explosion(p.dx, p.dy, scale: 3.0);
    fx.explosion(p.dx - 50 * sc - 20, p.dy + 10, scale: 2.0);
    fx.explosion(p.dx + 50 * sc + 20, p.dy + 10, scale: 2.0);
    shake = 18;
    _addScore(800);
    _addCoins(40);
    _banner('BASE DESTROYED');
    _sfx('explosion');
    _sfx('victory', v: 0.8);
    _haptic(2);
    celebrate = 3.5;
    missiles.clear();
    _tEnc = 35.0;
  }

  // ------------------------------------------------------------ render

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;
    if (w < 10 || h < 10) return;
    scene.layout(w, h);
    canvas.save();
    if (shake > 0.2) {
      canvas.translate((rnd.nextDouble() - 0.5) * shake, (rnd.nextDouble() - 0.5) * shake);
    }
    scene.drawBackdrop(canvas);
    scene.drawGround(canvas, scroll);
    _drawWorld(canvas);
    scene.drawFog(canvas);
    fx.render(canvas);
    canvas.restore();
    scene.drawVignette(canvas);
  }

  int _poolN = 0;

  void _add(int kind, double z, Object? o) {
    _Item it;
    if (_poolN < _pool.length) {
      it = _pool[_poolN];
    } else {
      it = _Item();
      _pool.add(it);
    }
    _poolN++;
    it.kind = kind;
    it.z = z;
    it.o = o;
    _items.add(it);
  }

  void _drawWorld(ui.Canvas c) {
    final cm = cam;

    // aim guide
    if (state == GameState.playing) {
      final y0 = cm.sy(1.0);
      final y1 = cm.sy(60.0);
      final path = ui.Path()
        ..moveTo(cm.sx(cannonX - 0.07, 1.0), y0)
        ..lineTo(cm.sx(cannonX - 0.012, 60.0), y1)
        ..lineTo(cm.sx(cannonX + 0.012, 60.0), y1)
        ..lineTo(cm.sx(cannonX + 0.07, 1.0), y0)
        ..close();
      c.drawPath(
        path,
        ui.Paint()
          ..shader = gLinear(ui.Offset(0, y0), ui.Offset(0, y1),
              const [ui.Color(0x40FFFFFF), ui.Color(0x00FFFFFF)]),
      );
    }

    // missile targets on the ground
    for (final m in missiles) {
      final sc = cm.scale(0.8);
      scene.drawMissileTarget(c, cm.sx(m.tx, 0.8), cm.sy(0.8), cm.w * 0.11 * sc, m.t / m.total);
    }

    _items.clear();
    _poolN = 0;
    for (final s in soldiers) {
      if (s.alive && s.z > -4) _add(0, s.z, s);
    }
    for (final e in enemies) {
      if (e.alive && e.z > -4) _add(1, e.z, e);
    }
    for (final g in gates) {
      if (g.alive && g.z > -4) _add(2, g.z, g);
    }
    for (final o in obstacles) {
      if (o.alive && o.z > -4) _add(3, o.z, o);
    }
    for (final co in coins) {
      if (co.alive && co.z > -4) _add(4, co.z, co);
    }
    final b = base;
    if (b != null) _add(5, b.z, b);
    for (final co in corpses) {
      _add(6, co.z, co);
    }
    for (final m in missiles) {
      if (m.t / m.total < 0.5) _add(7, 3.0, m);
    }
    _add(8, 0.6, null); // crew
    _add(9, 0.0, null); // cannon
    _items.sort((a, b2) => b2.z.compareTo(a.z));

    for (final it in _items) {
      switch (it.kind) {
        case 0: {
          _drawSoldier(c, it.o as Soldier);
          break;
        }
        case 1: {
          _drawEnemy(c, it.o as Enemy);
          break;
        }
        case 2: {
          final g = it.o as Gate;
          final sc = cm.scale(g.z);
          scene.drawGate(c, cm.sx(g.x, g.z), cm.sy(g.z), 2 * g.w * cm.roadW * sc, cm.w * 0.3 * sc, g.bad, g.label,
              g.flash, gameTime);
          break;
        }
        case 3: {
          final o = it.o as Obstacle;
          final sc = cm.scale(o.z);
          final px = cm.sx(o.x, o.z);
          final py = cm.sy(o.z);
          final hwp = o.hw * cm.roadW * sc;
          if (o.kind == 0) {
            scene.drawCrate(c, px, py, hwp, o.hitFlash, o.hp / o.maxHp);
          } else if (o.kind == 1) {
            scene.drawSpikes(c, px, py, hwp, o.hitFlash);
          } else {
            scene.drawBarrel(c, px, py, hwp, o.hitFlash, gameTime);
          }
          break;
        }
        case 4: {
          final co = it.o as Coin;
          final sc = cm.scale(co.z);
          scene.drawCoin(c, cm.sx(co.x, co.z), cm.sy(co.z), cm.w * 0.032 * sc, co.spin);
          break;
        }
        case 5: {
          final bb = it.o as BaseFort;
          final sc = cm.scale(bb.z);
          scene.drawBase(c, cm.sx(0, bb.z), cm.sy(bb.z), 2.4 * cm.roadW * sc, bb.hp / bb.maxHp, bb.hitFlash, gameTime);
          break;
        }
        case 6: {
          final co = it.o as Corpse;
          final sc = cm.scale(co.z);
          final dh = cm.w * co.size * sc;
          final px = cm.sx(co.x, co.z);
          final py = cm.sy(co.z);
          final a = (co.life / co.maxLife * 2.0).clamp(0.0, 1.0).toDouble();
          scene.drawSpriteRotated(c, co.style, px, py - dh * 0.5 - co.y * sc, dh, co.rot, a);
          break;
        }
        case 7: {
          final m = it.o as Missile;
          final p = 1.0 - m.t / m.total;
          final ty = cm.sy(0.8);
          final sy = -30.0 + (ty - 8 + 30.0) * p * p;
          scene.drawShell(c, cm.sx(m.tx, 0.8), sy, cm.w * 0.025);
          break;
        }
        case 8: {
          _drawCrew(c);
          break;
        }
        default: {
          _drawCannonItem(c);
          break;
        }
      }
    }
  }

  void _drawSoldier(ui.Canvas c, Soldier s) {
    final cm = cam;
    final sc = cm.scale(s.z);
    final px = cm.sx(s.x, s.z);
    final py = cm.sy(s.z);
    final dh = cm.w * 0.19 * sc;
    if (px < -dh || px > cm.w + dh) return;
    double hop = s.hop > 0 ? math.sin(s.hop * math.pi) * 0.35 : 0.0;
    if (celebrate > 0) hop = math.max(hop, math.sin(gameTime * 10 + s.phase).abs() * 0.3);
    final frame = (gameTime * 9 + s.phase).floor() % 6;
    if (hop > 0.02) scene.drawShadow(c, px, py, dh * 0.5);
    scene.drawSprite(c, s.type, frame, px, py - hop * dh, dh);
  }

  void _drawEnemy(ui.Canvas c, Enemy e) {
    final cm = cam;
    final sc = cm.scale(e.z);
    final px = cm.sx(e.x, e.z);
    final py = cm.sy(e.z);
    final size = e.kind == 2 ? 0.52 : (e.kind == 1 ? 0.235 : 0.19);
    final dh = cm.w * size * sc;
    if (px < -dh || px > cm.w + dh) return;
    final spd = e.kind == 2 ? 6.0 : 9.0;
    final frame = (gameTime * spd + e.phase).floor() % 6;
    scene.drawSprite(c, 4 + e.kind, frame, px, py, dh, flash: e.hitFlash > 0);
    if (e.kind != 0 && e.hp < e.maxHp) {
      scene.drawHpBar(c, px, py - dh - 6 * sc - 4, dh * 0.7, e.hp / e.maxHp);
    }
  }

  void _drawCrew(ui.Canvas c) {
    final cm = cam;
    final t = save.selectedTroop.clamp(0, 3).toInt();
    final sc = cm.scale(0.6);
    final dh = cm.w * 0.19 * sc;
    final py = cm.sy(0.6);
    for (final side in <double>[-1.0, 1.0]) {
      final x = clampD(cannonX + side * 0.24, -0.95, 0.95);
      final px = cm.sx(x, 0.6);
      final frame = (gameTime * 6 + (side > 0 ? 3 : 0)).floor() % 6;
      var hop = 0.0;
      if (celebrate > 0) hop = math.sin(gameTime * 10 + side).abs() * 0.3;
      if (hop > 0.02) scene.drawShadow(c, px, py, dh * 0.5);
      scene.drawSprite(c, t, frame, px, py - hop * dh, dh);
    }
  }

  void _drawCannonItem(ui.Canvas c) {
    if (state == GameState.over) return;
    if (invuln > 0 && state == GameState.playing && ((gameTime * 16).floor() & 1) == 0) return;
    final cm = cam;
    scene.drawCannon(c, cm.sx(cannonX, 0), cm.sy(0), lift * cm.w * 0.11, recoil, flash);
  }
}
