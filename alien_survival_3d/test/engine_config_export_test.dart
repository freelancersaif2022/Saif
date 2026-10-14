import 'dart:convert';
import 'dart:io';

import 'package:alien_survival_3d/progression/catalog.dart';
import 'package:alien_survival_3d/progression/game_state.dart';
import 'package:alien_survival_3d/storage/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes the exact boot configuration Flutter sends to the engine for an
/// upgraded profile, so the browser integration scenario
/// (engine_src/dev/scenarios/host.mjs) can boot the engine with it.
void main() {
  test('export engine boot config sample', () async {
    final s = GameState(null, SaveData()
      ..coins = 1e6.toInt()
      ..gems = 1000, Settings()..quality = Quality.LOW);
    await s.buyWeapon('shotgun');
    for (var i = 0; i < 2; i++) {
      await s.upgradeWeapon('rifle', WeaponStat.magazine);
    }
    await s.upgradeWeapon('shotgun', WeaponStat.damage);
    await s.upgradePlayer(PlayerStat.health);
    await s.upgradePlayer(PlayerStat.grenades);
    s.settings.layout = {'fire': {'x': 0.8, 'y': 0.6}};
    final dir = Directory('build')..createSync(recursive: true);
    File('${dir.path}/engine_config_sample.json').writeAsStringSync(jsonEncode(s.engineConfig()));
    File('${dir.path}/engine_config_layout.json').writeAsStringSync(jsonEncode(s.engineConfig(mode: 'layout')));
    expect(File('build/engine_config_sample.json').existsSync(), isTrue);
  });
}
