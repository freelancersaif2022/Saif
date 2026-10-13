/// The statistic a mission tracks.
enum MissionStat { coins, distance, enemies, flights, attacks, runs }

/// A mission line. Each line has endless tiers: after a tier is claimed the
/// next tier starts with a larger target and reward.
class MissionDef {
  const MissionDef({required this.id, required this.stat, required this.baseTarget, required this.baseReward, required this.titleTemplate});

  final String id;
  final MissionStat stat;
  final int baseTarget;
  final int baseReward;

  /// Title with `{n}` replaced by the target.
  final String titleTemplate;

  int targetForTier(int tier) => (baseTarget * _mult(tier)).round();
  int rewardForTier(int tier) => (baseReward * (1 + tier * 0.5)).round();
  String titleForTier(int tier) => titleTemplate.replaceAll('{n}', _fmt(targetForTier(tier)));

  static double _mult(int tier) => tier == 0 ? 1 : (1 + tier * 1.0);

  static String _fmt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  static const List<MissionDef> all = [
    MissionDef(id: 'collect_coins', stat: MissionStat.coins, baseTarget: 100, baseReward: 150, titleTemplate: 'Collect {n} coins'),
    MissionDef(id: 'run_distance', stat: MissionStat.distance, baseTarget: 500, baseReward: 150, titleTemplate: 'Run {n} meters in total'),
    MissionDef(id: 'defeat_enemies', stat: MissionStat.enemies, baseTarget: 10, baseReward: 200, titleTemplate: 'Defeat {n} enemies'),
    MissionDef(id: 'use_flight', stat: MissionStat.flights, baseTarget: 5, baseReward: 120, titleTemplate: 'Use flight {n} times'),
    MissionDef(id: 'perform_attacks', stat: MissionStat.attacks, baseTarget: 20, baseReward: 120, titleTemplate: 'Perform {n} attacks'),
    MissionDef(id: 'complete_runs', stat: MissionStat.runs, baseTarget: 3, baseReward: 200, titleTemplate: 'Complete {n} runs'),
  ];
}

/// Persistent progress on one mission line.
class MissionProgress {
  MissionProgress({this.tier = 0, this.progress = 0});

  int tier;
  int progress;

  Map<String, dynamic> toJson() => {'tier': tier, 'progress': progress};

  factory MissionProgress.fromJson(Map<String, dynamic> j) =>
      MissionProgress(tier: (j['tier'] as num?)?.toInt() ?? 0, progress: (j['progress'] as num?)?.toInt() ?? 0);
}
