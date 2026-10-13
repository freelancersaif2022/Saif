import '../config/economy_config.dart';
import '../models/mission_model.dart';
import 'progress_controller.dart';

enum DailyStatus { available, claimedToday, clockError }

/// Local daily rewards, missions and the timed free-coin reward.
///
/// Dates use the device's local calendar day. A claim is stored as the local
/// date string, so a reward can be claimed once per calendar day; moving the
/// clock backwards blocks claiming instead of granting extra rewards. If a
/// backend is added later, these checks should become server-authoritative.
class RewardService {
  RewardService(this._progress, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final ProgressController _progress;
  final DateTime Function() _clock;

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parse(String? s) {
    if (s == null) return null;
    final parts = s.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]), m = int.tryParse(parts[1]), d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  DateTime get _today {
    final n = _clock();
    return DateTime(n.year, n.month, n.day);
  }

  // ----------------------------------------------------------------- daily
  DailyStatus get dailyStatus {
    final last = _parse(_progress.data.lastDailyClaim);
    if (last == null) return DailyStatus.available;
    final diff = _today.difference(last).inDays;
    if (diff < 0) return DailyStatus.clockError;
    if (diff == 0) return DailyStatus.claimedToday;
    return DailyStatus.available;
  }

  /// The day (1..7) that the next claim grants.
  int get nextDailyDay {
    final last = _parse(_progress.data.lastDailyClaim);
    final streak = _progress.data.dailyStreak;
    if (last == null) return 1;
    final diff = _today.difference(last).inDays;
    if (diff == 0) return streak; // already claimed today: show today's day
    if (diff == 1) return streak >= 7 ? 1 : streak + 1;
    return 1; // streak broken
  }

  /// Day (1..7) highlighted as "current" in the UI.
  int get currentDisplayDay => nextDailyDay.clamp(1, 7);

  /// Claims today's reward. Returns the granted reward or null.
  DailyRewardDef? claimDaily() {
    if (dailyStatus != DailyStatus.available) return null;
    final day = nextDailyDay.clamp(1, 7);
    final reward = EconomyConfig.dailyRewards[day - 1];
    _progress.mutate((p) {
      p.lastDailyClaim = dateKey(_today);
      p.dailyStreak = day;
      p.coins += reward.coins;
      p.totalCoinsEarned += reward.coins;
      p.gems += reward.gems;
    });
    return reward;
  }

  // -------------------------------------------------------------- missions
  int missionProgress(MissionDef m) => _progress.data.mission(m.id).progress;
  int missionTier(MissionDef m) => _progress.data.mission(m.id).tier;
  int missionTarget(MissionDef m) => m.targetForTier(missionTier(m));
  bool missionComplete(MissionDef m) => missionProgress(m) >= missionTarget(m);
  int get claimableMissions => MissionDef.all.where(missionComplete).length;

  /// Claims a completed mission tier once; progress beyond the target carries
  /// over into the next tier.
  int? claimMission(MissionDef m) {
    if (!missionComplete(m)) return null;
    final tier = missionTier(m);
    final reward = m.rewardForTier(tier);
    _progress.mutate((p) {
      final mp = p.mission(m.id);
      mp.progress -= m.targetForTier(tier);
      if (mp.progress < 0) mp.progress = 0;
      mp.tier = tier + 1;
      p.coins += reward;
      p.totalCoinsEarned += reward;
    });
    return reward;
  }

  /// Adds run statistics to every mission line (called once per committed run delta).
  void addMissionProgress(Map<MissionStat, int> deltas) {
    if (deltas.values.every((v) => v <= 0)) return;
    _progress.mutate((p) {
      for (final m in MissionDef.all) {
        final d = deltas[m.stat] ?? 0;
        if (d > 0) p.mission(m.id).progress += d;
      }
    });
  }

  // ------------------------------------------------------------ free coins
  Duration get freeCoinsWait {
    final p = _progress.data;
    final now = _clock();
    if (p.freeCoinsDate == dateKey(now) && p.freeCoinsToday >= EconomyConfig.freeCoinsDailyLimit) {
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      return tomorrow.difference(now);
    }
    final last = DateTime.fromMillisecondsSinceEpoch(p.lastFreeCoinsEpochMs);
    final next = last.add(EconomyConfig.freeCoinsCooldown);
    if (last.isAfter(now)) return Duration.zero; // clock moved back; allow
    return next.isAfter(now) ? next.difference(now) : Duration.zero;
  }

  bool get freeCoinsReady => freeCoinsWait == Duration.zero;

  /// Grants the free coin reward. Must only be called from a rewarded-ad
  /// "user earned reward" callback.
  void grantFreeCoins() {
    final now = _clock();
    _progress.mutate((p) {
      final today = dateKey(now);
      if (p.freeCoinsDate != today) {
        p.freeCoinsDate = today;
        p.freeCoinsToday = 0;
      }
      p.freeCoinsToday++;
      p.lastFreeCoinsEpochMs = now.millisecondsSinceEpoch;
      p.coins += EconomyConfig.freeCoinsAdReward;
      p.totalCoinsEarned += EconomyConfig.freeCoinsAdReward;
    });
  }
}
