import 'package:dragon_land/game/run_state.dart';
import 'package:dragon_land/game/systems/currency_system.dart';
import 'package:dragon_land/models/mission_model.dart';
import 'package:dragon_land/services/progress_controller.dart';
import 'package:dragon_land/services/reward_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commit transfers run coins once, revive commits only the delta', () {
    final progress = ProgressController.memory();
    final rewards = RewardService(progress);
    final cs = CurrencySystem(progress, rewards);
    final stats = RunStats()
      ..coins = 40
      ..gems = 1
      ..enemiesDefeated = 3
      ..distanceUnits = 400 * 40;
    final r1 = cs.commit(stats);
    expect(progress.coins, 40);
    expect(progress.gems, 1);
    expect(progress.data.totalRuns, 1);
    expect(r1.distance, 400);
    expect(r1.newBestDistance, isTrue);

    // committing again with no new coins grants nothing
    cs.commit(stats);
    expect(progress.coins, 40);

    // after a revive the player collects 10 more coins
    stats.coins = 50;
    cs.commit(stats);
    expect(progress.coins, 50);
    expect(progress.data.totalRuns, 1, reason: 'a revived run is still one run');

    final runsMission = MissionDef.all.firstWhere((m) => m.stat == MissionStat.runs);
    expect(rewards.missionProgress(runsMission), 1);
  });

  test('double coins and bonus chest are once per run', () {
    final progress = ProgressController.memory();
    final cs = CurrencySystem(progress, RewardService(progress));
    final stats = RunStats()..coins = 30;
    cs.commit(stats);
    expect(cs.grantDoubleCoins(stats), 30);
    expect(cs.grantDoubleCoins(stats), 0);
    expect(cs.grantBonusChest(100), 100);
    expect(cs.grantBonusChest(100), 0);
    expect(progress.coins, 160);
    cs.reset();
    expect(cs.grantDoubleCoins(stats), 30);
  });
}
