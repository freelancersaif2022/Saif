import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../entities/player.dart';
import '../game/amadan_game.dart';

/// Full-screen post effects: cinematic vignette, damage flashes, the subtle
/// red danger pulse during critical moments and explosion flashes.
class ScreenFxComponent extends Component with HasGameReference<AmadanGame> {
  ScreenFxComponent() : super(priority: 10);

  final Paint _vignette = Paint();
  final Paint _red = Paint();
  final Paint _flat = Paint();
  double _forW = -1;
  double _forH = -1;

  void _rebuild(double w, double h) {
    _forW = w;
    _forH = h;
    final center = Offset(w / 2, h / 2);
    final radius = math.sqrt(w * w + h * h) / 2;
    _vignette.shader = ui.Gradient.radial(
      center,
      radius,
      const <Color>[Color(0x00000000), Color(0x00000000), Color(0x8C000000)],
      const <double>[0.0, 0.55, 1.0],
    );
    _red.shader = ui.Gradient.radial(
      center,
      radius,
      const <Color>[Color(0x00FF0000), Color(0x00B01008), Color(0xFFB01008)],
      const <double>[0.0, 0.5, 1.0],
    );
  }

  @override
  void render(Canvas canvas) {
    final g = game;
    if (!g.isReady) return;
    final w = g.size.x;
    final h = g.size.y;
    if (w <= 0 || h <= 0) return;
    if (w != _forW || h != _forH) _rebuild(w, h);
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(rect, _vignette);

    var redA = g.damagePulse * 0.55;
    final p = g.player;
    if (p.alive && p.hp < Player.maxHp * 0.3) {
      redA = math.max(redA, 0.16 + 0.12 * math.sin(g.session.time * 5));
    }
    final boss = g.director.boss;
    if (boss != null && boss.alive && boss.critical) {
      redA = math.max(redA, g.dangerPulse * 0.32);
    } else {
      redA = math.max(redA, g.dangerPulse * 0.4);
    }
    if (redA > 0.01) {
      _red.color = Color.fromRGBO(255, 255, 255, redA.clamp(0.0, 1.0));
      canvas.drawRect(rect, _red);
    }
    if (g.flashPulse > 0.01) {
      _flat.color = Color.fromRGBO(255, 236, 200, g.flashPulse.clamp(0.0, 1.0));
      canvas.drawRect(rect, _flat);
    }
    if (g.phase == GamePhase.dying || g.phase == GamePhase.gameOver) {
      final t = (p.deathTimer / 2.4).clamp(0.0, 1.0);
      _flat.color = Color.fromRGBO(20, 4, 2, 0.55 * t);
      canvas.drawRect(rect, _flat);
    }
  }
}
