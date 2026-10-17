import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'game_store.dart';
import 'roar_storage_stub.dart' if (dart.library.io) 'roar_storage_io.dart' as storage;

enum Fx { tap, hit, crit, guard, win, lose, coin, summon, levelup, whoosh }

/// Low-latency sound effects + haptics, respecting the player's settings.
class Sfx {
  Sfx._();

  static GameStore? _store;
  static final List<AudioPlayer> _pool = [];
  static int _next = 0;
  static AudioPlayer? _roar;

  static Future<void> init(GameStore store) async {
    _store = store;
    try {
      await AudioPlayer.global.setAudioContext(AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build());
      for (var i = 0; i < 4; i++) {
        final p = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        _pool.add(p);
      }
      _roar = AudioPlayer();
    } catch (e) {
      debugPrint('Audio init failed: $e');
    }
  }

  static bool get _soundOn => _store?.soundOn ?? true;
  static bool get _hapticsOn => _store?.hapticsOn ?? true;

  static void play(Fx fx, {double volume = 1}) {
    if (!_soundOn || _pool.isEmpty) return;
    final p = _pool[_next++ % _pool.length];
    p.play(AssetSource('sfx/${fx.name}.wav'), volume: volume).catchError((_) {});
  }

  static void tap() {
    play(Fx.tap, volume: 0.5);
    if (_hapticsOn) HapticFeedback.selectionClick();
  }

  static void haptic({bool heavy = false}) {
    if (!_hapticsOn) return;
    heavy ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact();
  }

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
      play(Fx.whoosh);
      return;
    }
    try {
      await _roar!.stop();
      await _roar!.setPlaybackRate(rate);
      if (path.startsWith('mem:')) {
        final bytes = storage.memoryRoarBytes(path);
        if (bytes == null) return play(Fx.whoosh);
        await _roar!.play(BytesSource(bytes, mimeType: 'audio/wav'));
      } else {
        await _roar!.play(DeviceFileSource(path));
      }
    } catch (e) {
      debugPrint('Roar playback failed: $e');
    }
  }
}
