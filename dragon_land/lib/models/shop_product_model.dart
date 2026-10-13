enum ProductKind { coins, gems, bundle, removeAds }

/// A Google Play in-app product as configured in [ProductConfig].
class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.kind,
    required this.amount,
    required this.title,
    required this.intendedPrice,
    this.gems = 0,
    this.badge,
  });

  final String id;
  final ProductKind kind;

  /// Coins granted (coins / bundle) or gems granted (gems).
  final int amount;

  /// Extra gems granted by bundles.
  final int gems;
  final String title;

  /// Intended price tier; the shop shows the real Google Play price instead.
  final String intendedPrice;
  final String? badge;

  bool get consumable => kind != ProductKind.removeAds;

  int get coinsGranted => kind == ProductKind.coins || kind == ProductKind.bundle ? amount : 0;
  int get gemsGranted => kind == ProductKind.gems ? amount : (kind == ProductKind.bundle ? gems : 0);
}
