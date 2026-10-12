import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../game/amadan_game.dart';
import '../ui/controls_overlay.dart';
import '../ui/game_over_overlay.dart';
import '../ui/pause_overlay.dart';
import '../ui/ui_theme.dart';
import '../utils/asset_paths.dart';
import '../weapons/weapon_data.dart';
import 'lobby_screen.dart';

/// Hosts the Flame game and its Flutter overlays, and ties the game to the
/// app lifecycle (auto-pause when backgrounded, audio cleanup on exit).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.weapon});

  final WeaponType weapon;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final AmadanGame _game = AmadanGame(weaponType: widget.weapon, onExitToLobby: _exitToLobby);
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(AudioManager.instance.playMusic(Sfx.musicBattle));
    unawaited(AudioManager.instance.startAmbient());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _game.pauseGame();
      unawaited(AudioManager.instance.pauseAmbient());
    }
  }

  void _exitToLobby() {
    if (_leaving || !mounted) return;
    _leaving = true;
    unawaited(AudioManager.instance.stopAmbient());
    unawaited(AudioManager.instance.playMusic(Sfx.musicMenu));
    Navigator.of(context).pushReplacement(fadeRoute<void>(const LobbyScreen(), milliseconds: 700));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.shutdown();
    unawaited(AudioManager.instance.stopAmbient());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _game.safeInsets = MediaQuery.paddingOf(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<AmadanGame>(
          game: _game,
          loadingBuilder: (context) => const ColoredBox(
            color: Colors.black,
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3, color: UiColors.accent),
              ),
            ),
          ),
          overlayBuilderMap: <String, Widget Function(BuildContext, AmadanGame)>{
            GameOverlays.controls: (context, game) => ControlsOverlay(game: game),
            GameOverlays.pause: (context, game) => PauseOverlay(game: game),
            GameOverlays.gameOver: (context, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const [GameOverlays.controls],
        ),
      ),
    );
  }
}
