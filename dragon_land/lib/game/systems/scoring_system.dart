import '../../config/economy_config.dart';
import '../run_state.dart';

/// Score = distance + coins + defeated enemies + bosses + broken crystals.
class ScoringSystem {
  static int score(RunStats s) =>
      s.distanceMeters * EconomyConfig.scorePerMeter +
      s.coins * EconomyConfig.scorePerCoin +
      s.enemiesDefeated * EconomyConfig.scorePerEnemy +
      s.bossesDefeated * EconomyConfig.scorePerBoss +
      s.crystalsBroken * EconomyConfig.scorePerCrystal;
}
