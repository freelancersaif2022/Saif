import 'dart:convert';

import 'package:alien_survival_3d/progression/catalog.dart';
import 'package:alien_survival_3d/storage/models.dart';
import 'package:alien_survival_3d/storage/save_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SaveData', () {
    test('round-trips through JSON', () {
      final d = SaveData()
        ..coins = 1234
        ..gems = 7
        ..unlocked = {'rifle', 'pistol', 'shotgun', 'sniper'}
        ..weaponLevels = {
          'rifle': {WeaponStat.damage: 3, WeaponStat.reload: 1},
        }
        ..playerLevels = {PlayerStat.health: 2}
        ..primary = 'sniper'
        ..secondary = 'shotgun'
        ..highScores = [HighScore(score: 900, wave: 4, kills: 40, seconds: 300, date: DateTime(2026, 10, 1))];
      d.stats.totalKills = 99;
      d.stats.killsByType = {'grunt': 50, 'boss': 1};
      final back = SaveData.fromJson(jsonDecode(jsonEncode(d.toJson())));
      expect(back.coins, 1234);
      expect(back.gems, 7);
      expect(back.unlocked, containsAll(['rifle', 'pistol', 'shotgun', 'sniper']));
      expect(back.weaponLevel('rifle', WeaponStat.damage), 3);
      expect(back.weaponLevel('rifle', WeaponStat.reload), 1);
      expect(back.playerLevel(PlayerStat.health), 2);
      expect(back.loadout, ['sniper', 'shotgun', 'pistol']);
      expect(back.highScores.single.score, 900);
      expect(back.stats.totalKills, 99);
      expect(back.stats.killsByType['boss'], 1);
    });

    test('rejects invalid and out-of-range values', () {
      final d = SaveData.fromJson({
        'coins': -50,
        'gems': 'lots',
        'unlocked': ['rifle', 'laser_cannon', 42],
        'weaponLevels': {
          'rifle': {'damage': 99},
          'bogus': {'damage': 1},
        },
        'playerLevels': {'health': -3, 'grenades': 50},
        'primary': 'minigun', // not unlocked
        'secondary': 'pistol', // sidearm cannot be secondary
        'highScores': [null, 'x', {'score': 10}],
        'stats': 'garbage',
      });
      expect(d.coins, 0);
      expect(d.gems, 0);
      expect(d.unlocked, {'rifle', 'pistol'});
      expect(d.weaponLevel('rifle', WeaponStat.damage), maxWeaponLevel);
      expect(d.weaponLevels.containsKey('bogus'), isFalse);
      expect(d.playerLevel(PlayerStat.health), 0);
      expect(d.playerLevel(PlayerStat.grenades), maxPlayerLevel[PlayerStat.grenades]);
      expect(d.primary, 'rifle');
      expect(d.secondary, '');
      expect(d.highScores.length, 1);
      expect(d.stats.totalKills, 0);
    });

    test('non-map input yields defaults', () {
      for (final bad in [null, 42, 'text', [1, 2]]) {
        final d = SaveData.fromJson(bad);
        expect(d.coins, 250);
        expect(d.loadout, ['rifle', 'pistol']);
      }
    });
  });

  group('Settings', () {
    test('clamps and validates', () {
      final s = Settings.fromJson({
        'quality': 'ULTRA',
        'fps': 144,
        'musicVolume': 7,
        'sensitivity': -1,
        'fov': 200,
        'shoulder': -5,
        'layout': {
          'fire': {'x': 0.9, 'y': 0.7},
          'aim': {'x': 'a', 'y': 1},
          'jump': {'x': 4, 'y': -2},
        },
      });
      expect(s.quality, Quality.MEDIUM);
      expect(s.fps, 60);
      expect(s.musicVolume, 1);
      expect(s.sensitivity, 0.2);
      expect(s.fov, 95);
      expect(s.shoulder, -1);
      expect(s.layout.keys, containsAll(['fire', 'jump']));
      expect(s.layout.containsKey('aim'), isFalse);
      expect(s.layout['jump'], {'x': 1.0, 'y': 0.0});
    });

    test('engine settings omit vibration and send null layout when unset', () {
      final e = Settings().toEngine();
      expect(e.containsKey('vibration'), isFalse);
      expect(e['layout'], isNull);
      expect(e['quality'], 'MEDIUM');
    });
  });

  group('SaveRepository', () {
    test('persists and reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await SaveRepository.open();
      final d = SaveData()..coins = 777;
      await repo.save(d);
      final s = Settings()..quality = Quality.HIGH;
      await repo.saveSettings(s);
      final repo2 = await SaveRepository.open();
      expect(repo2.loadSave().coins, 777);
      expect(repo2.loadSettings().quality, Quality.HIGH);
      expect(repo2.recovered, isFalse);
    });

    test('recovers from a corrupted main record using the backup', () async {
      final good = jsonEncode((SaveData()..coins = 4321).toJson());
      SharedPreferences.setMockInitialValues({
        SaveRepository.saveKey: '{"coins": 12, broken',
        '${SaveRepository.saveKey}_backup': good,
      });
      final repo = await SaveRepository.open();
      expect(repo.loadSave().coins, 4321);
      expect(repo.recovered, isTrue);
    });

    test('falls back to defaults when everything is corrupted', () async {
      SharedPreferences.setMockInitialValues({
        SaveRepository.saveKey: 'not json at all',
        '${SaveRepository.saveKey}_backup': '[1,2,3]',
        SaveRepository.settingsKey: '\u0000\u0001',
      });
      final repo = await SaveRepository.open();
      final d = repo.loadSave();
      expect(d.coins, 250);
      expect(d.unlocked, {'rifle', 'pistol'});
      expect(repo.loadSettings().quality, Quality.MEDIUM);
      expect(repo.recovered, isTrue);
    });
  });
}
