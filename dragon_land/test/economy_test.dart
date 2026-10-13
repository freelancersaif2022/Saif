import 'package:dragon_land/config/economy_config.dart';
import 'package:dragon_land/config/product_config.dart';
import 'package:dragon_land/models/player_progress_model.dart';
import 'package:dragon_land/services/progress_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dragon purchases', () {
    test('Ember is unlocked and equipped by default', () {
      final p = ProgressController.memory();
      expect(p.isUnlocked('ember'), isTrue);
      expect(p.selectedDragon.id, 'ember');
      for (final id in ['aqua', 'shadow', 'leaf', 'solar']) {
        expect(p.isUnlocked(id), isFalse);
      }
    });

    test('prices come from the economy config', () {
      expect(ProgressController.priceOf('aqua'), 2000);
      expect(ProgressController.priceOf('shadow'), 5000);
      expect(ProgressController.priceOf('leaf'), 8000);
      expect(ProgressController.priceOf('solar'), 15000);
      expect(ProgressController.priceOf('aqua'), EconomyConfig.dragonPrices['aqua']);
    });

    test('purchase deducts exactly once and unlocks', () {
      final p = ProgressController.memory(PlayerProgress()..coins = 2500);
      expect(p.purchaseDragon('aqua'), DragonPurchaseResult.success);
      expect(p.coins, 500);
      expect(p.isUnlocked('aqua'), isTrue);
      // repeated taps never deduct again
      expect(p.purchaseDragon('aqua'), DragonPurchaseResult.alreadyOwned);
      expect(p.purchaseDragon('aqua'), DragonPurchaseResult.alreadyOwned);
      expect(p.coins, 500);
    });

    test('insufficient coins never goes negative', () {
      final p = ProgressController.memory(PlayerProgress()..coins = 4999);
      expect(p.purchaseDragon('shadow'), DragonPurchaseResult.insufficientCoins);
      expect(p.coins, 4999);
      expect(p.isUnlocked('shadow'), isFalse);
    });

    test('only unlocked dragons can be equipped', () {
      final p = ProgressController.memory(PlayerProgress()..coins = 20000);
      expect(p.selectDragon('solar'), isFalse);
      expect(p.purchaseDragon('solar'), DragonPurchaseResult.success);
      expect(p.selectDragon('solar'), isTrue);
      expect(p.selectedDragon.id, 'solar');
    });

    test('all five dragons are unlockable with gameplay coins', () {
      final total = EconomyConfig.dragonPrices.values.fold<int>(0, (a, b) => a + b);
      final p = ProgressController.memory(PlayerProgress()..coins = total);
      for (final id in ['aqua', 'shadow', 'leaf', 'solar']) {
        expect(p.purchaseDragon(id), DragonPurchaseResult.success);
      }
      expect(p.coins, 0);
      expect(p.data.unlockedDragons.length, 5);
    });
  });

  group('Store grants', () {
    test('a purchase id is granted only once', () async {
      final p = ProgressController.memory();
      final pack = ProductConfig.byId('coins_medium')!;
      expect(await p.grantStorePurchase('GPA.1', pack), isTrue);
      expect(await p.grantStorePurchase('GPA.1', pack), isFalse);
      expect(p.coins, pack.amount);
      expect(await p.grantStorePurchase('GPA.2', pack), isTrue);
      expect(p.coins, pack.amount * 2);
    });

    test('bundles grant coins and gems; gem packs grant gems', () async {
      final p = ProgressController.memory();
      await p.grantStorePurchase('a', ProductConfig.byId('bundle_dragon_starter')!);
      await p.grantStorePurchase('b', ProductConfig.byId('gems_small')!);
      expect(p.coins, 3000);
      expect(p.gems, 30 + 20);
    });

    test('remove ads is a persistent entitlement', () async {
      final p = ProgressController.memory();
      expect(p.adsRemoved, isFalse);
      await p.grantStorePurchase('x', ProductConfig.removeAds);
      expect(p.adsRemoved, isTrue);
      // restore of the same entitlement is harmless
      await p.grantStorePurchase('x', ProductConfig.removeAds);
      expect(p.adsRemoved, isTrue);
      final restored = PlayerProgress.fromJson(p.data.toJson());
      expect(restored.removeAds, isTrue);
    });
  });

  group('Gem exchange', () {
    test('exchange requires enough gems', () {
      final p = ProgressController.memory(PlayerProgress()..gems = 9);
      final offer = EconomyConfig.gemExchanges.first;
      expect(p.exchangeGems(offer), isFalse);
      p.addGems(1);
      expect(p.exchangeGems(offer), isTrue);
      expect(p.gems, 0);
      expect(p.coins, offer.coins);
    });
  });
}
