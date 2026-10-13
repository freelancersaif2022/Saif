// Generates the Android launcher icons and the 512px store icon from the
// game's own vector dragon art.
// Run from the project root: flutter test tool/gen_icon_test.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dragon_land/art/dragon_art.dart';
import 'package:dragon_land/models/dragon_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> renderIcon(int size, String path) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  final s = size.toDouble();
  final rect = Rect.fromLTWH(0, 0, s, s);
  c.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(s * 0.5, s * 0.35),
        s * 0.8,
        const [Color(0xFF8FE3FF), Color(0xFF2F8FE8), Color(0xFF4E2A96)],
        const [0.0, 0.6, 1.0],
      ),
  );
  // sun rays
  final rays = Paint()..color = const Color(0x22FFFFFF);
  for (var i = 0; i < 12; i++) {
    final a = i / 12 * math.pi * 2;
    final p = Path()
      ..moveTo(s / 2, s / 2)
      ..lineTo(s / 2 + math.cos(a - 0.12) * s, s / 2 + math.sin(a - 0.12) * s)
      ..lineTo(s / 2 + math.cos(a + 0.12) * s, s / 2 + math.sin(a + 0.12) * s)
      ..close();
    c.drawPath(p, rays);
  }
  // island
  c.drawOval(
    Rect.fromCenter(center: Offset(s * 0.5, s * 0.82), width: s * 0.8, height: s * 0.16),
    Paint()..color = const Color(0xFF4CCB55),
  );
  c.drawOval(Rect.fromCenter(center: Offset(s * 0.5, s * 0.8), width: s * 0.72, height: s * 0.1), Paint()..color = const Color(0xFF8BE57A));
  final pose = DragonPose()
    ..wingSpread = 0.9
    ..flapAmount = 0.3
    ..flapPhase = 1.2
    ..happy = 1
    ..time = 1.0;
  c.save();
  c.translate(s * 0.5, s * 0.78);
  DragonArt.paint(c, Dragons.ember, pose, scale: s / 320);
  c.restore();
  final img = await rec.endRecording().toImage(size, size);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('generate icons', (tester) async {
    await tester.runAsync(() async {
      const res = 'android/app/src/main/res';
      for (final (dir, size) in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]) {
        await renderIcon(size, '$res/mipmap-$dir/ic_launcher.png');
      }
      await renderIcon(512, 'store/icon_512.png');
    });
  });
}
