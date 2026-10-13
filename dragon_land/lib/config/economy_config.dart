/// Central economy configuration. Every price and reward in the game is read
/// from here so balancing never requires touching gameplay or UI code.
class EconomyConfig {
  EconomyConfig._();

  // ----------------------------------------------------------- dragon prices
  /// Unlock price (coins) per dragon id. A price of 0 means unlocked by default.
  static const Map<String, int> dragonPrices = {'ember': 0, 'aqua': 2000, 'shadow': 5000, 'leaf': 8000, 'solar': 15000};

  // ------------------------------------------------------- in-run pickups
  static const int coinValue = 1;
  static const int coinClusterMin = 5;
  static const int coinClusterMax = 10;
  static const int gemPickupValue = 1;
  static const int treasureChestCoins = 60;
  static const int treasureChestCoinsPerKm = 20;

  /// Chance (0..1) that a treasure chest also contains a gem.
  static const double treasureChestGemChance = 0.35;
  static const int crystalCoinDrop = 3;
  static const int bossCoinReward = 150;
  static const int bossGemReward = 3;

  /// Coins dropped when an enemy type is defeated.
  static const Map<String, int> enemyCoinDrops = {'slime': 2, 'bat': 3, 'stone': 6, 'goblin': 5, 'boss': bossCoinReward};

  // ----------------------------------------------------- ad based rewards
  static const int freeCoinsAdReward = 100;
  static const Duration freeCoinsCooldown = Duration(minutes: 5);
  static const int freeCoinsDailyLimit = 10;
  static const int bonusChestAdCoinsMin = 80;
  static const int bonusChestAdCoinsMax = 200;

  // ----------------------------------------------------- gem conveniences
  static const int gemReviveCost = 5;

  /// Gem -> coin exchange offers shown on the Special Offers tab.
  static const List<GemExchangeOffer> gemExchanges = [
    GemExchangeOffer(id: 'exchange_small', gems: 10, coins: 1000),
    GemExchangeOffer(id: 'exchange_medium', gems: 45, coins: 5000),
    GemExchangeOffer(id: 'exchange_large', gems: 120, coins: 15000),
  ];

  // ----------------------------------------------------------- daily rewards
  static const List<DailyRewardDef> dailyRewards = [
    DailyRewardDef(day: 1, coins: 100),
    DailyRewardDef(day: 2, coins: 150),
    DailyRewardDef(day: 3, coins: 250),
    DailyRewardDef(day: 4, coins: 350),
    DailyRewardDef(day: 5, coins: 500),
    DailyRewardDef(day: 6, coins: 750),
    DailyRewardDef(day: 7, coins: 1000, gems: 5),
  ];

  // ---------------------------------------------------------- score values
  static const int scorePerMeter = 1;
  static const int scorePerCoin = 5;
  static const int scorePerEnemy = 50;
  static const int scorePerBoss = 1000;
  static const int scorePerCrystal = 20;
}

class GemExchangeOffer {
  const GemExchangeOffer({required this.id, required this.gems, required this.coins});
  final String id;
  final int gems;
  final int coins;
}

class DailyRewardDef {
  const DailyRewardDef({required this.day, required this.coins, this.gems = 0});
  final int day;
  final int coins;
  final int gems;
}
