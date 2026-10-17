import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/element.dart';
import 'game_store.dart';
import 'roar_storage_stub.dart' if (dart.library.io) 'roar_storage_io.dart' as storage;

enum Fx {
  tap,
  hit,
  crit,
  miss,
  slash,
  guard,
  heal,
  roarBuff,
  win,
  lose,
  coin,
  summon,
  levelup,
  whoosh,
  countdown,
  turn;

  String get file => switch (this) {
    Fx.roarBuff => 'roar_buff',
    _ => name,
  };
}

enum MusicTrack { none, menu, battle }

/// Low-latency sound effects, looping music and haptics, respecting the
/// player's settings.
class Sfx {
  Sfx._();

  static GameStore? _store;
  static final List<AudioPlayer> _pool = [];
  static int _next = 0;
  static AudioPlayer? _roar;
  static AudioPlayer? _music;
  static MusicTrack _track = MusicTrack.none;
  static MusicTrack _wanted = MusicTrack.none;

  static Future<void> init(GameStore store) async {
    _store = store;
    try {
      await AudioPlayer.global.setAudioContext(AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build());
      for (var i = 0; i < 6; i++) {
        final p = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        _pool.add(p);
      }
      _roar = AudioPlayer();
      _music = AudioPlayer();
      await _music!.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Audio init failed: $e');
    }
  }

  static bool get _soundOn => _store?.soundOn ?? true;
  static bool get _musicOn => _store?.musicOn ?? true;
  static bool get _hapticsOn => _store?.hapticsOn ?? true;

  static void play(Fx fx, {double volume = 1}) => _playFile(fx.file, volume);

  /// The signature sound of an element's special attack.
  static void element(BeastElement e) => _playFile('fx_${e.name}', 1);

  static void _playFile(String file, double volume) {
    if (!_soundOn || _pool.isEmpty) return;
    final p = _pool[_next++ % _pool.length];
    p.play(AssetSource('sfx/$file.wav'), volume: volume).catchError((_) {});
  }

  static void tap() {
    play(Fx.tap, volume: 0.5);
    if (_hapticsOn) HapticFeedback.selectionClick();
  }

  static void haptic({bool heavy = false}) {
    if (!_hapticsOn) return;
    heavy ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact();
  }

  // ---- Music ----------------------------------------------------------------
  static Future<void> music(MusicTrack track) async {
    _wanted = track;
    final m = _music;
    if (m == null) return;
    final target = _musicOn ? track : MusicTrack.none;
    if (target == _track) return;
    _track = target;
    try {
      if (target == MusicTrack.none) {
        await m.stop();
      } else {
        await m.stop();
        await m.play(AssetSource('sfx/music_${target.name}.wav'), volume: target == MusicTrack.battle ? 0.32 : 0.28);
      }
    } catch (e) {
      debugPrint('Music failed: $e');
    }
  }

  /// Re-applies the current track after the music setting changed.
  static Future<void> refreshMusic() => music(_wanted);

  static Future<void> pauseMusic() async {
    try {
      await _music?.pause();
    } catch (_) {}
  }

  static Future<void> resumeMusic() async {
    if (_track == MusicTrack.none) return;
    try {
      await _music?.resume();
    } catch (_) {}
  }

  // ---- Roars ----------------------------------------------------------------
  /// Plays a roar that is not saved yet (summon preview).
  static Future<void> roarBytes(Uint8List wav) async {
    if (!_soundOn || _roar == null) return;
    try {
      await _roar!.stop();
      await _roar!.setPlaybackRate(1);
      await _roar!.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('Roar preview failed: $e');
    }
  }

  /// Plays a monster's recorded roar. [rate] < 1 makes it deeper.
  static Future<void> roar(String? path, {double rate = 1.0}) async {
    if (!_soundOn || _roar == null || path == null) {
      play(Fx.roarBuff);
      return;
    }
    try {
      await _roar!.stop();
      await _roar!.setPlaybackRate(rate);
      if (path.startsWith('mem:')) {
        final bytes = storage.memoryRoarBytes(path);
        if (bytes == null) return play(Fx.roarBuff);
        await _roar!.play(BytesSource(bytes, mimeType: 'audio/wav'));
      } else {
        await _roar!.play(DeviceFileSource(path));
      }
    } catch (e) {
      debugPrint('Roar playback failed: $e');
    }
  }
}
