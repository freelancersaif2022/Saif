import 'mission_model.dart';

enum GraphicsQuality { low, medium, high }

class GameSettings {
  GameSettings({
    this.music = true,
    this.sound = true,
    this.vibration = true,
    this.musicVolume = 0.6,
    this.soundVolume = 0.9,
    this.graphics = GraphicsQuality.high,
    this.leftHanded = false,
  });

  bool music;
  bool sound;
  bool vibration;
  double musicVolume;
  double soundVolume;
  GraphicsQuality graphics;

  /// Swaps the movement and action control clusters.
  bool leftHanded;

  Map<String, dynamic> toJson() => {
    'music': music,
    'sound': sound,
    'vibration': vibration,
    'musicVolume': musicVolume,
    'soundVolume': soundVolume,
    'graphics': graphics.name,
    'leftHanded': leftHanded,
  };

  factory GameSettings.fromJson(Map<String, dynamic> j) => GameSettings(
    music: j['music'] as bool? ?? true,
    sound: j['sound'] as bool? ?? true,
    vibration: j['vibration'] as bool? ?? true,
    musicVolume: (j['musicVolume'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0.6,
    soundVolume: (j['soundVolume'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0.9,
    graphics: GraphicsQuality.values.firstWhere((g) => g.name == j['graphics'], orElse: () => GraphicsQuality.high),
    leftHanded: j['leftHanded'] as bool? ?? false,
  );
}

/// Everything that persists between launches.
class PlayerProgress {
  PlayerProgress();

  static const int schemaVersion = 1;

  int coins = 0;
  int gems = 0;
  Set<String> unlockedDragons = {'ember'};
  String selectedDragon = 'ember';

  // statistics
  int bestScore = 0;
  int bestDistance = 0;
  int totalCoinsEarned = 0;
  int totalRuns = 0;
  int totalEnemiesDefeated = 0;
  int totalDistance = 0;

  // monetisation
  bool removeAds = false;

  /// Purchase IDs already granted, used to keep consumable grants idempotent.
  List<String> processedPurchaseIds = [];
  int runsSinceInterstitial = 0;

  // daily rewards
  /// Local date (yyyy-mm-dd) of the last daily reward claim.
  String? lastDailyClaim;

  /// Day index (1..7) that was claimed last.
  int dailyStreak = 0;

  // free coins (rewarded ad)
  int lastFreeCoinsEpochMs = 0;
  String? freeCoinsDate;
  int freeCoinsToday = 0;

  Map<String, MissionProgress> missions = {};
  GameSettings settings = GameSettings();

  MissionProgress mission(String id) => missions.putIfAbsent(id, MissionProgress.new);

  Map<String, dynamic> toJson() => {
    'v': schemaVersion,
    'coins': coins,
    'gems': gems,
    'unlocked': unlockedDragons.toList(),
    'selected': selectedDragon,
    'bestScore': bestScore,
    'bestDistance': bestDistance,
    'totalCoinsEarned': totalCoinsEarned,
    'totalRuns': totalRuns,
    'totalEnemies': totalEnemiesDefeated,
    'totalDistance': totalDistance,
    'removeAds': removeAds,
    'processedPurchases': processedPurchaseIds,
    'runsSinceInterstitial': runsSinceInterstitial,
    'lastDailyClaim': lastDailyClaim,
    'dailyStreak': dailyStreak,
    'lastFreeCoins': lastFreeCoinsEpochMs,
    'freeCoinsDate': freeCoinsDate,
    'freeCoinsToday': freeCoinsToday,
    'missions': missions.map((k, v) => MapEntry(k, v.toJson())),
    'settings': settings.toJson(),
  };

  factory PlayerProgress.fromJson(Map<String, dynamic> j) {
    final p = PlayerProgress();
    int i(String k) => (j[k] as num?)?.toInt() ?? 0;
    p.coins = i('coins').clamp(0, 1 << 31);
    p.gems = i('gems').clamp(0, 1 << 31);
    p.unlockedDragons = {'ember', ...((j['unlocked'] as List?)?.whereType<String>() ?? const <String>[])};
    p.selectedDragon = j['selected'] as String? ?? 'ember';
    if (!p.unlockedDragons.contains(p.selectedDragon)) p.selectedDragon = 'ember';
    p.bestScore = i('bestScore');
    p.bestDistance = i('bestDistance');
    p.totalCoinsEarned = i('totalCoinsEarned');
    p.totalRuns = i('totalRuns');
    p.totalEnemiesDefeated = i('totalEnemies');
    p.totalDistance = i('totalDistance');
    p.removeAds = j['removeAds'] as bool? ?? false;
    p.processedPurchaseIds = ((j['processedPurchases'] as List?)?.whereType<String>().toList()) ?? [];
    p.runsSinceInterstitial = i('runsSinceInterstitial');
    p.lastDailyClaim = j['lastDailyClaim'] as String?;
    p.dailyStreak = i('dailyStreak');
    p.lastFreeCoinsEpochMs = i('lastFreeCoins');
    p.freeCoinsDate = j['freeCoinsDate'] as String?;
    p.freeCoinsToday = i('freeCoinsToday');
    final m = j['missions'];
    if (m is Map) {
      m.forEach((k, v) {
        if (k is String && v is Map) p.missions[k] = MissionProgress.fromJson(v.cast<String, dynamic>());
      });
    }
    final s = j['settings'];
    if (s is Map) p.settings = GameSettings.fromJson(s.cast<String, dynamic>());
    return p;
  }
}
