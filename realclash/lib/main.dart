import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/audio_manager.dart';
import 'core/storage.dart';
import 'graphics/sprites.dart';
import 'ui/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start rendering immediately; all startup work happens behind BootScreen
  // so a slow plugin can never leave the app stuck on a blank screen.
  runApp(const MyApp());
  unawaited(_configureSystemUi());
}

Future<void> _configureSystemUi() async {
  try {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (_) {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Clash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E8BFF), brightness: Brightness.dark),
      ),
      home: const BootScreen(),
    );
  }
}

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    await _guard(SaveData.instance.load(), const Duration(seconds: 3));
    try {
      Sprites.I.loadSync();
    } catch (_) {}
    // Audio preloading is best effort and must not block the game.
    unawaited(_guard(AudioManager.I.init(), const Duration(seconds: 6)));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (BuildContext c, Animation<double> a, Animation<double> b) => const SplashScreen(),
        transitionsBuilder: (BuildContext c, Animation<double> a, Animation<double> b, Widget child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  Future<void> _guard(Future<void> f, Duration timeout) async {
    try {
      await f.timeout(timeout);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1A33),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'REAL CLASH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFFFD25A)),
            ),
          ],
        ),
      ),
    );
  }
}
