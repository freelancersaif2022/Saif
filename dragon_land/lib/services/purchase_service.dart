import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/product_config.dart';
import '../models/shop_product_model.dart';
import 'progress_controller.dart';

enum StoreState { initializing, ready, unavailable }

/// Result of a purchase flow surfaced to the UI as a one-off event.
class PurchaseEvent {
  const PurchaseEvent(this.productId, this.kind, [this.message]);
  final String productId;
  final PurchaseEventKind kind;
  final String? message;
}

enum PurchaseEventKind { pending, granted, alreadyGranted, restored, cancelled, failed }

/// Google Play Billing via the official `in_app_purchase` plugin.
///
/// Flow: the UI calls [buy]; nothing is granted there. Grants only happen in
/// [_onPurchaseUpdates] after the store reports `purchased` / `restored` and
/// the purchase passes [_verify]. Each grant is keyed by the store purchase ID
/// so a purchase redelivered by the store (app restart, restore, network
/// retry) is never granted twice. `completePurchase` is called after the grant
/// is persisted, so an interrupted grant is redelivered on the next launch.
class PurchaseService extends ChangeNotifier {
  PurchaseService(this._progress, {this.enabled = true});

  final ProgressController _progress;
  final bool enabled;

  InAppPurchase? _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _details = {};
  final Set<String> _inFlight = {};
  final _events = StreamController<PurchaseEvent>.broadcast();

  StoreState state = StoreState.initializing;
  String? storeError;
  Set<String> notFoundIds = {};

  Stream<PurchaseEvent> get events => _events.stream;
  ProductDetails? details(String id) => _details[id];
  bool isBusy(String id) => _inFlight.contains(id);
  bool get anyBusy => _inFlight.isNotEmpty;

  Future<void> init() async {
    if (!enabled || kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      state = StoreState.unavailable;
      storeError = 'Store not supported on this platform.';
      notifyListeners();
      return;
    }
    try {
      final iap = InAppPurchase.instance;
      _iap = iap;
      // Subscribe first so purchases delivered at startup are not missed.
      _sub = iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onError: (Object e) {
          debugPrint('PurchaseService stream error: $e');
        },
      );
      final available = await iap.isAvailable();
      if (!available) {
        state = StoreState.unavailable;
        storeError = 'Google Play Store is not available.';
        notifyListeners();
        return;
      }
      await refreshProducts();
    } catch (e) {
      state = StoreState.unavailable;
      storeError = 'Store error: $e';
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    final iap = _iap;
    if (iap == null) return;
    final ids = ProductConfig.all.map((p) => p.id).toSet();
    final resp = await iap.queryProductDetails(ids);
    _details
      ..clear()
      ..addEntries(resp.productDetails.map((d) => MapEntry(d.id, d)));
    notFoundIds = resp.notFoundIDs.toSet();
    if (resp.error != null) storeError = resp.error!.message;
    state = StoreState.ready;
    notifyListeners();
  }

  /// Starts the Google Play purchase sheet. Returns false if it could not start.
  Future<bool> buy(ShopProduct product) async {
    final iap = _iap;
    final d = _details[product.id];
    if (iap == null || d == null || _inFlight.contains(product.id)) return false;
    _inFlight.add(product.id);
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: d);
      final started = product.consumable
          ? await iap.buyConsumable(purchaseParam: param, autoConsume: true)
          : await iap.buyNonConsumable(purchaseParam: param);
      if (!started) {
        _inFlight.remove(product.id);
        notifyListeners();
      }
      return started;
    } catch (e) {
      _inFlight.remove(product.id);
      notifyListeners();
      _events.add(PurchaseEvent(product.id, PurchaseEventKind.failed, '$e'));
      return false;
    }
  }

  Future<void> restore() async {
    final iap = _iap;
    if (iap == null) return;
    await iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> updates) async {
    for (final pd in updates) {
      final product = ProductConfig.byId(pd.productID);
      switch (pd.status) {
        case PurchaseStatus.pending:
          _events.add(PurchaseEvent(pd.productID, PurchaseEventKind.pending));
          continue; // keep in-flight; wait for the final state
        case PurchaseStatus.canceled:
          _events.add(PurchaseEvent(pd.productID, PurchaseEventKind.cancelled));
        case PurchaseStatus.error:
          _events.add(PurchaseEvent(pd.productID, PurchaseEventKind.failed, pd.error?.message));
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (product == null) {
            _events.add(PurchaseEvent(pd.productID, PurchaseEventKind.failed, 'Unknown product'));
          } else if (await _verify(pd, product)) {
            final id = _purchaseKey(pd);
            final granted = await _progress.grantStorePurchase(id, product);
            _events.add(
              PurchaseEvent(
                pd.productID,
                pd.status == PurchaseStatus.restored
                    ? PurchaseEventKind.restored
                    : (granted ? PurchaseEventKind.granted : PurchaseEventKind.alreadyGranted),
              ),
            );
          } else {
            _events.add(PurchaseEvent(pd.productID, PurchaseEventKind.failed, 'Purchase could not be verified'));
            // Do not complete: an unverified purchase is left for Google Play to refund.
            _inFlight.remove(pd.productID);
            continue;
          }
      }
      if (pd.pendingCompletePurchase) {
        try {
          await _iap?.completePurchase(pd);
        } catch (e) {
          debugPrint('PurchaseService: completePurchase failed: $e');
        }
      }
      _inFlight.remove(pd.productID);
    }
    notifyListeners();
  }

  String _purchaseKey(PurchaseDetails pd) {
    final id = pd.purchaseID;
    if (id != null && id.isNotEmpty) return id;
    return 'token:${pd.verificationData.serverVerificationData}';
  }

  /// Verifies a purchase. With [ProductConfig.verificationEndpoint] set, the
  /// purchase token is checked by your backend (which must call the Google
  /// Play Developer API and keep its own idempotency records). Otherwise basic
  /// local checks are applied.
  Future<bool> _verify(PurchaseDetails pd, ShopProduct product) async {
    final token = pd.verificationData.serverVerificationData;
    if (token.isEmpty || pd.productID != product.id) return false;
    final endpoint = ProductConfig.verificationEndpoint;
    if (endpoint.isEmpty) return true;
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      final req = await client.postUrl(Uri.parse(endpoint));
      req.headers.contentType = ContentType.json;
      req.write(
        jsonEncode({
          'packageName': 'com.moixlimited.dragonland',
          'productId': pd.productID,
          'purchaseToken': token,
          'purchaseId': pd.purchaseID,
          'source': pd.verificationData.source,
        }),
      );
      final resp = await req.close().timeout(const Duration(seconds: 15));
      final body = await resp.transform(utf8.decoder).join();
      client.close();
      if (resp.statusCode != 200) return false;
      final json = jsonDecode(body);
      return json is Map && json['valid'] == true;
    } catch (e) {
      debugPrint('PurchaseService: verification failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _events.close();
    super.dispose();
  }
}
