import 'package:flutter/material.dart';

import '../progression/game_state.dart';
import '../ui/screens/game_screen.dart';
import '../ui/screens/high_scores_screen.dart';
import '../ui/screens/layout_editor_screen.dart';
import '../ui/screens/loadout_screen.dart';
import '../ui/screens/main_menu_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/shop_screen.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/stats_screen.dart';
import '../ui/screens/upgrade_screen.dart';
import 'routes.dart';
import 'theme.dart';

class AlienSurvivalApp extends StatefulWidget {
  const AlienSurvivalApp({super.key, this.initialState});

  /// Pre-loaded state (tests); otherwise the splash screen loads it.
  final GameState? initialState;

  @override
  State<AlienSurvivalApp> createState() => _AlienSurvivalAppState();
}

class _AlienSurvivalAppState extends State<AlienSurvivalApp> {
  GameState? _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  Route<dynamic>? _route(RouteSettings settings) {
    final s = _state;
    if (s == null) return null;
    final Widget Function(BuildContext) b = switch (settings.name) {
      Routes.menu => (_) => MainMenuScreen(state: s),
      Routes.loadout => (_) => LoadoutScreen(state: s),
      Routes.game => (_) => GameScreen(state: s),
      Routes.shop => (_) => ShopScreen(state: s),
      Routes.upgrade => (_) => UpgradeScreen(state: s),
      Routes.settings => (_) => SettingsScreen(state: s),
      Routes.stats => (_) => StatsScreen(state: s),
      Routes.highScores => (_) => HighScoresScreen(state: s),
      Routes.layoutEditor => (_) => LayoutEditorScreen(state: s),
      _ => (_) => MainMenuScreen(state: s),
    };
    return FadeRoute(builder: b, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien Survival 3D',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      onGenerateRoute: _route,
      home: _state != null
          ? MainMenuScreen(state: _state!)
          : SplashScreen(onLoaded: (s) {
              setState(() => _state = s);
              navigatorKey.currentState?.pushReplacement(FadeRoute(builder: (_) => MainMenuScreen(state: s), settings: const RouteSettings(name: Routes.menu)));
            }),
    );
  }
}
