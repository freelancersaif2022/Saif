import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../audio/menu_audio.dart';
import '../../engine/asset_server.dart';
import '../../progression/game_state.dart';

/// Loads save data and settings, starts the local engine server and the menu
/// audio, then fades into the main menu.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onLoaded});

  final void Function(GameState state) onLoaded;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();
  String _status = 'LOADING';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final started = DateTime.now();
    try {
      final state = await GameState.load();
      setState(() => _status = 'PREPARING 3D ENGINE');
      await AssetServer.instance.start();
      await MenuAudio.instance.init(state.settings);
      final wait = const Duration(milliseconds: 1800) - DateTime.now().difference(started);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      if (!mounted) return;
      widget.onLoaded(state);
      if (state.repo?.recovered ?? false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Some saved data was damaged and has been recovered.')));
          }
        });
      }
    } catch (e) {
      setState(() => _status = 'FAILED TO START: $e');
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(fit: StackFit.expand, children: [
        FadeTransition(
          opacity: CurvedAnimation(parent: _anim, curve: const Interval(0.3, 1)),
          child: Opacity(opacity: 0.35, child: Image.asset('assets/images/menu_bg.jpg', fit: BoxFit.cover)),
        ),
        Center(
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutBack)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('ALIEN SURVIVAL', style: headline.copyWith(fontSize: 46, color: AppColors.lime, shadows: const [Shadow(color: Color(0x88D1FE17), blurRadius: 24)])),
              Text('3D  ·  FOREST INVASION', style: headline.copyWith(fontSize: 16, letterSpacing: 6)),
              const SizedBox(height: 28),
              const SizedBox(width: 220, child: LinearProgressIndicator(color: AppColors.lime, backgroundColor: Color(0xFF1D241B))),
              const SizedBox(height: 10),
              Text(_status, style: dim.copyWith(letterSpacing: 2)),
            ]),
          ),
        ),
      ]),
    );
  }
}
