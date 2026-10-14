import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';

import '../core/audio_manager.dart';
import '../game/real_clash_game.dart';
import 'overlays.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final RealClashGame game;

  @override
  void initState() {
    super.initState();
    game = RealClashGame();
    WidgetsBinding.instance.addObserver(this);
    AudioManager.I.playMusic('music_menu');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      game.pauseGame();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<RealClashGame>(
        game: game,
        initialActiveOverlays: const <String>['menu'],
        overlayBuilderMap: <String, Widget Function(BuildContext, RealClashGame)>{
          'menu': (BuildContext c, RealClashGame g) => MenuOverlay(game: g),
          'hud': (BuildContext c, RealClashGame g) => HudOverlay(game: g),
          'pause': (BuildContext c, RealClashGame g) => PauseOverlay(game: g),
          'over': (BuildContext c, RealClashGame g) => GameOverOverlay(game: g),
          'shop': (BuildContext c, RealClashGame g) => ShopOverlay(game: g),
          'settings': (BuildContext c, RealClashGame g) => SettingsOverlay(game: g),
        },
      ),
    );
  }
}
