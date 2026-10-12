import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import '../core/images.dart';
import '../core/utils.dart';
import 'level_data.dart';

/// Parallax background, static props and ground rendering for a level.
class Environment {
  Environment(this.cfg) {
    _buildChunks();
  }

  final LevelConfig cfg;
  static const double groundScreenY = 600;
  static const double virtualH = 720;
  static const double chunkW = 1024;

  final List<ui.Picture> _chunks = [];
  final Paint _img = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;
  final Paint _fill = Paint()..isAntiAlias = true;

  void dispose() {
    for (final p in _chunks) {
      p.dispose();
    }
    _chunks.clear();
  }

  // ------------------------------------------------------------ background

  void renderBackground(Canvas c, double camX, double viewW, double time) {
    final sky = GameImages.get(GameImages.sky);
    if (sky != null) {
      final s = math.max(viewW / sky.width, virtualH / sky.height) * 1.08;
      final w = sky.width * s;
      final h = sky.height * s;
      final ox = -(w - viewW) * 0.5 - (camX * 0.01) % 40;
      c.drawImageRect(sky, Rect.fromLTWH(0, 0, sky.width.toDouble(), sky.height.toDouble()), Rect.fromLTWH(ox, -h * 0.04, w, h), _img);
    } else {
      _fill.shader = ui.Gradient.linear(Offset.zero, const Offset(0, virtualH), const [Color(0xFF05070D), Color(0xFF1C2433)]);
      c.drawRect(Rect.fromLTWH(0, 0, viewW, virtualH), _fill);
      _fill.shader = null;
    }
    _layer(c, GameImages.get(GameImages.mountainsFar), camX, 0.06, viewW, 575, 430);
    _fog(c, camX, viewW, time, 0.1, 420, 220, 0.22, 8);
    _layer(c, GameImages.get(GameImages.mountainsNear), camX, 0.14, viewW, 595, 360);
    _layer(c, GameImages.get(GameImages.treesFar), camX, 0.3, viewW, 628, 380);
    _fog(c, camX, viewW, time, 0.35, 470, 200, 0.28, 14);
    _layer(c, GameImages.get(GameImages.ruinsMid), camX, 0.55, viewW, 642, 360);
    _fog(c, camX, viewW, time, 0.6, 520, 160, 0.22, 22);
    // Level tint grade.
    _fill
      ..shader = null
      ..color = fade(cfg.tint, 0.16);
    c.drawRect(Rect.fromLTWH(0, 0, viewW, virtualH), _fill);
  }

  void _layer(Canvas c, ui.Image? img, double camX, double factor, double viewW, double bottom, double height, {double drift = 0, double opacity = 1}) {
    if (img == null) return;
    final s = height / img.height;
    final tileW = img.width * s;
    var off = -((camX * factor + drift) % tileW);
    if (off > 0) off -= tileW;
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    _img.color = fade(const Color(0xFFFFFFFF), opacity);
    for (var x = off; x < viewW; x += tileW) {
      c.drawImageRect(img, src, Rect.fromLTWH(x, bottom - height, tileW + 1, height), _img);
    }
    _img.color = const Color(0xFFFFFFFF);
  }

  void _fog(Canvas c, double camX, double viewW, double time, double factor, double top, double height, double opacity, double speed) {
    final fog = GameImages.get(GameImages.fog);
    if (fog == null) return;
    _layer(c, fog, camX, factor, viewW, top + height, height, drift: time * speed, opacity: opacity);
  }

  // ------------------------------------------------------------ world

  /// World space: ground at y = 0.
  void renderGround(Canvas c, double camX, double viewW) {
    final g = GameImages.get(GameImages.ground);
    const h = 150.0;
    if (g != null) {
      final s = h / g.height;
      final tileW = g.width * s;
      final start = (camX / tileW).floor() * tileW;
      final src = Rect.fromLTWH(0, 0, g.width.toDouble(), g.height.toDouble());
      for (var x = start; x < camX + viewW + tileW; x += tileW) {
        c.drawImageRect(g, src, Rect.fromLTWH(x, 0, tileW + 1, h), _img);
      }
    } else {
      _fill.color = const Color(0xFF14151A);
      c.drawRect(Rect.fromLTWH(camX, 0, viewW, h), _fill);
    }
    // Darken the soil so silhouettes stay readable.
    _fill
      ..shader = null
      ..color = const Color(0x99050608);
    c.drawRect(Rect.fromLTWH(camX - 10, 0, viewW + 20, h), _fill);
    // Edge highlight on the ground line.
    _fill
      ..shader = null
      ..color = const Color(0x405F7898);
    c.drawRect(Rect.fromLTWH(camX, -1, viewW, 2), _fill);
  }

  void renderProps(Canvas c, double camX, double viewW) {
    final first = math.max(0, (camX / chunkW).floor());
    final last = math.min(_chunks.length - 1, ((camX + viewW) / chunkW).floor());
    for (var i = first; i <= last; i++) {
      c.drawPicture(_chunks[i]);
    }
    // Atmospheric haze pushes the props behind the fighters.
    _fill.shader = ui.Gradient.linear(const Offset(0, -620), const Offset(0, 0), [
      const Color(0x00283244),
      fade(const Color(0xFF283244), 0.28),
    ]);
    c.drawRect(Rect.fromLTWH(camX - 10, -620, viewW + 20, 620), _fill);
    _fill.shader = null;
  }

  void renderForeground(Canvas c, double camX, double viewW, double time) {
    _fog(c, camX, viewW, time, 1.1, 560, 170, 0.16, 30);
    _layer(c, GameImages.get(GameImages.foreground), camX, 1.35, viewW, 742, 150, opacity: 0.96);
  }

  // ------------------------------------------------------------ props

  void _buildChunks() {
    final r = math.Random(cfg.seed * 977 + 13);
    final props = <_Prop>[];
    var x = -200.0;
    while (x < cfg.length + 400) {
      final roll = r.nextDouble();
      _PropType t;
      if (cfg.index == 4 || cfg.index == 10) {
        t = roll < 0.45 ? _PropType.ruin : (roll < 0.7 ? _PropType.stone : _PropType.deadTree);
      } else if (cfg.index == 2) {
        t = roll < 0.5 ? _PropType.tree : (roll < 0.7 ? _PropType.stone : (roll < 0.85 ? _PropType.wood : _PropType.ruin));
      } else if (cfg.index == 3) {
        t = roll < 0.45 ? _PropType.house : (roll < 0.65 ? _PropType.wood : (roll < 0.85 ? _PropType.tree : _PropType.stone));
      } else {
        const all = _PropType.values;
        t = all[r.nextInt(all.length)];
      }
      props.add(_Prop(t, x, 0.7 + r.nextDouble() * 0.6, r.nextInt(1 << 20)));
      x += 220 + r.nextDouble() * 360;
    }
    final count = ((cfg.length + 600) / chunkW).ceil();
    for (var i = 0; i < count; i++) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      final rect = Rect.fromLTWH(i * chunkW, -900, chunkW, 1100);
      c.clipRect(rect);
      for (final p in props) {
        if (p.x + 420 < rect.left || p.x - 420 > rect.right) continue;
        _drawProp(c, p);
      }
      for (final pl in cfg.platforms) {
        if (pl.x + pl.width < rect.left || pl.x > rect.right) continue;
        _drawPlatform(c, pl);
      }
      _drawGrass(c, rect.left, rect.right, i);
      _chunks.add(rec.endRecording());
    }
  }

  static const Color _propCol = Color(0xFF111620);
  static const Color _propRim = Color(0x55809CC0);

  void _drawProp(Canvas c, _Prop p) {
    final r = math.Random(p.seed);
    final s = p.scale;
    final paint = Paint()..color = _propCol;
    final rim = Paint()
      ..color = _propRim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    switch (p.type) {
      case _PropType.house:
        final w = 230 * s, h = 150 * s;
        final x = p.x;
        path
          ..moveTo(x, 0)
          ..lineTo(x, -h)
          ..lineTo(x - 18 * s, -h)
          ..lineTo(x + w * 0.5, -h - 95 * s)
          ..lineTo(x + w + 18 * s, -h)
          ..lineTo(x + w, -h)
          ..lineTo(x + w, 0)
          ..close();
        c.drawPath(path, paint);
        c.drawPath(path, rim);
        final win = Paint()..color = r.nextDouble() < 0.5 ? const Color(0x33FF7A30) : const Color(0xFF050608);
        c.drawRect(Rect.fromLTWH(x + w * 0.18, -h * 0.72, w * 0.18, h * 0.26), win);
        c.drawRect(Rect.fromLTWH(x + w * 0.62, -h * 0.72, w * 0.18, h * 0.26), Paint()..color = const Color(0xFF050608));
        c.drawRect(Rect.fromLTWH(x + w * 0.42, -h * 0.5, w * 0.16, h * 0.5), Paint()..color = const Color(0xFF050608));
        final beam = Paint()
          ..color = _propCol
          ..strokeWidth = 6 * s;
        c.drawLine(Offset(x + w * 0.3, -h - 60 * s), Offset(x + w * 0.1, -h - 120 * s), beam);
        break;
      case _PropType.stone:
        for (var i = 0; i < 3; i++) {
          final rx = p.x + i * 46 * s + r.nextDouble() * 20;
          final rw = (50 + r.nextDouble() * 60) * s;
          final rh = rw * (0.5 + r.nextDouble() * 0.3);
          final rr = RRect.fromRectAndCorners(Rect.fromLTWH(rx, -rh, rw, rh + 4), topLeft: Radius.circular(rw * 0.45), topRight: Radius.circular(rw * 0.35));
          c.drawRRect(rr, paint);
          c.drawRRect(rr, rim);
        }
        break;
      case _PropType.wood:
        final w = 210 * s, h = 170 * s;
        final post = Paint()
          ..color = _propCol
          ..strokeWidth = 9 * s
          ..strokeCap = StrokeCap.square;
        for (var i = 0; i < 4; i++) {
          final px = p.x + w * i / 3;
          c.drawLine(Offset(px, 0), Offset(px + r.nextDouble() * 8 - 4, -h), post);
        }
        post.strokeWidth = 8 * s;
        c.drawLine(Offset(p.x - 12, -h), Offset(p.x + w + 12, -h), post);
        c.drawLine(Offset(p.x, -h * 0.55), Offset(p.x + w, -h * 0.5), post);
        post.strokeWidth = 5 * s;
        c.drawLine(Offset(p.x, 0), Offset(p.x + w / 3, -h * 0.55), post);
        c.drawLine(Offset(p.x + w, 0), Offset(p.x + 2 * w / 3, -h * 0.5), post);
        // Watch tower roof sometimes.
        if (r.nextDouble() < 0.5) {
          path
            ..moveTo(p.x - 25, -h)
            ..lineTo(p.x + w * 0.5, -h - 70 * s)
            ..lineTo(p.x + w + 25, -h)
            ..close();
          c.drawPath(path, paint);
          c.drawPath(path, rim);
        }
        break;
      case _PropType.tree:
        _tree(c, p.x, 380 * s, r, paint, leafy: true);
        break;
      case _PropType.deadTree:
        _tree(c, p.x, 320 * s, r, paint, leafy: false);
        break;
      case _PropType.ruin:
        final h = (180 + r.nextDouble() * 160) * s;
        final w = 54 * s;
        path
          ..moveTo(p.x, 0)
          ..lineTo(p.x, -h)
          ..lineTo(p.x + w * 0.3, -h - 18 * s)
          ..lineTo(p.x + w * 0.55, -h + 14 * s)
          ..lineTo(p.x + w, -h - 6 * s)
          ..lineTo(p.x + w, 0)
          ..close();
        c.drawPath(path, paint);
        c.drawPath(path, rim);
        if (r.nextDouble() < 0.6) {
          final p2 = Path()
            ..moveTo(p.x + 160 * s, 0)
            ..lineTo(p.x + 160 * s, -h * 0.6)
            ..lineTo(p.x + 214 * s, -h * 0.66)
            ..lineTo(p.x + 214 * s, 0)
            ..close();
          c.drawPath(p2, paint);
          c.drawPath(p2, rim);
          // Fallen lintel.
          c.save();
          c.translate(p.x + 120 * s, -18 * s);
          c.rotate(0.12);
          c.drawRect(Rect.fromLTWH(-90 * s, -16 * s, 200 * s, 30 * s), paint);
          c.restore();
        }
        break;
    }
  }

  void _tree(Canvas c, double x, double h, math.Random r, Paint paint, {required bool leafy}) {
    final stroke = Paint()
      ..color = _propCol
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void branch(Offset from, double ang, double len, double w, int depth) {
      final to = from + Offset(math.sin(ang) * len, -math.cos(ang) * len);
      stroke.strokeWidth = w;
      c.drawLine(from, to, stroke);
      if (depth <= 0) {
        if (leafy) {
          for (var i = 0; i < 4; i++) {
            c.drawCircle(to + Offset(r.nextDouble() * 50 - 25, r.nextDouble() * 40 - 25), 26 + r.nextDouble() * 22, paint);
          }
        }
        return;
      }
      final n = 2 + (r.nextDouble() < 0.4 ? 1 : 0);
      for (var i = 0; i < n; i++) {
        branch(to, ang + (r.nextDouble() - 0.5) * 1.3, len * (0.62 + r.nextDouble() * 0.15), w * 0.65, depth - 1);
      }
    }

    final base = Path()
      ..moveTo(x - 22, 0)
      ..quadraticBezierTo(x - 6, -20, x - 8, -60)
      ..lineTo(x + 8, -60)
      ..quadraticBezierTo(x + 6, -20, x + 22, 0)
      ..close();
    c.drawPath(base, paint);
    branch(Offset(x, -50), (r.nextDouble() - 0.5) * 0.2, h * 0.38, 16, leafy ? 3 : 4);
  }

  void _drawPlatform(Canvas c, PlatformDef pl) {
    final top = pl.top;
    final postPaint = Paint()
      ..color = const Color(0xFF0E0C0B)
      ..strokeWidth = 10;
    if (top > -260) {
      c.drawLine(Offset(pl.x + 18, top + 10), Offset(pl.x + 22, 0), postPaint);
      c.drawLine(Offset(pl.x + pl.width - 18, top + 10), Offset(pl.x + pl.width - 22, 0), postPaint);
      postPaint.strokeWidth = 5;
      c.drawLine(Offset(pl.x + 20, top + 30), Offset(pl.x + pl.width - 20, -10), postPaint);
    } else {
      // Hanging chains for high ledges.
      postPaint
        ..strokeWidth = 3
        ..color = const Color(0xFF1A1C22);
      c.drawLine(Offset(pl.x + 20, top), Offset(pl.x + 30, top - 400), postPaint);
      c.drawLine(Offset(pl.x + pl.width - 20, top), Offset(pl.x + pl.width - 30, top - 400), postPaint);
    }
    final plank = Paint()..color = const Color(0xFF17130F);
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(pl.x, top, pl.width, 20), const Radius.circular(4));
    c.drawRRect(rr, plank);
    final lines = Paint()
      ..color = const Color(0xFF0A0807)
      ..strokeWidth = 2;
    for (var x = pl.x + 34; x < pl.x + pl.width - 10; x += 34) {
      c.drawLine(Offset(x, top + 2), Offset(x, top + 18), lines);
    }
    c.drawRect(Rect.fromLTWH(pl.x + 2, top, pl.width - 4, 2), Paint()..color = const Color(0x6690A8C8));
  }

  void _drawGrass(Canvas c, double left, double right, int seed) {
    final r = math.Random(seed * 7 + cfg.seed);
    final paint = Paint()..color = const Color(0xFF07080B);
    final path = Path();
    for (var x = left - 10; x < right + 10; x += 6 + r.nextDouble() * 10) {
      final h = 6 + r.nextDouble() * 20;
      final lean = r.nextDouble() * 10 - 5;
      path
        ..moveTo(x - 2.5, 2)
        ..lineTo(x + lean, -h)
        ..lineTo(x + 2.5, 2)
        ..close();
    }
    c.drawPath(path, paint);
  }
}

enum _PropType { house, stone, wood, tree, deadTree, ruin }

class _Prop {
  _Prop(this.type, this.x, this.scale, this.seed);
  final _PropType type;
  final double x;
  final double scale;
  final int seed;
}
