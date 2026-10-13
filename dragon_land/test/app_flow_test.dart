import 'package:dragon_land/app/dragon_land_app.dart';
import 'package:dragon_land/screens/coin_shop_screen.dart';
import 'package:dragon_land/screens/daily_rewards_screen.dart';
import 'package:dragon_land/screens/dragon_select_screen.dart';
import 'package:dragon_land/screens/dragon_shop_screen.dart';
import 'package:dragon_land/screens/gameplay_screen.dart';
import 'package:dragon_land/screens/lobby_screen.dart';
import 'package:dragon_land/screens/missions_screen.dart';
import 'package:dragon_land/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle(WidgetTester tester, [int ms = 600]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> boot(WidgetTester tester, Size logical) async {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = logical * 2.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const DragonLandApp(platformServices: false));
  await settle(tester, 3600);
  expect(find.byType(LobbyScreen), findsOneWidget);
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
  await settle(tester);
}

void main() {
  for (final size in const [Size(851, 393), Size(640, 360), Size(1280, 800)]) {
    testWidgets('menus render without overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await boot(tester, size);
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('DRAGON SHOP'), findsOneWidget);
      expect(find.text('SELECT DRAGON'), findsOneWidget);
      expect(find.text('DAILY REWARD'), findsOneWidget);
      expect(find.text('MISSIONS'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);

      await tester.tap(find.text('DRAGON SHOP'));
      await settle(tester);
      expect(find.byType(DragonShopScreen), findsOneWidget);
      for (final n in ['Ember', 'Aqua', 'Shadow', 'Leaf', 'Solar']) {
        expect(find.text(n), findsOneWidget);
      }
      expect(find.text('EQUIPPED'), findsOneWidget);
      await back(tester);

      await tester.tap(find.text('SELECT DRAGON'));
      await settle(tester);
      expect(find.byType(DragonSelectScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await settle(tester);
      expect(find.text('Aqua'), findsOneWidget);
      await back(tester);

      await tester.tap(find.text('DAILY REWARD'));
      await settle(tester);
      expect(find.byType(DailyRewardsScreen), findsOneWidget);
      await tester.tap(find.text('CLAIM DAY 1'));
      await settle(tester);
      expect(find.textContaining('Come back tomorrow'), findsOneWidget);
      expect(find.text('100'), findsWidgets); // balance pill shows the reward
      await back(tester);

      await tester.tap(find.text('MISSIONS'));
      await settle(tester);
      expect(find.byType(MissionsScreen), findsOneWidget);
      expect(find.text('Collect 100 coins'), findsOneWidget);
      await back(tester);

      await tester.tap(find.text('SETTINGS'));
      await settle(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.tap(find.byType(Switch).first);
      await settle(tester);
      await back(tester);

      await tester.tap(find.byIcon(Icons.add).first);
      await settle(tester);
      expect(find.byType(CoinShopScreen), findsOneWidget);
      // store is unavailable in tests: products show as unavailable, never "purchased"
      expect(find.text('UNAVAILABLE'), findsWidgets);
      await tester.tap(find.text('REMOVE ADS').last);
      await settle(tester);
      await back(tester);
    });
  }

  testWidgets('PLAY opens gameplay and pause returns to the lobby', (tester) async {
    await boot(tester, const Size(851, 393));
    await tester.tap(find.text('PLAY'));
    await settle(tester, 1500);
    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(find.text('JUMP'), findsOneWidget);
    expect(find.text('FLY'), findsOneWidget);
    expect(find.text('SPRINT'), findsOneWidget);
    expect(find.text('ATTACK'), findsOneWidget);
    expect(find.text('SPECIAL'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await settle(tester);
    expect(find.text('PAUSED'), findsOneWidget);
    await tester.tap(find.text('RESUME'));
    await settle(tester);
    expect(find.text('PAUSED'), findsNothing);
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await settle(tester);
    await tester.tap(find.text('MAIN MENU'));
    await settle(tester, 1500);
    expect(find.byType(LobbyScreen), findsOneWidget);
  });
}
