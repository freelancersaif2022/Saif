// Dev tool: renders the launcher icon + splash logo from the in-game monster art.
// Run: flutter test tool/generate_icon_test.dart  (writes PNGs to build/icon/)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicebeast_arena/game/genome.dart';
import 'package:voicebeast_arena/models/element.dart';
import 'package:voicebeast_arena/widgets/monster_painter.dart';

const iconSeed = int.fromEnvironment('ICON_SEED', defaultValue: 31337);

Future<void> _save(String name, int size, void Function(Canvas c, double s) draw) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  draw(canvas, size.toDouble());
  final img = await rec.endRecording().toImage(size, size);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File('build/icon/$name')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _background(Canvas c, double s) {
  final rect = Rect.fromLTWH(0, 0, s, s);
  c.drawRect(rect, Paint()..shader = ui.Gradient.radial(Offset(s / 2, s * 0.45), s * 0.75, const [Color(0xFF8E6CFF), Color(0xFF3A1C8C), Color(0xFF0E0824)], const [0.0, 0.45, 1.0]));
  // light rays
  final ray = Paint()..color = Colors.white.withValues(alpha: 0.06);
  for (var i = 0; i < 12; i++) {
    c.save();
    c.translate(s / 2, s * 0.5);
    c.rotate(i * 3.14159 / 6);
    c.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-s * 0.08, -s)
        ..lineTo(s * 0.08, -s)
        ..close(),
      ray,
    );
    c.restore();
  }
}

void _monster(Canvas c, double s, double scale, {double dy = 0}) {
  final g = Genome.from(iconSeed, BeastElement.inferno, 3);
  final box = s * scale;
  c.save();
  c.translate((s - box) / 2, (s - box) / 2 + dy * s);
  MonsterPainter(g, t: 0.25, shadow: false).paint(c, Size(box, box));
  c.restore();
}

void main() {
  test('generate icons', () async {
    // Full square icon (Play Store 512 + legacy launcher icons).
    await _save('icon_1024.png', 1024, (c, s) {
      _background(c, s);
      _monster(c, s, 1.12, dy: -0.03);
    });
    // Adaptive icon foreground: art kept inside the 66/108 safe zone.
    await _save('foreground_1024.png', 1024, (c, s) => _monster(c, s, 0.8, dy: -0.02));
    await _save('background_1024.png', 1024, _background);
    // Splash logo (transparent).
    await _save('splash_1024.png', 1024, (c, s) => _monster(c, s, 1.0));
  });
}
