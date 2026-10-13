import '../../models/mission_model.dart';
import '../../services/progress_controller.dart';
import '../../services/reward_service.dart';
import '../run_state.dart';
import 'scoring_system.dart';

class RunResult {
  RunResult({
    required this.score,
    required this.distance,
    required this.coins,
    required this.gems,
    required this.enemies,
    required this.newBestScore,
    required this.newBestDistance,
    required this.bestDistance,
    required this.bestScore,
  });

  final int score;
  final int distance;
  final int coins;
  final int gems;
  final int enemies;
  final bool newBestScore;
  final bool newBestDistance;
  final int bestDistance;
  final int bestScore;
}

/// Moves run rewards into permanent progression.
///
/// Run coins/gems are temporary while playing. [commit] transfers only what
/// was collected since the previous commit, so committing again after a
/// revive never grants the same coins twice. Bonus rewards (double coins,
/// bonus chest) are also guarded to once per run.
class CurrencySystem {
  CurrencySystem(this._progress, this._rewards);

  final ProgressController _progress;
  final RewardService _rewards;

  int _coins = 0, _gems = 0, _enemies = 0, _meters = 0, _attacks = 0, _flights = 0;
  bool _runCounted = false;
  bool doubleCoinsClaimed = false;
  bool bonusChestClaimed = false;

  void reset() {
    _coins = _gems = _enemies = _meters = _attacks = _flights = 0;
    _runCounted = false;
    doubleCoinsClaimed = false;
    bonusChestClaimed = false;
  }

  RunResult commit(RunStats s) {
    final dc = s.coins - _coins;
    final dg = s.gems - _gems;
    final de = s.enemiesDefeated - _enemies;
    final dm = s.distanceMeters - _meters;
    final da = s.attacks - _attacks;
    final df = s.flights - _flights;
    _coins = s.coins;
    _gems = s.gems;
    _enemies = s.enemiesDefeated;
    _meters = s.distanceMeters;
    _attacks = s.attacks;
    _flights = s.flights;
    final countRun = !_runCounted;
    _runCounted = true;

    final score = ScoringSystem.score(s);
    final prevBestScore = _progress.data.bestScore;
    final prevBestDistance = _progress.data.bestDistance;
    _progress.mutate((p) {
      if (dc > 0) {
        p.coins += dc;
        p.totalCoinsEarned += dc;
      }
      if (dg > 0) p.gems += dg;
      if (de > 0) p.totalEnemiesDefeated += de;
      if (dm > 0) p.totalDistance += dm;
      if (countRun) p.totalRuns++;
      if (score > p.bestScore) p.bestScore = score;
      if (s.distanceMeters > p.bestDistance) p.bestDistance = s.distanceMeters;
    });
    _rewards.addMissionProgress({
      MissionStat.coins: dc,
      MissionStat.distance: dm,
      MissionStat.enemies: de,
      MissionStat.attacks: da,
      MissionStat.flights: df,
      MissionStat.runs: countRun ? 1 : 0,
    });
    return RunResult(
      score: score,
      distance: s.distanceMeters,
      coins: s.coins,
      gems: s.gems,
      enemies: s.enemiesDefeated,
      newBestScore: score > prevBestScore && score > 0,
      newBestDistance: s.distanceMeters > prevBestDistance && s.distanceMeters > 0,
      bestDistance: _progress.data.bestDistance,
      bestScore: _progress.data.bestScore,
    );
  }

  /// Rewarded-ad bonus: doubles the run's coins once per run. Returns the
  /// amount granted (0 if already claimed).
  int grantDoubleCoins(RunStats s) {
    if (doubleCoinsClaimed || s.coins <= 0) return 0;
    doubleCoinsClaimed = true;
    _progress.addCoins(s.coins);
    return s.coins;
  }

  int grantBonusChest(int coins) {
    if (bonusChestClaimed) return 0;
    bonusChestClaimed = true;
    _progress.addCoins(coins);
    return coins;
  }
}
