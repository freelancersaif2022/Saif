// Dev tool: renders attack effects mid-animation to build/fx.png
// Run: flutter test tool/render_fx_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicebeast_arena/models/element.dart';
import 'package:voicebeast_arena/widgets/battle_fx.dart';

void main() {
  testWidgets('render fx sheet', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    final cases = <(FxEffect, int)>[
      (FxEffect(FxKind.slash, from: const Offset(60, 150), to: const Offset(100, 100), size: 140, duration: 0.55), 120),
      (FxEffect(FxKind.slash, from: const Offset(60, 150), to: const Offset(100, 100), size: 140, duration: 0.55), 200),
      (FxEffect(FxKind.slash, from: const Offset(60, 150), to: const Offset(100, 100), size: 140, crit: true, duration: 0.55), 260),
      for (final e in BeastElement.values) (FxEffect(FxKind.projectile, from: const Offset(30, 170), to: const Offset(170, 50), element: e, size: 140, duration: 0.95), 220),
      (FxEffect(FxKind.projectile, from: const Offset(30, 170), to: const Offset(150, 70), element: BeastElement.inferno, size: 140, duration: 0.95), 450),
      (FxEffect(FxKind.shockwave, from: const Offset(100, 100), to: const Offset(100, 100), size: 120, duration: 0.9), 300),
      (FxEffect(FxKind.shield, from: const Offset(100, 100), to: const Offset(100, 100), size: 140, duration: 0.9), 400),
      (FxEffect(FxKind.heal, from: const Offset(100, 100), to: const Offset(100, 100), size: 140, duration: 0.9), 300),
    ];
    final key = GlobalKey();
    final ctrls = [for (final _ in cases) BattleFxController()];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Container(
            color: const Color(0xFF15102B),
            child: Wrap(
              children: [for (var i = 0; i < cases.length; i++) SizedBox(width: 200, height: 200, child: BattleFxLayer(controller: ctrls[i]))],
            ),
          ),
        ),
      ),
    );
    // Stagger: start each effect so that after the final pump it sits at its target time.
    const total = 500;
    final order = List.generate(cases.length, (i) => i)..sort((a, b) => cases[b].$2.compareTo(cases[a].$2));
    var elapsed = 0;
    for (final i in order) {
      final startAt = total - cases[i].$2;
      if (startAt > elapsed) {
        await tester.pump(Duration(milliseconds: startAt - elapsed));
        elapsed = startAt;
      }
      ctrls[i].add(cases[i].$1);
      await tester.pump();
    }
    await tester.pump(Duration(milliseconds: total - elapsed));
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await tester.runAsync(() => boundary.toImage());
    final bytes = await tester.runAsync(() => img!.toByteData(format: ui.ImageByteFormat.png));
    File('build/fx.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
