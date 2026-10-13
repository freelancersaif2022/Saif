import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/routes.dart';
import '../models/dragon_model.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/progress_controller.dart';
import '../services/purchase_service.dart';
import '../services/reward_service.dart';
import '../services/storage_service.dart';
import '../widgets/dragon_view.dart';
import '../widgets/logo.dart';
import '../widgets/scenic_background.dart';

/// Animated splash that boots every service, then fades into the lobby.
/// Initialisation is time-boxed and failure tolerant, so the player can never
/// get stuck here: storage falls back to memory, audio/ads/store degrade to
/// disabled.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.platformServices = true});

  /// False in widget tests (no plugins).
  final bool platformServices;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
  bool _leaving = false;
  String _status = 'Waking the dragons...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final services = AppScope.of(context);
    final started = DateTime.now();
    final platform = widget.platformServices && !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!services.ready) {
      try {
        final storage = await StorageService.create().timeout(const Duration(seconds: 5));
        services.progress = ProgressController(storage);
      } catch (e) {
        debugPrint('Splash: storage unavailable, using memory: $e');
        services.progress = ProgressController.memory();
      }
      services.rewards = RewardService(services.progress);
      services.audio = AudioService(enabled: platform);
      services.purchases = PurchaseService(services.progress, enabled: platform);
      services.ads = AdService(services.progress, enabled: platform);
      if (mounted) setState(() => _status = 'Loading magical sounds...');
      try {
        await services.audio.init(services.progress.settings).timeout(const Duration(seconds: 6));
      } catch (e) {
        debugPrint('Splash: audio init timed out: $e');
      }
      services.ready = true;
      // Store and ads initialise in the background; the game never waits on the network.
      unawaited(services.purchases.init());
      unawaited(services.ads.init());
    }
    if (mounted) setState(() => _status = 'Ready!');
    final elapsed = DateTime.now().difference(started);
    const minShow = Duration(milliseconds: 2200);
    if (elapsed < minShow) await Future.delayed(minShow - elapsed);
    if (!mounted) return;
    setState(() => _leaving = true);
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted) unawaited(Routes.lobby(context));
  }

  @override
  void dispose() {
    _intro.dispose();
    _fly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 420),
        opacity: _leaving ? 0 : 1,
        child: ScenicBackground(
          child: LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              return Stack(
                children: [
                  AnimatedBuilder(
                    animation: _fly,
                    builder: (context, child) {
                      final t = _fly.value;
                      return Positioned(
                        left: -160 + (box.maxWidth + 320) * t,
                        top: h * 0.08 + h * 0.06 * (1 - (2 * t - 1).abs()),
                        child: child!,
                      );
                    },
                    child: DragonView(dragon: Dragons.ember, size: h * 0.3, interactive: false, flying: true),
                  ),
                  Center(
                    child: FadeTransition(
                      opacity: _intro,
                      child: ScaleTransition(
                        scale: CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
                        child: DragonLandLogo(size: h * 0.16, subtitle: 'Discover Your Dragon Adventure'),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: h * 0.08,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const LinearProgressIndicator(
                              minHeight: 10,
                              color: Color(0xFFFFC93C),
                              backgroundColor: Color(0x662A1636),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _status,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [Shadow(color: Color(0xAA2A1636), offset: Offset(0, 2))],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
