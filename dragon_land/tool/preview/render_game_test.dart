// Renders gameplay frames to PNG for visual review.
// Run: flutter test tool/preview/render_game_test.dart --dart-define=OUT=/some/dir
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dragon_land/game/dragon_land_game.dart';
import 'package:dragon_land/models/dragon_model.dart';
import 'package:dragon_land/models/player_progress_model.dart';
import 'package:dragon_land/services/audio_service.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/gameplay_simulation_test.dart' show autopilot;

const out = String.fromEnvironment('OUT', defaultValue: 'build/preview');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('render gameplay frames', () async {
    for (final (dragon, seconds, flyAt) in [(Dragons.ember, 8.0, -1.0), (Dragons.aqua, 30.0, 28.5), (Dragons.solar, 140.0, -1.0)]) {
      final g = await initializeGame(
        () => DragonLandGame(dragonDef: dragon, settings: GameSettings(), audio: AudioService(enabled: false), seed: 11),
      );
      g.onGameResize(Vector2(1600, 720));
      var t = 0.0;
      var captured = false;
      while (t < seconds) {
        autopilot(g, t);
        if (flyAt > 0 && (t - flyAt).abs() < 0.01) g.input.pressFly();
        g.update(1 / 60);
        t += 1 / 60;
        if (dragon == Dragons.solar && g.enemies.boss != null && g.enemies.boss!.actionT > 0.5 && !captured && t > 40) {
          captured = true;
          break;
        }
        if (g.phase == RunPhase.over) g.revive();
      }
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      g.render(c);
      final img = await rec.endRecording().toImage(1600, 720);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      File('$out/game_${dragon.id}.png')
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
      g.onRemove();
    }
  });
}
