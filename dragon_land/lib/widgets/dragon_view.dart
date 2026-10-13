import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../art/dragon_art.dart';
import '../models/dragon_model.dart';

/// Animated dragon for menus: breathes, blinks, sways its tail, flaps its
/// wings, plays occasional idle animations and reacts when tapped.
class DragonView extends StatefulWidget {
  const DragonView({
    super.key,
    required this.dragon,
    this.size = 220,
    this.interactive = true,
    this.locked = false,
    this.celebrate = 0,
    this.flying = false,
  });

  final DragonDef dragon;
  final double size;
  final bool interactive;

  /// Shows the dragon as a dark silhouette.
  final bool locked;

  /// Increment to play the "selected" celebration.
  final int celebrate;
  final bool flying;

  @override
  State<DragonView> createState() => _DragonViewState();
}

class _DragonViewState extends State<DragonView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final DragonPose _pose = DragonPose();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();
  Duration _last = Duration.zero;
  double _t = 0;
  double _blinkIn = 2;
  double _idleIn = 4;
  double _hop = 0; // jump reaction
  double _roar = 0; // mouth open reaction
  double _spin = 0; // celebration
  double _flap = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didUpdateWidget(DragonView old) {
    super.didUpdateWidget(old);
    if (widget.celebrate != old.celebrate) _celebrate();
  }

  void _celebrate() {
    _spin = 1;
    _hop = 1;
    _roar = 0.8;
  }

  void _tap() {
    if (!widget.interactive) return;
    switch (_rng.nextInt(3)) {
      case 0:
        _hop = 1;
      case 1:
        _roar = 0.7;
      default:
        _flap = 1.2;
    }
  }

  void _tick(Duration now) {
    final dt = _last == Duration.zero ? 0.016 : ((now - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = now;
    _t += dt;
    final p = _pose;
    p.time = _t;
    p.breath += dt * 2.6;
    p.runAmount = 0;
    _blinkIn -= dt;
    if (_blinkIn < 0) {
      p.blink = 1;
      if (_blinkIn < -0.13) {
        p.blink = 0;
        _blinkIn = 1.5 + _rng.nextDouble() * 3;
      }
    }
    _idleIn -= dt;
    if (_idleIn < 0) {
      _idleIn = 3 + _rng.nextDouble() * 4;
      if (_rng.nextBool()) {
        _flap = 1.0;
      } else {
        _roar = 0.5;
      }
    }
    if (_hop > 0) _hop = math.max(0, _hop - dt * 1.6);
    if (_roar > 0) _roar = math.max(0, _roar - dt);
    if (_spin > 0) _spin = math.max(0, _spin - dt * 0.9);
    if (_flap > 0) _flap = math.max(0, _flap - dt);
    final flying = widget.flying || _flap > 0;
    p.wingSpread += ((flying ? 1.0 : 0.3) - p.wingSpread) * math.min(1, dt * 6);
    p.flapAmount = flying ? 0.55 : 0.12;
    p.flapPhase += dt * (flying ? 12 : 3.5);
    p.mouthOpen += ((_roar > 0.1 ? 1.0 : 0.0) - p.mouthOpen) * math.min(1, dt * 12);
    p.happy = _spin > 0 || _hop > 0 ? 1 : 0;
    p.tuck = _hop > 0.2 ? 0.8 : 0;
    p.tilt = math.sin(_t * 0.9) * 0.02 - _spin * 0.1;
    p.glow = _spin > 0 ? _spin : 0;
    _frame.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _DragonPainter(
              widget.dragon,
              _pose,
              _frame,
              widget.locked,
              () => _hop,
              () => widget.flying ? math.sin(_t * 2) * 8 : 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _DragonPainter extends CustomPainter {
  _DragonPainter(this.dragon, this.pose, this.frame, this.locked, this.hop, this.hover) : super(repaint: frame);

  final DragonDef dragon;
  final DragonPose pose;
  final ValueNotifier<int> frame;
  final bool locked;
  final double Function() hop;
  final double Function() hover;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 260;
    final h = hop();
    final jump = math.sin(h * math.pi) * 40 * scale;
    final feet = Offset(size.width * 0.5, size.height * 0.92 - jump + hover() * scale);
    // soft shadow
    final shadowK = 1 - jump / (60 * scale);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.93), width: 150 * scale * shadowK, height: 20 * scale * shadowK),
      Paint()..color = const Color(0x44203020),
    );
    canvas.save();
    canvas.translate(feet.dx - 6 * scale, feet.dy);
    if (locked) {
      canvas.saveLayer(
        Rect.fromLTWH(-200 * scale, -260 * scale, 420 * scale, 300 * scale),
        Paint()..colorFilter = const ColorFilter.mode(Color(0xFF2A1636), BlendMode.srcIn),
      );
    }
    DragonArt.paint(canvas, dragon, pose, scale: scale);
    if (locked) canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DragonPainter old) => old.dragon != dragon || old.locked != locked;
}
