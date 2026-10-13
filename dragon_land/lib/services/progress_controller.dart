import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/economy_config.dart';
import '../models/dragon_model.dart';
import '../models/player_progress_model.dart';
import '../models/shop_product_model.dart';
import 'storage_service.dart';

enum DragonPurchaseResult { success, alreadyOwned, insufficientCoins, unknownDragon }

/// Single source of truth for persistent player state. All mutations go
/// through this class, which validates them, notifies listeners and persists.
class ProgressController extends ChangeNotifier {
  ProgressController(this._storage) : _p = _storage?.load() ?? PlayerProgress();

  /// In-memory controller (tests).
  ProgressController.memory([PlayerProgress? initial]) : _storage = null, _p = initial ?? PlayerProgress();

  final StorageService? _storage;
  final PlayerProgress _p;
  Future<void> _pendingSave = Future.value();

  PlayerProgress get data => _p;
  int get coins => _p.coins;
  int get gems => _p.gems;
  GameSettings get settings => _p.settings;
  DragonDef get selectedDragon => Dragons.byId(_p.selectedDragon);
  bool isUnlocked(String dragonId) => _p.unlockedDragons.contains(dragonId);
  bool get adsRemoved => _p.removeAds;

  /// Persists the current state. Calls are serialized so writes never interleave.
  Future<void> save() {
    final storage = _storage;
    if (storage == null) return Future.value();
    _pendingSave = _pendingSave.then((_) => storage.save(_p)).catchError((Object e) {
      debugPrint('ProgressController: save failed: $e');
    });
    return _pendingSave;
  }

  void _commit() {
    notifyListeners();
    unawaited(save());
  }

  // --------------------------------------------------------------- currency
  void addCoins(int amount, {bool countAsEarned = true}) {
    if (amount <= 0) return;
    _p.coins += amount;
    if (countAsEarned) _p.totalCoinsEarned += amount;
    _commit();
  }

  bool spendCoins(int amount) {
    if (amount <= 0 || _p.coins < amount) return false;
    _p.coins -= amount;
    _commit();
    return true;
  }

  void addGems(int amount) {
    if (amount <= 0) return;
    _p.gems += amount;
    _commit();
  }

  bool spendGems(int amount) {
    if (amount <= 0 || _p.gems < amount) return false;
    _p.gems -= amount;
    _commit();
    return true;
  }

  bool exchangeGems(GemExchangeOffer offer) {
    if (_p.gems < offer.gems) return false;
    _p.gems -= offer.gems;
    _p.coins += offer.coins;
    _commit();
    return true;
  }

  // ---------------------------------------------------------------- dragons
  static int priceOf(String dragonId) => EconomyConfig.dragonPrices[dragonId] ?? 0;

  /// Unlocks a dragon with coins. The check-and-deduct is synchronous, so a
  /// rapid double tap can never deduct twice or unlock twice.
  DragonPurchaseResult purchaseDragon(String dragonId) {
    if (!Dragons.all.any((d) => d.id == dragonId)) return DragonPurchaseResult.unknownDragon;
    if (_p.unlockedDragons.contains(dragonId)) return DragonPurchaseResult.alreadyOwned;
    final price = priceOf(dragonId);
    if (_p.coins < price) return DragonPurchaseResult.insufficientCoins;
    _p.coins -= price;
    _p.unlockedDragons.add(dragonId);
    _commit();
    return DragonPurchaseResult.success;
  }

  bool selectDragon(String dragonId) {
    if (!_p.unlockedDragons.contains(dragonId)) return false;
    if (_p.selectedDragon == dragonId) return true;
    _p.selectedDragon = dragonId;
    _commit();
    return true;
  }

  // -------------------------------------------------------------- purchases
  bool hasProcessedPurchase(String purchaseId) => _p.processedPurchaseIds.contains(purchaseId);

  /// Grants a verified store purchase exactly once per [purchaseId].
  /// Returns false when the purchase was already granted.
  Future<bool> grantStorePurchase(String purchaseId, ShopProduct product) async {
    if (product.kind == ProductKind.removeAds) {
      final changed = !_p.removeAds;
      _p.removeAds = true;
      if (!_p.processedPurchaseIds.contains(purchaseId)) _p.processedPurchaseIds.add(purchaseId);
      notifyListeners();
      await save();
      return changed;
    }
    if (_p.processedPurchaseIds.contains(purchaseId)) return false;
    _p.processedPurchaseIds.add(purchaseId);
    if (_p.processedPurchaseIds.length > 500) {
      _p.processedPurchaseIds.removeRange(0, _p.processedPurchaseIds.length - 500);
    }
    _p.coins += product.coinsGranted;
    _p.gems += product.gemsGranted;
    notifyListeners();
    await save();
    return true;
  }

  void setRemoveAds(bool value) {
    if (_p.removeAds == value) return;
    _p.removeAds = value;
    _commit();
  }

  // --------------------------------------------------------------- settings
  void updateSettings(void Function(GameSettings s) change) {
    change(_p.settings);
    _commit();
  }

  /// Generic mutation hook for systems (rewards, run results) that need to
  /// change several fields atomically.
  void mutate(void Function(PlayerProgress p) change) {
    change(_p);
    _commit();
  }
}
