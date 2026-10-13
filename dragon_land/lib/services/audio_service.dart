import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/player_progress_model.dart';

/// Every sound effect bundled in assets/audio.
enum Sfx {
  coin('coin.wav'),
  gem('gem.wav'),
  jump('jump.wav'),
  land('land.wav'),
  flap('flap.wav'),
  fly('fly.wav'),
  sprint('sprint.wav'),
  fire('fire.wav'),
  water('water.wav'),
  shadow('shadow.wav'),
  leaf('leaf.wav'),
  solar('solar.wav'),
  special('special.wav'),
  shield('shield.wav'),
  hit('hit.wav'),
  defeat('defeat.wav'),
  damage('damage.wav'),
  breakObj('break.wav'),
  chest('chest.wav'),
  unlock('unlock.wav'),
  button('button.wav'),
  powerup('powerup.wav'),
  gameOver('game_over.wav'),
  bossRoar('boss_roar.wav'),
  slam('slam.wav'),
  purchase('purchase.wav');

  const Sfx(this.file);
  final String file;
}

enum MusicTrack {
  lobby('music_lobby.wav'),
  game('music_game.wav');

  const MusicTrack(this.file);
  final String file;
}

/// Sound effects, music and haptics, all gated by the player's settings.
class AudioService {
  AudioService({this.enabled = true});

  /// False in tests / unsupported platforms: every call becomes a no-op.
  final bool enabled;
  GameSettings _settings = GameSettings();
  final Map<Sfx, AudioPool> _pools = {};
  final Map<Sfx, int> _lastPlayed = {};
  MusicTrack? _currentTrack;
  bool _musicSuspended = false;
  bool _ready = false;

  Future<void> init(GameSettings settings) async {
    _settings = settings;
    if (!enabled) return;
    try {
      FlameAudio.updatePrefix('assets/audio/');
      await FlameAudio.audioCache.loadAll([...Sfx.values.map((s) => s.file), ...MusicTrack.values.map((m) => m.file)]);
      for (final s in const [Sfx.coin, Sfx.hit, Sfx.jump, Sfx.button, Sfx.flap]) {
        _pools[s] = await FlameAudio.createPool(s.file, maxPlayers: s == Sfx.coin ? 4 : 2);
      }
      await FlameAudio.bgm.initialize();
      _ready = true;
    } catch (e) {
      debugPrint('AudioService: init failed, continuing without audio: $e');
    }
  }

  void applySettings(GameSettings settings) {
    _settings = settings;
    if (!_ready) return;
    if (!settings.music) {
      unawaited(_safe(() => FlameAudio.bgm.stop()));
    } else if (_currentTrack != null && !_musicSuspended) {
      if (FlameAudio.bgm.isPlaying) {
        unawaited(_safe(() => FlameAudio.bgm.audioPlayer.setVolume(settings.musicVolume)));
      } else {
        playMusic(_currentTrack!);
      }
    }
  }

  void play(Sfx s, {double volume = 1.0}) {
    if (!_ready || !_settings.sound || _settings.soundVolume <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayed[s] ?? 0;
    if (now - last < 45) return; // throttle identical sounds in the same frame burst
    _lastPlayed[s] = now;
    final v = (volume * _settings.soundVolume).clamp(0.0, 1.0);
    final pool = _pools[s];
    if (pool != null) {
      unawaited(_safe(() => pool.start(volume: v)));
    } else {
      unawaited(_safe(() => FlameAudio.play(s.file, volume: v)));
    }
  }

  void playMusic(MusicTrack track) {
    _currentTrack = track;
    if (!_ready || !_settings.music || _musicSuspended) return;
    unawaited(_safe(() => FlameAudio.bgm.play(track.file, volume: _settings.musicVolume)));
  }

  void stopMusic() {
    _currentTrack = null;
    if (!_ready) return;
    unawaited(_safe(() => FlameAudio.bgm.stop()));
  }

  /// Called when the app goes to the background / returns.
  void suspend() {
    _musicSuspended = true;
    if (_ready) unawaited(_safe(() => FlameAudio.bgm.pause()));
  }

  void resume() {
    _musicSuspended = false;
    if (!_ready || !_settings.music || _currentTrack == null) return;
    unawaited(_safe(() => FlameAudio.bgm.resume()));
  }

  void vibrate({bool heavy = false}) {
    if (!enabled || !_settings.vibration) return;
    unawaited(_safe(() => heavy ? HapticFeedback.heavyImpact() : HapticFeedback.lightImpact()));
  }

  Future<void> _safe(FutureOr<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      debugPrint('AudioService: $e');
    }
  }
}
