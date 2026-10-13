import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../art/sprite_cache.dart';
import '../config/economy_config.dart';
import '../models/dragon_model.dart';
import '../models/enemy_model.dart';
import '../models/player_progress_model.dart';
import '../services/audio_service.dart';
import 'components/coin_component.dart';
import 'components/dragon_component.dart';
import 'components/enemy_component.dart';
import 'components/environment_component.dart';
import 'components/obstacle_component.dart';
import 'components/particle_component.dart';
import 'components/projectile_component.dart';
import 'game_config.dart';
import 'input_state.dart';
import 'run_state.dart';
import 'systems/collision_system.dart';
import 'systems/difficulty_system.dart';
import 'systems/scoring_system.dart';
import 'systems/spawning_system.dart';

enum RunPhase { loading, playing, dying, over }

/// Applies the world->screen scale for every gameplay layer.
class _Playfield extends Component {
  double scale = 1;

  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    canvas.scale(scale);
    super.renderTree(canvas);
    canvas.restore();
  }
}

/// Draws the dragon's ground shadow under all entities.
class _ShadowLayer extends Component {
  _ShadowLayer(this.game, {super.priority});
  final DragonLandGame game;

  @override
  void render(Canvas canvas) => game.dragon.renderShadow(canvas, game.ground);
}

/// Full-screen effects: solar beam, screen flash and damage vignette.
class _FxLayer extends Component {
  _FxLayer(this.game, {super.priority});
  final DragonLandGame game;
  final Paint _p = Paint()..isAntiAlias = true;

  @override
  void render(Canvas canvas) {
    final w = game.viewWidth;
    if (game.solarBeam > 0) {
      final m = game.dragon.mouth;
      final k = (game.solarBeam / 0.7).clamp(0.0, 1.0);
      final h = 150 * (0.6 + 0.4 * k);
      final rect = Rect.fromLTRB(m.dx, m.dy - h / 2, w + 20, m.dy + h / 2);
      _p
        ..shader = Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [const Color(0x00FFE066), Color.fromRGBO(255, 240, 160, 0.95 * k), const Color(0x00FF9F1C)],
          const [0.0, 0.5, 1.0],
        )
        ..blendMode = BlendMode.plus;
      canvas.drawRect(rect, _p);
      _p
        ..shader = null
        ..blendMode = BlendMode.srcOver;
    }
    if (game.flash > 0) {
      _p.color = game.flashColor.withValues(alpha: (game.flash * 0.6).clamp(0.0, 0.6));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, GameConfig.worldHeight), _p);
    }
    if (game.damageVignette > 0) {
      final a = game.damageVignette.clamp(0.0, 1.0);
      _p.shader = Gradient.radial(
        Offset(w / 2, GameConfig.worldHeight / 2),
        w * 0.7,
        [const Color(0x00FF0000), Color.fromRGBO(255, 30, 60, 0.45 * a)],
        const [0.6, 1.0],
      );
      canvas.drawRect(Rect.fromLTWH(0, 0, w, GameConfig.worldHeight), _p);
      _p.shader = null;
    }
  }
}

/// The endless-runner game itself.
class DragonLandGame extends FlameGame {
  DragonLandGame({required this.dragonDef, required this.settings, required this.audio, this.onGameOver, this.seed}) {
    // The gameplay screen owns pausing on background so the game can never
    // auto-resume behind the pause menu.
    pauseWhenBackgrounded = false;
  }

  final DragonDef dragonDef;
  final GameSettings settings;
  final AudioService audio;
  final int? seed;

  /// Called once when a run ends (after the defeat animation).
  void Function()? onGameOver;

  final HudState hud = HudState();
  final InputState input = InputState();
  RunStats stats = RunStats();
  final DifficultySystem difficulty = DifficultySystem();

  late final SpriteCache sprites;
  late final BackgroundComponent background;
  late final GroundComponent ground;
  late final ForegroundComponent foreground;
  late final ObstacleLayer obstacles;
  late final PickupLayer pickups;
  late final EnemyLayer enemies;
  late final ProjectileLayer projectiles;
  late final ParticleLayer particles;
  late final DragonComponent dragon;
  late final SpawningSystem spawner;
  late final CollisionSystem collisions;
  final _Playfield _playfield = _Playfield();

  RunPhase phase = RunPhase.loading;
  double viewWidth = 1280;
  double currentSpeed = 0;
  int revivesUsed = 0;
  final math.Random _rng = math.Random();

  // timed effects
  double magnetTime = 0;
  double doubleCoinsTime = 0;
  double solarBeam = 0;
  final Set<Object> _beamHits = {};
  double flash = 0;
  Color flashColor = const Color(0xFFFFFFFF);
  double damageVignette = 0;
  double _hudTimer = 0;
  double _dyingTimer = 0;
  double _flapSoundT = 0;

  int get quality => settings.graphics.index;

  @override
  Color backgroundColor() => const Color(0xFF6CC6FF);

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/images/';
    final loaded = await images.loadAll([
      'sky.png',
      'sun.png',
      'bg_far.png',
      'bg_mid.png',
      'bg_near.png',
      'ground.png',
      'foreground.png',
      'cloud_1.png',
      'cloud_2.png',
      'cloud_3.png',
      'cloud_4.png',
    ]);
    final env = EnvironmentImages(
      sky: loaded[0],
      sun: loaded[1],
      far: loaded[2],
      mid: loaded[3],
      near: loaded[4],
      ground: loaded[5],
      foreground: loaded[6],
      clouds: loaded.sublist(7),
    );
    sprites = SpriteCache(pixelRatio: quality == 0 ? 1.2 : 1.6)..build();

    background = BackgroundComponent(env, quality: quality, priority: 0);
    ground = GroundComponent(env.ground, priority: 1);
    final shadow = _ShadowLayer(this, priority: 2);
    obstacles = ObstacleLayer(sprites, priority: 3);
    pickups = PickupLayer(sprites, priority: 4);
    enemies = EnemyLayer(sprites, priority: 5);
    dragon = DragonComponent(dragonDef, priority: 6);
    projectiles = ProjectileLayer(priority: 7);
    particles = ParticleLayer(maxParticles: const [140, 260, 420][quality], priority: 8)..density = const [0.45, 0.75, 1.0][quality];
    foreground = ForegroundComponent(env.foreground, priority: 9);
    final fx = _FxLayer(this, priority: 10);

    add(_playfield);
    await _playfield.addAll([background, ground, shadow, obstacles, pickups, enemies, dragon, projectiles, particles, foreground, fx]);

    spawner = SpawningSystem(this, seed: seed);
    collisions = CollisionSystem(this);
    _applyViewSize(size);
    _startRun();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _applyViewSize(size);
  }

  void _applyViewSize(Vector2 size) {
    if (size.y <= 0) return;
    final scale = size.y / GameConfig.worldHeight;
    _playfield.scale = scale;
    viewWidth = size.x / scale;
    background.viewWidth = viewWidth;
    ground.viewWidth = viewWidth;
    foreground.viewWidth = viewWidth;
    enemies.viewWidth = viewWidth;
    projectiles.viewWidth = viewWidth;
    final oldStart = dragon.startX;
    dragon.minX = math.max(GameConfig.minPlayerX, viewWidth * GameConfig.minPlayerXFraction);
    dragon.maxX = math.max(dragon.minX + 120, viewWidth * GameConfig.maxPlayerXFraction);
    dragon.startX = math.max(dragon.minX, viewWidth * GameConfig.startPlayerXFraction);
    if (dragon.x == oldStart || stats.distanceUnits == 0) dragon.x = dragon.startX;
    dragon.x = dragon.x.clamp(dragon.minX, dragon.maxX);
  }

  void _startRun() {
    stats = RunStats();
    difficulty.meters = 0;
    dragon.reset();
    ground.reset();
    obstacles.items.clear();
    pickups.clear();
    enemies.clear();
    projectiles.clear();
    particles.clear();
    magnetTime = doubleCoinsTime = solarBeam = flash = damageVignette = 0;
    revivesUsed = 0;
    input.reset();
    spawner.reset();
    phase = RunPhase.playing;
    hud.showBanner('RUN!');
    _pushHud();
  }

  /// Restarts from scratch (Play Again).
  void restart() {
    _startRun();
    resumeEngine();
  }

  bool get canRevive => phase == RunPhase.over && revivesUsed == 0;

  /// Continues the run once: full health, safe position, invulnerability.
  bool revive() {
    if (!canRevive) return false;
    revivesUsed++;
    dragon
      ..dead = false
      ..deadT = 0
      ..health = GameConfig.maxHealth
      ..invulnerable = GameConfig.reviveInvulnerability
      ..x = dragon.startX
      ..flying = false
      ..rescue = 0
      ..vy = 0
      ..y = GameConfig.groundY
      ..grounded = true;
    // clear hazards near the player so the revive is safe
    ground.gaps.removeWhere((g) => g.x0 < viewWidth + 200);
    obstacles.items.removeWhere((o) => o.x < viewWidth + 300);
    enemies.items.removeWhere((e) => e.x < viewWidth + 300);
    projectiles.clearHostile();
    spawner.pushCursor(400);
    phase = RunPhase.playing;
    hud.showBanner('REVIVED!');
    particles.burst(
      dragon.x,
      dragon.y - 60,
      count: 40,
      colors: [dragonDef.glow, const Color(0xFFFFFFFF)],
      shape: ParticleShape.star,
      additive: true,
      gravity: -100,
    );
    audio.play(Sfx.powerup);
    resumeEngine();
    _pushHud();
    return true;
  }

  // ------------------------------------------------------------------ loop
  @override
  void update(double dt) {
    dt = math.min(dt, 1 / 30);
    if (phase == RunPhase.playing || phase == RunPhase.dying) _step(dt);
    super.update(dt);
  }

  void _step(double dt) {
    final playing = phase == RunPhase.playing;
    stats.time += playing ? dt : 0;
    var speed = playing ? difficulty.speed : 0.0;
    if (playing && dragon.sprinting) speed *= GameConfig.sprintMultiplier;
    if (playing && dragon.dash > 0) speed *= GameConfig.shadowDashSpeedMultiplier;
    if (!playing) speed = currentSpeed * math.max(0, 1 - dt * 3);
    currentSpeed = speed;
    final scroll = speed * dt;
    if (playing) {
      stats.distanceUnits += scroll;
      difficulty.meters = stats.distanceMeters.toDouble();
    }

    dragon.step(dt, input, ground);
    if (playing) {
      _handleDragonEvents(dt);
      if (input.consumeAttack()) _attack();
      if (input.consumeSpecial()) _special();
    } else {
      input.reset();
    }

    background.scroll(scroll, dt);
    ground.scroll(scroll);
    foreground.scroll(scroll);
    obstacles.scroll(scroll, dt);
    pickups.scroll(scroll, dt);
    enemies.step(dt, speed);
    projectiles.step(dt, speed);
    particles.scrollSpeed = speed;

    if (playing) {
      spawner.update(scroll);
      _updateBoss(dt);
      collisions.update(dt);
      _updateBeam(dt);
      _ambientParticles(dt);
    }
    if (magnetTime > 0) magnetTime -= dt;
    if (doubleCoinsTime > 0) doubleCoinsTime -= dt;
    if (flash > 0) flash -= dt * 2.5;
    if (damageVignette > 0) damageVignette -= dt * 1.5;

    if (phase == RunPhase.dying) {
      _dyingTimer += dt;
      if (_dyingTimer > 1.5) {
        phase = RunPhase.over;
        _pushHud();
        pauseEngine();
        onGameOver?.call();
      }
    }

    _hudTimer -= dt;
    if (_hudTimer <= 0) {
      _hudTimer = 0.05;
      _pushHud();
    }
  }

  void _handleDragonEvents(double dt) {
    for (final ev in dragon.events) {
      switch (ev) {
        case DragonEvent.jumped:
          audio.play(Sfx.jump, volume: 0.7);
          particles.burst(
            dragon.x,
            GameConfig.groundY - 4,
            count: 8,
            colors: const [Color(0xFFE8F5D0), Color(0xFFC9B48C)],
            speedMax: 160,
            angleMin: math.pi,
            angleMax: math.pi * 2,
            gravity: 300,
            shape: ParticleShape.smoke,
          );
        case DragonEvent.landed:
          audio.play(Sfx.land, volume: 0.6);
          particles.burst(
            dragon.x,
            GameConfig.groundY - 4,
            count: 10,
            colors: const [Color(0xFFE8F5D0), Color(0xFFC9B48C)],
            speedMax: 200,
            angleMin: math.pi,
            angleMax: math.pi * 2,
            gravity: 300,
            shape: ParticleShape.smoke,
          );
        case DragonEvent.flightStarted:
          stats.flights++;
          audio.play(Sfx.fly);
          particles.burst(
            dragon.x,
            dragon.y - 40,
            count: 16,
            colors: const [Color(0xFFFFFFFF), Color(0xFFDFF4FF)],
            speedMax: 260,
            shape: ParticleShape.smoke,
            gravity: 0,
          );
        case DragonEvent.flightEnded:
          audio.play(Sfx.flap, volume: 0.6);
        case DragonEvent.sprintStarted:
          audio.play(Sfx.sprint);
        case DragonEvent.sprintEnded:
          break;
        case DragonEvent.fellInGap:
          _fellInGap();
      }
    }
    if (dragon.flying) {
      _flapSoundT -= dt;
      if (_flapSoundT <= 0) {
        _flapSoundT = 0.45;
        audio.play(Sfx.flap, volume: 0.35);
      }
    }
  }

  void _fellInGap() {
    if (dragon.dead) return;
    dragon.health -= 1;
    damageVignette = 1;
    hud.damageEvents++;
    audio.play(Sfx.damage);
    audio.vibrate(heavy: true);
    if (dragon.health <= 0) {
      dragon.health = 0;
      _die();
    } else {
      dragon.startRescue();
      hud.showBanner('Saved by magic!');
    }
  }

  void _ambientParticles(double dt) {
    if (quality == 0) return;
    if (dragon.sprinting && _rng.nextDouble() < dt * 30) {
      particles.burst(
        dragon.x - 40,
        dragon.y - 10,
        count: 1,
        colors: const [Color(0xFFFFFFFF)],
        speedMin: 40,
        speedMax: 120,
        angleMin: math.pi * 0.9,
        angleMax: math.pi * 1.1,
        gravity: 0,
        shape: ParticleShape.smoke,
        life: 0.4,
      );
    }
    if (dragonDef.element == DragonElement.fire && _rng.nextDouble() < dt * 6) {
      particles.burst(
        dragon.x - 95,
        dragon.y - 50,
        count: 1,
        colors: const [Color(0xFFFFB347), Color(0xFFFF5A1F)],
        speedMin: 20,
        speedMax: 60,
        gravity: -120,
        life: 0.5,
        additive: true,
      );
    }
    if (dragonDef.element == DragonElement.shadow && _rng.nextDouble() < dt * 8) {
      particles.burst(
        dragon.x + _rng.nextDouble() * 60 - 30,
        dragon.y - 50 - _rng.nextDouble() * 40,
        count: 1,
        colors: [dragonDef.accent],
        speedMin: 10,
        speedMax: 40,
        gravity: -60,
        life: 0.7,
        additive: true,
      );
    }
  }

  // ---------------------------------------------------------------- combat
  void _attack() {
    if (dragon.attackCooldown > 0 || dragon.dead) return;
    dragon.attackCooldown = GameConfig.attackCooldown;
    dragon.triggerMouth();
    stats.attacks++;
    final m = dragon.mouth;
    final kind = Projectile.forElement(dragonDef.element);
    final dmg = dragonDef.attackDamage;
    switch (dragonDef.element) {
      case DragonElement.fire:
        projectiles.spawn(kind, m.dx + 10, m.dy, 1150, 0, damage: dmg, life: 0.6);
        particles.burst(
          m.dx + 10,
          m.dy,
          count: 14,
          colors: const [Color(0xFFFFE066), Color(0xFFFF8A1F), Color(0xFFFF4D1F)],
          speedMin: 300,
          speedMax: 700,
          angleMin: -0.35,
          angleMax: 0.35,
          gravity: -60,
          life: 0.35,
          additive: true,
          scrolls: false,
        );
        audio.play(Sfx.fire, volume: 0.8);
      case DragonElement.water:
        projectiles.spawn(kind, m.dx + 10, m.dy, 1000, 0, damage: dmg, life: 1.2);
        audio.play(Sfx.water, volume: 0.8);
      case DragonElement.shadow:
        projectiles.spawn(kind, m.dx + 10, m.dy, 900, 0, damage: dmg, life: 1.1, pierce: 2);
        audio.play(Sfx.shadow, volume: 0.8);
      case DragonElement.nature:
        projectiles.spawn(kind, m.dx + 10, m.dy, 1050, 0, damage: dmg, life: 1.2);
        audio.play(Sfx.leaf, volume: 0.8);
      case DragonElement.solar:
        projectiles.spawn(kind, m.dx + 10, m.dy, 1150, 0, damage: dmg, life: 1.2);
        audio.play(Sfx.solar, volume: 0.7);
    }
  }

  void _special() {
    if (dragon.specialCooldown > 0 || dragon.dead) return;
    dragon.specialCooldown = dragonDef.specialCooldown;
    dragon.triggerMouth(0.5);
    audio.play(Sfx.special);
    audio.vibrate();
    final c = Offset(dragon.x, dragon.y - 60);
    switch (dragonDef.element) {
      case DragonElement.fire:
        projectiles.spawn(ProjectileKind.fireWave, dragon.x + 80, GameConfig.groundY, 1300, 0, damage: 6, life: 1.1, pierce: 999);
        flash = 0.6;
        flashColor = const Color(0xFFFF8A1F);
        particles.burst(
          c.dx + 60,
          c.dy,
          count: 40,
          colors: const [Color(0xFFFFE066), Color(0xFFFF8A1F), Color(0xFFFF4D1F)],
          speedMin: 300,
          speedMax: 900,
          angleMin: -0.8,
          angleMax: 0.8,
          gravity: -100,
          additive: true,
          scrolls: false,
        );
        hud.showBanner('FIRE BURST!');
      case DragonElement.water:
        dragon.waterShield = GameConfig.waterShieldDuration;
        audio.play(Sfx.shield);
        particles.burst(
          c.dx,
          c.dy,
          count: 30,
          colors: const [Color(0xFFBFF7FF), Color(0xFF38B6FF)],
          shape: ParticleShape.circle,
          scrolls: false,
        );
        hud.showBanner('WATER SHIELD!');
      case DragonElement.shadow:
        dragon.dash = GameConfig.shadowDashDuration;
        dragon.invulnerable = math.max(dragon.invulnerable, GameConfig.shadowDashDuration + 0.3);
        particles.burst(c.dx, c.dy, count: 30, colors: [dragonDef.accent, dragonDef.body], additive: true, scrolls: false);
        hud.showBanner('SHADOW DASH!');
      case DragonElement.nature:
        dragon.natureShield = GameConfig.natureShieldDuration;
        dragon.natureHits = GameConfig.natureShieldHits;
        audio.play(Sfx.shield);
        particles.burst(
          c.dx,
          c.dy,
          count: 30,
          colors: const [Color(0xFF7FE06A), Color(0xFFFFE27A)],
          shape: ParticleShape.leaf,
          scrolls: false,
        );
        hud.showBanner('NATURE SHIELD!');
      case DragonElement.solar:
        solarBeam = 0.7;
        _beamHits.clear();
        flash = 0.8;
        flashColor = const Color(0xFFFFF2A0);
        hud.showBanner('SOLAR BLAST!');
    }
  }

  void _updateBeam(double dt) {
    if (solarBeam <= 0) return;
    solarBeam -= dt;
    final m = dragon.mouth;
    final beam = Rect.fromLTRB(m.dx, m.dy - 75, viewWidth + 20, m.dy + 75);
    for (final e in enemies.items) {
      if (!e.alive || e.warn > 0 || _beamHits.contains(e) || !beam.overlaps(e.hitbox)) continue;
      _beamHits.add(e);
      damageEnemy(e, 10);
    }
    for (final o in obstacles.items) {
      if (o.destroyed || !o.destructible || _beamHits.contains(o) || !beam.overlaps(o.hitbox)) continue;
      _beamHits.add(o);
      damageObstacle(o, 99);
    }
    final b = enemies.boss;
    if (b != null && b.alive && !_beamHits.contains(b) && beam.overlaps(b.hitbox)) {
      _beamHits.add(b);
      damageBoss(10);
    }
    if (_rng.nextDouble() < 0.6) {
      particles.burst(
        m.dx + _rng.nextDouble() * (viewWidth - m.dx),
        m.dy + _rng.nextDouble() * 80 - 40,
        count: 2,
        colors: const [Color(0xFFFFFFFF), Color(0xFFFFE066)],
        shape: ParticleShape.star,
        additive: true,
        gravity: 0,
        life: 0.4,
        scrolls: false,
      );
    }
  }

  void hurtPlayer(int amount, {Offset? at}) {
    if (!dragon.canBeHurt) return;
    dragon.health -= amount;
    dragon.invulnerable = GameConfig.invulnerableAfterHit;
    dragon.hurtT = 0.25;
    damageVignette = 1;
    hud.damageEvents++;
    audio.play(Sfx.damage);
    audio.vibrate(heavy: true);
    final p = at ?? Offset(dragon.x, dragon.y - 50);
    particles.burst(p.dx, p.dy, count: 16, colors: const [Color(0xFFFFFFFF), Color(0xFFFF5A5A)], shape: ParticleShape.star, additive: true);
    if (dragon.health <= 0) {
      dragon.health = 0;
      _die();
    }
  }

  void consumeNatureShield() {
    dragon.natureHits = math.max(0, dragon.natureHits - 1);
    if (dragon.natureHits == 0) dragon.natureShield = 0;
    dragon.invulnerable = math.max(dragon.invulnerable, 0.4);
    audio.play(Sfx.shield, volume: 0.7);
    particles.burst(
      dragon.x + 40,
      dragon.y - 60,
      count: 14,
      colors: const [Color(0xFF7FE06A), Color(0xFFB9FF7A)],
      shape: ParticleShape.leaf,
    );
  }

  void _die() {
    if (phase != RunPhase.playing) return;
    dragon.dead = true;
    dragon.vy = -600;
    dragon.sprinting = false;
    dragon.flying = false;
    phase = RunPhase.dying;
    _dyingTimer = 0;
    audio.play(Sfx.gameOver);
    hud.showBanner('Oh no!');
  }

  void damageEnemy(Enemy e, int dmg) {
    if (!e.alive || e.dying > 0) return;
    e.hp -= dmg;
    e.flash = 0.12;
    final hb = e.hitbox;
    particles.burst(
      hb.center.dx,
      hb.center.dy,
      count: 8,
      colors: [dragonDef.glow, const Color(0xFFFFFFFF)],
      shape: ParticleShape.spark,
      additive: true,
    );
    if (e.hp > 0) {
      audio.play(Sfx.hit, volume: 0.7);
      return;
    }
    e.dying = 0.001;
    if (e.rewarded) return;
    e.rewarded = true;
    stats.enemiesDefeated++;
    final drop = EconomyConfig.enemyCoinDrops[e.def.id] ?? 1;
    _addRunCoins(drop, hb.center.dx, hb.top);
    audio.play(Sfx.defeat);
    particles.burst(
      hb.center.dx,
      hb.center.dy,
      count: 22,
      colors: const [Color(0xFFFFE14D), Color(0xFFFFFFFF), Color(0xFFB98BFF)],
      shape: ParticleShape.star,
    );
  }

  void damageBoss(int dmg) {
    final b = enemies.boss;
    if (b == null || !b.alive) return;
    b.hp -= dmg;
    b.flash = 0.1;
    audio.play(Sfx.hit, volume: 0.8);
    particles.burst(
      b.x - 80,
      b.y - 150,
      count: 10,
      colors: const [Color(0xFF5CF2E6), Color(0xFFFFFFFF)],
      shape: ParticleShape.spark,
      additive: true,
    );
    if (b.hp <= 0) {
      b.kill();
      if (!b.rewarded) {
        b.rewarded = true;
        stats.bossesDefeated++;
        stats.enemiesDefeated++;
        stats.gems += EconomyConfig.bossGemReward;
        _addRunCoins(EconomyConfig.bossCoinReward, b.x - 60, b.y - 280);
        particles.text(b.x - 60, b.y - 330, '+${EconomyConfig.bossGemReward} GEMS', color: const Color(0xFFFF8AE6), size: 30);
        audio.play(Sfx.bossRoar);
        audio.play(Sfx.chest);
        flash = 0.8;
        flashColor = const Color(0xFFFFFFFF);
        projectiles.clearHostile();
        hud.showBanner('CRYSTAL GOLEM DEFEATED!');
        particles.burst(
          b.x - 40,
          b.y - 140,
          count: 60,
          colors: const [Color(0xFF5CF2E6), Color(0xFFC792FF), Color(0xFFFFE14D)],
          speedMax: 600,
          shape: ParticleShape.star,
          additive: true,
        );
      }
    }
  }

  void damageObstacle(Obstacle o, int dmg) {
    if (o.destroyed || (!o.destructible && dmg < 99)) return;
    o.hp -= dmg;
    o.flash = 0.1;
    audio.play(Sfx.hit, volume: 0.6);
    if (o.hp <= 0) destroyObstacle(o, rewarded: true);
  }

  void destroyObstacle(Obstacle o, {required bool rewarded}) {
    if (o.destroyed) return;
    o.destroyed = true;
    final hb = o.hitbox;
    audio.play(Sfx.breakObj);
    final colors = switch (o.kind) {
      ObstacleKind.crystal => const [Color(0xFF5CF2E6), Color(0xFFC792FF), Color(0xFFFFFFFF)],
      ObstacleKind.barrier => const [Color(0xFFFF8AE6), Color(0xFFB98BFF), Color(0xFFFFFFFF)],
      ObstacleKind.pod => const [Color(0xFFB98BFF), Color(0xFFF3E6FF)],
      ObstacleKind.thorns => const [Color(0xFF6B3FA0), Color(0xFF3F2A5C)],
      ObstacleKind.boulder => const [Color(0xFFB0927A), Color(0xFF7A5F4F), Color(0xFF66C95A)],
    };
    particles.burst(hb.center.dx, hb.center.dy, count: 20, colors: colors, speedMax: 420, sizeMax: 9);
    if (rewarded && o.kind == ObstacleKind.crystal) {
      stats.crystalsBroken++;
      _addRunCoins(EconomyConfig.crystalCoinDrop, hb.center.dx, hb.top);
    }
  }

  void projectileImpact(Projectile p) {
    p.active = false;
    final colors = switch (p.kind) {
      ProjectileKind.fire || ProjectileKind.fireWave => const [Color(0xFFFFE066), Color(0xFFFF8A1F)],
      ProjectileKind.water => const [Color(0xFFBFF7FF), Color(0xFF38B6FF)],
      ProjectileKind.shadow => const [Color(0xFFE47BFF), Color(0xFF8A4FE0)],
      ProjectileKind.leaf => const [Color(0xFF7FE06A), Color(0xFFFFE27A)],
      ProjectileKind.solar => const [Color(0xFFFFFFFF), Color(0xFFFFD23F)],
      ProjectileKind.rock => const [Color(0xFF8E8AA2), Color(0xFF5CF2E6)],
      ProjectileKind.shockwave => const [Color(0xFFC792FF), Color(0xFF5CF2E6)],
    };
    particles.burst(
      p.x,
      p.y,
      count: 10,
      colors: colors,
      speedMax: 260,
      shape: p.kind == ProjectileKind.leaf ? ParticleShape.leaf : ParticleShape.circle,
    );
    particles.ring(p.x, p.y, colors.first, size: 40);
  }

  // --------------------------------------------------------------- rewards
  void _addRunCoins(int base, double x, double y) {
    final amount = doubleCoinsTime > 0 ? base * 2 : base;
    stats.coins += amount;
    particles.text(x, y - 10, '+$amount', size: amount >= 10 ? 34 : 26);
  }

  void collect(Pickup p) {
    if (p.collected) return;
    p.collected = true;
    switch (p.kind) {
      case PickupKind.coin:
        _addRunCoinsQuiet(EconomyConfig.coinValue);
        audio.play(Sfx.coin, volume: 0.6);
        particles.burst(
          p.x,
          p.y,
          count: 5,
          colors: const [Color(0xFFFFE14D), Color(0xFFFFFFFF)],
          speedMax: 160,
          gravity: 0,
          shape: ParticleShape.star,
          additive: true,
          life: 0.35,
        );
      case PickupKind.coinCluster:
        _addRunCoins(p.value, p.x, p.y);
        audio.play(Sfx.coin);
        particles.burst(
          p.x,
          p.y,
          count: 14,
          colors: const [Color(0xFFFFE14D), Color(0xFFFFFFFF)],
          shape: ParticleShape.star,
          additive: true,
        );
      case PickupKind.gem:
        stats.gems += EconomyConfig.gemPickupValue;
        audio.play(Sfx.gem);
        particles.text(p.x, p.y - 20, '+1 GEM', color: const Color(0xFFFF8AE6));
        particles.burst(
          p.x,
          p.y,
          count: 14,
          colors: const [Color(0xFFFF8AE6), Color(0xFFFFFFFF)],
          shape: ParticleShape.star,
          additive: true,
        );
      case PickupKind.heart:
        if (dragon.health < GameConfig.maxHealth) dragon.health++;
        audio.play(Sfx.powerup);
        particles.text(p.x, p.y - 20, '+1 HP', color: const Color(0xFFFF5A7A));
      case PickupKind.magnet:
        magnetTime = GameConfig.magnetDuration;
        audio.play(Sfx.powerup);
        hud.showBanner('COIN MAGNET!');
      case PickupKind.chest:
        p.anim = 0.001;
        stats.chests++;
        _addRunCoins(p.value, p.x, p.y - 90);
        if (_rng.nextDouble() < EconomyConfig.treasureChestGemChance) {
          stats.gems += 1;
          particles.text(p.x, p.y - 140, '+1 GEM', color: const Color(0xFFFF8AE6));
        }
        audio.play(Sfx.chest);
        particles.burst(
          p.x,
          p.y - 40,
          count: 30,
          colors: const [Color(0xFFFFE14D), Color(0xFFFFFFFF), Color(0xFFFFB347)],
          speedMin: 200,
          speedMax: 520,
          angleMin: -math.pi * 0.9,
          angleMax: -math.pi * 0.1,
          gravity: 900,
          shape: ParticleShape.star,
        );
      case PickupKind.gate:
        break;
    }
  }

  void _addRunCoinsQuiet(int base) {
    stats.coins += doubleCoinsTime > 0 ? base * 2 : base;
  }

  void passGate(Pickup p) {
    if (p.collected) return;
    p.collected = true;
    p.anim = 0.001;
    audio.play(Sfx.powerup);
    final magnet = _rng.nextBool();
    if (magnet) {
      magnetTime = GameConfig.magnetDuration;
      hud.showBanner('MAGIC GATE: COIN MAGNET!');
    } else {
      doubleCoinsTime = GameConfig.doubleCoinsDuration;
      hud.showBanner('MAGIC GATE: DOUBLE COINS!');
    }
    particles.burst(
      p.x,
      p.y,
      count: 30,
      colors: const [Color(0xFF8FF5FF), Color(0xFFFFE14D), Color(0xFFFFFFFF)],
      shape: ParticleShape.star,
      additive: true,
    );
  }

  // ------------------------------------------------------------------ boss
  void startBoss(int index) {
    enemies.boss = Boss(maxHp: 30 + index * 12, index: index)..x = viewWidth + 260;
    audio.play(Sfx.bossRoar);
    hud.showBanner('MINI BOSS: CRYSTAL GOLEM!');
  }

  void _updateBoss(double dt) {
    final b = enemies.boss;
    if (b == null) return;
    b.update(dt, viewWidth, difficulty: difficulty.level);
    if (b.pendingRocks > 0) {
      final n = b.pendingRocks;
      b.pendingRocks = -1; // consumed for this throw
      for (var i = 0; i < n; i++) {
        final sx = b.x - 120, sy = b.y - 280.0;
        final tx = dragon.x + (i - (n - 1) / 2) * 140 + _rng.nextDouble() * 40;
        const ty = GameConfig.groundY - 30;
        final t = 1.05 + i * 0.12;
        const g = 1300.0;
        final vx = (tx - sx) / t + currentSpeed;
        final vy = (ty - sy - 0.5 * g * t * t) / t;
        projectiles.spawn(ProjectileKind.rock, sx, sy, vx, vy, hostile: true, gravity: g, life: 3, damage: 1);
      }
      audio.play(Sfx.slam, volume: 0.5);
    } else if (b.action != BossAction.throwRocks && b.pendingRocks < 0) {
      b.pendingRocks = 0;
    }
    if (b.pendingShockwave) {
      b.pendingShockwave = false;
      projectiles.spawn(ProjectileKind.shockwave, b.x - 150, GameConfig.groundY, -420, 0, hostile: true, life: 5, damage: 1);
      audio.play(Sfx.slam);
      audio.vibrate();
      particles.burst(
        b.x - 150,
        GameConfig.groundY - 10,
        count: 20,
        colors: const [Color(0xFFC9B48C), Color(0xFF8E8AA2)],
        speedMax: 300,
        angleMin: math.pi,
        angleMax: math.pi * 2,
        scrolls: false,
      );
    }
    if (b.pendingBats > 0) {
      for (var i = 0; i < b.pendingBats; i++) {
        final e = Enemy(EnemyDef.bat, b.x - 60 - i * 90, i.isEven ? 545 : 380);
        enemies.items.add(e);
      }
      b.pendingBats = 0;
      audio.play(Sfx.bossRoar, volume: 0.6);
    }
    if (b.gone) {
      if (!b.rewarded) hud.showBanner('The golem retreated...');
      enemies.boss = null;
    }
  }

  // ------------------------------------------------------------------- hud
  void _pushHud() {
    final d = dragon;
    hud
      ..health = d.health
      ..maxHealth = GameConfig.maxHealth
      ..stamina01 = d.stamina / GameConfig.maxStamina
      ..energy01 = d.energy / d.maxEnergy
      ..attackReady01 = 1 - (d.attackCooldown / GameConfig.attackCooldown).clamp(0.0, 1.0)
      ..specialReady01 = 1 - (d.specialCooldown / dragonDef.specialCooldown).clamp(0.0, 1.0)
      ..sprinting = d.sprinting
      ..flying = d.flying
      ..shieldActive = d.waterShield > 0 || d.natureShield > 0
      ..shieldHits = d.natureHits
      ..coins = stats.coins
      ..gems = stats.gems
      ..distance = stats.distanceMeters
      ..score = ScoringSystem.score(stats)
      ..magnetLeft = math.max(0, math.max(magnetTime, d.waterShield))
      ..doubleCoinsLeft = math.max(0, doubleCoinsTime);
    final b = enemies.boss;
    if (b != null && b.alive) {
      hud
        ..bossHealth01 = b.hp / b.maxHp
        ..bossName = 'CRYSTAL GOLEM';
    } else {
      hud
        ..bossHealth01 = null
        ..bossName = null;
    }
    hud.push();
  }

  /// Freezes gameplay (pause menu, app backgrounded, full-screen ad).
  void pauseGameplay() {
    input.reset();
    pauseEngine();
  }

  void resumeGameplay() {
    if (phase == RunPhase.over) return;
    input.reset();
    resumeEngine();
  }

  @override
  void onRemove() {
    if (isLoaded) sprites.dispose();
    super.onRemove();
  }
}
