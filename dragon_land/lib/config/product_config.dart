import '../models/shop_product_model.dart';

/// Google Play product catalog. Product IDs must match the in-app products you
/// create in Play Console (Monetize > Products > In-app products).
///
/// Prices listed here are only the *intended* tiers used as a fallback label;
/// the shop always displays the localized price returned by Google Play.
class ProductConfig {
  ProductConfig._();

  static const String removeAdsId = 'remove_ads';

  static const List<ShopProduct> coinPacks = [
    ShopProduct(id: 'coins_starter', kind: ProductKind.coins, amount: 250, title: 'Starter Coins', intendedPrice: '\$0.20'),
    ShopProduct(id: 'coins_small', kind: ProductKind.coins, amount: 1500, title: 'Small Coins Pack', intendedPrice: '\$0.99'),
    ShopProduct(
      id: 'coins_medium',
      kind: ProductKind.coins,
      amount: 5000,
      title: 'Medium Coins Pack',
      intendedPrice: '\$2.99',
      badge: 'POPULAR',
    ),
    ShopProduct(id: 'coins_large', kind: ProductKind.coins, amount: 9500, title: 'Large Coins Pack', intendedPrice: '\$4.99'),
    ShopProduct(
      id: 'coins_mega',
      kind: ProductKind.coins,
      amount: 21000,
      title: 'Mega Coins Pack',
      intendedPrice: '\$9.99',
      badge: 'BEST VALUE',
    ),
    ShopProduct(id: 'coins_ultimate', kind: ProductKind.coins, amount: 45000, title: 'Ultimate Coins Pack', intendedPrice: '\$19.99'),
  ];

  static const List<ShopProduct> gemPacks = [
    ShopProduct(id: 'gems_small', kind: ProductKind.gems, amount: 20, title: 'Small Gems Pack', intendedPrice: '\$0.99'),
    ShopProduct(id: 'gems_medium', kind: ProductKind.gems, amount: 65, title: 'Medium Gems Pack', intendedPrice: '\$2.99'),
    ShopProduct(id: 'gems_large', kind: ProductKind.gems, amount: 115, title: 'Large Gems Pack', intendedPrice: '\$4.99', badge: 'POPULAR'),
    ShopProduct(id: 'gems_premium', kind: ProductKind.gems, amount: 250, title: 'Premium Gems Pack', intendedPrice: '\$9.99'),
    ShopProduct(
      id: 'gems_ultimate',
      kind: ProductKind.gems,
      amount: 550,
      title: 'Ultimate Gems Pack',
      intendedPrice: '\$19.99',
      badge: 'BEST VALUE',
    ),
  ];

  static const List<ShopProduct> specialOffers = [
    ShopProduct(
      id: 'bundle_dragon_starter',
      kind: ProductKind.bundle,
      amount: 3000,
      gems: 30,
      title: 'Dragon Starter Bundle',
      intendedPrice: '\$1.99',
      badge: 'SPECIAL',
    ),
  ];

  static const ShopProduct removeAds = ShopProduct(
    id: removeAdsId,
    kind: ProductKind.removeAds,
    amount: 0,
    title: 'Remove Ads',
    intendedPrice: '\$3.99',
  );

  static List<ShopProduct> get all => [...coinPacks, ...gemPacks, ...specialOffers, removeAds];

  static ShopProduct? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Optional HTTPS endpoint for server-side purchase verification.
  ///
  /// When empty, purchases are validated locally (status, known product id and
  /// non-empty Google Play purchase token). For production, deploy a backend
  /// that calls the Google Play Developer API (purchases.products.get) with a
  /// service account, and put its URL here. Never ship service-account
  /// credentials inside the app.
  static const String verificationEndpoint = '';
}
