import 'dart:math' as math;
import 'dart:ui';

enum EnemyKind { grunt, swordsman, heavy, brute, elite, monster, skeleton, archer, wraith }

enum SpawnSide { left, right, ground, sky }

enum BossKind { none, eagle, elephant, finalBoss, skeletonKing, tiger }

enum EnvTheme { classic, bamboo, graveyard, volcano }

class SpawnDef {
  const SpawnDef(this.triggerX, this.kind, this.side, this.delay);
  final double triggerX;
  final EnemyKind kind;
  final SpawnSide side;
  final double delay;
}

class PlatformDef {
  const PlatformDef(this.x, this.top, this.width, {this.moveX = 0, this.moveY = 0, this.period = 4, this.phase = 0});
  final double x;
  final double top;
  final double width;

  /// Movement amplitude for moving platforms (0 = static).
  final double moveX;
  final double moveY;
  final double period;
  final double phase;

  bool get moving => moveX != 0 || moveY != 0;
  Rect get rect => Rect.fromLTWH(x, top, width, 22);

  Offset offsetAt(double t) {
    if (!moving) return Offset.zero;
    final a = (t / period + phase) * math.pi * 2;
    return Offset(math.sin(a) * moveX, math.sin(a) * moveY);
  }
}

class TrapDef {
  const TrapDef(this.x, this.phase);
  final double x;
  final double phase;
}

class SpikeDef {
  const SpikeDef(this.x, this.width, this.phase);
  final double x;
  final double width;
  final double phase;
}

class LevelConfig {
  const LevelConfig({
    required this.index,
    required this.name,
    required this.length,
    required this.spawns,
    required this.platforms,
    required this.spikes,
    required this.boss,
    required this.tint,
    this.rollingEvery = 0,
    this.fallingEvery = 0,
    this.speedMul = 1,
    this.cooldownMul = 1,
    this.damageMul = 1,
    this.hpMul = 1,
    this.detectMul = 1,
    this.dropMul = 1,
    this.seed = 1,
    this.theme = EnvTheme.classic,
    this.pendulums = const [],
    this.vents = const [],
    this.revive = 0,
  });

  final int index;
  final String name;
  final double length;
  final List<SpawnDef> spawns;
  final List<PlatformDef> platforms;
  final List<SpikeDef> spikes;
  final BossKind boss;
  final Color tint;
  final double rollingEvery;
  final double fallingEvery;
  final double speedMul;
  final double cooldownMul;
  final double damageMul;
  final double hpMul;
  final double detectMul;
  final double dropMul;
  final int seed;
  final EnvTheme theme;
  final List<TrapDef> pendulums;
  final List<TrapDef> vents;

  /// Chance that a slain skeleton reassembles once.
  final double revive;

  bool get isBoss => boss != BossKind.none;
  double get checkpointX => isBoss ? 0 : length * 0.5;
}

const List<String> levelNames = [
  'THE SILENT RUINS',
  'WHISPERING JUNGLE',
  'HOLLOW VILLAGE',
  'SKY OF TALONS',
  'CRIMSON PASS',
  'STONEFALL VALLEY',
  'THE BROKEN FORTRESS',
  'TITAN GROUNDS',
  'ABYSS GATE',
  'THRONE OF SHADOWS',
  'MOONLIT BAMBOO PASS',
  'LANTERN VILLAGE',
  'CLIFFS OF WHISPERS',
  'THE BONE KING',
  'FIELDS OF BONES',
  'CRYPT ROAD',
  'HOLLOW CATHEDRAL',
  'RIVER OF SOULS',
  'GATES OF EMBER',
  'THE TIGER GOD',
];

const _g = EnemyKind.grunt;
const _s = EnemyKind.swordsman;
const _h = EnemyKind.heavy;
const _b = EnemyKind.brute;
const _e = EnemyKind.elite;
const _m = EnemyKind.monster;
const _k = EnemyKind.skeleton;
const _a = EnemyKind.archer;
const _w = EnemyKind.wraith;

List<SpawnDef> _waves(int seed, double length, List<List<EnemyKind>> waves, {bool varied = true}) {
  final r = math.Random(seed);
  final out = <SpawnDef>[];
  final start = 650.0;
  final end = length - 700;
  for (var w = 0; w < waves.length; w++) {
    final x = waves.length == 1 ? start : start + (end - start) * w / (waves.length - 1);
    final kinds = waves[w];
    for (var i = 0; i < kinds.length; i++) {
      SpawnSide side;
      if (!varied) {
        side = SpawnSide.right;
      } else {
        final roll = r.nextDouble();
        if (i == 0) {
          side = SpawnSide.right;
        } else if (roll < 0.3) {
          side = SpawnSide.left;
        } else if (roll < 0.55) {
          side = SpawnSide.ground;
        } else if (roll < 0.75 && kinds[i] != EnemyKind.brute) {
          side = SpawnSide.sky;
        } else {
          side = SpawnSide.right;
        }
      }
      out.add(SpawnDef(x, kinds[i], side, i * (0.35 + r.nextDouble() * 0.5)));
    }
  }
  return out;
}

List<PlatformDef> _platforms(int seed, double length, int count) {
  final r = math.Random(seed * 31 + 7);
  final out = <PlatformDef>[];
  if (count <= 0) return out;
  final gap = (length - 1200) / count;
  for (var i = 0; i < count; i++) {
    final x = 700 + i * gap + r.nextDouble() * gap * 0.4;
    final w = 200 + r.nextDouble() * 140;
    final top = -(150 + r.nextDouble() * 90);
    out.add(PlatformDef(x, top, w));
    if (r.nextDouble() < 0.35 && count > 3) {
      out.add(PlatformDef(x + w * 0.5, top - 140, 160 + r.nextDouble() * 80));
    }
  }
  return out;
}

List<PlatformDef> _adventurePlatforms(int seed, double length, int count) {
  final r = math.Random(seed * 53 + 11);
  final out = <PlatformDef>[];
  final gap = (length - 1400) / count;
  for (var i = 0; i < count; i++) {
    final x = 800 + i * gap + r.nextDouble() * gap * 0.3;
    final w = 170 + r.nextDouble() * 120;
    final top = -(150 + r.nextDouble() * 80);
    switch (i % 3) {
      case 0:
        out.add(PlatformDef(x, top, w, moveX: 120 + r.nextDouble() * 80, period: 4 + r.nextDouble() * 2, phase: r.nextDouble()));
        break;
      case 1:
        out.add(PlatformDef(x, top - 30, w, moveY: 70 + r.nextDouble() * 40, period: 3.5 + r.nextDouble() * 2, phase: r.nextDouble()));
        out.add(PlatformDef(x + w + 60, top - 170, 150));
        break;
      default:
        out.add(PlatformDef(x, top, w));
        out.add(PlatformDef(x + w * 0.4, top - 150, 170, moveX: 90, period: 5, phase: r.nextDouble()));
    }
  }
  return out;
}

List<TrapDef> _traps(int seed, double length, int count, double start) {
  final r = math.Random(seed * 71 + 5);
  final out = <TrapDef>[];
  if (count <= 0) return out;
  final gap = (length - start - 700) / count;
  for (var i = 0; i < count; i++) {
    out.add(TrapDef(start + i * gap + r.nextDouble() * gap * 0.5, r.nextDouble() * 4));
  }
  return out;
}

List<SpikeDef> _spikes(int seed, double length, int count) {
  final r = math.Random(seed * 17 + 3);
  final out = <SpikeDef>[];
  if (count <= 0) return out;
  final gap = (length - 1400) / count;
  for (var i = 0; i < count; i++) {
    out.add(SpikeDef(900 + i * gap + r.nextDouble() * gap * 0.5, 110 + r.nextDouble() * 70, r.nextDouble() * 3));
  }
  return out;
}

LevelConfig levelConfig(int level) {
  switch (level) {
    case 1:
      return LevelConfig(
        index: 1,
        name: levelNames[0],
        length: 3400,
        spawns: _waves(1, 3400, [
          [_g],
          [_g, _g],
          [_s],
          [_g, _s],
          [_g, _g, _s],
          [_h],
        ], varied: false),
        platforms: _platforms(1, 3400, 2),
        spikes: const [],
        boss: BossKind.none,
        tint: const Color(0xFF2A4060),
        speedMul: 0.85,
        cooldownMul: 1.3,
        damageMul: 0.75,
        hpMul: 0.85,
        detectMul: 0.9,
        dropMul: 1.3,
        seed: 1,
      );
    case 2:
      return LevelConfig(
        index: 2,
        name: levelNames[1],
        length: 3800,
        spawns: _waves(2, 3800, [
          [_g, _g],
          [_s, _g],
          [_h],
          [_s, _s],
          [_g, _g, _g],
          [_h, _s],
          [_s, _g, _g],
        ]),
        platforms: _platforms(2, 3800, 3),
        spikes: _spikes(2, 3800, 1),
        boss: BossKind.none,
        tint: const Color(0xFF1E4A3C),
        speedMul: 0.92,
        cooldownMul: 1.15,
        damageMul: 0.85,
        hpMul: 0.95,
        dropMul: 1.2,
        seed: 2,
      );
    case 3:
      return LevelConfig(
        index: 3,
        name: levelNames[2],
        length: 4200,
        spawns: _waves(3, 4200, [
          [_s, _g],
          [_h, _g],
          [_s, _s, _g],
          [_b],
          [_g, _g, _s, _s],
          [_h, _h],
          [_b, _s],
        ]),
        platforms: _platforms(3, 4200, 4),
        spikes: _spikes(3, 4200, 2),
        boss: BossKind.none,
        tint: const Color(0xFF3A3450),
        speedMul: 1.0,
        cooldownMul: 1.0,
        damageMul: 0.95,
        hpMul: 1.0,
        dropMul: 1.1,
        seed: 3,
      );
    case 4:
      return const LevelConfig(
        index: 4,
        name: 'SKY OF TALONS',
        length: 2200,
        spawns: [],
        platforms: [PlatformDef(420, -190, 240), PlatformDef(1540, -190, 240)],
        spikes: [],
        boss: BossKind.eagle,
        tint: Color(0xFF40485A),
        seed: 4,
      );
    case 5:
      return LevelConfig(
        index: 5,
        name: levelNames[4],
        length: 4600,
        spawns: _waves(5, 4600, [
          [_s, _s],
          [_e, _g, _g],
          [_h, _s],
          [_b, _g],
          [_e, _e],
          [_h, _h, _s],
          [_b, _e, _g],
          [_s, _s, _s, _e],
        ]),
        platforms: _platforms(5, 4600, 5),
        spikes: _spikes(5, 4600, 2),
        boss: BossKind.none,
        tint: const Color(0xFF5A2028),
        rollingEvery: 9,
        speedMul: 1.1,
        cooldownMul: 0.9,
        damageMul: 1.05,
        hpMul: 1.1,
        detectMul: 1.1,
        dropMul: 1.0,
        seed: 5,
      );
    case 6:
      return LevelConfig(
        index: 6,
        name: levelNames[5],
        length: 5000,
        spawns: _waves(6, 5000, [
          [_e, _s],
          [_h, _g, _g],
          [_b, _s],
          [_e, _e, _g],
          [_h, _h],
          [_b, _e, _s],
          [_s, _s, _e, _g],
          [_b, _h, _e],
          [_e, _e, _s, _s],
        ]),
        platforms: _platforms(6, 5000, 6),
        spikes: _spikes(6, 5000, 3),
        boss: BossKind.none,
        tint: const Color(0xFF4A3A30),
        rollingEvery: 7,
        fallingEvery: 6,
        speedMul: 1.18,
        cooldownMul: 0.82,
        damageMul: 1.12,
        hpMul: 1.2,
        detectMul: 1.2,
        dropMul: 0.95,
        seed: 6,
      );
    case 7:
      return LevelConfig(
        index: 7,
        name: levelNames[6],
        length: 5400,
        spawns: _waves(7, 5400, [
          [_e, _e, _s],
          [_b, _g, _g],
          [_h, _h, _e],
          [_b, _s, _s],
          [_e, _e, _e],
          [_b, _b],
          [_h, _e, _s, _g],
          [_b, _h, _e, _e],
          [_s, _s, _s, _e],
          [_b, _b, _e],
        ]),
        platforms: _platforms(7, 5400, 7),
        spikes: _spikes(7, 5400, 4),
        boss: BossKind.none,
        tint: const Color(0xFF552430),
        rollingEvery: 6,
        fallingEvery: 5,
        speedMul: 1.25,
        cooldownMul: 0.75,
        damageMul: 1.2,
        hpMul: 1.3,
        detectMul: 1.3,
        dropMul: 0.9,
        seed: 7,
      );
    case 8:
      return const LevelConfig(
        index: 8,
        name: 'TITAN GROUNDS',
        length: 2400,
        spawns: [],
        platforms: [],
        spikes: [],
        boss: BossKind.elephant,
        tint: Color(0xFF5A4022),
        seed: 8,
      );
    case 9:
      return LevelConfig(
        index: 9,
        name: levelNames[8],
        length: 6200,
        spawns: _waves(9, 6200, [
          [_e, _e, _s],
          [_b, _h, _g, _g],
          [_e, _e, _e],
          [_b, _b, _s],
          [_h, _h, _e, _e],
          [_b, _e, _s, _s],
          [_e, _e, _e, _g, _g],
          [_b, _b, _h],
          [_h, _e, _e, _s, _s],
          [_b, _b, _e, _e],
          [_e, _e, _e, _e],
          [_b, _b, _h, _h],
        ]),
        platforms: _platforms(9, 6200, 9),
        spikes: _spikes(9, 6200, 5),
        boss: BossKind.none,
        tint: const Color(0xFF6A1018),
        rollingEvery: 5,
        fallingEvery: 3.6,
        speedMul: 1.35,
        cooldownMul: 0.62,
        damageMul: 1.3,
        hpMul: 1.45,
        detectMul: 1.5,
        dropMul: 0.85,
        seed: 9,
      );
    case 11:
      return LevelConfig(
        index: 11,
        name: levelNames[10],
        length: 5600,
        spawns: _waves(11, 5600, [
          [_e, _e, _w],
          [_m, _s],
          [_w, _w, _e],
          [_b, _m],
          [_e, _e, _e, _w],
          [_m, _m],
          [_b, _w, _w, _e],
          [_m, _b, _e, _e],
        ]),
        platforms: _adventurePlatforms(11, 5600, 7),
        spikes: _spikes(11, 5600, 3),
        pendulums: _traps(11, 5600, 3, 1300),
        vents: _traps(111, 5600, 3, 1100),
        boss: BossKind.none,
        tint: const Color(0xFF203A30),
        theme: EnvTheme.bamboo,
        rollingEvery: 7,
        fallingEvery: 5,
        speedMul: 1.3,
        cooldownMul: 0.66,
        damageMul: 1.3,
        hpMul: 1.5,
        detectMul: 1.5,
        dropMul: 0.9,
        seed: 11,
      );
    case 12:
      return LevelConfig(
        index: 12,
        name: levelNames[11],
        length: 6000,
        spawns: _waves(12, 6000, [
          [_e, _w, _w],
          [_m, _m, _s],
          [_b, _e, _e],
          [_w, _w, _w, _e],
          [_m, _b, _e],
          [_h, _h, _w, _w],
          [_m, _m, _e, _e],
          [_b, _b, _w],
          [_e, _e, _e, _m, _w],
        ]),
        platforms: _adventurePlatforms(12, 6000, 8),
        spikes: _spikes(12, 6000, 4),
        pendulums: _traps(12, 6000, 4, 1200),
        vents: _traps(112, 6000, 4, 1000),
        boss: BossKind.none,
        tint: const Color(0xFF3A2A18),
        theme: EnvTheme.bamboo,
        rollingEvery: 6,
        fallingEvery: 4.5,
        speedMul: 1.35,
        cooldownMul: 0.62,
        damageMul: 1.38,
        hpMul: 1.6,
        detectMul: 1.6,
        dropMul: 0.9,
        seed: 12,
      );
    case 13:
      return LevelConfig(
        index: 13,
        name: levelNames[12],
        length: 6400,
        spawns: _waves(13, 6400, [
          [_a, _e, _w],
          [_m, _m, _a],
          [_b, _e, _e, _w],
          [_a, _a, _m],
          [_w, _w, _w, _e, _e],
          [_b, _b, _a],
          [_m, _m, _e, _w],
          [_a, _a, _b, _e],
          [_m, _b, _w, _w, _e],
        ]),
        platforms: _adventurePlatforms(13, 6400, 10),
        spikes: _spikes(13, 6400, 4),
        pendulums: _traps(13, 6400, 5, 1100),
        vents: _traps(113, 6400, 5, 900),
        boss: BossKind.none,
        tint: const Color(0xFF2A2440),
        theme: EnvTheme.bamboo,
        rollingEvery: 5.5,
        fallingEvery: 4,
        speedMul: 1.4,
        cooldownMul: 0.58,
        damageMul: 1.45,
        hpMul: 1.7,
        detectMul: 1.7,
        dropMul: 0.85,
        seed: 13,
      );
    case 14:
      return const LevelConfig(
        index: 14,
        name: 'THE BONE KING',
        length: 2600,
        spawns: [],
        platforms: [PlatformDef(380, -200, 220), PlatformDef(2000, -200, 220)],
        spikes: [],
        boss: BossKind.skeletonKing,
        tint: Color(0xFF5A1010),
        theme: EnvTheme.graveyard,
        damageMul: 1.2,
        hpMul: 1.2,
        seed: 14,
      );
    case 15:
    case 16:
    case 17:
    case 18:
    case 19:
      final i = level - 15;
      final waves = <List<EnemyKind>>[
        [_k, _k, _a],
        [_k, _w, _a, _k],
        [_m, _k, _k],
        [_a, _a, _k, _w],
        [_b, _k, _k, _a],
        [_m, _m, _w, _k],
        [_k, _k, _k, _a, _a],
        [_m, _b, _w, _w, _k],
        [_a, _a, _a, _k, _k],
        [_m, _m, _b, _k, _w],
        [_k, _k, _k, _k, _a, _w],
        [_m, _m, _m, _a, _a],
        [_b, _b, _k, _k, _w, _w],
      ];
      final count = 8 + i;
      final length = 6000.0 + i * 450;
      return LevelConfig(
        index: level,
        name: levelNames[level - 1],
        length: length,
        spawns: _waves(level, length, waves.sublist(0, math.min(waves.length, count))),
        platforms: i.isEven ? _adventurePlatforms(level, length, 7 + i) : _platforms(level, length, 7 + i),
        spikes: _spikes(level, length, 4 + i),
        pendulums: _traps(level, length, 3 + i, 1200),
        vents: _traps(level + 100, length, 3 + i, 1000),
        boss: BossKind.none,
        tint: level == 19 ? const Color(0xFF6A2A08) : const Color(0xFF5A0A10),
        theme: level == 19 ? EnvTheme.volcano : EnvTheme.graveyard,
        rollingEvery: 6 - i * 0.4,
        fallingEvery: 4.2 - i * 0.35,
        speedMul: 1.42 + i * 0.03,
        cooldownMul: 0.58 - i * 0.025,
        damageMul: 1.45 + i * 0.05,
        hpMul: 1.7 + i * 0.08,
        detectMul: 1.7 + i * 0.05,
        dropMul: 0.85,
        revive: 0.25 + i * 0.06,
        seed: level,
      );
    case 20:
      return const LevelConfig(
        index: 20,
        name: 'THE TIGER GOD',
        length: 2800,
        spawns: [],
        platforms: [PlatformDef(420, -210, 230), PlatformDef(2150, -210, 230)],
        spikes: [],
        boss: BossKind.tiger,
        tint: Color(0xFF6A2008),
        theme: EnvTheme.volcano,
        damageMul: 1.3,
        seed: 20,
      );
    default:
      return const LevelConfig(
        index: 10,
        name: 'THRONE OF SHADOWS',
        length: 2600,
        spawns: [],
        platforms: [],
        spikes: [],
        boss: BossKind.finalBoss,
        tint: Color(0xFF3A1050),
        seed: 10,
      );
  }
}
