import 'package:flutter/material.dart';

import '../../config/monetization_config.dart';
import '../../screens/test_checkout_sheet.dart';
import '../../widgets/feedback.dart';
import '../game_store.dart';
import '../sfx.dart';
import 'iap_backend.dart';
import 'iap_backend_stub.dart' if (dart.library.io) 'iap_backend_play.dart' as backend;

class ProductInfo {
  const ProductInfo(this.id, this.title, this.subtitle, this.fallbackPrice);
  final String id;
  final String title;
  final String subtitle;
  final String fallbackPrice;
}

/// Google Play Billing wrapper. Delivers items locally (no server).
class IapService extends ChangeNotifier {
  IapService._();
  static final IapService instance = IapService._();

  static const catalog = <String, ProductInfo>{
    ProductIds.removeAds: ProductInfo(ProductIds.removeAds, 'Remove Ads', 'No more interstitial ads. Forever.', '\$2.99'),
    ProductIds.starterPack: ProductInfo(ProductIds.starterPack, 'Starter Pack', '150 gems • 3 evolution stones • +1 monster slot', '\$1.99'),
    ProductIds.gemsSmall: ProductInfo(ProductIds.gemsSmall, 'Pouch of Gems', '80 gems', '\$0.99'),
    ProductIds.gemsMedium: ProductInfo(ProductIds.gemsMedium, 'Chest of Gems', '500 gems • Best seller', '\$4.99'),
    ProductIds.gemsLarge: ProductInfo(ProductIds.gemsLarge, 'Vault of Gems', '1200 gems • Best value', '\$9.99'),
  };

  final IapBackend _backend = backend.createIapBackend();
  late GameStore _store;
  bool storeReady = false;
  String? _pending;

  Future<void> init(GameStore store) async {
    _store = store;
    storeReady = await _backend.init(
      productIds: ProductIds.all,
      onGranted: _deliver,
      onError: (msg) {
        _pending = null;
        notifyListeners();
        AppToast.show(msg, type: ToastType.error, title: 'Purchase failed');
      },
      onCanceled: () {
        _pending = null;
        notifyListeners();
        AppToast.show('Purchase canceled. You were not charged.', type: ToastType.info);
      },
    );
    notifyListeners();
  }

  bool isPending(String id) => _pending == id;

  String priceOf(String id) => _backend.products[id]?.price ?? catalog[id]!.fallbackPrice;

  bool isOwned(String id) => switch (id) {
    ProductIds.removeAds => _store.removeAds,
    ProductIds.starterPack => _store.starterPackOwned,
    _ => false,
  };

  Future<void> buy(String id) async {
    if (isOwned(id)) {
      AppToast.show('You already own this.', type: ToastType.info);
      return;
    }
    if (_pending != null) return;
    final consumable = ProductIds.consumables.contains(id);

    if (_backend.available && _backend.products.containsKey(id)) {
      _pending = id;
      notifyListeners();
      final started = await _backend.buy(id, consumable: consumable);
      if (!started) {
        _pending = null;
        notifyListeners();
        AppToast.show('Could not open Google Play. Try again.', type: ToastType.error);
      }
      return;
    }

    if (MonetizationConfig.testMode) {
      final ok = await TestCheckoutSheet.open(catalog[id]!, priceOf(id));
      if (ok) _deliver(id, false);
      return;
    }

    AppToast.show('The store is unavailable. Connect to the internet and make sure Google Play is signed in.', type: ToastType.error, title: 'Store offline');
  }

  Future<void> restore() async {
    if (_backend.available) {
      await _backend.restore();
      AppToast.show('Checking your purchases…', type: ToastType.info);
    } else {
      AppToast.show('Connect to the internet to restore purchases.', type: ToastType.error, title: 'Store offline');
    }
  }

  void _deliver(String id, bool restored) {
    _pending = null;
    final wasOwned = isOwned(id);
    _store.grantProduct(id);
    notifyListeners();
    if (restored && wasOwned) return;
    Sfx.play(Fx.coin);
    final info = catalog[id];
    AppToast.show(
      restored ? '${info?.title ?? id} restored.' : '${info?.title ?? id} delivered. Thank you for supporting VoiceBeast!',
      type: ToastType.reward,
      title: restored ? 'Restored' : 'Purchase complete',
    );
  }
}
