import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realclash/game/real_clash_game.dart';
import 'package:realclash/main.dart';
import 'package:realclash/ui/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('boots through splash into a running game', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(GameScreen), findsOneWidget);

    final state = tester.state(find.byType(GameScreen));
    final game = (state as dynamic).game as RealClashGame;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    game.startGame();
    for (var i = 0; i < 1200; i++) {
      if (i % 40 == 0) game.leftHeld = !game.leftHeld;
      await tester.pump(const Duration(milliseconds: 33));
    }
    expect(game.state == GameState.playing || game.state == GameState.over, isTrue);

    // Visit every overlay.
    Future<void> frames(int n) async {
      for (var i = 0; i < n; i++) {
        await tester.pump(const Duration(milliseconds: 33));
      }
    }

    if (game.state == GameState.playing) {
      game.pauseGame();
      await frames(10);
      game.openSettings();
      await frames(10);
      game.closeSettings();
      await frames(5);
      game.resumeGame();
      await frames(10);
    }
    game.leftHeld = false;
    game.rightHeld = false;
    for (var i = 0; i < 6000 && game.state != GameState.over; i++) {
      await tester.pump(const Duration(milliseconds: 33));
    }
    await frames(60);
    expect(game.state, GameState.over);
    game.openShop();
    await frames(20);
    game.closeShop();
    await frames(10);
    game.toMenu();
    await frames(30);
    game.openSettings();
    await frames(10);
    game.closeSettings();
    await frames(10);
    expect(tester.takeException(), isNull);
  });
}
