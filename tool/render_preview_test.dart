// Dev tool: renders a sheet of sample monsters to build/preview.png
// Run: flutter test tool/render_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicebeast_arena/game/genome.dart';
import 'package:voicebeast_arena/models/element.dart';
import 'package:voicebeast_arena/widgets/monster_painter.dart';

void main() {
  test('render preview sheet', () async {
    const cell = 300.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawRect(const Rect.fromLTWH(0, 0, cell * 6, cell * 3), Paint()..color = const Color(0xFF15102B));
    for (var row = 0; row < 3; row++) {
      for (var i = 0; i < 6; i++) {
        canvas.save();
        canvas.translate(i * cell, row * cell);
        final g = Genome.from(1000 + i * 37 + row * 991, BeastElement.values[i], row + 1);
        MonsterPainter(g, t: 0.2).paint(canvas, const Size(cell, cell));
        canvas.restore();
      }
    }
    final img = await rec.endRecording().toImage((cell * 6).toInt(), (cell * 3).toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('build/preview.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
