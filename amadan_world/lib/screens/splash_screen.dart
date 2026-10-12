import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../ui/atmosphere.dart';
import '../ui/ui_theme.dart';
import '../utils/asset_paths.dart';
import '../utils/image_store.dart';
import '../utils/save_manager.dart';
import 'lobby_screen.dart';

/// Cinematic opening: smoky battlefield, distant fire and the title.
/// Assets, audio and save data load in the background meanwhile.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
  bool _boomPlayed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _anim.addListener(_onTick);
    _anim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  void _onTick() {
    if (!_boomPlayed && _anim.value > 0.32 && AudioManager.instance.isReady) {
      _boomPlayed = true;
      AudioManager.instance.play(Sfx.explosion, volume: 0.6, minGapMs: 0);
    }
  }

  Future<void> _boot() async {
    final loading = Future.wait<void>([
      SaveManager.init(),
      AudioManager.instance.init(),
      ImageStore.loadAll(AssetPaths.gameImages),
      for (final path in AssetPaths.widgetImages)
        if (mounted) precacheImage(AssetImage(path), context),
    ]).catchError((Object e) {
      debugPrint('Startup loading issue: $e');
      return <void>[];
    });
    final minimum = Future<void>.delayed(const Duration(milliseconds: 4300));
    await Future.wait<void>([loading, minimum]);
    if (!mounted || _navigated) return;
    _navigated = true;
    unawaited(AudioManager.instance.playMusic(Sfx.musicMenu));
    unawaited(Navigator.of(context).pushReplacement(fadeRoute<void>(const LobbyScreen(), milliseconds: 900)));
  }

  @override
  void dispose() {
    _anim.removeListener(_onTick);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final t = _anim.value;
          final bgFade = Curves.easeOut.transform((t / 0.3).clamp(0.0, 1.0));
          final zoom = 1.12 - 0.1 * Curves.easeOut.transform(t);
          final titleT = Curves.easeOutCubic.transform(((t - 0.3) / 0.25).clamp(0.0, 1.0));
          final outT = ((t - 0.86) / 0.14).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: bgFade * (1 - outT * 0.6),
                child: Transform.scale(
                  scale: zoom,
                  child: Image.asset(AssetPaths.splashBg, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                ),
              ),
              Opacity(opacity: bgFade, child: const AtmosphereLayer(intensity: 1.0)),
              Center(
                child: Opacity(
                  opacity: titleT * (1 - outT),
                  child: Transform.scale(
                    scale: 1.25 - 0.25 * titleT,
                    child: _Title(height: MediaQuery.sizeOf(context).height),
                  ),
                ),
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: (1 - bgFade).clamp(0.0, 1.0),
                  child: const ColoredBox(color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final size = (height * 0.15).clamp(34.0, 96.0);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF0D2), Color(0xFFE0A050), Color(0xFF8A4A1C)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect),
      child: Text(
        'AMADAN WORLD',
        textAlign: TextAlign.center,
        style: UiText.title(size),
      ),
    );
  }
}
