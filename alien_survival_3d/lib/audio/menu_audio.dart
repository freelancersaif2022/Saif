import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../storage/models.dart';

/// Menu music and UI sounds for the Flutter screens. In-game audio is played
/// by the engine's WebAudio mixer. Uses the same generated OGG files.
class MenuAudio {
  MenuAudio._();

  static final MenuAudio instance = MenuAudio._();

  // Created in init() so screens work (silently) where audio is unavailable.
  late AudioPlayer _music;
  List<AudioPlayer> _ui = const [];
  int _next = 0;
  Settings? _settings;
  bool _musicOn = false;
  bool _ready = false;

  Future<void> init(Settings s) async {
    _settings = s;
    try {
      _music = AudioPlayer(playerId: 'menu_music');
      _ui = List.generate(3, (i) => AudioPlayer(playerId: 'ui_$i'));
      await AudioPlayer.global.setAudioContext(AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build());
      await _music.setReleaseMode(ReleaseMode.loop);
      for (final p in _ui) {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
      }
      _ready = true;
    } catch (e) {
      debugPrint('menu audio unavailable: $e');
    }
  }

  double get _musicVol => (_settings?.masterVolume ?? 1) * (_settings?.musicVolume ?? 0.6) * 0.8;
  double get _sfxVol => (_settings?.masterVolume ?? 1) * (_settings?.sfxVolume ?? 0.9) * 0.7;

  Future<void> playMenuMusic() async {
    if (!_ready || _musicOn) return;
    _musicOn = true;
    try {
      await _music.setVolume(_musicVol);
      await _music.play(AssetSource('game/audio/music_menu.ogg'));
    } catch (e) {
      debugPrint('menu music failed: $e');
    }
  }

  Future<void> stopMusic() async {
    if (!_ready || !_musicOn) return;
    _musicOn = false;
    try {
      await _music.stop();
    } catch (_) {}
  }

  Future<void> refreshVolumes() async {
    if (!_ready) return;
    try {
      await _music.setVolume(_musicVol);
    } catch (_) {}
  }

  void click([String name = 'ui_click']) {
    if (!_ready) return;
    final p = _ui[_next++ % _ui.length];
    p.play(AssetSource('game/audio/$name.ogg'), volume: _sfxVol).catchError((Object e) => debugPrint('ui sound: $e'));
  }

  Future<void> pauseAll() async {
    if (!_ready) return;
    try {
      await _music.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!_ready || !_musicOn) return;
    try {
      await _music.resume();
    } catch (_) {}
  }
}
