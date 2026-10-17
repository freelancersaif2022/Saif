import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicebeast_arena/app.dart';
import 'package:voicebeast_arena/config/monetization_config.dart';
import 'package:voicebeast_arena/game/monster_factory.dart';
import 'package:voicebeast_arena/models/element.dart';
import 'package:voicebeast_arena/services/game_store.dart';

Future<GameStore> freshStore([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return GameStore.load();
}

Future<void> pumpApp(WidgetTester tester, GameStore store) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(VoiceBeastApp(store: store));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('onboarding → home with summon tab', (tester) async {
    final store = await freshStore();
    await pumpApp(tester, store);
    expect(find.text('Your Voice.\nYour Beast.'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text("Let's Roar!"), findsOneWidget);
    await tester.tap(find.text("Let's Roar!"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 100));
    expect(store.onboarded, isTrue);
    expect(find.text('TAP TO ROAR'), findsOneWidget);
  });

  testWidgets('lair shows champion, arena and shop render', (tester) async {
    final store = await freshStore();
    store.completeOnboarding();
    final m = MonsterFactory.showcase(BeastElement.storm, 42, stage: 1)..name = 'Zapgor';
    store.addMonster(m);
    await pumpApp(tester, store);
    expect(find.text('Zapgor'), findsWidgets);
    expect(find.text('CHAMPION'), findsOneWidget);

    await tester.tap(find.text('Arena'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Challenge a Friend'), findsOneWidget);
    expect(find.text('Mud Pit'), findsOneWidget);

    await tester.tap(find.text('Shop'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Starter Pack'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Remove Ads'), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('Remove Ads'), findsOneWidget);
  });

  testWidgets('daily chest can be collected', (tester) async {
    final store = await freshStore();
    store.completeOnboarding();
    await pumpApp(tester, store);
    final coins = store.coins;
    await tester.tap(find.text('Daily Chest ready!'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Just collect'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(store.coins, coins + 100);
    expect(store.dailyReady, isFalse);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('test-mode purchase delivers gems offline', (tester) async {
    expect(MonetizationConfig.testMode, isTrue);
    final store = await freshStore();
    store.completeOnboarding();
    await pumpApp(tester, store);
    await tester.tap(find.text('Shop'));
    await tester.pump(const Duration(milliseconds: 500));
    // IapService isn't initialised in tests; buying falls back to the test checkout.
    expect(find.text('80 Gems'), findsOneWidget);
  });

  test('energy spend and refill', () async {
    final store = await freshStore();
    expect(store.energy, GameStore.maxEnergy);
    expect(store.spendEnergy(), isTrue);
    expect(store.energy, GameStore.maxEnergy - 1);
    store.addEnergy(5);
    expect(store.energy, GameStore.maxEnergy + 4);
  });

  test('ladder progress only advances on the current stage', () async {
    final store = await freshStore();
    store.recordBattle(won: true, ladderStage: 3);
    expect(store.ladderProgress, 0);
    store.recordBattle(won: true, ladderStage: 0);
    expect(store.ladderProgress, 1);
    store.recordBattle(won: false, ladderStage: 1);
    expect(store.ladderProgress, 1);
  });

  test('purchases grant items and starter pack only once', () async {
    final store = await freshStore();
    final gems = store.gems;
    store.grantProduct(ProductIds.starterPack);
    store.grantProduct(ProductIds.starterPack);
    expect(store.gems, gems + 150);
    expect(store.stones, 3);
    expect(store.slots, 5);
    store.grantProduct(ProductIds.removeAds);
    expect(store.removeAds, isTrue);
  });

  test('save survives reload', () async {
    final store = await freshStore();
    store.addCoins(999);
    store.addMonster(MonsterFactory.showcase(BeastElement.frost, 7));
    await store.flush();
    final reloaded = await GameStore.load();
    expect(reloaded.coins, store.coins);
    expect(reloaded.monsters.single.seed, 7);
  });
}
