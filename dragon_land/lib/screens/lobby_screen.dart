import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../config/economy_config.dart';
import '../services/audio_service.dart';
import '../services/reward_service.dart';
import '../widgets/coin_counter.dart';
import '../widgets/dragon_view.dart';
import '../widgets/game_button.dart';
import '../widgets/logo.dart';
import '../widgets/panel.dart';
import '../widgets/scenic_background.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  Timer? _clock;
  int _celebrate = 0;
  String? _lastDragon;
  bool _adBusy = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppScope.of(context).audio.playMusic(MusicTrack.lobby);
    });
  }

  @override
  void dispose() {
    _float.dispose();
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _play() async {
    final s = AppScope.of(context);
    await Routes.play(context);
    if (mounted) s.audio.playMusic(MusicTrack.lobby);
  }

  Future<void> _freeCoins() async {
    final s = AppScope.of(context);
    if (_adBusy) return;
    if (!s.rewards.freeCoinsReady) {
      unawaited(showMessage(context, 'Free coins recharge in ${_fmt(s.rewards.freeCoinsWait)}', good: false));
      return;
    }
    if (!s.ads.rewardedReady) {
      unawaited(showMessage(context, 'No reward video available right now. Please try again shortly.', good: false));
      return;
    }
    setState(() => _adBusy = true);
    s.audio.suspend();
    final earned = await s.ads.showRewarded(() => s.rewards.grantFreeCoins());
    s.audio.resume();
    if (!mounted) return;
    setState(() => _adBusy = false);
    if (earned) {
      s.audio.play(Sfx.purchase);
      unawaited(showMessage(context, '+${EconomyConfig.freeCoinsAdReward} coins!'));
    }
  }

  static String _fmt(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    final m = d.inMinutes, s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<bool> _confirmExit() async {
    final r = await showCartoonDialog<bool>(
      context,
      title: 'Leave Dragon Land?',
      body: Text(
        'Your dragons will be waiting for you!',
        style: AppText.label(16, color: AppColors.ink),
        textAlign: TextAlign.center,
      ),
      actions: [
        GameButton(label: 'STAY', color: AppColors.grass, width: 140, onPressed: () => Navigator.of(context).pop(false)),
        GameButton(label: 'EXIT', color: AppColors.red, width: 140, onPressed: () => Navigator.of(context).pop(true)),
      ],
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit()) unawaited(SystemNavigator.pop());
      },
      child: Scaffold(
        body: ScenicBackground(
          child: SafeArea(
            child: ListenableBuilder(
              listenable: Listenable.merge([s.progress, s.ads]),
              builder: (context, _) {
                final dragon = s.progress.selectedDragon;
                if (_lastDragon != null && _lastDragon != dragon.id) _celebrate++;
                _lastDragon = dragon.id;
                return LayoutBuilder(
                  builder: (context, box) {
                    final h = box.maxHeight;
                    final w = box.maxWidth;
                    final btnW = math.min(230.0, w * 0.24);
                    final btnH = math.min(58.0, h * 0.14);
                    return Stack(
                      children: [
                        // floating island with the selected dragon
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _float,
                            builder: (context, child) {
                              final bob = math.sin(_float.value * math.pi * 2) * h * 0.015;
                              return Transform.translate(offset: Offset(0, bob), child: child);
                            },
                            child: Align(
                              alignment: const Alignment(0, 0.55),
                              child: SizedBox(
                                width: h * 0.95,
                                height: h * 0.78,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      height: h * 0.95 * 420 / 760,
                                      child: Image.asset('assets/images/lobby_island.png', fit: BoxFit.contain),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: h * 0.95 * 420 / 760 * 0.62,
                                      child: Center(
                                        child: DragonView(dragon: dragon, size: h * 0.5, celebrate: _celebrate),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // dragon name plate
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: h * 0.02,
                          child: Column(
                            children: [
                              Text(dragon.name.toUpperCase(), style: AppText.title(h * 0.07)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(color: dragon.bodyDark, borderRadius: BorderRadius.circular(10)),
                                child: Text('${dragon.elementLabel} • ${dragon.specialName}', style: AppText.label(13)),
                              ),
                            ],
                          ),
                        ),
                        // top bar
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 6,
                          child: Row(
                            children: [
                              if (w > 760) ...[DragonLandLogo(size: math.min(30, h * 0.07)), const SizedBox(width: 10)],
                              Flexible(
                                child: Text(
                                  'Best ${formatNumber(s.progress.data.bestDistance)} m',
                                  style: AppText.label(14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 5,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _FreeCoinsButton(
                                          ready: s.rewards.freeCoinsReady && s.ads.rewardedReady,
                                          label: s.rewards.freeCoinsReady
                                              ? 'FREE +${EconomyConfig.freeCoinsAdReward}'
                                              : _fmt(s.rewards.freeCoinsWait),
                                          onTap: _freeCoins,
                                        ),
                                        const SizedBox(width: 8),
                                        CurrencyPill(amount: s.progress.coins, onAdd: () => Routes.coinShop(context)),
                                        const SizedBox(width: 8),
                                        CurrencyPill(amount: s.progress.gems, gem: true, onAdd: () => Routes.coinShop(context, tab: 1)),
                                        const SizedBox(width: 8),
                                        RoundIconButton(
                                          icon: s.progress.settings.sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                          size: 42,
                                          color: s.progress.settings.sound ? AppColors.skyDeep : const Color(0xFF8E8AA2),
                                          onPressed: () {
                                            s.progress.updateSettings((st) => st.sound = !st.sound);
                                            s.audio.applySettings(s.progress.settings);
                                          },
                                        ),
                                        const SizedBox(width: 6),
                                        RoundIconButton(
                                          icon: s.progress.settings.music ? Icons.music_note_rounded : Icons.music_off_rounded,
                                          size: 42,
                                          color: s.progress.settings.music ? AppColors.skyDeep : const Color(0xFF8E8AA2),
                                          onPressed: () {
                                            s.progress.updateSettings((st) => st.music = !st.music);
                                            s.audio.applySettings(s.progress.settings);
                                            if (s.progress.settings.music) s.audio.playMusic(MusicTrack.lobby);
                                          },
                                        ),
                                        const SizedBox(width: 6),
                                        RoundIconButton(
                                          icon: Icons.settings_rounded,
                                          size: 42,
                                          color: AppColors.purple,
                                          onPressed: () => Routes.settings(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // left menu
                        Positioned(
                          left: 16,
                          bottom: h * 0.06,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GameButton(
                                label: 'DRAGON SHOP',
                                icon: Icons.storefront_rounded,
                                color: AppColors.gold,
                                width: btnW,
                                height: btnH,
                                fontSize: btnH * 0.36,
                                onPressed: () => Routes.dragonShop(context),
                              ),
                              SizedBox(height: h * 0.025),
                              GameButton(
                                label: 'SELECT DRAGON',
                                icon: Icons.pets_rounded,
                                color: AppColors.purple,
                                width: btnW,
                                height: btnH,
                                fontSize: btnH * 0.36,
                                onPressed: () => Routes.selectDragon(context),
                              ),
                              SizedBox(height: h * 0.025),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GameButton(
                                    label: 'DAILY REWARD',
                                    icon: Icons.card_giftcard_rounded,
                                    color: AppColors.pink,
                                    width: btnW,
                                    height: btnH,
                                    fontSize: btnH * 0.36,
                                    pulse: s.rewards.dailyStatus == DailyStatus.available,
                                    onPressed: () => Routes.daily(context),
                                  ),
                                  if (s.rewards.dailyStatus == DailyStatus.available) const _Badge(text: '!'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // right menu
                        Positioned(
                          right: 16,
                          bottom: h * 0.06,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GameButton(
                                    label: 'MISSIONS',
                                    icon: Icons.flag_rounded,
                                    color: AppColors.turquoise,
                                    width: btnW,
                                    height: btnH,
                                    fontSize: btnH * 0.36,
                                    onPressed: () => Routes.missions(context),
                                  ),
                                  if (s.rewards.claimableMissions > 0) _Badge(text: '${s.rewards.claimableMissions}'),
                                ],
                              ),
                              SizedBox(height: h * 0.025),
                              GameButton(
                                label: 'SETTINGS',
                                icon: Icons.tune_rounded,
                                color: AppColors.skyDeep,
                                width: btnW,
                                height: btnH,
                                fontSize: btnH * 0.36,
                                onPressed: () => Routes.settings(context),
                              ),
                              SizedBox(height: h * 0.03),
                              GameButton(
                                label: 'PLAY',
                                icon: Icons.play_arrow_rounded,
                                color: AppColors.grass,
                                width: btnW * 1.15,
                                height: btnH * 1.45,
                                fontSize: btnH * 0.62,
                                pulse: true,
                                cooldown: const Duration(seconds: 1),
                                onPressed: _play,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Positioned(
    right: -6,
    top: -8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(text, style: AppText.title(14)),
    ),
  );
}

class _FreeCoinsButton extends StatelessWidget {
  const _FreeCoinsButton({required this.ready, required this.label, required this.onTap});
  final bool ready;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GameButton(
    label: label,
    icon: Icons.ondemand_video_rounded,
    color: ready ? AppColors.grass : const Color(0xFF7D86A6),
    height: 42,
    fontSize: 15,
    pulse: ready,
    onPressed: onTap,
  );
}
