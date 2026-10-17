import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/game_store.dart';
import 'services/sfx.dart';
import 'theme/app_theme.dart';
import 'widgets/feedback.dart';

class VoiceBeastApp extends StatefulWidget {
  const VoiceBeastApp({super.key, required this.store});
  final GameStore store;

  @override
  State<VoiceBeastApp> createState() => _VoiceBeastAppState();
}

class _VoiceBeastAppState extends State<VoiceBeastApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      widget.store.flush();
      Sfx.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      Sfx.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      store: widget.store,
      child: MaterialApp(
        title: 'VoiceBeast Arena',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootMessengerKey,
        home: widget.store.onboarded ? const HomeShell() : const OnboardingScreen(),
      ),
    );
  }
}

/// Smooth slide+fade route used across the app.
Route<T> gameRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 240),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, a, _, child) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  },
);
