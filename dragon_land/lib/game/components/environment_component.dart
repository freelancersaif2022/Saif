import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game_config.dart';

/// A gap in the ground, in screen-space world units (scrolls left).
class GroundGap {
  GroundGap(this.x0, this.x1);
  double x0;
  double x1;
}

/// Bitmaps used by the environment layers.
class EnvironmentImages {
  EnvironmentImages({
    required this.sky,
    required this.sun,
    required this.far,
    required this.mid,
    required this.near,
    required this.ground,
    required this.foreground,
    required this.clouds,
  });

  final ui.Image sky, sun, far, mid, near, ground, foreground;
  final List<ui.Image> clouds;
}

class _Cloud {
  _Cloud(this.image, this.x, this.y, this.scale, this.speed);
  ui.Image image;
  double x, y, scale, speed;
}

class _Critter {
  double x = 0, y = 0, phase = 0, speed = 0, baseY = 0, size = 1;
  bool butterfly = false;
  Color color = const Color(0xFFFFFFFF);
}

/// Sky, sun, parallax mountains / floating islands / hills, clouds and
/// ambient birds and butterflies. Scrolls at fractions of the world speed.
class BackgroundComponent extends Component {
  BackgroundComponent(this.images, {required this.quality, super.priority});

  final EnvironmentImages images;

  /// 0 = low, 1 = medium, 2 = high.
  final int quality;
  double viewWidth = 1280;
  double _far = 0, _mid = 0, _near = 0;
  double _time = 0;
  final List<_Cloud> _clouds = [];
  final List<_Critter> _critters = [];
  final math.Random _rng = math.Random(3);
  final Paint _paint = Paint()..filterQuality = FilterQuality.medium;
  final Paint _fx = Paint()..isAntiAlias = true;
  final Paint _line = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3;

  @override
  Future<void> onLoad() async {
    final n = quality == 0 ? 3 : 6;
    for (var i = 0; i < n; i++) {
      _clouds.add(
        _Cloud(
          images.clouds[i % images.clouds.length],
          _rng.nextDouble() * 1800,
          20 + _rng.nextDouble() * 220,
          0.35 + _rng.nextDouble() * 0.4,
          8 + _rng.nextDouble() * 14,
        ),
      );
    }
    if (quality > 0) {
      for (var i = 0; i < 6; i++) {
        _critters.add(_spawnCritter(i.isEven, initial: true));
      }
    }
  }

  _Critter _spawnCritter(bool butterfly, {bool initial = false}) {
    final c = _Critter()
      ..butterfly = butterfly
      ..x = initial ? _rng.nextDouble() * viewWidth : viewWidth + 50 + _rng.nextDouble() * 400
      ..phase = _rng.nextDouble() * 10
      ..size = butterfly ? 0.8 + _rng.nextDouble() * 0.5 : 0.7 + _rng.nextDouble() * 0.6;
    c.baseY = butterfly ? 470 + _rng.nextDouble() * 80 : 90 + _rng.nextDouble() * 180;
    c.speed = butterfly ? 30 + _rng.nextDouble() * 40 : 60 + _rng.nextDouble() * 60;
    c.color = butterfly
        ? const [Color(0xFFFF7AB6), Color(0xFFFFD45C), Color(0xFF8FD3FF), Color(0xFFB98BFF)][_rng.nextInt(4)]
        : const Color(0xFF3B3355);
    return c;
  }

  void scroll(double dx, double dt) {
    _time += dt;
    _far += dx * 0.05;
    _mid += dx * 0.14;
    _near += dx * 0.32;
    for (final c in _clouds) {
      c.x -= dx * 0.08 + c.speed * dt;
      final w = c.image.width * c.scale;
      if (c.x < -w - 20) {
        c.x = viewWidth + _rng.nextDouble() * 300;
        c.y = 20 + _rng.nextDouble() * 220;
        c.image = images.clouds[_rng.nextInt(images.clouds.length)];
        c.scale = 0.35 + _rng.nextDouble() * 0.4;
      }
    }
    for (var i = 0; i < _critters.length; i++) {
      final c = _critters[i];
      c.phase += dt * (c.butterfly ? 9 : 7);
      c.x -= (c.butterfly ? dx * 0.6 : dx * 0.1) + c.speed * dt;
      c.y = c.baseY + math.sin(c.phase * (c.butterfly ? 0.35 : 0.2)) * (c.butterfly ? 26 : 12);
      if (c.x < -60) _critters[i] = _spawnCritter(c.butterfly);
    }
  }

  void _tile(Canvas canvas, ui.Image img, double offset, double y, double scale, [double opacity = 1]) {
    final w = img.width * scale;
    final h = img.height * scale;
    var x = -(offset % w);
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    _paint.color = Color.fromRGBO(255, 255, 255, opacity);
    while (x < viewWidth) {
      canvas.drawImageRect(img, src, Rect.fromLTWH(x, y, w + 0.5, h), _paint);
      x += w;
    }
  }

  @override
  void render(Canvas canvas) {
    final skySrc = Rect.fromLTWH(0, 0, images.sky.width.toDouble(), images.sky.height.toDouble());
    _paint.color = const Color(0xFFFFFFFF);
    canvas.drawImageRect(images.sky, skySrc, Rect.fromLTWH(0, 0, viewWidth, GameConfig.worldHeight), _paint);
    // sun
    final sunSize = 360.0 + math.sin(_time * 0.8) * 10;
    canvas.drawImageRect(
      images.sun,
      Rect.fromLTWH(0, 0, images.sun.width.toDouble(), images.sun.height.toDouble()),
      Rect.fromCenter(center: Offset(viewWidth * 0.78, 90), width: sunSize, height: sunSize),
      _paint,
    );
    _tile(canvas, images.far, _far, 0, 1);
    for (final c in _clouds) {
      if (c.scale > 0.55) continue;
      _drawCloud(canvas, c);
    }
    if (quality > 0) _tile(canvas, images.mid, _mid, 0, 1);
    for (final c in _critters) {
      if (!c.butterfly) _bird(canvas, c);
    }
    for (final c in _clouds) {
      if (c.scale <= 0.55) continue;
      _drawCloud(canvas, c);
    }
    _tile(canvas, images.near, _near, 0, 1);
    // atmospheric depth fog over the hills
    _fx.shader = ui.Gradient.linear(const Offset(0, 420), const Offset(0, GameConfig.groundY), [
      const Color(0x00E8F6FF),
      const Color(0x44E8F6FF),
    ]);
    canvas.drawRect(Rect.fromLTWH(0, 420, viewWidth, GameConfig.groundY - 420), _fx);
    _fx.shader = null;
    for (final c in _critters) {
      if (c.butterfly) _butterfly(canvas, c);
    }
  }

  void _drawCloud(Canvas canvas, _Cloud c) {
    final img = c.image;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(c.x, c.y, img.width * c.scale, img.height * c.scale),
      _paint,
    );
  }

  void _bird(Canvas canvas, _Critter c) {
    final flap = math.sin(c.phase) * 8 * c.size;
    _line
      ..color = c.color
      ..strokeWidth = 2.6 * c.size;
    final s = 12 * c.size;
    final path = Path()
      ..moveTo(c.x - s, c.y - flap)
      ..quadraticBezierTo(c.x - s * 0.4, c.y - s * 0.3, c.x, c.y)
      ..quadraticBezierTo(c.x + s * 0.4, c.y - s * 0.3, c.x + s, c.y - flap);
    canvas.drawPath(path, _line);
  }

  void _butterfly(Canvas canvas, _Critter c) {
    final open = (math.sin(c.phase) * 0.5 + 0.5) * 0.8 + 0.2;
    final s = 9 * c.size;
    _fx.color = c.color;
    canvas.save();
    canvas.translate(c.x, c.y);
    canvas.scale(open, 1);
    canvas.drawOval(Rect.fromCenter(center: Offset(-s * 0.6, -s * 0.3), width: s * 1.3, height: s * 1.1), _fx);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.6, -s * 0.3), width: s * 1.3, height: s * 1.1), _fx);
    canvas.drawOval(Rect.fromCenter(center: Offset(-s * 0.45, s * 0.4), width: s * 0.9, height: s * 0.8), _fx);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.45, s * 0.4), width: s * 0.9, height: s * 0.8), _fx);
    canvas.restore();
    _fx.color = const Color(0xFF3B2A1A);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.x, c.y), width: 2, height: s * 1.3), _fx);
  }
}

/// The running path: tiled ground with scrolling gaps (chasms).
class GroundComponent extends Component {
  GroundComponent(this.groundImage, {super.priority});

  final ui.Image groundImage;
  final List<GroundGap> gaps = [];
  double viewWidth = 1280;
  double _offset = 0;
  final Paint _paint = Paint()..filterQuality = FilterQuality.medium;
  final Paint _fx = Paint()..isAntiAlias = true;
  final List<double> _segBuffer = [];

  void scroll(double dx) {
    _offset += dx;
    for (final g in gaps) {
      g.x0 -= dx;
      g.x1 -= dx;
    }
    gaps.removeWhere((g) => g.x1 < -200);
  }

  void reset() {
    gaps.clear();
  }

  /// True when solid ground exists at x.
  bool solidAt(double x) {
    for (final g in gaps) {
      if (x > g.x0 && x < g.x1) return false;
    }
    return true;
  }

  /// True when the whole span [x0, x1] is over a gap (used for "standing").
  bool spanOverGap(double x0, double x1) {
    for (final g in gaps) {
      if (x0 >= g.x0 && x1 <= g.x1) return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    const top = GameConfig.groundY - 30;
    // chasm backdrop for every visible gap
    for (final g in gaps) {
      if (g.x1 < 0 || g.x0 > viewWidth) continue;
      final r = Rect.fromLTRB(g.x0, GameConfig.groundY - 6, g.x1, GameConfig.worldHeight);
      _fx.shader = ui.Gradient.linear(r.topCenter, r.bottomCenter, const [Color(0xFF3C6FA8), Color(0xFF152A55)]);
      canvas.drawRect(r, _fx);
      _fx.shader = null;
      _fx.color = const Color(0x55BFE8FF);
      for (var i = 0; i < 3; i++) {
        final y = GameConfig.worldHeight - 30 - i * 26;
        canvas.drawOval(Rect.fromLTWH(g.x0 + 10 + i * 14, y, g.x1 - g.x0 - 20 - i * 28, 22), _fx);
      }
    }
    // solid segments between gaps
    _segBuffer
      ..clear()
      ..add(-10);
    final sorted = gaps.where((g) => g.x1 > -10 && g.x0 < viewWidth + 10).toList()..sort((a, b) => a.x0.compareTo(b.x0));
    for (final g in sorted) {
      _segBuffer
        ..add(g.x0)
        ..add(g.x1);
    }
    _segBuffer.add(viewWidth + 10);
    final w = groundImage.width.toDouble();
    final src = Rect.fromLTWH(0, 0, w, groundImage.height.toDouble());
    _paint.color = const Color(0xFFFFFFFF);
    for (var i = 0; i + 1 < _segBuffer.length; i += 2) {
      final a = _segBuffer[i], b = _segBuffer[i + 1];
      if (b <= a) continue;
      canvas.save();
      canvas.clipRRect(
        RRect.fromLTRBAndCorners(
          a,
          GameConfig.groundY - 12,
          b,
          GameConfig.worldHeight + 10,
          topLeft: Radius.circular(i == 0 ? 0 : 18),
          topRight: Radius.circular(i + 2 >= _segBuffer.length ? 0 : 18),
        ),
      );
      var x = a - ((a + _offset) % w);
      while (x < b) {
        canvas.drawImageRect(groundImage, src, Rect.fromLTWH(x, top, w + 0.5, groundImage.height.toDouble()), _paint);
        x += w;
      }
      // cliff shading at gap edges
      if (i != 0) {
        _fx.shader = ui.Gradient.linear(Offset(a, 0), Offset(a + 26, 0), const [Color(0x88301A10), Color(0x00301A10)]);
        canvas.drawRect(Rect.fromLTWH(a, top + 28, 26, GameConfig.worldHeight - top), _fx);
      }
      if (i + 2 < _segBuffer.length) {
        _fx.shader = ui.Gradient.linear(Offset(b, 0), Offset(b - 26, 0), const [Color(0x88301A10), Color(0x00301A10)]);
        canvas.drawRect(Rect.fromLTWH(b - 26, top + 28, 26, GameConfig.worldHeight - top), _fx);
      }
      _fx.shader = null;
      canvas.restore();
    }
  }
}

/// Grass, flowers and mushrooms passing in front of the action.
class ForegroundComponent extends Component {
  ForegroundComponent(this.image, {super.priority});
  final ui.Image image;
  double viewWidth = 1280;
  double _offset = 0;
  final Paint _paint = Paint()..filterQuality = FilterQuality.medium;

  void scroll(double dx) => _offset += dx * 1.25;

  @override
  void render(Canvas canvas) {
    const scale = 0.7;
    final w = image.width * scale;
    final h = image.height * scale;
    var x = -(_offset % w);
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    _paint.color = const Color(0xFFFFFFFF);
    while (x < viewWidth) {
      canvas.drawImageRect(image, src, Rect.fromLTWH(x, GameConfig.worldHeight - h + 6, w + 0.5, h), _paint);
      x += w;
    }
  }
}
