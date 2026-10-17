class StoreProduct {
  const StoreProduct(this.id, this.price);
  final String id;
  final String price;
}

/// Contract for the real Google Play Billing backend and the web/no-op stub.
abstract class IapBackend {
  /// [onGranted] fires for every purchase (or restore) that should be delivered.
  /// [onError] fires with a user-facing message.
  Future<bool> init({
    required Set<String> productIds,
    required void Function(String productId, bool restored) onGranted,
    required void Function(String message) onError,
    required void Function() onCanceled,
  });

  Map<String, StoreProduct> get products;
  bool get available;
  Future<bool> buy(String productId, {required bool consumable});
  Future<void> restore();
}
