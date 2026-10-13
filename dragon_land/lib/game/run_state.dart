import 'package:flutter/foundation.dart';

import 'game_config.dart';

/// Statistics of the current run. Run coins/gems are temporary until the run
/// is committed by the [CurrencySystem].
class RunStats {
  int coins = 0;
  int gems = 0;
  double distanceUnits = 0;
  int enemiesDefeated = 0;
  int bossesDefeated = 0;
  int crystalsBroken = 0;
  int attacks = 0;
  int flights = 0;
  int chests = 0;
  double time = 0;

  int get distanceMeters => (distanceUnits / GameConfig.unitsPerMeter).floor();
}

enum BuffKind { magnet, doubleCoins }

/// Snapshot of what the HUD shows. Updated by the game at ~20 Hz.
class HudState extends ChangeNotifier {
  int health = 3;
  int maxHealth = 3;
  double stamina01 = 1;
  double energy01 = 1;
  double attackReady01 = 1;
  double specialReady01 = 1;
  bool sprinting = false;
  bool flying = false;
  bool shieldActive = false;
  int shieldHits = 0;
  int coins = 0;
  int gems = 0;
  int distance = 0;
  int score = 0;
  double? bossHealth01;
  String? bossName;
  double magnetLeft = 0;
  double doubleCoinsLeft = 0;
  int damageEvents = 0;
  String? banner;
  int bannerId = 0;

  void push() => notifyListeners();

  void showBanner(String text) {
    banner = text;
    bannerId++;
  }
}
