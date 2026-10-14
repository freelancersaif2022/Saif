import 'package:flame_audio/flame_audio.dart';

import 'storage.dart';

class AudioManager {
  static final AudioManager I = AudioManager._();
  AudioManager._();

  final SaveData _d = SaveData.instance;
  String? _current;
  bool _paused = false;
  final Map<String, int> _last = <String, int>{};

  static const List<String> sfxFiles = <String>[
    'shoot', 'explosion', 'hit', 'gate', 'coin', 'damage', 'click', 'footstep',
    'voice_battle', 'voice_hurt', 'boss_roar', 'base_cannon', 'jump', 'victory', 'defeat',
  ];

  Future<void> _safe(Future<dynamic> Function() f) async {
    try {
      await f();
    } catch (_) {}
  }

  Future<void> init() async {
    await _safe(() async {
      await FlameAudio.audioCache.loadAll(sfxFiles.map((e) => '$e.wav').toList());
    });
    try {
      FlameAudio.bgm.initialize();
    } catch (_) {}
  }

  double get musicVol =>
      (_d.muteAll || _d.muteMusic) ? 0.0 : (_d.master * _d.music).clamp(0.0, 1.0).toDouble();
  double get sfxVol =>
      (_d.muteAll || _d.muteSfx) ? 0.0 : (_d.master * _d.sfx).clamp(0.0, 1.0).toDouble();

  void sfx(String name, {double volume = 1.0, int minGapMs = 0}) {
    final v = sfxVol * volume;
    if (v <= 0.001) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _last[name] ?? 0;
    if (now - last < minGapMs) return;
    _last[name] = now;
    _safe(() async {
      await FlameAudio.play('$name.wav', volume: v.clamp(0.0, 1.0).toDouble());
    });
  }

  Future<void> playMusic(String name) async {
    if (_current == name && !_paused) {
      applyVolume();
      return;
    }
    _current = name;
    _paused = false;
    await _safe(() async {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play('$name.wav', volume: musicVol);
    });
  }

  Future<void> stopMusic() async {
    _current = null;
    _paused = false;
    await _safe(() async {
      await FlameAudio.bgm.stop();
    });
  }

  void pauseMusic() {
    _paused = true;
    _safe(() async {
      await FlameAudio.bgm.pause();
    });
  }

  void resumeMusic() {
    _paused = false;
    _safe(() async {
      await FlameAudio.bgm.resume();
    });
    applyVolume();
  }

  void applyVolume() {
    _safe(() async {
      await FlameAudio.bgm.audioPlayer.setVolume(musicVol);
    });
  }
}
