import 'dart:convert';
import 'dart:math';

import 'element.dart';

/// Numbers measured from the player's roar.
class VoiceProfile {
  const VoiceProfile({required this.pitchHz, required this.loudnessDb, required this.roughness, required this.variation, required this.duration});

  final double pitchHz; // average voiced pitch
  final double loudnessDb; // dBFS, -60 (silent) .. 0 (max)
  final double roughness; // 0 smooth .. 1 raspy/noisy
  final double variation; // 0 steady .. 1 wild pitch changes
  final double duration; // 0..1 portion of the 3s window that had sound

  Map<String, dynamic> toJson() => {'p': pitchHz, 'l': loudnessDb, 'r': roughness, 'v': variation, 'd': duration};

  factory VoiceProfile.fromJson(Map<String, dynamic> j) => VoiceProfile(
    pitchHz: (j['p'] as num).toDouble(),
    loudnessDb: (j['l'] as num).toDouble(),
    roughness: (j['r'] as num).toDouble(),
    variation: (j['v'] as num).toDouble(),
    duration: (j['d'] as num).toDouble(),
  );

  String get pitchLabel => pitchHz < 140
      ? 'Deep'
      : pitchHz < 230
      ? 'Mid'
      : pitchHz < 380
      ? 'High'
      : 'Shrill';
}

class BaseStats {
  const BaseStats(this.hp, this.atk, this.def, this.spd);
  final int hp, atk, def, spd;
  int get total => hp + atk + def + spd;
  List<int> toList() => [hp, atk, def, spd];
  factory BaseStats.fromList(List l) => BaseStats(l[0] as int, l[1] as int, l[2] as int, l[3] as int);
}

class Monster {
  Monster({
    required this.id,
    required this.name,
    required this.seed,
    required this.element,
    required this.rarity,
    required this.stats,
    this.voice,
    this.level = 1,
    this.xp = 0,
    this.stage = 1,
    this.wins = 0,
    this.losses = 0,
    this.roarPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  int seed; // drives appearance + stat jitter
  final BeastElement element;
  Rarity rarity;
  BaseStats stats;
  final VoiceProfile? voice;
  int level;
  int xp;
  int stage; // evolution 1..3
  int wins;
  int losses;
  String? roarPath;
  final DateTime createdAt;

  static const int maxLevel = 30;

  static int xpForLevel(int level) => 60 + (level - 1) * 35;
  int get xpToNext => xpForLevel(level);
  double get xpProgress => level >= maxLevel ? 1 : (xp / xpToNext).clamp(0, 1);

  double get _growth => (1 + 0.06 * (level - 1)) * const [1.0, 1.0, 1.15, 1.32][stage];

  int get maxHp => (stats.hp * 2.4 * _growth).round() + 20;
  int get atk => (stats.atk * _growth).round();
  int get def => (stats.def * _growth).round();
  int get spd => (stats.spd * _growth).round();
  int get power => ((maxHp / 2.4) + atk + def + spd).round();

  int? get nextEvolutionLevel => stage == 1 ? 10 : (stage == 2 ? 20 : null);
  int get stonesForNextEvolution => stage == 1 ? 1 : 3;
  bool get canEvolve => nextEvolutionLevel != null && level >= nextEvolutionLevel!;

  /// Adds XP and returns how many levels were gained.
  int addXp(int amount) {
    if (level >= maxLevel) return 0;
    xp += amount;
    var gained = 0;
    while (level < maxLevel && xp >= xpToNext) {
      xp -= xpToNext;
      level++;
      gained++;
    }
    if (level >= maxLevel) xp = 0;
    return gained;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'n': name,
    's': seed,
    'e': element.index,
    'r': rarity.index,
    'st': stats.toList(),
    'v': voice?.toJson(),
    'lv': level,
    'xp': xp,
    'g': stage,
    'w': wins,
    'lo': losses,
    'rp': roarPath,
    'c': createdAt.millisecondsSinceEpoch,
  };

  factory Monster.fromJson(Map<String, dynamic> j) => Monster(
    id: j['id'] as String,
    name: j['n'] as String,
    seed: j['s'] as int,
    element: BeastElement.values[j['e'] as int],
    rarity: Rarity.values[j['r'] as int],
    stats: BaseStats.fromList(j['st'] as List),
    voice: j['v'] == null ? null : VoiceProfile.fromJson(Map<String, dynamic>.from(j['v'] as Map)),
    level: j['lv'] as int,
    xp: j['xp'] as int,
    stage: j['g'] as int,
    wins: j['w'] as int? ?? 0,
    losses: j['lo'] as int? ?? 0,
    roarPath: j['rp'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(j['c'] as int),
  );

  // ---------------------------------------------------------------------------
  // Challenge code (QR / text). Small, versioned, checksummed.
  // ---------------------------------------------------------------------------
  static const _prefix = 'VBA1.';

  String toChallengeCode() {
    final payload = jsonEncode([name, seed, element.index, rarity.index, stats.toList(), level, stage]);
    final b64 = base64Url.encode(utf8.encode(payload)).replaceAll('=', '');
    return '$_prefix$b64.${_checksum(b64)}';
  }

  /// Returns null if the code is invalid or tampered with.
  static Monster? fromChallengeCode(String raw) {
    try {
      final code = raw.trim();
      final start = code.indexOf(_prefix);
      if (start < 0) return null;
      final parts = code.substring(start + _prefix.length).split(RegExp(r'\s'))[0].split('.');
      if (parts.length != 2 || _checksum(parts[0]) != parts[1]) return null;
      var b64 = parts[0];
      while (b64.length % 4 != 0) {
        b64 += '=';
      }
      final l = jsonDecode(utf8.decode(base64Url.decode(b64))) as List;
      final stats = BaseStats.fromList(l[4] as List);
      final level = l[5] as int;
      final stage = l[6] as int;
      final valid = stats.toList().every((s) => s >= 1 && s <= 120) && level >= 1 && level <= maxLevel && stage >= 1 && stage <= 3;
      if (!valid) return null;
      final name = (l[0] as String);
      return Monster(
        id: 'friend',
        name: name.length > 16 ? name.substring(0, 16) : name,
        seed: l[1] as int,
        element: BeastElement.values[l[2] as int],
        rarity: Rarity.values[l[3] as int],
        stats: stats,
        level: level,
        stage: stage,
      );
    } catch (_) {
      return null;
    }
  }

  static String _checksum(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return (h & 0xFFFFFF).toRadixString(36);
  }

  static String newId() => '${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(9999)}';
}
