import 'package:dragon_land/models/mission_model.dart';
import 'package:dragon_land/services/progress_controller.dart';
import 'package:dragon_land/services/reward_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late ProgressController progress;
  late RewardService rewards;

  setUp(() {
    now = DateTime(2026, 3, 10, 9);
    progress = ProgressController.memory();
    rewards = RewardService(progress, clock: () => now);
  });

  test('daily reward can be claimed once per day', () {
    expect(rewards.dailyStatus, DailyStatus.available);
    final r = rewards.claimDaily();
    expect(r!.day, 1);
    expect(progress.coins, 100);
    expect(rewards.dailyStatus, DailyStatus.claimedToday);
    expect(rewards.claimDaily(), isNull);
    now = now.add(const Duration(hours: 10)); // same calendar day
    expect(rewards.claimDaily(), isNull);
    expect(progress.coins, 100);
  });

  test('consecutive days build the streak and day 7 pays the bonus', () {
    var total = 0;
    for (var d = 1; d <= 7; d++) {
      final r = rewards.claimDaily()!;
      expect(r.day, d);
      total += r.coins;
      now = now.add(const Duration(days: 1));
    }
    expect(progress.coins, total);
    expect(progress.gems, 5);
    // cycle restarts after day 7
    expect(rewards.claimDaily()!.day, 1);
  });

  test('missing a day resets the streak', () {
    rewards.claimDaily();
    now = now.add(const Duration(days: 1));
    expect(rewards.claimDaily()!.day, 2);
    now = now.add(const Duration(days: 3));
    expect(rewards.claimDaily()!.day, 1);
  });

  test('moving the clock backwards blocks claiming', () {
    rewards.claimDaily();
    now = now.subtract(const Duration(days: 2));
    expect(rewards.dailyStatus, DailyStatus.clockError);
    expect(rewards.claimDaily(), isNull);
  });

  test('missions complete, claim once and advance a tier', () {
    final m = MissionDef.all.firstWhere((m) => m.stat == MissionStat.enemies);
    expect(rewards.missionComplete(m), isFalse);
    expect(rewards.claimMission(m), isNull);
    rewards.addMissionProgress({MissionStat.enemies: 12});
    expect(rewards.missionComplete(m), isTrue);
    final reward = rewards.claimMission(m);
    expect(reward, m.rewardForTier(0));
    expect(progress.coins, reward);
    expect(rewards.missionTier(m), 1);
    expect(rewards.missionProgress(m), 2); // overflow carries over
    expect(rewards.claimMission(m), isNull);
  });

  test('free coins respect cooldown', () {
    expect(rewards.freeCoinsReady, isTrue);
    rewards.grantFreeCoins();
    expect(progress.coins, 100);
    expect(rewards.freeCoinsReady, isFalse);
    now = now.add(const Duration(minutes: 6));
    expect(rewards.freeCoinsReady, isTrue);
  });
}
