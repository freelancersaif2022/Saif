import 'dart:math';

import '../models/element.dart';
import '../models/monster.dart';

class MonsterFactory {
  MonsterFactory._();

  static double _pitchNorm(double hz) => ((log(hz.clamp(70, 700)) - log(80)) / (log(600) - log(80))).clamp(0.0, 1.0);
  static double _loudNorm(double db) => ((db + 48) / 40).clamp(0.0, 1.0);

  static BeastElement elementFor(VoiceProfile v) {
    final p = _pitchNorm(v.pitchHz);
    final l = _loudNorm(v.loudnessDb);
    final scores = <BeastElement, double>{
      BeastElement.terra: (1 - p) * 1.2 + (1 - v.variation) * 0.8,
      BeastElement.inferno: l * 1.1 + v.roughness * 1.0 + (1 - p) * 0.2,
      BeastElement.tide: (1 - (p - 0.45).abs() * 2) * 1.2 + (1 - v.roughness) * 0.8,
      BeastElement.frost: p * 1.2 + (1 - v.roughness) * 0.6 + (1 - v.variation) * 0.3,
      BeastElement.storm: p * 0.8 + v.variation * 1.3,
      BeastElement.shadow: (1 - l) * 1.6 + v.roughness * 0.4,
    };
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Voice decides the shape of the stats; [seed] adds a small jitter that
  /// "Reforge" can re-roll.
  static BaseStats statsFor(VoiceProfile v, int seed) {
    final r = Random(seed ^ 0x5bd1e995);
    final p = _pitchNorm(v.pitchHz);
    final l = _loudNorm(v.loudnessDb);
    int j(double base) => (base + r.nextInt(17) - 8).round().clamp(10, 100);
    return BaseStats(j(38 + 34 * (1 - p) + 22 * v.duration), j(32 + 40 * l + 18 * v.roughness), j(34 + 30 * (1 - p) + 24 * (1 - v.variation)), j(32 + 40 * p + 20 * v.variation));
  }

  static Rarity rarityFor(BaseStats s, VoiceProfile v, int seed) {
    final r = Random(seed ^ 0x2545F491);
    final score = s.total + _loudNorm(v.loudnessDb) * 20 + r.nextInt(40);
    if (score >= 290) return Rarity.legendary;
    if (score >= 255) return Rarity.epic;
    if (score >= 215) return Rarity.rare;
    return Rarity.common;
  }

  static const _pre = ['Grim', 'Rok', 'Zar', 'Vex', 'Mor', 'Kra', 'Thun', 'Sly', 'Bru', 'Fen', 'Gor', 'Xal', 'Dra', 'Quo', 'Nyx', 'Ul', 'Bel', 'Sko'];
  static const _mid = ['', 'a', 'o', 'u', 'i', 'ra', 'ga', 'th', 'zo'];
  static const _suf = ['gor', 'thar', 'mox', 'rax', 'zul', 'dor', 'nak', 'vyrn', 'gash', 'lisk', 'mire', 'fang', 'cleft', 'dax'];

  static String nameFor(int seed) {
    final r = Random(seed ^ 0x68E31DA4);
    return _pre[r.nextInt(_pre.length)] + _mid[r.nextInt(_mid.length)] + _suf[r.nextInt(_suf.length)];
  }

  static Monster fromVoice(VoiceProfile v, {int? seed}) {
    final s = seed ?? Random().nextInt(1 << 31);
    final stats = statsFor(v, s);
    return Monster(id: Monster.newId(), name: nameFor(s), seed: s, element: elementFor(v), rarity: rarityFor(stats, v, s), stats: stats, voice: v);
  }

  /// Re-rolls appearance + stat jitter + name, keeps the voice-driven core.
  static void reforge(Monster m) {
    final s = Random().nextInt(1 << 31);
    m.seed = s;
    m.stats = statsFor(m.voice!, s);
    m.rarity = rarityFor(m.stats, m.voice!, s);
    m.name = nameFor(s);
  }

  // ---------------------------------------------------------------------------
  // Arena ladder opponents (deterministic per stage).
  // ---------------------------------------------------------------------------
  static const tiers = ['Mud Pit', 'Bone Yard', 'Lava Rim', 'Frost Hollow', 'Storm Peak', 'Toxic Marsh', 'Crystal Caves', 'The Abyss', 'Sky Citadel', 'Titan Throne'];
  static const stagesPerTier = 6;
  static int get totalStages => tiers.length * stagesPerTier;

  static bool isBoss(int stage) => stage % stagesPerTier == stagesPerTier - 1;

  static Monster opponentForStage(int stage) {
    final r = Random(stage * 7919 + 17);
    // 60 stages climb smoothly from Lv 1 to the Lv 30 final boss.
    final level = (1 + stage * 0.49).round().clamp(1, Monster.maxLevel);
    final boss = isBoss(stage);
    int stat() => (34 + r.nextInt(30) + stage * 0.45 + (boss ? 8 : 0)).round().clamp(10, 100);
    final evo = boss ? (stage >= 35 ? 3 : 2) : (stage >= 40 ? 3 : (stage >= 18 ? 2 : 1));
    final seed = stage * 104729 + 7;
    return Monster(
      id: 'ai_$stage',
      name: nameFor(seed),
      seed: seed,
      element: BeastElement.values[r.nextInt(BeastElement.values.length)],
      rarity: stage == totalStages - 1 ? Rarity.legendary : (boss ? Rarity.epic : (stage > 36 ? Rarity.rare : Rarity.common)),
      stats: BaseStats(stat(), stat(), stat(), stat()),
      level: level,
      stage: evo,
    );
  }

  /// Sample monsters used by onboarding / empty states.
  static Monster showcase(BeastElement e, int seed, {int stage = 2}) =>
      Monster(id: 'show_$seed', name: nameFor(seed), seed: seed, element: e, rarity: Rarity.epic, stats: const BaseStats(60, 60, 60, 60), stage: stage);
}
