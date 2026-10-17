import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/genome.dart';
import '../models/monster.dart';
import 'monster_painter.dart';

/// Rasterises each monster once and reuses the bitmap, so lists and battles
/// animate with cheap transforms instead of repainting gradients every frame.
class MonsterImageCache {
  MonsterImageCache._();

  static const _maxEntries = 90;
  static final LinkedHashMap<String, ui.Image> _cache = LinkedHashMap();

  static ui.Image get(Genome g, int seed, double logicalSize, double dpr, {bool blink = false, bool shadow = true}) {
    // Bucket sizes so tiny layout differences share one bitmap.
    final px = ((logicalSize * dpr) / 16).ceil() * 16;
    final key = '$seed|${g.element.index}|${g.stage}|$px|$blink|$shadow';
    final hit = _cache.remove(key);
    if (hit != null) {
      _cache[key] = hit; // mark as most recently used
      return hit;
    }
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    MonsterPainter(g, t: 0.25, blink: blink ? 1 : 0, shadow: shadow).paint(canvas, Size(px.toDouble(), px.toDouble()));
    final picture = rec.endRecording();
    final img = picture.toImageSync(px, px);
    picture.dispose();
    _cache[key] = img;
    while (_cache.length > _maxEntries) {
      final oldest = _cache.keys.first;
      // Not disposed: a widget may still be showing it; the GC frees it once unused.
      _cache.remove(oldest);
    }
    return img;
  }
}

/// Animated monster: breathing, bobbing, swaying and blinking.
/// Set [animate] false in long lists to skip the ticker entirely.
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

  bool _blinking(double t) {
    final d = t - _nextBlinkAt;
    if (d >= 0 && d < 0.04) return true;
    if (d >= 0.04 || d < -0.96) _nextBlinkAt = _rnd.nextDouble() * 0.9;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.monster;
    final g = Genome.from(m.seed, m.element, m.stage);
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    final open = MonsterImageCache.get(g, m.seed, widget.size, dpr, shadow: widget.shadow);
    if (!widget.animate) {
      return RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: _ImagePainter(open, flash: widget.flash, flip: widget.facingLeft),
          ),
        ),
      );
    }
    final closed = MonsterImageCache.get(g, m.seed, widget.size, dpr, blink: true, shadow: widget.shadow);
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) {
            final t = _c.value;
            final wave = sin(t * 2 * pi);
            return CustomPaint(
              painter: _ImagePainter(
                _blinking(t) ? closed : open,
                flash: widget.flash,
                flip: widget.facingLeft,
                scaleX: 1 - wave * 0.012,
                scaleY: 1 + wave * 0.02,
                dy: -wave * widget.size * 0.008,
                tilt: sin(t * 2 * pi + 0.8) * 0.012,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImagePainter extends CustomPainter {
  _ImagePainter(this.image, {this.flash = 0, this.flip = false, this.scaleX = 1, this.scaleY = 1, this.dy = 0, this.tilt = 0});
  final ui.Image image;
  final double flash;
  final bool flip;
  final double scaleX, scaleY, dy, tilt;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Squash & stretch around the feet so the monster "breathes" in place.
    canvas.translate(size.width / 2, size.height * 0.86 + dy);
    canvas.rotate(tilt);
    canvas.scale(flip ? -scaleX : scaleX, scaleY);
    canvas.translate(-size.width / 2, -size.height * 0.86);
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Offset.zero & size;
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(image, src, dst, paint);
    if (flash > 0) {
      canvas.drawImageRect(image, src, dst, Paint()..colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: (flash * 0.85).clamp(0, 1)), BlendMode.srcATop));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ImagePainter o) => o.image != image || o.flash != flash || o.flip != flip || o.scaleX != scaleX || o.scaleY != scaleY || o.dy != dy || o.tilt != tilt;
}
