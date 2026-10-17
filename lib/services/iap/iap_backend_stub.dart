import 'iap_backend.dart';

IapBackend createIapBackend() => _NoStore();

class _NoStore implements IapBackend {
  @override
  Future<bool> init({
    required Set<String> productIds,
    required void Function(String productId, bool restored) onGranted,
    required void Function(String message) onError,
    required void Function() onCanceled,
  }) async => false;

  @override
  Map<String, StoreProduct> get products => const {};
  @override
  bool get available => false;
  @override
  Future<bool> buy(String productId, {required bool consumable}) async => false;
  @override
  Future<void> restore() async {}
}
