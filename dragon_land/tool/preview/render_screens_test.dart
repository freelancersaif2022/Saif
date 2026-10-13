// Captures screenshots of the menu screens (real fonts) for visual review.
// Run: flutter test tool/preview/render_screens_test.dart --dart-define=OUT=/some/dir
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dragon_land/app/dragon_land_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const out = String.fromEnvironment('OUT', defaultValue: 'build/preview');

Future<void> loadFont(String family, String asset) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}

void main() {
  testWidgets('screens', (tester) async {
    await tester.runAsync(() async {
      await loadFont('LilitaOne', 'assets/fonts/LilitaOne-Regular.ttf');
      await loadFont('Fredoka', 'assets/fonts/Fredoka.ttf');
      final icons = File('/opt/flutter-sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
      if (icons.existsSync()) {
        final l = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
        await l.load();
      }
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(851, 393);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const DragonLandApp(platformServices: false)));

    Future<void> shot(String name) async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.runAsync(() async {
        final ro = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await ro.toImage(pixelRatio: 1.5);
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$out/screen_$name.png')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }

    Future<void> wait(int ms) async {
      for (var i = 0; i < ms ~/ 50; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await wait(1000);
    await shot('splash');
    await wait(3000);
    await shot('lobby');
    Future<void> visit(String button, String name, {String? tap}) async {
      await tester.tap(find.text(button).first);
      await wait(600);
      if (tap != null) {
        await tester.tap(find.text(tap).first);
        await wait(600);
      }
      await shot(name);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await wait(600);
    }

    await visit('DRAGON SHOP', 'dragon_shop');
    await visit('SELECT DRAGON', 'select');
    await visit('DAILY REWARD', 'daily');
    await visit('MISSIONS', 'missions');
    await visit('SETTINGS', 'settings');
    await tester.tap(find.byIcon(Icons.add).first);
    await wait(600);
    await shot('shop');
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await wait(600);
    await tester.tap(find.text('PLAY'));
    for (var i = 0; i < 160; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await shot('gameplay');
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await wait(400);
    await shot('pause');
  });
}
