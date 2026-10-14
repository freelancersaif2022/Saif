import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../audio/menu_audio.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.state});

  final GameState state;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin, RouteAware {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    MenuAudio.instance.playMenuMusic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    // back from a game or sub-screen
    MenuAudio.instance.playMenuMusic();
    _intro.forward(from: 0.4);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _intro.dispose();
    super.dispose();
  }

  Future<void> _exit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.lime)),
        title: Text('EXIT GAME?', style: headline.copyWith(fontSize: 20)),
        content: const Text('Your progress is saved on this device.'),
        actions: [
          NeonButton(label: 'CANCEL', height: 40, onPressed: () => Navigator.of(ctx).pop(false)),
          NeonButton(label: 'EXIT', primary: true, height: 40, onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    if (ok == true) {
      await MenuAudio.instance.stopMusic();
      await SystemNavigator.pop();
    }
  }

  Widget _slide(int i, Widget child) {
    final a = CurvedAnimation(parent: _intro, curve: Interval(0.1 * i, (0.1 * i + 0.6).clamp(0, 1), curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(position: Tween(begin: const Offset(0.25, 0), end: Offset.zero).animate(a), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final best = s.save.highScores.isEmpty ? 0 : s.save.highScores.first.score;
    // compact layout for short landscape phones
    final compact = MediaQuery.sizeOf(context).height < 380;
    final bh = compact ? 38.0 : 46.0, gap = compact ? 6.0 : 8.0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        body: Backdrop(
          dim: 0.35,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 16),
              child: Row(children: [
                // title block
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ALIEN SURVIVAL', style: headline.copyWith(fontSize: compact ? 32 : 40, color: AppColors.lime, shadows: const [Shadow(color: Color(0xAA000000), blurRadius: 8)])),
                    Text('3D · FOREST INVASION', style: headline.copyWith(fontSize: 14, letterSpacing: 5)),
                    const Spacer(),
                    Panel(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.emoji_events, color: AppColors.lime, size: 20),
                        const SizedBox(width: 8),
                        Text('BEST $best', style: label),
                        const SizedBox(width: 16),
                        const Icon(Icons.waves, color: AppColors.lime, size: 20),
                        const SizedBox(width: 6),
                        Text('WAVE ${s.save.stats.bestWave}', style: label),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Wrap(spacing: 10, runSpacing: 6, children: [
                      NeonButton(label: 'STATS', icon: Icons.bar_chart, height: compact ? 36 : 40, fontSize: 13, onPressed: () => Navigator.of(context).pushNamed(Routes.stats)),
                      NeonButton(label: 'HIGH SCORES', icon: Icons.emoji_events_outlined, height: compact ? 36 : 40, fontSize: 13, onPressed: () => Navigator.of(context).pushNamed(Routes.highScores)),
                    ]),
                  ]),
                ),
                // menu buttons (PLAY | SETTINGS | SHOP | UPGRADE | EXIT)
                SizedBox(
                  width: 250,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Align(alignment: Alignment.centerRight, child: CurrencyBar(state: s)),
                    const Spacer(),
                    _slide(0, NeonButton(key: const Key('play'), label: 'PLAY', primary: true, height: compact ? 52 : 64, fontSize: compact ? 24 : 28, sound: 'ui_select', onPressed: () => Navigator.of(context).pushNamed(Routes.loadout))),
                    SizedBox(height: gap + 2),
                    _slide(1, NeonButton(key: const Key('settings'), label: 'SETTINGS', icon: Icons.settings, height: bh, onPressed: () => Navigator.of(context).pushNamed(Routes.settings))),
                    SizedBox(height: gap),
                    _slide(2, NeonButton(key: const Key('shop'), label: 'SHOP', icon: Icons.shopping_cart, height: bh, onPressed: () => Navigator.of(context).pushNamed(Routes.shop))),
                    SizedBox(height: gap),
                    _slide(3, NeonButton(key: const Key('upgrade'), label: 'UPGRADE', icon: Icons.upgrade, height: bh, onPressed: () => Navigator.of(context).pushNamed(Routes.upgrade))),
                    SizedBox(height: gap),
                    _slide(4, NeonButton(key: const Key('exit'), label: 'EXIT', icon: Icons.logout, height: bh, onPressed: _exit)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
