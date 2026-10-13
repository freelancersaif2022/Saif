// Renders preview sheets of the procedural art to PNG files.
// Run: flutter test tool/preview/render_dragons_test.dart --dart-define=OUT=/some/dir
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dragon_land/art/dragon_art.dart';
import 'package:dragon_land/art/enemy_art.dart';
import 'package:dragon_land/art/prop_art.dart';
import 'package:dragon_land/models/dragon_model.dart';
import 'package:dragon_land/models/enemy_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const out = String.fromEnvironment('OUT', defaultValue: 'build/preview');

Future<void> writePng(ui.Image img, String name) async {
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  final f = File('$out/$name');
  f.parent.createSync(recursive: true);
  f.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render dragons', (tester) async {
    await tester.runAsync(() async {
      const w = 1500.0, h = 760.0;
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      c.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF9ED8FF));
      final poses = <DragonPose>[
        DragonPose()..breath = 0.5,
        DragonPose()
          ..runAmount = 1
          ..runPhase = 0.25
          ..time = 1,
        DragonPose()
          ..wingSpread = 1
          ..flapAmount = 0.5
          ..flapPhase = 1
          ..tuck = 1
          ..mouthOpen = 1,
      ];
      for (var i = 0; i < Dragons.all.length; i++) {
        for (var j = 0; j < poses.length; j++) {
          c.save();
          c.translate(150 + i * 290.0, 220 + j * 250.0);
          DragonArt.paint(c, Dragons.all[i], poses[j]..time = 1.3, scale: 1.0);
          c.restore();
        }
      }
      final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
      await writePng(img, 'dragons.png');

      final rec2 = ui.PictureRecorder();
      final c2 = Canvas(rec2);
      c2.drawRect(const Rect.fromLTWH(0, 0, 1500, 700), Paint()..color = const Color(0xFF9ED8FF));
      var x = 100.0;
      for (final k in EnemyKind.values) {
        if (k == EnemyKind.boss) continue;
        c2.save();
        c2.translate(x, 250);
        EnemyArt.paint(c2, k, 0.2);
        c2.restore();
        x += 220;
      }
      c2.save();
      c2.translate(1150, 330);
      EnemyArt.paint(c2, EnemyKind.boss, 0.2, action: 0.5);
      c2.restore();
      final props = <void Function(Canvas)>[
        (c) => PropArt.coin(c, 0.1),
        (c) => PropArt.gem(c, 0.1),
        (c) => PropArt.crystal(c, 0.1),
        (c) => PropArt.boulder(c, crack: 1),
        (c) => PropArt.thorns(c, 0.1),
        (c) => PropArt.barrier(c, 0.1),
        (c) => PropArt.spikePod(c, 0.1),
        (c) => PropArt.chest(c, 0.1),
        (c) => PropArt.gate(c, 0.1, r: 60),
        (c) => PropArt.heart(c, 0.1),
        (c) => PropArt.magnet(c, 0.1),
      ];
      for (var i = 0; i < props.length; i++) {
        c2.save();
        c2.translate(70 + i * 128.0, 640);
        props[i](c2);
        c2.restore();
      }
      final img2 = await rec2.endRecording().toImage(1500, 700);
      await writePng(img2, 'enemies.png');
    });
  });
}
