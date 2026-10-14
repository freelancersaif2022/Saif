import 'package:alien_survival_3d/app/app.dart';
import 'package:alien_survival_3d/progression/catalog.dart';
import 'package:alien_survival_3d/progression/game_state.dart';
import 'package:alien_survival_3d/storage/models.dart';
import 'package:alien_survival_3d/storage/save_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GameState> pumpApp(WidgetTester tester, {int coins = 2000, int gems = 20, Size size = const Size(1600, 760)}) async {
  SharedPreferences.setMockInitialValues({});
  final repo = await SaveRepository.open();
  final state = GameState(repo, SaveData()
    ..coins = coins
    ..gems = gems, Settings());
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AlienSurvivalApp(initialState: state));
  await tester.pumpAndSettle();
  return state;
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.text('BACK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('main menu shows PLAY, SETTINGS, SHOP, UPGRADE and EXIT', (tester) async {
    await pumpApp(tester);
    for (final t in ['PLAY', 'SETTINGS', 'SHOP', 'UPGRADE', 'EXIT', 'STATS', 'HIGH SCORES']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.byKey(const Key('coins')), findsOneWidget);
  });

  testWidgets('every menu button opens its screen and BACK returns', (tester) async {
    await pumpApp(tester);
    for (final (key, title) in [('settings', 'SETTINGS'), ('shop', 'SHOP'), ('upgrade', 'UPGRADES')]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets);
      expect(find.text('BACK'), findsOneWidget);
      await back(tester);
      expect(find.byKey(const Key('play')), findsOneWidget);
    }
    await tester.tap(find.text('STATS'));
    await tester.pumpAndSettle();
    expect(find.text('STATISTICS'), findsOneWidget);
    expect(find.text('ALIENS ELIMINATED'), findsOneWidget);
    await back(tester);
    await tester.tap(find.text('HIGH SCORES'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No runs yet'), findsOneWidget);
    await back(tester);
    await tester.tap(find.byKey(const Key('play')));
    await tester.pumpAndSettle();
    expect(find.text('WEAPON SELECTION'), findsOneWidget);
    expect(find.byKey(const Key('deploy')), findsOneWidget);
  });

  testWidgets('EXIT asks for confirmation', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('exit')));
    await tester.pumpAndSettle();
    expect(find.text('EXIT GAME?'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('EXIT GAME?'), findsNothing);
  });

  testWidgets('shop purchase spends coins and unlocks the weapon', (tester) async {
    final s = await pumpApp(tester, coins: 1000);
    await tester.tap(find.byKey(const Key('shop')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('buy_shotgun')));
    await tester.tap(find.byKey(const Key('buy_shotgun')));
    await tester.pumpAndSettle();
    expect(s.owns('shotgun'), isTrue);
    expect(s.save.coins, 400);
    expect(find.text('400'), findsWidgets);
    // persisted
    final repo = await SaveRepository.open();
    expect(repo.loadSave().unlocked, contains('shotgun'));
  });

  testWidgets('upgrade screen upgrades soldier and weapon stats', (tester) async {
    final s = await pumpApp(tester, coins: 5000);
    await tester.tap(find.byKey(const Key('upgrade')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('up_health')));
    await tester.pumpAndSettle();
    expect(s.save.playerLevel(PlayerStat.health), 1);
    await tester.tap(find.byKey(const Key('tab_rifle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('up_rifle_damage')));
    await tester.pumpAndSettle();
    expect(s.save.weaponLevel('rifle', WeaponStat.damage), 1);
  });

  testWidgets('settings changes persist', (tester) async {
    final s = await pumpApp(tester);
    await tester.tap(find.byKey(const Key('settings')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('opt_Quality_HIGH')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('opt_Quality_HIGH')));
    await tester.pumpAndSettle();
    expect(s.settings.quality, Quality.HIGH);
    final repo = await SaveRepository.open();
    expect(repo.loadSettings().quality, Quality.HIGH);
  });

  testWidgets('loadout selection picks primary and secondary', (tester) async {
    final s = await pumpApp(tester);
    s.save.unlocked.addAll(['shotgun', 'smg']);
    await tester.tap(find.byKey(const Key('play')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SHOTGUN'));
    await tester.pumpAndSettle();
    expect(find.text('SECONDARY'), findsOneWidget);
    expect(find.textContaining('Assault Rifle  ·  Shotgun  ·  Pistol'), findsOneWidget);
  });

  for (final size in [const Size(1280, 640), const Size(1830, 824)]) {
    testWidgets('screens lay out without overflow at ${size.width ~/ 2}x${size.height ~/ 2}', (tester) async {
      final s = await pumpApp(tester, size: size, coins: 99999, gems: 99);
      s.save.unlocked.addAll(weapons.map((w) => w.id));
      s.save.highScores.add(HighScore(score: 123456, wave: 12, kills: 300, seconds: 1500, date: DateTime(2026, 10, 14)));
      for (final key in ['settings', 'shop', 'upgrade']) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: key);
        await back(tester);
      }
      for (final t in ['STATS', 'HIGH SCORES']) {
        await tester.tap(find.text(t));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: t);
        await back(tester);
      }
      await tester.tap(find.byKey(const Key('play')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'loadout');
    });
  }
}
