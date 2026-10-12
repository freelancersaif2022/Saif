import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/painting.dart' show EdgeInsets;

import '../audio/audio_manager.dart';
import '../components/battlefield_renderer.dart';
import '../components/hud_component.dart';
import '../components/minimap_builder.dart';
import '../components/screen_fx_component.dart';
import '../entities/enemy.dart';
import '../entities/player.dart';
import '../entities/projectiles.dart';
import '../entities/soldier_rig.dart';
import '../systems/battle_map.dart';
import '../systems/bullet_system.dart';
import '../systems/effects_system.dart';
import '../systems/enemy_director.dart';
import '../systems/player_controller.dart';
import '../systems/projection.dart';
import '../utils/asset_paths.dart';
import '../utils/image_store.dart';
import '../utils/math_utils.dart';
import '../utils/save_manager.dart';
import '../weapons/weapon_data.dart';
import 'game_session.dart';
import 'input_state.dart';

enum GamePhase { loading, playing, dying, gameOver }

class GameOverlays {
  GameOverlays._();

  static const String controls = 'controls';
  static const String pause = 'pause';
  static const String gameOver = 'gameOver';
}

/// The battlefield game: owns every system and drives the frame loop.
class AmadanGame extends FlameGame {
  AmadanGame({required this.weaponType, required this.onExitToLobby});

  final WeaponType weaponType;
  final void Function() onExitToLobby;

  final InputState input = InputState();
  final Projection proj = Projection();
  final BattleMap map = BattleMap();
  final SoldierRenderer rig = SoldierRenderer();
  final GameSession session = GameSession();
  final ValueNotifier<bool> aimingNotifier = ValueNotifier<bool>(false);

  late final Player player;
  late final EffectsSystem fx;
  late final BulletSystem bullets;
  late final EnemyDirector director;
  late final PlayerController controller;
  late final RigLook playerLook;

  final List<Grenade> grenades = List<Grenade>.generate(10, (_) => Grenade());
  final List<Pickup> pickups = List<Pickup>.generate(8, (_) => Pickup());
  final List<ScorePopup> popups = List<ScorePopup>.generate(10, (_) => ScorePopup());
  final List<Decal> dynamicDecals = <Decal>[];
  static const int _maxDynamicDecals = 18;
  int _decalCursor = 0;

  EdgeInsets safeInsets = EdgeInsets.zero;
  GamePhase phase = GamePhase.loading;
  bool _disposed = false;

  // Camera and feedback state read by the render components.
  double shakeX = 0;
  double shakeY = 0;
  double _shakePower = 0;
  double damagePulse = 0;
  double dangerPulse = 0;
  double flashPulse = 0;
  double hitMarker = 0;
  bool hitMarkerKill = false;
  bool hitMarkerHead = false;
  double hitMarkerX = 0;
  double hitMarkerY = 0;
  double hitMarkerZ = 0;
  String banner = '';
  double bannerTime = 0;
  bool bannerWarning = false;
  int ammoVersion = 0;

  double _ambientBoomTimer = 9;
  double _emberTimer = 0;
  double _survivalTick = 0;

  AudioManager get audio => AudioManager.instance;
  WeaponSpec get weaponSpec => player.weapon.spec;
  bool get isReady => phase != GamePhase.loading;

  @override
  Color backgroundColor() => const Color(0xFF0B0C0E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await ImageStore.loadAll(AssetPaths.gameImages);
    map.generate(20251);
    player = Player(WeaponSpec.of(weaponType));
    fx = EffectsSystem(ImageStore.get(AssetPaths.fxAtlas));
    bullets = BulletSystem(this);
    director = EnemyDirector(this);
    controller = PlayerController(this);
    playerLook = RigLook(
      uniform: const Color(0xFF4E5A3A),
      vest: const Color(0xFF3A4230),
      skin: const Color(0xFFC4946E),
      helmet: const Color(0xFF4A5436),
      gear: const Color(0xFF3E4230),
      boots: const Color(0xFF231F1A),
      gloves: const Color(0xFF2A2822),
      headGear: HeadGear.helmet,
      camo: ImageStore.tryGet(AssetPaths.camoPlayer),
      visor: const Color(0xFF1A1C1E),
    );
    final minimap = await buildMinimapImage(map);
    await add(BattlefieldRenderer());
    await add(ScreenFxComponent());
    await add(HudComponent(minimap));
    _resetState();
    phase = GamePhase.playing;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x > 0 && size.y > 0) {
      proj.configure(size.x, size.y);
    }
  }

  void _resetState() {
    session.reset();
    player.reset(map.startX, map.startY);
    director.reset();
    bullets.clear();
    fx.clear();
    for (final g in grenades) {
      g.active = false;
    }
    for (final p in pickups) {
      p.active = false;
    }
    for (final p in popups) {
      p.active = false;
    }
    dynamicDecals.clear();
    _decalCursor = 0;
    input.reset();
    setAimingFlag(false);
    proj.camX = player.x;
    proj.camY = player.y;
    proj.setZoom(1);
    shakeX = 0;
    shakeY = 0;
    _shakePower = 0;
    damagePulse = 0;
    dangerPulse = 0;
    flashPulse = 0;
    hitMarker = 0;
    _ambientBoomTimer = 9;
    _survivalTick = 0;
    ammoVersion++;
    showBanner('WAVE 1');
  }

  // ---------------------------------------------------------------- frame loop

  @override
  void update(double dt) {
    super.update(dt);
    if (phase == GamePhase.loading || _disposed) return;
    final d = math.min(dt, 1 / 30);

    switch (phase) {
      case GamePhase.playing:
        session.time += d;
        _survivalTick += d;
        if (_survivalTick >= 1) {
          _survivalTick -= 1;
          session.addScore(5);
        }
        controller.update(d);
        director.update(d);
        bullets.update(d);
        _updateGrenades(d);
        _updatePickups(d);
        _updateAmbience(d);
        break;
      case GamePhase.dying:
        controller.updateDead(d);
        director.update(d);
        bullets.update(d);
        _updateGrenades(d);
        if (player.deathTimer > 2.4) {
          _enterGameOver();
        }
        break;
      case GamePhase.gameOver:
      case GamePhase.loading:
        break;
    }

    fx.update(d);
    _updateFires(d);
    _updatePopups(d);
    _updateCamera(d);
    _updateFeedback(d);
  }

  void _updateCamera(double dt) {
    final p = player;
    var lookX = 0.0;
    var lookY = 0.0;
    if (p.aiming && p.alive) {
      lookX = math.cos(p.pose.facing) * 110;
      lookY = math.sin(p.pose.facing) * 70;
    } else {
      lookX = p.vx * 0.25;
      lookY = p.vy * 0.15;
    }
    final k = damp(5.5, dt);
    proj.camX += (p.x + lookX - proj.camX) * k;
    proj.camY += (p.y + lookY - proj.camY) * k;
    final targetZoom = (p.aiming && p.alive) ? weaponSpec.zoom : (phase == GamePhase.dying ? 1.12 : 1.0);
    proj.setZoom(proj.zoom + (targetZoom - proj.zoom) * damp(4, dt));
  }

  void _updateFeedback(double dt) {
    _shakePower = math.max(0.0, _shakePower - dt * (_shakePower * 5 + 4));
    if (_shakePower > 0.05) {
      shakeX = (rng.nextDouble() * 2 - 1) * _shakePower;
      shakeY = (rng.nextDouble() * 2 - 1) * _shakePower;
    } else {
      shakeX = 0;
      shakeY = 0;
    }
    damagePulse = math.max(0.0, damagePulse - dt * 1.8);
    dangerPulse = math.max(0.0, dangerPulse - dt * 1.6);
    flashPulse = math.max(0.0, flashPulse - dt * 3);
    hitMarker = math.max(0.0, hitMarker - dt * 4);
    if (bannerTime > 0) bannerTime -= dt;
  }

  void _updateFires(double dt) {
    final maxDepth = Projection.farClip - 400;
    for (final f in map.fires) {
      final depth = proj.depthOf(f.y);
      if (depth < Projection.nearClip || depth > maxDepth) continue;
      final half = (proj.width * 0.5 + 200) * depth / proj.focal;
      if ((f.x - proj.camX).abs() > half) continue;
      f.emitAcc += dt * 9 * f.intensity;
      while (f.emitAcc >= 1) {
        f.emitAcc -= 1;
        fx.fireTick(f.x, f.y, f.z, f.intensity);
      }
      f.smokeAcc += dt * (f.smokeColumn ? 2.4 : 1.0);
      while (f.smokeAcc >= 1) {
        f.smokeAcc -= 1;
        fx.smokePuff(f.x, f.y, f.z + 30, f.intensity * (f.smokeColumn ? 1.3 : 0.8), column: f.smokeColumn);
      }
      if (rng.nextDouble() < dt * 2.5) {
        fx.ember(f.x + randRange(-20, 20), f.y, f.z + 40);
      }
    }
  }

  void _updateAmbience(double dt) {
    _emberTimer -= dt;
    if (_emberTimer <= 0) {
      _emberTimer = randRange(0.08, 0.25);
      fx.ember(player.x + randRange(-500, 500), player.y + randRange(-700, 150), randRange(20, 140));
    }
    _ambientBoomTimer -= dt;
    if (_ambientBoomTimer <= 0) {
      _ambientBoomTimer = randRange(9, 17);
      final depth = randRange(1300, 2100);
      final y = proj.camY + Projection.backDist - depth;
      final half = proj.width * 0.5 * depth / proj.focal;
      final x = proj.camX + randRange(-half, half);
      fx.explosion(x, y, 0.9);
      audio.play(Sfx.explosion, volume: 0.28, minGapMs: 0);
      shake(1.5);
    }
  }

  void _updateGrenades(double dt) {
    for (final g in grenades) {
      if (!g.active) continue;
      g.t += dt;
      if (g.t >= g.duration) {
        g.active = false;
        explode(g.tx, g.ty, g.radius, g.damage);
      }
    }
  }

  void _updatePickups(double dt) {
    for (final p in pickups) {
      if (!p.active) continue;
      p.life -= dt;
      if (p.life <= 0) {
        p.active = false;
        continue;
      }
      if (player.alive && dist2(p.x, p.y, player.x, player.y) < 44 * 44) {
        if (player.hp < Player.maxHp) {
          player.hp = math.min(Player.maxHp, player.hp + p.heal);
          p.active = false;
          fx.healBurst(p.x, p.y);
          audio.play(Sfx.uiSelect, volume: 0.8, minGapMs: 0);
        }
      }
    }
  }

  void _updatePopups(double dt) {
    for (final p in popups) {
      if (!p.active) continue;
      p.life -= dt;
      p.z += dt * 40;
      if (p.life <= 0) p.active = false;
    }
  }

  // ---------------------------------------------------------------- events

  void shake(double power) {
    _shakePower = math.min(18.0, math.max(_shakePower, power));
  }

  void showBanner(String text, {bool warning = false}) {
    banner = text;
    bannerWarning = warning;
    bannerTime = 2.6;
  }

  void ammoChanged() => ammoVersion++;

  void setAimingFlag(bool value) {
    if (!_disposed && aimingNotifier.value != value) {
      aimingNotifier.value = value;
    }
  }

  void registerHit(double x, double y, double z, bool kill, bool headshot) {
    hitMarker = 1;
    hitMarkerKill = kill;
    hitMarkerHead = headshot;
    hitMarkerX = x;
    hitMarkerY = y;
    hitMarkerZ = z;
  }

  void addCrater(double x, double y, double size) {
    if (dynamicDecals.length < _maxDynamicDecals) {
      dynamicDecals.add(Decal(x, y, size));
    } else {
      final d = dynamicDecals[_decalCursor];
      d
        ..x = x
        ..y = y
        ..size = size;
      _decalCursor = (_decalCursor + 1) % _maxDynamicDecals;
    }
  }

  void launchGrenade(double sx, double sy, double tx, double ty, double duration, double damage) {
    final tX = clampD(tx, BattleMap.margin, BattleMap.size - BattleMap.margin);
    final tY = clampD(ty, BattleMap.margin, BattleMap.size - BattleMap.margin);
    for (final g in grenades) {
      if (g.active) continue;
      g
        ..active = true
        ..sx = sx
        ..sy = sy
        ..tx = tX
        ..ty = tY
        ..t = 0
        ..duration = duration
        ..radius = 150
        ..damage = damage;
      return;
    }
  }

  void explode(double x, double y, double radius, double damage) {
    fx.explosion(x, y, 1.0);
    addCrater(x, y, radius * 1.3);
    final v = AudioCue.volumeAt(this, x, y, radius: 1800);
    audio.play(Sfx.explosion, volume: 0.4 + v * 0.6, minGapMs: 40);
    final d = math.sqrt(dist2(x, y, player.x, player.y));
    shake(4 + 10 * clampD(1 - d / 900, 0, 1));
    flashPulse = math.max(flashPulse, 0.35 * clampD(1 - d / 1200, 0, 1));
    if (player.alive && d < radius) {
      final falloff = 1 - (d / radius) * 0.6;
      damagePlayer(damage * falloff, x, y);
      final nx = (player.x - x) / (d + 1e-3);
      final ny = (player.y - y) / (d + 1e-3);
      knockPlayer(nx * 220, ny * 220);
    }
  }

  void knockPlayer(double vx, double vy) {
    player.vx += vx;
    player.vy += vy;
  }

  void damagePlayer(double amount, double fromX, double fromY) {
    if (!player.alive || phase != GamePhase.playing) return;
    player.hp -= amount;
    player.sinceDamage = 0;
    player.hitFlash = 1;
    player.pose.hit = 1;
    damagePulse = math.min(1.0, damagePulse + 0.45 + amount / 40);
    shake(3 + amount * 0.25);
    audio.play(Sfx.playerHurt, volume: 0.7, minGapMs: 260);
    if (player.hp <= 0) {
      player.hp = 0;
      _killPlayer();
    }
  }

  void _killPlayer() {
    player.alive = false;
    player.sprinting = false;
    player.aiming = false;
    player.target = null;
    player.deathTimer = 0;
    setAimingFlag(false);
    input.reset();
    phase = GamePhase.dying;
    audio.play(Sfx.playerDeath, volume: 1.0, minGapMs: 0);
    shake(10);
    overlays.remove(GameOverlays.controls);
  }

  void onEnemyKilled(Enemy e, bool headshot) {
    var points = e.spec.points.toDouble() * (1 + (session.level - 1) * 0.1);
    if (headshot) {
      points *= 1.5;
      session.headshots++;
    }
    session.kills++;
    session.addScore(points);
    _spawnPopup(e.x, e.y, 70 * e.spec.scale, points.round(), headshot);

    if (e.isBoss) {
      session.bossActive = false;
      session.bossesDefeated++;
      session.level++;
      session.levelKills = 0;
      showBanner('BOSS DEFEATED');
      _dropPickup(e.x + 30, e.y);
      _dropPickup(e.x - 30, e.y + 20);
      return;
    }

    if (rng.nextDouble() < 0.1) {
      _dropPickup(e.x, e.y);
    }

    if (!session.bossActive) {
      session.levelKills++;
      if (session.levelKills >= session.killsForNextLevel) {
        session.level++;
        session.levelKills = 0;
        session.addScore(250.0 * session.level);
        if (session.level % 4 == 0) {
          session.bossActive = true;
          showBanner('WARNING  BOSS INCOMING', warning: true);
          dangerPulse = 1;
          director.spawnBoss();
        } else {
          showBanner('WAVE ${session.level}');
          audio.play(Sfx.uiSelect, volume: 0.6, minGapMs: 0);
        }
      }
    }
  }

  void _dropPickup(double x, double y) {
    for (final p in pickups) {
      if (p.active) continue;
      p
        ..active = true
        ..x = x
        ..y = y
        ..life = 22
        ..heal = 35;
      return;
    }
  }

  void _spawnPopup(double x, double y, double z, int value, bool headshot) {
    ScorePopup? slot;
    var oldest = double.infinity;
    for (final p in popups) {
      if (!p.active) {
        slot = p;
        break;
      }
      if (p.life < oldest) {
        oldest = p.life;
        slot = p;
      }
    }
    if (slot == null) return;
    slot
      ..active = true
      ..x = x
      ..y = y
      ..z = z
      ..life = 1.2
      ..value = value
      ..headshot = headshot;
  }

  Future<void> _enterGameOver() async {
    if (phase == GamePhase.gameOver) return;
    phase = GamePhase.gameOver;
    session.newHighScore = await SaveManager.submitScore(session.score);
    if (_disposed) return;
    unawaited(audio.stopAmbient());
    unawaited(audio.playMusic(Sfx.musicMenu));
    overlays.remove(GameOverlays.controls);
    overlays.add(GameOverlays.gameOver);
    pauseEngine();
  }

  // ---------------------------------------------------------------- flow control

  void pauseGame() {
    if (phase != GamePhase.playing || paused || _disposed) return;
    input.reset();
    pauseEngine();
    overlays.add(GameOverlays.pause);
    audio.play(Sfx.uiClick, volume: 0.5, minGapMs: 0);
    unawaited(audio.pauseAmbient());
  }

  void resumeGame() {
    if (_disposed) return;
    overlays.remove(GameOverlays.pause);
    input.reset();
    resumeEngine();
    unawaited(audio.resumeAmbient());
  }

  void restart() {
    if (_disposed) return;
    overlays.remove(GameOverlays.pause);
    overlays.remove(GameOverlays.gameOver);
    _resetState();
    phase = GamePhase.playing;
    if (!overlays.isActive(GameOverlays.controls)) {
      overlays.add(GameOverlays.controls);
    }
    resumeEngine();
    unawaited(audio.playMusic(Sfx.musicBattle));
    unawaited(audio.startAmbient());
  }

  void exitToLobby() {
    if (_disposed) return;
    input.reset();
    onExitToLobby();
  }

  /// Called by the hosting screen when it is disposed.
  void shutdown() {
    _disposed = true;
    input.reset();
    aimingNotifier.dispose();
  }
}
