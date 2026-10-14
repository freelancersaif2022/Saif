import 'package:alien_survival_3d/progression/catalog.dart';
import 'package:alien_survival_3d/progression/game_state.dart';
import 'package:alien_survival_3d/storage/models.dart';
import 'package:flutter_test/flutter_test.dart';

GameState fresh({int coins = 250, int gems = 0}) => GameState(null, SaveData()
  ..coins = coins
  ..gems = gems, Settings());

void main() {
  test('weapon purchase needs enough coins and adds it to the loadout', () async {
    final s = fresh(coins: 500);
    expect(await s.buyWeapon('shotgun'), PurchaseResult.notEnoughCoins);
    s.save.coins = 700;
    expect(await s.buyWeapon('shotgun'), PurchaseResult.ok);
    expect(s.save.coins, 100);
    expect(s.owns('shotgun'), isTrue);
    expect(s.save.loadout, ['rifle', 'shotgun', 'pistol']);
    expect(await s.buyWeapon('shotgun'), PurchaseResult.alreadyOwned);
  });

  test('minigun also costs gems', () async {
    final s = fresh(coins: 5000, gems: 3);
    expect(await s.buyWeapon('minigun'), PurchaseResult.notEnoughGems);
    s.save.gems = 10;
    expect(await s.buyWeapon('minigun'), PurchaseResult.ok);
    expect(s.save.gems, 0);
  });

  test('weapon upgrades: costs grow, top levels need gems, max is enforced', () async {
    final s = fresh(coins: 100000, gems: 100);
    final costs = <int>[];
    for (var i = 0; i < maxWeaponLevel; i++) {
      final c = weaponUpgradeCost('rifle', WeaponStat.damage, i);
      costs.add(c.coins);
      if (i >= 3) expect(c.gems, greaterThan(0));
      expect(await s.upgradeWeapon('rifle', WeaponStat.damage), PurchaseResult.ok);
    }
    for (var i = 1; i < costs.length; i++) {
      expect(costs[i], greaterThan(costs[i - 1]));
    }
    expect(await s.upgradeWeapon('rifle', WeaponStat.damage), PurchaseResult.maxed);
    expect(await s.upgradeWeapon('sniper', WeaponStat.damage), PurchaseResult.locked);
    final stats = engineWeaponStats('rifle', s.save.weaponLevels['rifle']!);
    expect(stats['damage'], closeTo(24 * 1.6, 0.01));
  });

  test('upgraded stats are sent to the engine config', () async {
    final s = fresh(coins: 100000, gems: 100);
    await s.upgradeWeapon('rifle', WeaponStat.magazine);
    await s.upgradeWeapon('rifle', WeaponStat.reload);
    await s.upgradePlayer(PlayerStat.health);
    await s.upgradePlayer(PlayerStat.grenades);
    final cfg = s.engineConfig();
    expect(cfg['loadout'], ['rifle', 'pistol']);
    final rifle = (cfg['weapons'] as Map)['rifle'] as Map;
    expect(rifle['mag'], 35); // 30 * 1.15 rounded
    expect(rifle['reload'], closeTo(1.8, 0.001));
    final player = cfg['player'] as Map;
    expect(player['maxHealth'], 120);
    expect(player['grenades'], 4);
    final pistol = (cfg['weapons'] as Map)['pistol'] as Map;
    expect(pistol.containsKey('reserve'), isFalse); // unlimited sidearm ammo
    expect((cfg['settings'] as Map)['quality'], 'MEDIUM');
  });

  test('loadout rejects unowned weapons and sidearms', () async {
    final s = fresh();
    await s.setLoadout('minigun', 'pistol');
    expect(s.save.primary, 'rifle');
    expect(s.save.secondary, '');
  });

  test('run rewards, statistics and high-score table', () async {
    final s = fresh(coins: 0);
    for (var i = 0; i < 12; i++) {
      await s.applyRun(RunResult({'score': 1000 * (i + 1), 'wave': i, 'kills': 10, 'time': 60, 'coins': 5, 'gems': 0, 'killsByType': {'grunt': 10}}));
    }
    expect(s.save.highScores.length, 10);
    expect(s.save.highScores.first.score, 12000);
    expect(s.save.highScores.last.score, 3000);
    expect(s.save.stats.gamesPlayed, 12);
    expect(s.save.stats.killsByType['grunt'], 120);
    expect(s.save.stats.bestWave, 11);
    final r = await s.applyRun(RunResult({'score': 50000, 'wave': 9, 'kills': 120, 'time': 600, 'coins': 80, 'gems': 2, 'accuracy': 40}));
    expect(r.newHighScore, isTrue);
    expect(r.rank, 1);
    expect(r.totalCoins, 80 + 90 + 125);
    expect(s.save.gems, 2);
    final low = await s.applyRun(RunResult({'score': 1, 'wave': 1}));
    expect(low.rank, 0);
    expect(low.newHighScore, isFalse);
  });

  test('malformed run results are tolerated', () async {
    final s = fresh(coins: 10);
    final r = await s.applyRun(RunResult({'score': 'NaN', 'wave': -4, 'coins': 1e20, 'killsByType': 'x'}));
    expect(r.coinsCollected, 1 << 30);
    expect(s.save.stats.gamesPlayed, 1);
  });
}
