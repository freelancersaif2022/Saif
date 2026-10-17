import 'dart:math';

import 'package:flutter/material.dart';

import '../game/genome.dart';
import '../models/monster.dart';
import 'monster_painter.dart';

/// Animated monster: breathing, swaying, random blinking.
/// Set [animate] false in lists for best scrolling performance.
class MonsterView extends StatefulWidget {
  const MonsterView({super.key, required this.monster, this.size = 200, this.animate = true, this.flash = 0, this.facingLeft = false, this.shadow = true});
  final Monster monster;
  final double size;
  final bool animate;
  final double flash;
  final bool facingLeft;
  final bool shadow;

  @override
  State<MonsterView> createState() => _MonsterViewState();
}

class _MonsterViewState extends State<MonsterView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  final _rnd = Random();
  double _nextBlinkAt = 0.4;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant MonsterView old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) _c.repeat();
    if (!widget.animate && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _blinkFor(double t) {
    final d = (t - _nextBlinkAt);
    if (d >= 0 && d < 0.05) return 1 - (d - 0.025).abs() / 0.025;
    if (d >= 0.05 || d < -0.95) _nextBlinkAt = _rnd.nextDouble() * 0.9;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final g = Genome.from(widget.monster.seed, widget.monster.element, widget.monster.stage);
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: widget.animate
            ? AnimatedBuilder(
                animation: _c,
                builder: (_, _) => CustomPaint(
                  painter: MonsterPainter(g, t: _c.value, blink: _blinkFor(_c.value), flash: widget.flash, facingLeft: widget.facingLeft, shadow: widget.shadow),
                ),
              )
            : CustomPaint(
                painter: MonsterPainter(g, t: 0.25, flash: widget.flash, facingLeft: widget.facingLeft, shadow: widget.shadow),
              ),
      ),
    );
  }
}
