import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../config/economy_config.dart';
import '../game/dragon_land_game.dart';
import '../game/systems/currency_system.dart';
import '../services/audio_service.dart';
import '../widgets/coin_counter.dart';
import '../widgets/currency_icons.dart';
import '../widgets/dragon_view.dart';
import '../widgets/game_button.dart';
import '../widgets/panel.dart';

/// Results screen shown after defeat, with optional rewarded-ad bonuses.
class GameOverPanel extends StatefulWidget {
  const GameOverPanel({
    super.key,
    required this.game,
    required this.result,
    required this.currency,
    required this.onPlayAgain,
    required this.onRevived,
    required this.onShop,
    required this.onMenu,
  });

  final DragonLandGame game;
  final RunResult result;
  final CurrencySystem currency;
  final VoidCallback onPlayAgain;
  final VoidCallback onRevived;
  final VoidCallback onShop;
  final VoidCallback onMenu;

  @override
  State<GameOverPanel> createState() => _GameOverPanelState();
}

class _GameOverPanelState extends State<GameOverPanel> {
  bool _busy = false;

  Future<void> _watchAd(void Function() onReward, VoidCallback afterEarned) async {
    final s = AppScope.of(context);
    if (_busy) return;
    if (!s.ads.rewardedReady) {
      unawaited(showMessage(context, 'No reward video available right now. Please try again shortly.', good: false));
      return;
    }
    setState(() => _busy = true);
    s.audio.suspend();
    final earned = await s.ads.showRewarded(onReward);
    s.audio.resume();
    if (!mounted) return;
    setState(() => _busy = false);
    if (earned) afterEarned();
  }

  void _reviveWithAd() {
    var earned = false;
    _watchAd(() => earned = true, () {
      // The game only resumes after the ad has fully closed.
      if (earned && widget.game.revive()) widget.onRevived();
    });
  }

  void _reviveWithGems() {
    final s = AppScope.of(context);
    if (_busy || !widget.game.canRevive) return;
    if (!s.progress.spendGems(EconomyConfig.gemReviveCost)) {
      showMessage(context, 'Not enough gems.', good: false);
      return;
    }
    if (widget.game.revive()) widget.onRevived();
  }

  void _doubleCoins() {
    final s = AppScope.of(context);
    var granted = 0;
    _watchAd(() => granted = widget.currency.grantDoubleCoins(widget.game.stats), () {
      if (granted > 0) {
        s.audio.play(Sfx.purchase);
        showMessage(context, '+${formatNumber(granted)} bonus coins!');
      }
      setState(() {});
    });
  }

  void _bonusChest() {
    final s = AppScope.of(context);
    var granted = 0;
    final amount =
        EconomyConfig.bonusChestAdCoinsMin +
        math.Random().nextInt(EconomyConfig.bonusChestAdCoinsMax - EconomyConfig.bonusChestAdCoinsMin + 1);
    _watchAd(() => granted = widget.currency.grantBonusChest(amount), () {
      if (granted > 0) {
        s.audio.play(Sfx.chest);
        showMessage(context, 'Bonus chest: +${formatNumber(granted)} coins!');
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final r = widget.result;
    final g = widget.game;
    final record = r.newBestDistance || r.newBestScore;
    return ColoredBox(
      color: const Color(0xB3140A28),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([s.ads, s.progress]),
          builder: (context, _) {
            final adReady = s.ads.rewardedReady && !_busy;
            return LayoutBuilder(
              builder: (context, box) {
                final h = box.maxHeight;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: CartoonPanel(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // stats
                          SizedBox(
                            width: 270,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('GAME OVER', style: AppText.title(34, color: AppColors.red)),
                                if (record)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
                                    child: Text('NEW RECORD!', style: AppText.title(18)),
                                  ),
                                _stat(Icons.emoji_events_rounded, 'Score', formatNumber(r.score)),
                                _stat(Icons.straighten_rounded, 'Distance', '${formatNumber(r.distance)} m'),
                                _statWidget(const CoinIcon(size: 20), 'Coins', formatNumber(g.stats.coins)),
                                _statWidget(const GemIcon(size: 20), 'Gems', formatNumber(g.stats.gems)),
                                _stat(Icons.sports_martial_arts_rounded, 'Enemies', formatNumber(r.enemies)),
                                _stat(Icons.flag_rounded, 'Best distance', '${formatNumber(r.bestDistance)} m'),
                                _stat(Icons.pets_rounded, 'Dragon', g.dragonDef.name),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          DragonView(dragon: g.dragonDef, size: math.min(170, h * 0.4), interactive: true),
                          const SizedBox(width: 12),
                          // actions
                          SizedBox(
                            width: 250,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (g.canRevive) ...[
                                  GameButton(
                                    label: 'REVIVE',
                                    icon: Icons.ondemand_video_rounded,
                                    color: AppColors.pink,
                                    height: 48,
                                    fontSize: 19,
                                    width: 250,
                                    pulse: adReady,
                                    onPressed: adReady ? _reviveWithAd : null,
                                  ),
                                  const SizedBox(height: 6),
                                  GameButton(
                                    label: 'REVIVE  ${EconomyConfig.gemReviveCost}',
                                    leading: const GemIcon(size: 22),
                                    color: AppColors.purple,
                                    height: 44,
                                    fontSize: 17,
                                    width: 250,
                                    onPressed: s.progress.gems >= EconomyConfig.gemReviveCost && !_busy ? _reviveWithGems : null,
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                if (!widget.currency.doubleCoinsClaimed && g.stats.coins > 0) ...[
                                  GameButton(
                                    label: 'DOUBLE COINS',
                                    icon: Icons.ondemand_video_rounded,
                                    color: AppColors.gold,
                                    height: 44,
                                    fontSize: 17,
                                    width: 250,
                                    onPressed: adReady ? _doubleCoins : null,
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                if (!widget.currency.bonusChestClaimed) ...[
                                  GameButton(
                                    label: 'BONUS CHEST',
                                    icon: Icons.ondemand_video_rounded,
                                    color: AppColors.orange,
                                    height: 44,
                                    fontSize: 17,
                                    width: 250,
                                    onPressed: adReady ? _bonusChest : null,
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                GameButton(
                                  label: 'PLAY AGAIN',
                                  icon: Icons.replay_rounded,
                                  color: AppColors.grass,
                                  height: 50,
                                  fontSize: 20,
                                  width: 250,
                                  onPressed: _busy ? null : widget.onPlayAgain,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GameButton(
                                        label: 'SHOP',
                                        icon: Icons.storefront_rounded,
                                        color: AppColors.skyDeep,
                                        height: 44,
                                        fontSize: 16,
                                        onPressed: _busy ? null : widget.onShop,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: GameButton(
                                        label: 'MENU',
                                        icon: Icons.home_rounded,
                                        color: AppColors.red,
                                        height: 44,
                                        fontSize: 16,
                                        onPressed: _busy ? null : widget.onMenu,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String k, String v) => _statWidget(Icon(icon, size: 20, color: AppColors.purple), k, v);

  Widget _statWidget(Widget icon, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.5),
    child: Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(k, style: AppText.label(15, color: const Color(0xFF6B5A7A))),
        const Spacer(),
        Text(v, style: AppText.title(18, color: AppColors.ink)),
      ],
    ),
  );
}
