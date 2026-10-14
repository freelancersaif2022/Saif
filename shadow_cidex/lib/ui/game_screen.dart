import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio.dart';
import '../core/save_data.dart';
import '../game/battle.dart';
import '../game/level_data.dart';
import '../game/shadow_game.dart';
import 'hud.dart';
import 'levels_screen.dart';
import 'theme.dart';
import 'victory_screen.dart';
import 'widgets.dart';

enum _Overlay { none, paused, fallen, gameOver, complete }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level});
  final int level;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final GameInput _input = GameInput();
  final HudState _hud = HudState();
  late int _level;
  int _hearts = 3;
  int _levelStartScore = 0;
  int _score = 0;
  int _gameId = 0;
  ShadowGame? _game;
  _Overlay _overlay = _Overlay.none;
  Timer? _fallenTimer;
  final Set<LogicalKeyboardKey> _keys = {};
  final FocusNode _focus = FocusNode();
  bool _victory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _level = widget.level;
    _newGame(fromCheckpoint: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fallenTimer?.cancel();
    _focus.dispose();
    _hud.dispose();
    if (!_victory) GameAudio.instance.playMusic(Sfx.musicLobby, volume: 0.55);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused || state == AppLifecycleState.inactive) && _overlay == _Overlay.none) {
      _pause(silent: true);
    }
  }

  bool get _ultimateEnabled => _level >= 11 || SaveData.instance.unlockedLevel >= 11;

  void _playMusic() {
    final boss = levelConfig(_level).isBoss;
    GameAudio.instance.playMusic(boss ? Sfx.musicBoss : Sfx.musicGame, volume: boss ? 0.6 : 0.5);
  }

  void _newGame({required bool fromCheckpoint}) {
    _input.reset();
    _hud.boss.value = null;
    _hud.banner.value = null;
    _hud.hearts.value = _hearts;
    _hud.health.value = 1;
    _hud.score.value = _levelStartScore;
    _hud.objective.value = '';
    final save = SaveData.instance;
    if (!fromCheckpoint) save.clearCheckpoint(_level);
    final startX = fromCheckpoint ? save.checkpointFor(_level) : 0.0;
    _gameId++;
    _game = ShadowGame(
      level: _level,
      input: _input,
      hud: _hud,
      startX: startX,
      baseScore: _levelStartScore,
      onPlayerDied: _onPlayerDied,
      onLevelComplete: _onLevelComplete,
      ultimateEnabled: _ultimateEnabled,
    );
    _overlay = _Overlay.none;
    _playMusic();
  }

  // ------------------------------------------------------------------ events

  void _onPlayerDied() {
    if (!mounted) return;
    setState(() {
      _hearts = math.max(0, _hearts - 1);
      _hud.hearts.value = _hearts;
      if (_hearts <= 0) {
        _overlay = _Overlay.gameOver;
        _score = _game?.battle?.score ?? _levelStartScore;
        SaveData.instance.submitScore(_score);
        GameAudio.instance.stopMusic();
        GameAudio.instance.play(Sfx.gameOver, volume: 0.9);
        _game?.pauseEngine();
      } else {
        _overlay = _Overlay.fallen;
        _fallenTimer?.cancel();
        _fallenTimer = Timer(const Duration(milliseconds: 2600), () {
          if (!mounted || _overlay != _Overlay.fallen) return;
          setState(() => _newGame(fromCheckpoint: true));
        });
      }
    });
  }

  void _onLevelComplete(int score) {
    if (!mounted) return;
    _score = score;
    final save = SaveData.instance;
    save.completeLevel(_level);
    save.submitScore(score);
    if (_level >= SaveData.levelCount) {
      _victory = true;
      GameAudio.instance.stopMusic();
      GameAudio.instance.play(Sfx.victory, volume: 1.0);
      Navigator.of(context).pushReplacement(FadeRoute(page: VictoryScreen(score: score), ms: 1200));
      return;
    }
    setState(() => _overlay = _Overlay.complete);
  }

  void _pause({bool silent = false}) {
    if (_overlay != _Overlay.none) return;
    if (!silent) GameAudio.instance.play(Sfx.pause, volume: 0.7);
    _input.reset();
    _keys.clear();
    _game?.pauseEngine();
    GameAudio.instance.pauseMusic();
    setState(() => _overlay = _Overlay.paused);
  }

  void _resume() {
    GameAudio.instance.play(Sfx.pause, volume: 0.7);
    _game?.resumeEngine();
    GameAudio.instance.resumeMusic();
    setState(() => _overlay = _Overlay.none);
    _focus.requestFocus();
  }

  void _restartLevel() {
    _fallenTimer?.cancel();
    setState(() {
      _hearts = 3;
      _newGame(fromCheckpoint: false);
    });
    _focus.requestFocus();
  }

  void _nextLevel() {
    setState(() {
      _level = math.min(SaveData.levelCount, _level + 1);
      SaveData.instance.selectLevel(_level);
      _hearts = 3;
      _levelStartScore = _score;
      _newGame(fromCheckpoint: false);
    });
    _focus.requestFocus();
  }

  void _toLobby() {
    _fallenTimer?.cancel();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _toLevels() {
    _fallenTimer?.cancel();
    Navigator.of(context).pushReplacement(FadeRoute(page: const LevelsScreen()));
  }

  // ------------------------------------------------------------------ keyboard

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    final k = e.logicalKey;
    if (e is KeyDownEvent) {
      _keys.add(k);
      if (k == LogicalKeyboardKey.keyJ || k == LogicalKeyboardKey.enter) {
        _input.attack = true;
        _input.attackHeld = true;
      }
      if (k == LogicalKeyboardKey.keyU || k == LogicalKeyboardKey.keyQ) _input.ultimate = true;
      if (k == LogicalKeyboardKey.keyK || k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.keyW || k == LogicalKeyboardKey.arrowUp) _input.jump = true;
      if (k == LogicalKeyboardKey.keyL || k == LogicalKeyboardKey.keyE) _input.power = true;
      if (k == LogicalKeyboardKey.shiftLeft || k == LogicalKeyboardKey.shiftRight) {
        _input.dash = true;
        _input.sprint = true;
      }
      if (k == LogicalKeyboardKey.escape || k == LogicalKeyboardKey.keyP) {
        if (_overlay == _Overlay.none) {
          _pause();
        } else if (_overlay == _Overlay.paused) {
          _resume();
        }
      }
    } else if (e is KeyUpEvent) {
      _keys.remove(k);
      if (k == LogicalKeyboardKey.shiftLeft || k == LogicalKeyboardKey.shiftRight) _input.sprint = false;
      if (k == LogicalKeyboardKey.keyJ || k == LogicalKeyboardKey.enter) _input.attackHeld = false;
    }
    final left = _keys.contains(LogicalKeyboardKey.keyA) || _keys.contains(LogicalKeyboardKey.arrowLeft);
    final right = _keys.contains(LogicalKeyboardKey.keyD) || _keys.contains(LogicalKeyboardKey.arrowRight);
    if (left || right || e is KeyUpEvent) {
      if (left != right) {
        _input.moveX = right ? 1 : -1;
      } else if (e is KeyUpEvent && (k == LogicalKeyboardKey.keyA || k == LogicalKeyboardKey.keyD || k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.arrowRight)) {
        _input.moveX = 0;
      }
    }
    return KeyEventResult.handled;
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final game = _game!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_overlay == _Overlay.none) {
          _pause();
        } else if (_overlay == _Overlay.paused) {
          _resume();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: _onKey,
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: GameWidget<ShadowGame>(
                    key: ValueKey(_gameId),
                    game: game,
                    loadingBuilder: (context) => const ColoredBox(color: Colors.black),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _overlay == _Overlay.none ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: _overlay != _Overlay.none,
                    child: RepaintBoundary(child: GameHud(hud: _hud, input: _input, onPause: _pause, ultimate: _ultimateEnabled)),
                  ),
                ),
              ),
              if (_overlay != _Overlay.none) Positioned.fill(child: _buildOverlay()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    switch (_overlay) {
      case _Overlay.paused:
        return _Popup(
          key: const ValueKey('pause'),
          title: 'PAUSED',
          subtitle: 'LEVEL $_level  ${levelConfig(_level).name}',
          accent: UiColors.accent,
          extra: _SoundToggle(onChanged: () => setState(() {})),
          buttons: [
            _Btn('RESUME', Icons.play_arrow_rounded, _resume, primary: true),
            _Btn('RESTART', Icons.replay_rounded, _restartLevel),
            _Btn('LOBBY', Icons.home_rounded, _toLobby),
          ],
        );
      case _Overlay.fallen:
        return _Popup(
          key: const ValueKey('fallen'),
          title: 'YOU HAVE FALLEN',
          subtitle: 'RISING AGAIN FROM THE LAST CHECKPOINT',
          accent: UiColors.red,
          dim: 0.45,
          extra: HeartsRow(hearts: _hearts, size: 40),
          buttons: const [],
        );
      case _Overlay.gameOver:
        return _Popup(
          key: const ValueKey('over'),
          title: 'GAME OVER',
          subtitle: 'SCORE  $_score     BEST  ${SaveData.instance.highScore}',
          accent: UiColors.red,
          extra: const HeartsRow(hearts: 0, size: 40),
          buttons: [
            _Btn('RETRY', Icons.replay_rounded, _restartLevel, primary: true),
            _Btn('LEVEL SELECT', Icons.grid_view_rounded, _toLevels),
            _Btn('LOBBY', Icons.home_rounded, _toLobby),
          ],
        );
      case _Overlay.complete:
        return _Popup(
          key: const ValueKey('complete'),
          title: 'LEVEL COMPLETE',
          subtitle: '${levelConfig(_level).name}     SCORE  $_score',
          accent: UiColors.gold,
          extra: Text(
            _level < SaveData.levelCount ? 'LEVEL ${_level + 1} UNLOCKED' : '',
            style: UiText.body(18, color: UiColors.accent),
          ),
          buttons: [
            _Btn('NEXT LEVEL', Icons.arrow_forward_rounded, _nextLevel, primary: true),
            _Btn('LEVELS', Icons.grid_view_rounded, _toLevels),
            _Btn('LOBBY', Icons.home_rounded, _toLobby),
          ],
        );
      case _Overlay.none:
        return const SizedBox.shrink();
    }
  }
}

class _Btn {
  const _Btn(this.label, this.icon, this.onTap, {this.primary = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
}

class _Popup extends StatelessWidget {
  const _Popup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.buttons,
    this.extra,
    this.dim = 0.7,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<_Btn> buttons;
  final Widget? extra;
  final double dim;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final u = math.min(box.maxHeight / 650, box.maxWidth / 1150).clamp(0.7, 1.3).toDouble();
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, k, child) => Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: Colors.black.withAlpha((255 * dim * k).round()))),
            Center(
              child: Opacity(
                opacity: k,
                child: Transform.scale(scale: 0.9 + 0.1 * k, child: child),
              ),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12 * u),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, textAlign: TextAlign.center, style: UiText.title(46 * u, glow: 1)),
                SizedBox(height: 10 * u),
                Container(width: 320 * u, height: 1.5, color: accent.withAlpha(200)),
                SizedBox(height: 10 * u),
                Text(subtitle, textAlign: TextAlign.center, style: UiText.body(18 * u, color: const Color(0xFFC8D4E8))),
                if (extra != null) ...[SizedBox(height: 16 * u), extra!],
                if (buttons.isNotEmpty) SizedBox(height: 24 * u),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16 * u,
                  runSpacing: 12 * u,
                  children: [
                    for (final b in buttons)
                      CinematicButton(
                        label: b.label,
                        icon: b.icon,
                        width: 230 * u,
                        height: 54 * u,
                        primary: b.primary,
                        accent: b.primary ? accent : UiColors.accent,
                        onTap: b.onTap,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SoundToggle extends StatelessWidget {
  const _SoundToggle({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final on = SaveData.instance.soundOn;
    return GestureDetector(
      onTap: () {
        GameAudio.instance.setEnabled(!on, startMusic: false);
        onChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xAA05070C),
          border: Border.all(color: (on ? UiColors.accent : UiColors.locked).withAlpha(160)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(on ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: on ? UiColors.accent : UiColors.dim),
            const SizedBox(width: 10),
            Text('SOUND: ${on ? 'ON' : 'OFF'}', style: UiText.body(17)),
          ],
        ),
      ),
    );
  }
}
