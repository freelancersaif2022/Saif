import 'dart:math' as math;

/// Static weapon and upgrade data. The base stats mirror
/// engine_src/src/core/config.js; the upgraded values computed here are sent
/// to the 3D engine in the run configuration, so Flutter is the single source
/// of truth for progression.
class WeaponInfo {
  const WeaponInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.gemPrice = 0,
    required this.damage,
    required this.fireRate,
    required this.magazine,
    required this.reload,
    required this.range,
    this.pellets = 1,
    this.sidearm = false,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final int gemPrice;
  final double damage;

  /// Seconds between shots.
  final double fireRate;
  final int magazine;
  final double reload;
  final double range;
  final int pellets;
  final bool sidearm;

  String get image => 'assets/images/weapon_$id.png';
  double get roundsPerMinute => 60 / fireRate;
}

const weapons = <WeaponInfo>[
  WeaponInfo(id: 'rifle', name: 'Assault Rifle', description: 'Reliable automatic rifle. Good at every range.', price: 0, damage: 24, fireRate: 0.1, magazine: 30, reload: 2.0, range: 120),
  WeaponInfo(id: 'shotgun', name: 'Shotgun', description: 'Nine pellets per shell. Devastating up close.', price: 600, damage: 15, fireRate: 0.75, magazine: 8, reload: 2.6, range: 35, pellets: 9),
  WeaponInfo(id: 'smg', name: 'SMG', description: 'Very high fire rate, light and mobile.', price: 900, damage: 15, fireRate: 0.066, magazine: 35, reload: 1.6, range: 60),
  WeaponInfo(id: 'sniper', name: 'Sniper Rifle', description: 'Scoped, armor-piercing rounds that pass through several aliens.', price: 1500, damage: 160, fireRate: 1.25, magazine: 5, reload: 2.8, range: 320),
  WeaponInfo(id: 'minigun', name: 'Minigun', description: 'Spins up, then shreds everything. Slows you down.', price: 3000, gemPrice: 10, damage: 19, fireRate: 0.045, magazine: 200, reload: 4.2, range: 90),
  WeaponInfo(id: 'pistol', name: 'Pistol', description: 'Sidearm with unlimited reserve ammo.', price: 0, damage: 32, fireRate: 0.2, magazine: 12, reload: 1.2, range: 70, sidearm: true),
];

WeaponInfo weaponById(String id) => weapons.firstWhere((w) => w.id == id, orElse: () => weapons.first);

/// Upgrade tracks. Each level costs coins; the last two levels also cost gems.
enum WeaponStat { damage, magazine, reload }

enum PlayerStat { health, armor, grenades }

const maxWeaponLevel = 5;
const maxPlayerLevel = {PlayerStat.health: 5, PlayerStat.armor: 5, PlayerStat.grenades: 3};

String weaponStatLabel(WeaponStat s) => switch (s) {
      WeaponStat.damage => 'Damage',
      WeaponStat.magazine => 'Magazine',
      WeaponStat.reload => 'Reload Speed',
    };

String playerStatLabel(PlayerStat s) => switch (s) {
      PlayerStat.health => 'Max Health',
      PlayerStat.armor => 'Armor',
      PlayerStat.grenades => 'Grenades',
    };

class Cost {
  const Cost(this.coins, this.gems);
  final int coins;
  final int gems;
}

Cost weaponUpgradeCost(String weaponId, WeaponStat stat, int currentLevel) {
  final base = switch (stat) { WeaponStat.damage => 150, WeaponStat.magazine => 110, WeaponStat.reload => 100 };
  final tier = weaponId == 'minigun' || weaponId == 'sniper' ? 1.3 : 1.0;
  final coins = (base * tier * math.pow(currentLevel + 1, 1.6)).round();
  final gems = currentLevel >= 3 ? (currentLevel - 2) * 2 : 0;
  return Cost(coins, gems);
}

Cost playerUpgradeCost(PlayerStat stat, int currentLevel) {
  final base = switch (stat) { PlayerStat.health => 200, PlayerStat.armor => 180, PlayerStat.grenades => 250 };
  final coins = (base * math.pow(currentLevel + 1, 1.7)).round();
  final gems = currentLevel >= 3 ? currentLevel - 1 : 0;
  return Cost(coins, gems);
}

/// Multipliers applied per upgrade level.
double damageMultiplier(int level) => 1 + 0.12 * level;
double magazineMultiplier(int level) => 1 + 0.15 * level;
double reloadMultiplier(int level) => math.pow(0.9, level).toDouble();

/// Final weapon stats sent to the engine (overrides of its base table).
Map<String, Object> engineWeaponStats(String id, Map<WeaponStat, int> levels) {
  final w = weaponById(id);
  final dmg = levels[WeaponStat.damage] ?? 0;
  final mag = levels[WeaponStat.magazine] ?? 0;
  final rel = levels[WeaponStat.reload] ?? 0;
  final magazine = (w.magazine * magazineMultiplier(mag)).round();
  return {
    'damage': double.parse((w.damage * damageMultiplier(dmg)).toStringAsFixed(2)),
    'mag': magazine,
    'reload': double.parse((w.reload * reloadMultiplier(rel)).toStringAsFixed(3)),
    if (!w.sidearm) 'reserve': magazine * (id == 'minigun' ? 2 : id == 'sniper' || id == 'shotgun' ? 5 : 6),
    if (!w.sidearm) 'maxReserve': magazine * (id == 'minigun' ? 4 : 10),
  };
}

Map<String, Object> enginePlayerStats(Map<PlayerStat, int> levels) {
  final h = levels[PlayerStat.health] ?? 0;
  final a = levels[PlayerStat.armor] ?? 0;
  final g = levels[PlayerStat.grenades] ?? 0;
  return {
    'maxHealth': 100 + 20 * h,
    'maxArmor': 100 + 20 * a,
    'startArmor': 50 + 10 * a,
    'grenades': 3 + g,
    'maxGrenades': 6 + g,
  };
}

/// Alien roster shown in the statistics screen (mirrors the engine).
class AlienInfo {
  const AlienInfo(this.id, this.name, this.color);
  final String id;
  final String name;
  final int color;
}

const aliens = <AlienInfo>[
  AlienInfo('grunt', 'Purple Grunt', 0xFFB44DFF),
  AlienInfo('runner', 'Red Stalker', 0xFFFF3B2F),
  AlienInfo('tank', 'Blue Brute', 0xFF2EE6FF),
  AlienInfo('crawler', 'Green Crawler', 0xFF9DFF2E),
  AlienInfo('spitter', 'Acid Spitter', 0xFFD8FF3A),
  AlienInfo('exploder', 'Bloater', 0xFFFF9B1F),
  AlienInfo('flyer', 'Sky Wraith', 0xFF4DFFF0),
  AlienInfo('elite', 'Void Elite', 0xFFFF2EE6),
  AlienInfo('boss', 'Hive Titan', 0xFF7A5CFF),
];
