import 'package:flame_audio/flame_audio.dart';

import 'core/save_data.dart';

/// Every audio file used by the game (WAV, stored in assets/audio/).
class Sfx {
  Sfx._();

  // Splash
  static const splashIntro = 'splash_intro.wav';
  static const splashShadowForm = 'splash_shadow_form.wav';
  static const splashReveal = 'splash_reveal.wav';
  static const splashTitle = 'splash_title.wav';
  static const splashLoading = 'splash_loading.wav';

  // Music
  static const musicLobby = 'music_lobby.wav';
  static const musicGame = 'music_game.wav';
  static const musicBoss = 'music_boss.wav';

  // Lobby / UI
  static const uiClick = 'ui_click.wav';
  static const uiLevelSelect = 'ui_level_select.wav';
  static const uiLocked = 'ui_locked.wav';
  static const uiSettings = 'ui_settings.wav';
  static const uiExit = 'ui_exit.wav';
  static const pause = 'pause.wav';

  // Gameplay
  static const footstep = 'footstep.wav';
  static const swordSwing = 'sword_swing.wav';
  static const swordHit = 'sword_hit.wav';
  static const enemyHit = 'enemy_hit.wav';
  static const enemyDeath = 'enemy_death.wav';
  static const playerHurt = 'player_hurt.wav';
  static const playerDeath = 'player_death.wav';
  static const jump = 'jump.wav';
  static const land = 'land.wav';
  static const powerUp = 'powerup.wav';
  static const pickupHealth = 'pickup_health.wav';
  static const stoneRoll = 'stone_roll.wav';
  static const stoneImpact = 'stone_impact.wav';
  static const spikeTrap = 'spike_trap.wav';
  static const envWind = 'env_wind.wav';
  static const levelComplete = 'level_complete.wav';
  static const victory = 'victory.wav';
  static const gameOver = 'game_over.wav';

  // Bosses
  static const bossEntrance = 'boss_entrance.wav';
  static const bossRoar = 'boss_roar.wav';
  static const bossAttack = 'boss_attack.wav';
  static const bossHit = 'boss_hit.wav';
  static const bossTransform = 'boss_transform.wav';
  static const bossSpecial = 'boss_special.wav';
  static const bossDeath = 'boss_death.wav';
  static const eagleFly = 'eagle_fly.wav';
  static const eagleScreech = 'eagle_screech.wav';
  static const eagleDive = 'eagle_dive.wav';
  static const eagleBomb = 'eagle_bomb.wav';
  static const bombExplode = 'bomb_explode.wav';
  static const elephantStomp = 'elephant_stomp.wav';
  static const elephantCharge = 'elephant_charge.wav';
  static const elephantTrumpet = 'elephant_trumpet.wav';
  static const shockwave = 'shockwave.wav';
  static const monsterAttack = 'monster_attack.wav';
  static const monsterCross = 'monster_cross.wav';
  static const ratScreech = 'rat_screech.wav';

  static const List<String> effects = [
    splashIntro, splashShadowForm, splashReveal, splashTitle, splashLoading,
    uiClick, uiLevelSelect, uiLocked, uiSettings, uiExit, pause,
    footstep, swordSwing, swordHit, enemyHit, enemyDeath, playerHurt,
    playerDeath, jump, land, powerUp, pickupHealth, stoneRoll, stoneImpact,
    spikeTrap, envWind, levelComplete, victory, gameOver,
    bossEntrance, bossRoar, bossAttack, bossHit, bossTransform, bossSpecial,
    bossDeath, eagleFly, eagleScreech, eagleDive, eagleBomb, bombExplode,
    elephantStomp, elephantCharge, elephantTrumpet, shockwave, monsterAttack,
    monsterCross, ratScreech,
  ];

  /// Short sounds that fire very often get a small pool of players.
  static const Map<String, int> pooled = {
    footstep: 3,
    swordSwing: 3,
    swordHit: 3,
    enemyHit: 3,
    enemyDeath: 2,
    playerHurt: 2,
    uiClick: 2,
    jump: 2,
    land: 2,
    bossHit: 2,
    bossAttack: 2,
    stoneImpact: 2,
    bombExplode: 2,
    shockwave: 2,
    elephantStomp: 2,
    eagleFly: 1,
    eagleBomb: 2,
    monsterCross: 2,
    spikeTrap: 1,
    pickupHealth: 1,
  };
}

/// Central audio manager. All music and sound effects go through here.
class GameAudio {
  GameAudio._();
  static final GameAudio instance = GameAudio._();

  final Map<String, AudioPool> _pools = {};
  final Map<String, int> _lastPlayed = {};
  final Stopwatch _clock = Stopwatch()..start();

  bool _ready = false;
  bool _bgmInitialized = false;
  String? _music;
  double _musicVolume = 0.6;
  int _musicRequest = 0;

  bool get enabled => SaveData.instance.soundOn;

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    try {
      FlameAudio.updatePrefix('assets/audio/');
    } catch (_) {}
    try {
      await FlameAudio.bgm.initialize();
      _bgmInitialized = true;
    } catch (_) {}
  }

  /// Preloads every effect, reporting progress 0..1.
  Future<void> preload({void Function(double progress)? onProgress}) async {
    await init();
    final total = Sfx.effects.length + 3;
    var done = 0;
    for (final s in Sfx.effects) {
      try {
        await FlameAudio.audioCache.load(s);
      } catch (_) {}
      done++;
      onProgress?.call(done / total);
    }
    for (final m in [Sfx.musicLobby, Sfx.musicGame, Sfx.musicBoss]) {
      try {
        await FlameAudio.audioCache.load(m);
      } catch (_) {}
      done++;
      onProgress?.call(done / total);
    }
    for (final e in Sfx.pooled.entries) {
      if (_pools.containsKey(e.key)) continue;
      try {
        _pools[e.key] = await FlameAudio.createPool(e.key, maxPlayers: e.value);
      } catch (_) {}
    }
  }

  /// Plays a one-shot sound effect. [minGapMs] throttles rapid repeats.
  void play(String file, {double volume = 1.0, int minGapMs = 40}) {
    if (!enabled) return;
    final now = _clock.elapsedMilliseconds;
    final last = _lastPlayed[file];
    if (last != null && now - last < minGapMs) return;
    _lastPlayed[file] = now;
    final v = volume.clamp(0.0, 1.0).toDouble();
    final pool = _pools[file];
    if (pool != null) {
      _safe(() => pool.start(volume: v));
    } else {
      _safe(() async {
        final player = await FlameAudio.play(file, volume: v);
        // Release the one-shot player once it finishes (or after a timeout).
        await player.onPlayerComplete.first.timeout(const Duration(seconds: 12), onTimeout: () {});
        await _safe(() => player.dispose());
      });
    }
  }

  /// Starts a looping music track (no-op if it is already playing).
  void playMusic(String file, {double volume = 0.6}) {
    final changed = _music != file;
    _music = file;
    _musicVolume = volume;
    if (!enabled || !_bgmInitialized) return;
    if (!changed && FlameAudio.bgm.isPlaying) return;
    final request = ++_musicRequest;
    _safe(() async {
      if (request != _musicRequest) return;
      await FlameAudio.bgm.play(file, volume: volume);
    });
  }

  void stopMusic() {
    _music = null;
    _musicRequest++;
    if (!_bgmInitialized) return;
    _safe(() => FlameAudio.bgm.stop());
  }

  void pauseMusic() {
    if (!_bgmInitialized) return;
    _safe(() => FlameAudio.bgm.pause());
  }

  void resumeMusic() {
    if (!enabled || !_bgmInitialized) return;
    final m = _music;
    if (m == null) return;
    _safe(() async {
      if (FlameAudio.bgm.audioPlayer.state == PlayerState.paused) {
        await FlameAudio.bgm.resume();
      } else {
        await FlameAudio.bgm.play(m, volume: _musicVolume);
      }
    });
  }

  /// Global sound switch (music and effects), persisted.
  void setEnabled(bool on, {bool startMusic = true}) {
    SaveData.instance.setSound(on);
    if (!_bgmInitialized) return;
    if (on && !startMusic) return;
    if (on) {
      final m = _music;
      if (m != null) {
        final request = ++_musicRequest;
        _safe(() async {
          if (request != _musicRequest) return;
          await FlameAudio.bgm.play(m, volume: _musicVolume);
        });
      }
    } else {
      _musicRequest++;
      _safe(() => FlameAudio.bgm.stop());
    }
  }

  Future<void> _safe(Future<dynamic> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}
