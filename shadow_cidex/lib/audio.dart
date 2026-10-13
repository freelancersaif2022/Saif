import 'dart:async';

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
  static const swordDraw = 'sword_draw.wav';
  static const swordSheathe = 'sword_sheathe.wav';
  static const enemyHit = 'enemy_hit.wav';
  static const enemyDeath = 'enemy_death.wav';
  static const playerHurt = 'player_hurt.wav';
  static const playerDeath = 'player_death.wav';
  static const jump = 'jump.wav';
  static const land = 'land.wav';
  static const dash = 'dash.wav';
  static const powerCharge = 'power_charge.wav';
  static const powerUp = 'powerup.wav';
  static const shadowWave = 'shadow_wave.wav';
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

  /// Effects in preload order (splash sounds first) with their voice count.
  static const Map<String, int> voices = {
    splashIntro: 1,
    splashShadowForm: 1,
    splashReveal: 1,
    splashTitle: 1,
    splashLoading: 1,
    uiClick: 2,
    uiLevelSelect: 1,
    uiLocked: 1,
    uiSettings: 1,
    uiExit: 1,
    pause: 1,
    footstep: 3,
    swordSwing: 4,
    swordHit: 4,
    swordDraw: 1,
    swordSheathe: 1,
    enemyHit: 4,
    enemyDeath: 3,
    playerHurt: 2,
    playerDeath: 1,
    jump: 2,
    land: 2,
    dash: 2,
    powerCharge: 1,
    powerUp: 2,
    shadowWave: 2,
    pickupHealth: 2,
    stoneRoll: 2,
    stoneImpact: 3,
    spikeTrap: 2,
    envWind: 1,
    levelComplete: 1,
    victory: 1,
    gameOver: 1,
    bossEntrance: 1,
    bossRoar: 2,
    bossAttack: 3,
    bossHit: 3,
    bossTransform: 1,
    bossSpecial: 2,
    bossDeath: 1,
    eagleFly: 2,
    eagleScreech: 2,
    eagleDive: 2,
    eagleBomb: 3,
    bombExplode: 3,
    elephantStomp: 3,
    elephantCharge: 1,
    elephantTrumpet: 1,
    shockwave: 3,
    monsterAttack: 2,
    monsterCross: 3,
    ratScreech: 2,
  };

  static Iterable<String> get effects => voices.keys;
}

/// A sound with a few pre-loaded players used round-robin. Players are created
/// once and replayed, so nothing is allocated during gameplay.
class _Voice {
  _Voice(this.file);
  final String file;
  final List<AudioPlayer> players = [];
  int next = 0;
  bool ready = false;
}

/// Central audio manager. All music and sound effects go through here.
class GameAudio {
  GameAudio._();
  static final GameAudio instance = GameAudio._();

  final Map<String, _Voice> _voices = {};
  final Map<String, int> _lastPlayed = {};
  final Stopwatch _clock = Stopwatch()..start();
  final AudioContext _context = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

  bool _initStarted = false;
  bool _bgmInitialized = false;
  Future<void>? _preloadFuture;
  String? _music;
  double _musicVolume = 0.6;
  int _musicRequest = 0;

  bool get enabled => SaveData.instance.soundOn;

  Future<void> init() async {
    if (_initStarted) return;
    _initStarted = true;
    try {
      FlameAudio.updatePrefix('assets/audio/');
    } catch (_) {}
    try {
      await FlameAudio.bgm.initialize(audioContext: _context);
      _bgmInitialized = true;
    } catch (_) {}
  }

  /// Preloads every effect and music file, reporting progress 0..1.
  Future<void> preload({void Function(double progress)? onProgress}) {
    return _preloadFuture ??= _preload(onProgress);
  }

  Future<void> _preload(void Function(double progress)? onProgress) async {
    await init();
    final files = Sfx.effects.toList();
    final total = files.length + 3;
    var done = 0;
    for (final m in [Sfx.musicLobby, Sfx.musicGame, Sfx.musicBoss]) {
      try {
        await FlameAudio.audioCache.load(m);
      } catch (_) {}
      onProgress?.call(++done / total);
    }
    for (final f in files) {
      await _prepare(f, Sfx.voices[f] ?? 1);
      onProgress?.call(++done / total);
    }
  }

  Future<void> _prepare(String file, int count) async {
    final v = _voices.putIfAbsent(file, () => _Voice(file));
    if (v.ready) return;
    try {
      await FlameAudio.audioCache.load(file);
    } catch (_) {}
    while (v.players.length < count) {
      final p = AudioPlayer();
      try {
        p.audioCache = FlameAudio.audioCache;
        await p.setAudioContext(_context);
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource(file));
        v.players.add(p);
      } catch (_) {
        try {
          await p.dispose();
        } catch (_) {}
        break;
      }
    }
    v.ready = v.players.isNotEmpty;
  }

  /// Plays a one-shot sound effect. [minGapMs] throttles rapid repeats.
  void play(String file, {double volume = 1.0, int minGapMs = 40}) {
    if (!enabled) return;
    final now = _clock.elapsedMilliseconds;
    final last = _lastPlayed[file];
    if (last != null && now - last < minGapMs) return;
    _lastPlayed[file] = now;
    final vol = volume.clamp(0.0, 1.0).toDouble();
    final v = _voices[file];
    if (v == null || !v.ready) {
      // Not preloaded yet: prepare in the background and play once ready.
      _safe(() async {
        await _prepare(file, Sfx.voices[file] ?? 1);
        final pv = _voices[file];
        if (pv != null && pv.ready) await _start(pv, vol);
      });
      return;
    }
    _safe(() => _start(v, vol));
  }

  Future<void> _start(_Voice v, double volume) async {
    final p = v.players[v.next % v.players.length];
    v.next++;
    await p.stop();
    await p.setVolume(volume);
    await p.resume();
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
      for (final v in _voices.values) {
        for (final p in v.players) {
          _safe(() => p.stop());
        }
      }
    }
  }

  Future<void> _safe(Future<dynamic> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}
