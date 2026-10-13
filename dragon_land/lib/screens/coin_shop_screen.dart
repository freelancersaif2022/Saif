import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../config/economy_config.dart';
import '../config/product_config.dart';
import '../models/shop_product_model.dart';
import '../services/audio_service.dart';
import '../services/purchase_service.dart';
import '../widgets/coin_counter.dart';
import '../widgets/currency_icons.dart';
import '../widgets/game_button.dart';
import '../widgets/panel.dart';

/// Coins / Gems / Special Offers / Remove Ads shop backed by Google Play
/// Billing. Buttons only *start* a purchase; rewards are granted by
/// [PurchaseService] after Google Play confirms it.
class CoinShopScreen extends StatefulWidget {
  const CoinShopScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<CoinShopScreen> createState() => _CoinShopScreenState();
}

class _CoinShopScreenState extends State<CoinShopScreen> {
  late int _tab = widget.initialTab;
  StreamSubscription<PurchaseEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return;
    final s = AppScope.of(context);
    _sub = s.purchases.events.listen((e) {
      if (!mounted) return;
      final p = ProductConfig.byId(e.productId);
      switch (e.kind) {
        case PurchaseEventKind.pending:
          showMessage(context, 'Purchase pending. Rewards arrive once Google Play confirms payment.');
        case PurchaseEventKind.granted:
          s.audio.play(Sfx.purchase);
          if (p?.kind == ProductKind.removeAds) s.ads.onRemoveAdsChanged();
          showMessage(context, '${p?.title ?? 'Purchase'} delivered. Thank you!');
        case PurchaseEventKind.restored:
          if (p?.kind == ProductKind.removeAds) s.ads.onRemoveAdsChanged();
          showMessage(context, '${p?.title ?? 'Purchase'} restored.');
        case PurchaseEventKind.alreadyGranted:
          showMessage(context, 'This purchase was already delivered.');
        case PurchaseEventKind.cancelled:
          showMessage(context, 'Purchase cancelled.', good: false);
        case PurchaseEventKind.failed:
          showMessage(context, 'Purchase failed${e.message != null ? ': ${e.message}' : ''}.', good: false);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const tabs = ['COINS', 'GEMS', 'SPECIAL OFFERS', 'REMOVE ADS'];
    return MenuScaffold(
      title: 'SHOP',
      child: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GameButton(
                      label: tabs[i],
                      height: 42,
                      fontSize: 16,
                      cooldown: Duration.zero,
                      color: i == _tab ? AppColors.orange : const Color(0xFF7D86A6),
                      onPressed: () => setState(() => _tab = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([s.purchases, s.progress]),
              builder: (context, _) => switch (_tab) {
                0 => const _ProductRow(products: ProductConfig.coinPacks),
                1 => const _ProductRow(products: ProductConfig.gemPacks),
                2 => _SpecialOffers(),
                _ => _RemoveAds(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreNotice extends StatelessWidget {
  const _StoreNotice();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.purchases;
    if (p.state == StoreState.ready && p.notFoundIds.isEmpty) return const SizedBox.shrink();
    final text = switch (p.state) {
      StoreState.initializing => 'Connecting to Google Play...',
      StoreState.unavailable => p.storeError ?? 'Store unavailable.',
      StoreState.ready => 'Some products are not available in your region yet.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(text, style: AppText.label(14), overflow: TextOverflow.ellipsis),
          ),
          if (p.state != StoreState.initializing) ...[
            const SizedBox(width: 10),
            GameButton(
              label: 'RETRY',
              height: 34,
              fontSize: 14,
              color: AppColors.skyDeep,
              onPressed: () => p.state == StoreState.ready ? p.refreshProducts() : p.init(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.products});
  final List<ShopProduct> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StoreNotice(),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            children: [for (final p in products) _ProductCard(product: p)],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final details = s.purchases.details(product.id);
    final busy = s.purchases.isBusy(product.id);
    final gem = product.kind == ProductKind.gems;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 170,
        child: CartoonPanel(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            children: [
              if (product.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(10)),
                  child: Text(product.badge!, style: AppText.title(12)),
                )
              else
                const SizedBox(height: 18),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  product.title,
                  style: AppText.label(14, color: AppColors.ink, weight: FontWeight.w700),
                  maxLines: 1,
                ),
              ),
              Expanded(child: FittedBox(child: gem ? const GemIcon(size: 64) : const CoinIcon(size: 64))),
              Text(formatNumber(product.amount), style: AppText.title(26, color: gem ? AppColors.purple : AppColors.goldDark)),
              Text(gem ? 'gems' : 'coins', style: AppText.label(12, color: AppColors.ink)),
              const SizedBox(height: 6),
              GameButton(
                label: busy ? '...' : (details?.price ?? 'UNAVAILABLE'),
                color: AppColors.grass,
                height: 42,
                fontSize: 16,
                width: 150,
                cooldown: const Duration(seconds: 2),
                onPressed: details == null || busy ? null : () => s.purchases.buy(product),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialOffers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        const _StoreNotice(),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            children: [
              for (final p in ProductConfig.specialOffers)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 230,
                    child: CartoonPanel(
                      color: const Color(0xFFFFF0C8),
                      child: Column(
                        children: [
                          Text(
                            p.title,
                            style: AppText.title(20, color: AppColors.orange),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CoinIcon(size: 40),
                              Text(' ${formatNumber(p.amount)}', style: AppText.title(24, color: AppColors.goldDark)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const GemIcon(size: 36),
                              Text(' ${formatNumber(p.gems)}', style: AppText.title(24, color: AppColors.purple)),
                            ],
                          ),
                          const Spacer(),
                          GameButton(
                            label: s.purchases.isBusy(p.id) ? '...' : (s.purchases.details(p.id)?.price ?? 'UNAVAILABLE'),
                            color: AppColors.grass,
                            height: 44,
                            width: 190,
                            fontSize: 17,
                            cooldown: const Duration(seconds: 2),
                            onPressed: s.purchases.details(p.id) == null || s.purchases.isBusy(p.id) ? null : () => s.purchases.buy(p),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              for (final o in EconomyConfig.gemExchanges)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 190,
                    child: CartoonPanel(
                      child: Column(
                        children: [
                          Text('Gem Exchange', style: AppText.title(18, color: AppColors.purple)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const GemIcon(size: 30),
                              Text(' ${o.gems}', style: AppText.title(22, color: AppColors.purple)),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.ink),
                              const CoinIcon(size: 30),
                              Text(' ${formatNumber(o.coins)}', style: AppText.title(22, color: AppColors.goldDark)),
                            ],
                          ),
                          const Spacer(),
                          GameButton(
                            label: 'EXCHANGE',
                            color: AppColors.purple,
                            height: 42,
                            fontSize: 16,
                            width: 160,
                            cooldown: const Duration(seconds: 1),
                            onPressed: s.progress.gems >= o.gems
                                ? () {
                                    if (s.progress.exchangeGems(o)) {
                                      s.audio.play(Sfx.purchase);
                                      showMessage(context, '+${formatNumber(o.coins)} coins!');
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RemoveAds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final owned = s.progress.adsRemoved;
    final details = s.purchases.details(ProductConfig.removeAdsId);
    return Column(
      children: [
        const _StoreNotice(),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 460,
              child: CartoonPanel(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block_rounded, size: 40, color: AppColors.red),
                      Text('REMOVE ADS', style: AppText.title(28, color: AppColors.orange)),
                      const SizedBox(height: 6),
                      Text(
                        'Removes all banner and interstitial (full-screen) ads forever. '
                        'Optional reward videos you choose to watch (free coins, revive, double coins) stay available.',
                        style: AppText.label(14, color: AppColors.ink, weight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (owned)
                        Text('PURCHASED — THANK YOU!', style: AppText.title(20, color: AppColors.grassDark))
                      else
                        GameButton(
                          label: s.purchases.isBusy(ProductConfig.removeAdsId) ? '...' : (details?.price ?? 'UNAVAILABLE'),
                          color: AppColors.grass,
                          width: 220,
                          cooldown: const Duration(seconds: 2),
                          onPressed: details == null || s.purchases.isBusy(ProductConfig.removeAdsId)
                              ? null
                              : () => s.purchases.buy(ProductConfig.removeAds),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: s.purchases.state == StoreState.ready
                            ? () {
                                s.purchases.restore();
                                showMessage(context, 'Restoring purchases...');
                              }
                            : null,
                        child: Text('Restore purchases', style: AppText.label(14, color: AppColors.skyDeep)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
