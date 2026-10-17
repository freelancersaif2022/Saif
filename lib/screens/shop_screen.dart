import 'package:flutter/material.dart';

import '../config/monetization_config.dart';
import '../services/ads/ad_service.dart';
import '../services/game_store.dart';
import '../services/iap/iap_service.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/ui.dart';
import 'home_shell.dart';
import 'monster_detail_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const stoneGemPrice = 40;

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopHud(title: 'Shop'),
          Expanded(
            child: ListenableBuilder(
              listenable: IapService.instance,
              builder: (context, _) {
                final iap = IapService.instance;
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    if (!store.starterPackOwned) _StarterPackCard(iap: iap),
                    const SectionTitle('Free rewards'),
                    _FreeGemsCard(left: store.gemAdsLeft),
                    const SectionTitle('Gems'),
                    _GemPack(id: ProductIds.gemsSmall, amount: 80, icon: Icons.diamond_outlined, iap: iap),
                    _GemPack(id: ProductIds.gemsMedium, amount: 500, icon: Icons.diamond_rounded, iap: iap, tag: 'BEST SELLER'),
                    _GemPack(id: ProductIds.gemsLarge, amount: 1200, icon: Icons.workspace_premium_rounded, iap: iap, tag: 'BEST VALUE'),
                    const SectionTitle('Items'),
                    _ItemRow(
                      icon: const CurrencyIcon(Currency.stones, size: 30),
                      title: 'Evolution Stone',
                      subtitle: 'Evolve beasts at Lv 10 and Lv 20',
                      price: '$stoneGemPrice',
                      currency: Currency.gems,
                      onBuy: () => _buyStoneGems(context),
                    ),
                    _ItemRow(
                      icon: const CurrencyIcon(Currency.stones, size: 30),
                      title: 'Evolution Stone',
                      subtitle: 'Pay with battle coins',
                      price: '${MonsterDetailScreen.stoneCoinPrice}',
                      currency: Currency.coins,
                      onBuy: () => _buyStoneCoins(context),
                    ),
                    _ItemRow(
                      icon: const CurrencyIcon(Currency.energy, size: 30),
                      title: 'Full Energy Refill',
                      subtitle: 'Back to ${GameStore.maxEnergy} energy',
                      price: '15',
                      currency: Currency.gems,
                      onBuy: () {
                        if (store.spendGems(15)) {
                          store.addEnergy(GameStore.maxEnergy);
                          Sfx.play(Fx.coin);
                          AppToast.show('Energy refilled!', type: ToastType.success);
                        } else {
                          _notEnough(Currency.gems);
                        }
                      },
                    ),
                    const SectionTitle('Premium'),
                    _RemoveAdsCard(iap: iap, owned: store.removeAds),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => iap.restore(),
                        icon: const Icon(Icons.restore_rounded, color: AppColors.textDim, size: 18),
                        label: Text('Restore purchases', style: AppText.label.copyWith(color: AppColors.textDim)),
                      ),
                    ),
                    if (MonetizationConfig.testMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'TEST MODE: purchases are simulated, no money is charged.',
                          textAlign: TextAlign.center,
                          style: AppText.small.copyWith(color: AppColors.warning),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static void _notEnough(Currency c) {
    AppToast.show(
      c == Currency.gems ? 'Not enough gems. Grab a gem pack or watch a free video above.' : 'Not enough coins. Win battles to earn more!',
      type: ToastType.error,
      title: 'Not enough ${c == Currency.gems ? 'gems' : 'coins'}',
    );
  }

  static Future<void> _buyStoneGems(BuildContext context) async {
    final store = GameScope.read(context);
    if (store.spendGems(stoneGemPrice)) {
      store.addStones(1);
      Sfx.play(Fx.coin);
      AppToast.show('+1 Evolution Stone (you have ${store.stones})', type: ToastType.success);
    } else {
      _notEnough(Currency.gems);
    }
  }

  static Future<void> _buyStoneCoins(BuildContext context) async {
    final store = GameScope.read(context);
    if (store.spendCoins(MonsterDetailScreen.stoneCoinPrice)) {
      store.addStones(1);
      Sfx.play(Fx.coin);
      AppToast.show('+1 Evolution Stone (you have ${store.stones})', type: ToastType.success);
    } else {
      _notEnough(Currency.coins);
    }
  }
}

class _StarterPackCard extends StatelessWidget {
  const _StarterPackCard({required this.iap});
  final IapService iap;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.gold.withValues(alpha: 0.7),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6A3B00), Color(0xFF2B1A4A)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  'NEW PLAYER OFFER',
                  style: AppText.small.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Starter Pack', style: AppText.display.copyWith(fontSize: 30)),
          const SizedBox(height: 10),
          const Wrap(spacing: 14, runSpacing: 8, children: [_PackItem(Currency.gems, '150'), _PackItem(Currency.stones, '3'), _PackItemIcon(Icons.add_box_rounded, '+1 slot')]),
          const SizedBox(height: 14),
          GameButton(
            label: iap.priceOf(ProductIds.starterPack),
            icon: Icons.shopping_bag_rounded,
            color: AppColors.gold,
            expand: true,
            loading: iap.isPending(ProductIds.starterPack),
            onTap: () => iap.buy(ProductIds.starterPack),
          ),
        ],
      ),
    );
  }
}

class _PackItem extends StatelessWidget {
  const _PackItem(this.c, this.text);
  final Currency c;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CurrencyIcon(c, size: 22),
      const SizedBox(width: 4),
      Text(text, style: AppText.h2),
    ],
  );
}

class _PackItemIcon extends StatelessWidget {
  const _PackItemIcon(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 22, color: AppColors.cyan),
      const SizedBox(width: 4),
      Text(text, style: AppText.h2),
    ],
  );
}

class _FreeGemsCard extends StatelessWidget {
  const _FreeGemsCard({required this.left});
  final int left;

  Future<void> _watch(BuildContext context) async {
    final store = GameScope.read(context);
    final ok = await AdService.instance.showRewarded(rewardLabel: '5 free gems');
    if (ok) {
      store.recordGemAd();
      Sfx.play(Fx.coin);
      AppToast.show('+5 gems! ${store.gemAdsLeft} free videos left today.', type: ToastType.reward);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          const IconBadge(icon: Icons.ondemand_video_rounded, color: AppColors.gem, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Free Gems', style: AppText.h3),
                Text(left > 0 ? 'Watch a video for 5 gems • $left left today' : 'Come back tomorrow for more!', style: AppText.small),
              ],
            ),
          ),
          GameButton(label: '+5', icon: Icons.play_circle_fill_rounded, color: AppColors.success, small: true, onTap: left > 0 ? () => _watch(context) : null),
        ],
      ),
    );
  }
}

class _GemPack extends StatelessWidget {
  const _GemPack({required this.id, required this.amount, required this.icon, required this.iap, this.tag});
  final String id;
  final int amount;
  final IconData icon;
  final IapService iap;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final info = IapService.catalog[id]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Panel(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            borderColor: tag != null ? AppColors.gem.withValues(alpha: 0.5) : null,
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [AppColors.gem.withValues(alpha: 0.4), Colors.transparent]),
                  ),
                  child: Icon(icon, color: AppColors.gem, size: 34),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$amount Gems', style: AppText.h2),
                      Text(info.title, style: AppText.small),
                    ],
                  ),
                ),
                GameButton(label: iap.priceOf(id), color: AppColors.primary, small: true, loading: iap.isPending(id), onTap: () => iap.buy(id)),
              ],
            ),
          ),
          if (tag != null)
            Positioned(
              top: -8,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.gem, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  tag!,
                  style: AppText.small.copyWith(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.icon, required this.title, required this.subtitle, required this.price, required this.currency, required this.onBuy});
  final Widget icon;
  final String title;
  final String subtitle;
  final String price;
  final Currency currency;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Panel(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            SizedBox(width: 44, child: Center(child: icon)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h3),
                  Text(subtitle, style: AppText.small),
                ],
              ),
            ),
            GameButton(label: price, color: AppColors.surfaceHi, small: true, trailing: CurrencyIcon(currency, size: 16), onTap: onBuy),
          ],
        ),
      ),
    );
  }
}

class _RemoveAdsCard extends StatelessWidget {
  const _RemoveAdsCard({required this.iap, required this.owned});
  final IapService iap;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      gradient: const LinearGradient(colors: [Color(0xFF3B1E6E), AppColors.surface]),
      borderColor: const Color(0xFFB388FF).withValues(alpha: 0.5),
      child: Row(
        children: [
          const IconBadge(icon: Icons.block_rounded, color: Color(0xFFB388FF), size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remove Ads', style: AppText.h2),
                Text(owned ? 'Active. Thanks for your support!' : 'No more pop-up ads. Bonus videos stay optional.', style: AppText.small),
              ],
            ),
          ),
          owned
              ? const Icon(Icons.verified_rounded, color: AppColors.success, size: 32)
              : GameButton(
                  label: iap.priceOf(ProductIds.removeAds),
                  color: const Color(0xFF7C4DFF),
                  small: true,
                  loading: iap.isPending(ProductIds.removeAds),
                  onTap: () => iap.buy(ProductIds.removeAds),
                ),
        ],
      ),
    );
  }
}
