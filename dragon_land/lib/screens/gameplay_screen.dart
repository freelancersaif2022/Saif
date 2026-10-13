import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/routes.dart';
import '../game/dragon_land_game.dart';
import '../game/systems/currency_system.dart';
import '../services/audio_service.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_hud.dart';
import '../widgets/pause_overlay.dart';
import 'game_over_screen.dart';

/// Hosts the Flame game plus the Flutter HUD, controls, pause menu and the
/// results screen. Gameplay pauses whenever the app loses focus.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with WidgetsBindingObserver {
  DragonLandGame? _game;
  CurrencySystem? _currency;
  bool _paused = false;
  bool _over = false;
  RunResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_game != null) return;
    final s = AppScope.of(context);
    _currency = CurrencySystem(s.progress, s.rewards);
    _game = DragonLandGame(dragonDef: s.progress.selectedDragon, settings: s.progress.settings, audio: s.audio, onGameOver: _onGameOver);
    s.audio.playMusic(MusicTrack.game);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final s = AppScope.of(context);
    if (state == AppLifecycleState.resumed) {
      s.audio.resume();
      // stay paused: the player resumes from the pause menu
      if (_paused || _over) _game?.pauseEngine();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      s.audio.suspend();
      if (!_over && !_paused) _pause();
      _game?.pauseEngine();
    }
  }

  void _pause() {
    if (_over || _paused) return;
    _game?.pauseGameplay();
    setState(() => _paused = true);
  }

  void _resume() {
    if (_over) return;
    setState(() => _paused = false);
    _game?.resumeGameplay();
  }

  void _onGameOver() {
    final s = AppScope.of(context);
    final game = _game!;
    final result = _currency!.commit(game.stats);
    if (game.revivesUsed == 0) s.ads.registerCompletedRun();
    if (!mounted) return;
    setState(() {
      _result = result;
      _over = true;
    });
  }

  void _restart() {
    setState(() {
      _over = false;
      _paused = false;
      _result = null;
    });
    _currency!.reset();
    _game!.restart();
  }

  void _revived() {
    setState(() {
      _over = false;
      _paused = false;
    });
  }

  Future<void> _quitToLobby() async {
    final s = AppScope.of(context);
    if (!_over) {
      // Leaving mid-run still banks what was collected so far.
      _currency!.commit(_game!.stats);
    }
    s.audio.stopMusic();
    await Routes.lobby(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final game = _game!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_over) {
          _quitToLobby();
        } else if (_paused) {
          _resume();
        } else {
          _pause();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GameWidget(game: game),
            if (!_over)
              ListenableBuilder(
                listenable: s.progress,
                builder: (context, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    SafeArea(
                      child: GameControls(
                        input: game.input,
                        hud: game.hud,
                        dragon: game.dragonDef,
                        leftHanded: s.progress.settings.leftHanded,
                      ),
                    ),
                    SafeArea(
                      child: GameHud(hud: game.hud, onPause: _pause, leftHanded: s.progress.settings.leftHanded),
                    ),
                  ],
                ),
              ),
            if (_paused && !_over)
              PauseOverlay(
                onResume: _resume,
                onRestart: () {
                  _currency!.commit(game.stats);
                  _restart();
                },
                onQuit: _quitToLobby,
                onSettings: () async {
                  await Routes.settings(context);
                  if (mounted) s.audio.applySettings(s.progress.settings);
                },
              ),
            if (_over && _result != null)
              GameOverPanel(
                game: game,
                result: _result!,
                currency: _currency!,
                onPlayAgain: () async {
                  await s.ads.maybeShowInterstitial();
                  if (mounted) _restart();
                },
                onRevived: _revived,
                onShop: () async {
                  await s.ads.maybeShowInterstitial();
                  if (!context.mounted) return;
                  s.audio.stopMusic();
                  Routes.lobbyThenDragonShop(context);
                },
                onMenu: () async {
                  await s.ads.maybeShowInterstitial();
                  if (mounted) await _quitToLobby();
                },
              ),
          ],
        ),
      ),
    );
  }
}
