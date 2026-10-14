import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../audio.dart';
import '../core/save_data.dart';
import '../core/utils.dart';
import 'bosses/boss.dart';
import 'bosses/eagle_boss.dart';
import 'bosses/elephant_boss.dart';
import 'bosses/final_boss.dart';
import 'bosses/skeleton_king.dart';
import 'bosses/tiger_boss.dart';
import 'enemy.dart';
import 'environment.dart';
import 'fx.dart';
import 'hazards.dart';
import 'level_data.dart';
import 'player.dart';
import 'player_fx.dart';

/// Anything the player's sword can strike.
abstract class Hittable {
  Rect get hurtBox;
  bool get canBeHit;
  void receiveHit(double damage, double dir, double knock, {bool heavy = false});
}

/// Touch / keyboard input shared between Flutter widgets and the game loop.
class GameInput {
  double moveX = 0;
  bool attack = false;
  bool jump = false;
  bool power = false;
  bool dash = false;
  bool sprint = false;
  bool ultimate = false;
  bool attackHeld = false;

  void reset() {
    ultimate = false;
    attackHeld = false;
    moveX = 0;
    attack = false;
    jump = false;
    power = false;
    dash = false;
    sprint = false;
  }
}

class BossHud {
  const BossHud(this.name, this.frac, this.color, this.phase, this.phases);
  final String name;
  final double frac;
  final Color color;
  final int phase;
  final int phases;
}

class BannerInfo {
  const BannerInfo(this.title, this.subtitle, this.id);
  final String title;
  final String subtitle;
  final int id;
}

/// Values the Flutter HUD listens to. Only updated when they change.
class HudState {
  final ValueNotifier<double> health = ValueNotifier<double>(1);
  final ValueNotifier<int> hearts = ValueNotifier<int>(3);
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<double> power = ValueNotifier<double>(1);
  final ValueNotifier<BossHud?> boss = ValueNotifier<BossHud?>(null);
  final ValueNotifier<BannerInfo?> banner = ValueNotifier<BannerInfo?>(null);
  final ValueNotifier<String> objective = ValueNotifier<String>('');
  final ValueNotifier<bool> regen = ValueNotifier<bool>(false);
  final ValueNotifier<double> ultimate = ValueNotifier<double>(1);

  void dispose() {
    health.dispose();
    hearts.dispose();
    score.dispose();
    power.dispose();
    boss.dispose();
    banner.dispose();
    objective.dispose();
    regen.dispose();
    ultimate.dispose();
  }
}

enum BattleState { intro, playing, playerDead, complete, finished }

class _Pending {
  _Pending(this.def, this.time);
  final SpawnDef def;
  double time;
}

/// The whole battlefield simulation and rendering.
class Battle {
  Battle({
    required this.cfg,
    required this.input,
    required this.hud,
    required this.startX,
    required this.baseScore,
    required this.onPlayerDied,
    required this.onLevelComplete,
    this.ultimateEnabled = false,
  }) {
    env = Environment(cfg);
    fx = Fx(particles);
    player = Player(this, startX <= 0 ? 340 : startX);
    camX = player.x - 400;
    score = baseScore;
    // Spawns before the checkpoint are treated as already cleared.
    _spawnQueue.addAll(cfg.spawns.where((s) => s.triggerX > startX + 250));
    _spawnQueue.sort((a, b) => a.triggerX.compareTo(b.triggerX));
    for (final s in cfg.spikes) {
      spikes.add(SpikeTrap(this, s));
    }
    for (final t in cfg.pendulums) {
      hazards.add(PendulumTrap(this, t));
    }
    for (final t in cfg.vents) {
      hazards.add(FlameVent(this, t));
    }
    checkpointReached = startX > 0;
    _rollTimer = cfg.rollingEvery > 0 ? cfg.rollingEvery * 0.6 : 0;
    _fallTimer = cfg.fallingEvery > 0 ? cfg.fallingEvery * 0.8 : 0;
    switch (cfg.boss) {
      case BossKind.eagle:
        boss = EagleBoss(this);
        break;
      case BossKind.elephant:
        boss = ElephantBoss(this);
        break;
      case BossKind.finalBoss:
        boss = FinalBoss(this);
        break;
      case BossKind.skeletonKing:
        boss = SkeletonKingBoss(this);
        break;
      case BossKind.tiger:
        boss = TigerBoss(this);
        break;
      case BossKind.none:
        break;
    }
    if (boss != null) letterboxTarget = 1;
    showBanner('LEVEL ${cfg.index}', cfg.name);
  }

  final LevelConfig cfg;
  final GameInput input;
  final HudState hud;
  final double startX;
  final int baseScore;
  final VoidCallback onPlayerDied;
  final void Function(int score) onLevelComplete;
  final bool ultimateEnabled;

  late final Environment env;
  double darkness = 0;
  double darknessTarget = 0;
  final Particles particles = Particles(900);
  late final Fx fx;
  final List<Ring> rings = [];
  late final Player player;
  final List<Enemy> enemies = [];
  Boss? boss;
  final List<Projectile> projectiles = [];
  final List<Hazard> hazards = [];
  final List<SpikeTrap> spikes = [];
  final List<HealthPickup> pickups = [];
  final List<PlayerEffect> playerFx = [];
  final List<SpawnDef> _spawnQueue = [];
  final List<_Pending> _pending = [];

  BattleState state = BattleState.intro;
  double stateT = 0;
  double time = 0;
  double viewW = 1280;
  double camX = 0;
  double trauma = 0;
  double _hitStop = 0;
  double _slowT = 0;
  double _slowScale = 1;
  double flashWhite = 0;
  double flashRed = 0;
  double letterbox = 0;
  double letterboxTarget = 0;
  double shakeX = 0;
  double shakeY = 0;
  int score = 0;
  int kills = 0;
  bool checkpointReached = false;
  double _rollTimer = 0;
  double _fallTimer = 0;
  double _ambientT = 0;
  int _bannerId = 0;
  bool _completeFired = false;
  bool _deathFired = false;
  Paint? _vignette;
  double _vignetteW = 0;
  double _vignetteH = 0;

  double get exitX => cfg.length - 170;
  double get viewLeft => camX;
  double get viewRight => camX + viewW;
  bool get controlsLocked => state != BattleState.playing || (boss != null && !boss!.introDone);
  bool get exitOpen => !cfg.isBoss && _spawnQueue.isEmpty && _pending.isEmpty && enemies.every((e) => e.isDead);

  // ---------------------------------------------------------------- helpers

  void addShake(double amount) => trauma = math.min(1.0, trauma + amount);
  void hitStop(double s) => _hitStop = math.max(_hitStop, s);
  void slowMotion(double duration, double scale) {
    _slowT = duration;
    _slowScale = scale;
  }

  void addScore(int n) => score += n;

  void sfx(String file, {double x = double.nan, double volume = 1.0, int gap = 40}) {
    var v = volume;
    if (!x.isNaN) {
      final center = camX + viewW / 2;
      final d = (x - center).abs() - viewW / 2;
      if (d > 0) v *= clampD(1 - d / 900, 0.15, 1);
    }
    GameAudio.instance.play(file, volume: v, minGapMs: gap);
  }

  void showBanner(String title, String subtitle) {
    _bannerId++;
    hud.banner.value = BannerInfo(title, subtitle, _bannerId);
  }

  void ring(double x, double y, double r, double dur, Color color, double width, {double flat = 0.35}) {
    if (rings.length > 40) rings.removeAt(0);
    rings.add(Ring(x, y, r, dur, color, width, flat: flat));
  }

  /// Current top-left of a (possibly moving) platform.
  Offset platformOffset(PlatformDef p) => p.offsetAt(time);

  /// Returns the landing height for something falling from [prevY] to [newY] at [x].
  double? landingY(double x, double halfW, double prevY, double newY) {
    for (final p in cfg.platforms) {
      final o = p.moving ? p.offsetAt(time) : Offset.zero;
      final px = p.x + o.dx;
      final top = p.top + o.dy;
      if (x + halfW * 0.4 < px || x - halfW * 0.4 > px + p.width) continue;
      final tol = p.moving ? 7.0 : 0.5;
      if (prevY <= top + tol && newY >= top) return top;
    }
    if (newY >= 0) return 0;
    return null;
  }

  bool supportedAt(double x, double halfW, double y) {
    if (y >= -0.5) return true;
    return platformUnder(x, halfW, y) != null;
  }

  PlatformDef? platformUnder(double x, double halfW, double y) {
    for (final p in cfg.platforms) {
      final o = p.moving ? p.offsetAt(time) : Offset.zero;
      final tol = p.moving ? 8.0 : 1.5;
      if ((y - (p.top + o.dy)).abs() < tol && x + halfW * 0.4 >= p.x + o.dx && x - halfW * 0.4 <= p.x + o.dx + p.width) return p;
    }
    return null;
  }

  Iterable<Hittable> hittables() sync* {
    for (final e in enemies) {
      if (e.canBeHit) yield e;
    }
    final b = boss;
    if (b != null && b.canBeHit) yield b;
  }

  void spawnPickup(double x, double y, double chance) {
    if (rng.nextDouble() > chance * cfg.dropMul) return;
    if (pickups.length >= 4) return;
    pickups.add(HealthPickup(this, x, math.min(y, -20)));
  }

  void onEnemyKilled(Enemy e) {
    kills++;
    addScore(e.stats.score);
    spawnPickup(e.x, e.y - 60, 0.3);
  }

  void playerDeathFinished() {
    if (_deathFired) return;
    _deathFired = true;
    onPlayerDied();
  }

  void bossDefeated() {
    final b = boss;
    if (b == null) return;
    addScore(b.scoreValue);
  }

  // ---------------------------------------------------------------- update

  void resize(double w) {
    viewW = w;
  }

  void update(double rawDt) {
    var dt = rawDt;
    time += dt;
    // Screen effects always run in real time.
    trauma = math.max(0, trauma - rawDt * 1.5);
    final st = trauma * trauma;
    shakeX = st * 22 * math.sin(time * 61.0);
    shakeY = st * 16 * math.cos(time * 47.0);
    flashWhite = math.max(0, flashWhite - rawDt * 2.2);
    flashRed = math.max(0, flashRed - rawDt * 1.8);
    letterbox += (letterboxTarget - letterbox) * smoothK(4, rawDt);
    darkness += (darknessTarget - darkness) * smoothK(6, rawDt);

    if (_hitStop > 0) {
      _hitStop -= rawDt;
      return;
    }
    if (_slowT > 0) {
      _slowT -= rawDt;
      dt *= _slowScale;
    }

    stateT += dt;
    switch (state) {
      case BattleState.intro:
        if (stateT > 1.2) {
          state = BattleState.playing;
          stateT = 0;
        }
        break;
      case BattleState.playing:
        break;
      case BattleState.playerDead:
        break;
      case BattleState.complete:
        if (stateT > 2.6 && !_completeFired) {
          _completeFired = true;
          state = BattleState.finished;
          final bonus = (player.health * 10).round() + cfg.index * 500;
          addScore(bonus);
          hud.score.value = score;
          onLevelComplete(score);
        }
        break;
      case BattleState.finished:
        break;
    }

    player.update(dt);
    if (!player.alive && state != BattleState.playerDead && state != BattleState.complete && state != BattleState.finished) {
      state = BattleState.playerDead;
      stateT = 0;
    }

    _updateSpawns(dt);
    for (final e in enemies) {
      e.update(dt);
    }
    enemies.removeWhere((e) => e.removed);
    _separateEnemies();

    final b = boss;
    if (b != null) {
      b.update(dt);
      if (b.introDone && letterboxTarget > 0 && !b.defeated) letterboxTarget = 0;
      if (b.defeated) letterboxTarget = 1;
      if (b.finished && state == BattleState.playing) {
        _levelComplete();
      }
    }

    for (final p in projectiles) {
      p.update(dt);
    }
    projectiles.removeWhere((p) => p.dead);
    for (final f in playerFx) {
      f.update(dt);
    }
    playerFx.removeWhere((f) => f.dead);
    _updateHazards(dt);
    for (final s in spikes) {
      s.update(dt);
    }
    for (final p in pickups) {
      p.update(dt);
    }
    pickups.removeWhere((p) => p.dead);

    particles.update(dt);
    for (final r in rings) {
      r.update(dt);
    }
    rings.removeWhere((r) => r.done);

    _ambient(dt);
    _checkpointAndExit();
    _updateCamera(dt);
    _syncHud();
  }

  void _updateSpawns(double dt) {
    if (state != BattleState.playing || cfg.isBoss) return;
    while (_spawnQueue.isNotEmpty && player.x + viewW * 0.5 >= _spawnQueue.first.triggerX) {
      final d = _spawnQueue.removeAt(0);
      _pending.add(_Pending(d, d.delay));
    }
    for (final p in _pending) {
      p.time -= dt;
      if (p.time <= 0) _spawnEnemy(p.def);
    }
    _pending.removeWhere((p) => p.time <= 0);
  }

  void _spawnEnemy(SpawnDef d) {
    double x;
    switch (d.side) {
      case SpawnSide.right:
        x = math.min(camX + viewW + 90, cfg.length - 40);
        break;
      case SpawnSide.left:
        x = math.max(camX - 90, 40);
        break;
      case SpawnSide.ground:
      case SpawnSide.sky:
        final dir = rng.nextBool() ? 1 : -1;
        x = clampD(player.x + dir * randRange(240, 420), 60, cfg.length - 60);
        break;
    }
    enemies.add(Enemy(this, d.kind, x, d.side));
  }

  void _separateEnemies() {
    for (var i = 0; i < enemies.length; i++) {
      final a = enemies[i];
      if (!a.solid) continue;
      for (var j = i + 1; j < enemies.length; j++) {
        final b = enemies[j];
        if (!b.solid) continue;
        final dx = b.x - a.x;
        final minD = (a.stats.height + b.stats.height) * 0.18;
        if (dx.abs() < minD) {
          final push = (minD - dx.abs()) * 0.5;
          final s = dx >= 0 ? 1.0 : -1.0;
          a.x -= s * push * 0.5;
          b.x += s * push * 0.5;
        }
      }
    }
  }

  void _updateHazards(double dt) {
    if (state == BattleState.playing && !cfg.isBoss) {
      if (cfg.rollingEvery > 0) {
        _rollTimer -= dt;
        if (_rollTimer <= 0) {
          _rollTimer = cfg.rollingEvery * randRange(0.75, 1.3);
          final fromRight = player.x < cfg.length - 900 ? rng.nextDouble() < 0.75 : false;
          hazards.add(RollingStone(this, fromRight ? -1 : 1, randRange(36, 62)));
        }
      }
      if (cfg.fallingEvery > 0) {
        _fallTimer -= dt;
        if (_fallTimer <= 0) {
          _fallTimer = cfg.fallingEvery * randRange(0.7, 1.3);
          final tx = clampD(player.x + player.vx * 0.6 + randRange(-160, 160), 60, cfg.length - 60);
          hazards.add(FallingStone(this, tx));
        }
      }
    }
    for (final h in hazards) {
      h.update(dt);
    }
    hazards.removeWhere((h) => h.dead);
  }

  void _ambient(double dt) {
    _ambientT -= dt;
    if (_ambientT <= 0) {
      _ambientT = 0.06;
      // Floating ash and embers across the view.
      particles.spawn(
        px: camX + rng.nextDouble() * viewW,
        py: -randRange(0, 560),
        pvx: randRange(-25, 10),
        pvy: randRange(-25, -5),
        plife: randRange(3, 6),
        psize: randRange(1, 2.4),
        pcolor: rng.nextDouble() < 0.2 ? const Color(0x88FF6A3A) : const Color(0x55A8B8D0),
        pkind: PKind.ember,
      );
    }
  }

  void _checkpointAndExit() {
    if (state != BattleState.playing || cfg.isBoss) {
      hud.objective.value = cfg.isBoss ? '' : hud.objective.value;
      return;
    }
    if (!checkpointReached && player.x >= cfg.checkpointX && player.alive) {
      checkpointReached = true;
      SaveData.instance.saveCheckpoint(cfg.index, cfg.checkpointX);
      showBanner('CHECKPOINT', 'PROGRESS SAVED');
      fx.energy(cfg.checkpointX, -120, n: 30, color: const Color(0xFF7FD8FF));
      ring(cfg.checkpointX, -4, 140, 0.8, const Color(0xFF7FD8FF), 5);
      sfx(Sfx.pickupHealth, volume: 0.6);
    }
    final alive = enemies.where((e) => !e.isDead).length + _pending.length;
    if (exitOpen) {
      hud.objective.value = 'REACH THE SHADOW GATE';
      if (player.x >= exitX - 40 && player.alive) _levelComplete();
    } else {
      hud.objective.value = alive > 0 ? 'SHADOWS REMAINING  $alive' : 'ADVANCE';
    }
  }

  void _levelComplete() {
    if (state == BattleState.complete || state == BattleState.finished) return;
    state = BattleState.complete;
    stateT = 0;
    letterboxTarget = 1;
    sfx(Sfx.levelComplete, volume: 0.9);
    showBanner(cfg.index == 20 ? 'VICTORY' : 'LEVEL COMPLETE', cfg.name);
    SaveData.instance.clearCheckpoint(cfg.index);
  }

  void _updateCamera(double dt) {
    final look = player.facing * 110;
    var target = player.x - viewW * 0.42 + look;
    final b = boss;
    if (b != null && b.introDone == false) {
      target = b.focusX - viewW * 0.5;
    } else if (b != null && !b.finished) {
      final mid = (player.x + b.focusX) * 0.5 - viewW * 0.5;
      target = clampD(mid, player.x - viewW * 0.78, player.x - viewW * 0.22);
    }
    final maxX = cfg.length - viewW;
    if (maxX <= 0) {
      camX = maxX / 2;
      return;
    }
    target = clampD(target, 0, maxX);
    camX += (target - camX) * smoothK(4.5, dt);
    camX = clampD(camX, 0, maxX);
  }

  double _lastHealth = -1;
  double _lastPower = -1;
  int _lastScore = -1;
  double _lastBossFrac = -1;
  int _lastBossPhase = -1;

  void _syncHud() {
    final h = (player.health / Player.maxHealth).clamp(0.0, 1.0);
    if ((h - _lastHealth).abs() > 0.001) {
      _lastHealth = h;
      hud.health.value = h;
    }
    final p = (player.powerCharge * 50).round() / 50;
    if (p != _lastPower) {
      _lastPower = p;
      hud.power.value = p;
    }
    if (hud.regen.value != player.regenerating) hud.regen.value = player.regenerating;
    final ul = (player.ultimateCharge * 40).round() / 40;
    if (hud.ultimate.value != ul) hud.ultimate.value = ul;
    if (score != _lastScore) {
      _lastScore = score;
      hud.score.value = score;
    }
    final b = boss;
    if (b != null && b.introDone && !b.finished) {
      final f = b.barFraction;
      if ((f - _lastBossFrac).abs() > 0.002 || b.phase != _lastBossPhase) {
        _lastBossFrac = f;
        _lastBossPhase = b.phase;
        hud.boss.value = BossHud(b.phaseName, f, b.barColor, b.phase, b.phaseCount);
      }
    } else if (hud.boss.value != null && (b == null || b.finished)) {
      hud.boss.value = null;
    }
  }

  // ---------------------------------------------------------------- render

  void render(Canvas c, double screenW, double screenH) {
    // Wide phone screens get a closer camera (crop the top of the sky).
    final aspect = screenW / math.max(1.0, screenH);
    final crop = clampD((aspect - 1.5) * 250, 0, 150);
    final visH = Environment.virtualH - crop;
    final scale = screenH / visH;
    final vw = screenW / scale;
    if ((vw - viewW).abs() > 0.5) resize(vw);
    c.save();
    c.scale(scale, scale);
    c.translate(0, -crop);
    env.renderBackground(c, camX, viewW, time);
    if (darkness > 0.01) {
      _mk
        ..shader = null
        ..color = fade(const Color(0xFF020208), darkness * 0.8);
      c.drawRect(Rect.fromLTWH(0, 0, viewW, Environment.virtualH), _mk);
    }

    c.save();
    c.translate(-camX + shakeX, Environment.groundScreenY + shakeY);
    env.renderGround(c, camX, viewW);
    env.renderProps(c, camX, viewW);
    env.renderMovingPlatforms(c, time);
    _renderMarkers(c);
    for (final s in spikes) {
      s.render(c);
    }
    for (final h in hazards) {
      if (h.behind) h.render(c);
    }
    for (final f in playerFx) {
      if (f is GroundCrack) f.render(c);
    }
    for (final p in pickups) {
      p.render(c);
    }
    boss?.render(c);
    for (final e in enemies) {
      e.render(c);
    }
    player.render(c);
    for (final h in hazards) {
      if (!h.behind) h.render(c);
    }
    for (final p in projectiles) {
      p.render(c);
    }
    for (final f in playerFx) {
      if (f is! GroundCrack) f.render(c);
    }
    particles.render(c, camX - 100, camX + viewW + 100);
    for (final r in rings) {
      r.render(c);
    }
    c.restore();

    env.renderForeground(c, camX - shakeX, viewW, time);
    _renderScreenFx(c, crop, visH);
    c.restore();
  }

  final Paint _mk = Paint()..isAntiAlias = true;

  void _renderMarkers(Canvas c) {
    if (cfg.isBoss) return;
    // Checkpoint shrine.
    final cx = cfg.checkpointX;
    if (cx > camX - 200 && cx < camX + viewW + 200) {
      _mk.color = const Color(0xFF0B0D12);
      c.drawRect(Rect.fromLTWH(cx - 14, -150, 28, 150), _mk);
      c.drawRect(Rect.fromLTWH(cx - 26, -160, 52, 14), _mk);
      final g = checkpointReached ? 1.0 : 0.35;
      final pulse = 0.8 + 0.2 * math.sin(time * 4);
      _mk.color = fade(const Color(0xFF7FD8FF), 0.18 * g * pulse);
      c.drawCircle(Offset(cx, -178), 34, _mk);
      _mk.color = fade(const Color(0xFFBFF0FF), 0.9 * g);
      c.drawCircle(Offset(cx, -178), 7, _mk);
    }
    // Exit gate.
    final ex = exitX;
    if (ex > camX - 300 && ex < camX + viewW + 300) {
      _mk.color = const Color(0xFF090A0F);
      c.drawRect(Rect.fromLTWH(ex - 90, -300, 34, 300), _mk);
      c.drawRect(Rect.fromLTWH(ex + 56, -300, 34, 300), _mk);
      c.drawRect(Rect.fromLTWH(ex - 110, -330, 220, 40), _mk);
      final open = exitOpen;
      final k = open ? 1.0 : 0.25;
      final r = Rect.fromLTWH(ex - 56, -290, 112, 290);
      _mk.shader = ui.Gradient.linear(r.topCenter, r.bottomCenter, [
        fade(const Color(0xFF6A3CFF), 0.0),
        fade(const Color(0xFF8A5CFF), 0.55 * k),
        fade(const Color(0xFFE0D0FF), 0.8 * k),
      ], const [0.0, 0.6, 1.0]);
      c.drawRect(r, _mk);
      _mk.shader = null;
      if (open && rng.nextDouble() < 0.5) {
        particles.spawn(px: ex + randRange(-50, 50), py: randRange(-280, -10), pvy: randRange(-60, -20), plife: 1.0, psize: 2.5, pcolor: const Color(0xFFB89CFF), pkind: PKind.glow);
      }
    }
  }

  void _renderScreenFx(Canvas c, double top, double h) {
    final w = viewW;
    c.save();
    c.translate(0, top);
    if (_vignette == null || (_vignetteW - w).abs() > 1 || (_vignetteH - h).abs() > 1) {
      _vignetteW = w;
      _vignetteH = h;
      _vignette = Paint()
        ..shader = ui.Gradient.radial(
          Offset(w / 2, h * 0.48),
          w * 0.72,
          const [Color(0x00000000), Color(0x00000000), Color(0xB0000000)],
          const [0.0, 0.55, 1.0],
        );
    }
    c.drawRect(Rect.fromLTWH(0, 0, w, h), _vignette!);
    final lowHealth = player.alive && player.health < 30;
    final redA = math.max(flashRed * 0.55, lowHealth ? 0.18 + 0.1 * math.sin(time * 6) : 0.0);
    if (redA > 0.01) {
      _mk.shader = ui.Gradient.radial(
        Offset(w / 2, h / 2),
        w * 0.7,
        [const Color(0x00000000), fade(const Color(0xFFB00010), redA)],
        const [0.45, 1.0],
      );
      c.drawRect(Rect.fromLTWH(0, 0, w, h), _mk);
      _mk.shader = null;
    }
    if (flashWhite > 0.01) {
      _mk.color = fade(const Color(0xFFE8EEFF), flashWhite * 0.75);
      c.drawRect(Rect.fromLTWH(0, 0, w, h), _mk);
    }
    if (letterbox > 0.01) {
      _mk.color = const Color(0xFF000000);
      final bh = 64 * letterbox;
      c.drawRect(Rect.fromLTWH(0, 0, w, bh), _mk);
      c.drawRect(Rect.fromLTWH(0, h - bh, w, bh), _mk);
    }
    c.restore();
  }

  void dispose() {
    env.dispose();
  }
}
