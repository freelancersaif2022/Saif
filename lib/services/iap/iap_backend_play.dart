import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_backend.dart';

IapBackend createIapBackend() => _PlayBackend();

class _PlayBackend implements IapBackend {
  final InAppPurchase _iap = InAppPurchase.instance;
  final Map<String, ProductDetails> _details = {};
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _available = false;

  @override
  bool get available => _available && _details.isNotEmpty;

  @override
  Map<String, StoreProduct> get products => {for (final d in _details.values) d.id: StoreProduct(d.id, d.price)};

  @override
  Future<bool> init({
    required Set<String> productIds,
    required void Function(String productId, bool restored) onGranted,
    required void Function(String message) onError,
    required void Function() onCanceled,
  }) async {
    await _sub?.cancel();
    try {
      _sub = _iap.purchaseStream.listen((purchases) async {
        for (final p in purchases) {
          switch (p.status) {
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
              onGranted(p.productID, p.status == PurchaseStatus.restored);
            case PurchaseStatus.error:
              onError(p.error?.message ?? 'Purchase failed. You were not charged.');
            case PurchaseStatus.canceled:
              onCanceled();
            case PurchaseStatus.pending:
              break;
          }
          if (p.pendingCompletePurchase) {
            await _iap.completePurchase(p);
          }
        }
      }, onError: (Object e) => onError('Store error. Please try again.'));

      _available = await _iap.isAvailable().timeout(const Duration(seconds: 6), onTimeout: () => false);
      if (!_available) return false;
      final res = await _iap.queryProductDetails(productIds).timeout(const Duration(seconds: 10));
      for (final d in res.productDetails) {
        _details[d.id] = d;
      }
      if (res.notFoundIDs.isNotEmpty) debugPrint('IAP products not found in Play Console: ${res.notFoundIDs}');
      return available;
    } catch (e) {
      debugPrint('IAP init failed: $e');
      _available = false;
      return false;
    }
  }

  @override
  Future<bool> buy(String productId, {required bool consumable}) async {
    final d = _details[productId];
    if (d == null) return false;
    final param = PurchaseParam(productDetails: d);
    try {
      return consumable ? await _iap.buyConsumable(purchaseParam: param) : await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('IAP buy failed: $e');
      return false;
    }
  }

  @override
  Future<void> restore() => _iap.restorePurchases();
}
