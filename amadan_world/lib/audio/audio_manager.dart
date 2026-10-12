import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../utils/asset_paths.dart';

typedef _PoolStart = Future<void> Function(double volume);

/// Central audio service: pooled sound effects, one music track and one
/// ambient loop. Every call is safe before initialisation and never throws.
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  bool _ready = false;
  Future<void>? _initFuture;
  final Map<String, _PoolStart> _pools = {};
  final Map<String, int> _lastPlayMs = {};
  final Stopwatch _clock = Stopwatch()..start();

  ap.AudioPlayer? _ambient;
  bool _ambientWanted = false;
  bool _ambientStarting = false;
  bool _ambientPaused = false;
  String? _music;

  double musicVolume = 0.42;
  double sfxVolume = 0.9;
  double ambientVolume = 0.32;

  bool get isReady => _ready;

  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    try {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll([
        ...Sfx.pools.keys,
        Sfx.musicMenu,
        Sfx.musicBattle,
        Sfx.ambient,
      ]);
      for (final entry in Sfx.pools.entries) {
        final pool = await FlameAudio.createPool(entry.key, maxPlayers: entry.value);
        _pools[entry.key] = (double v) => pool.start(volume: v);
      }
      _ready = true;
    } catch (e) {
      debugPrint('Audio initialisation failed: $e');
    }
  }

  /// Plays a pooled effect. [minGapMs] throttles rapid repeats of one sound.
  void play(String name, {double volume = 1.0, int minGapMs = 35}) {
    if (!_ready) return;
    final start = _pools[name];
    if (start == null) return;
    final now = _clock.elapsedMilliseconds;
    final last = _lastPlayMs[name];
    if (last != null && now - last < minGapMs) return;
    final v = (volume * sfxVolume).clamp(0.0, 1.0);
    if (v < 0.02) return;
    _lastPlayMs[name] = now;
    start(v).catchError((Object e) {
      debugPrint('Sound $name failed: $e');
    });
  }

  Future<void> playMusic(String file) async {
    if (!_ready || _music == file) return;
    _music = file;
    try {
      await FlameAudio.bgm.play(file, volume: musicVolume);
    } catch (e) {
      debugPrint('Music failed: $e');
    }
  }

  Future<void> stopMusic() async {
    _music = null;
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      debugPrint('Music stop failed: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (_music == null) return;
    try {
      await FlameAudio.bgm.resume();
    } catch (_) {}
  }

  Future<void> startAmbient() async {
    _ambientWanted = true;
    _ambientPaused = false;
    if (!_ready || _ambientStarting) return;
    final existing = _ambient;
    if (existing != null) {
      try {
        await existing.resume();
      } catch (_) {}
      return;
    }
    _ambientStarting = true;
    try {
      final player = await FlameAudio.loop(Sfx.ambient, volume: ambientVolume);
      if (!_ambientWanted) {
        await player.stop();
        await player.dispose();
      } else {
        _ambient = player;
        if (_ambientPaused) {
          await player.pause();
        }
      }
    } catch (e) {
      debugPrint('Ambient failed: $e');
    } finally {
      _ambientStarting = false;
    }
  }

  Future<void> pauseAmbient() async {
    _ambientPaused = true;
    try {
      await _ambient?.pause();
    } catch (_) {}
  }

  Future<void> resumeAmbient() async {
    _ambientPaused = false;
    if (!_ambientWanted) return;
    try {
      await _ambient?.resume();
    } catch (_) {}
  }

  Future<void> stopAmbient() async {
    _ambientWanted = false;
    final player = _ambient;
    _ambient = null;
    if (player == null) return;
    try {
      await player.stop();
      await player.dispose();
    } catch (_) {}
  }
}
