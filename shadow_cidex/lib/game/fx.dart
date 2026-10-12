import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../core/utils.dart';
import '../render/soft_sprite.dart';

enum PKind { smoke, glow, spark, ember, debris, shard }

/// Pooled particle system using flat typed arrays for speed.
class Particles {
  Particles(this.max)
      : x = Float32List(max),
        y = Float32List(max),
        vx = Float32List(max),
        vy = Float32List(max),
        life = Float32List(max),
        maxLife = Float32List(max),
        size = Float32List(max),
        grow = Float32List(max),
        grav = Float32List(max),
        drag = Float32List(max),
        rot = Float32List(max),
        kind = Uint8List(max),
        color = List<Color>.filled(max, const Color(0xFF000000));

  final int max;
  final Float32List x, y, vx, vy, life, maxLife, size, grow, grav, drag, rot;
  final Uint8List kind;
  final List<Color> color;
  int count = 0;
  int _cursor = 0;

  static final Paint _paint = Paint()..isAntiAlias = true;
  static final Paint _line = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  static final Path _path = Path();

  void clear() => count = 0;

  void spawn({
    required double px,
    required double py,
    double pvx = 0,
    double pvy = 0,
    double plife = 1,
    double psize = 6,
    double pgrow = 0,
    double pgrav = 0,
    double pdrag = 0,
    Color pcolor = const Color(0xFF000000),
    PKind pkind = PKind.smoke,
  }) {
    int i;
    if (count < max) {
      i = count++;
    } else {
      i = _cursor;
      _cursor = (_cursor + 1) % max;
    }
    x[i] = px;
    y[i] = py;
    vx[i] = pvx;
    vy[i] = pvy;
    life[i] = plife;
    maxLife[i] = plife;
    size[i] = psize;
    grow[i] = pgrow;
    grav[i] = pgrav;
    drag[i] = pdrag;
    rot[i] = rng.nextDouble() * math.pi * 2;
    color[i] = pcolor;
    kind[i] = pkind.index;
  }

  void update(double dt) {
    var i = 0;
    while (i < count) {
      life[i] -= dt;
      if (life[i] <= 0) {
        final last = count - 1;
        if (i != last) {
          x[i] = x[last];
          y[i] = y[last];
          vx[i] = vx[last];
          vy[i] = vy[last];
          life[i] = life[last];
          maxLife[i] = maxLife[last];
          size[i] = size[last];
          grow[i] = grow[last];
          grav[i] = grav[last];
          drag[i] = drag[last];
          rot[i] = rot[last];
          color[i] = color[last];
          kind[i] = kind[last];
        }
        count--;
        continue;
      }
      final d = 1 - drag[i] * dt;
      vx[i] *= d;
      vy[i] = vy[i] * d + grav[i] * dt;
      x[i] += vx[i] * dt;
      y[i] += vy[i] * dt;
      size[i] = math.max(0.0, size[i] + grow[i] * dt);
      rot[i] += dt * 3;
      if (kind[i] == PKind.debris.index && y[i] > 0) {
        y[i] = 0;
        vy[i] = -vy[i] * 0.3;
        vx[i] *= 0.6;
      }
      i++;
    }
  }

  void render(Canvas c, double left, double right) {
    for (var i = 0; i < count; i++) {
      final px = x[i];
      final s = size[i];
      if (px + s < left || px - s > right) continue;
      final t = 1 - life[i] / maxLife[i];
      final k = PKind.values[kind[i]];
      switch (k) {
        case PKind.smoke:
          final a = t < 0.15 ? t / 0.15 : (1 - t) / 0.85;
          SoftSprite.draw(c, Offset(px, y[i]), s * 2.0, fade(color[i], a));
          break;
        case PKind.glow:
          final a = 1 - t;
          SoftSprite.draw(c, Offset(px, y[i]), s * 2.4, fade(color[i], a * 0.8), blend: BlendMode.plus);
          _paint
            ..blendMode = BlendMode.plus
            ..color = fade(color[i], a * 0.9);
          c.drawCircle(Offset(px, y[i]), s * 0.45, _paint);
          _paint.blendMode = BlendMode.srcOver;
          break;
        case PKind.spark:
          final a = 1 - t;
          _line
            ..blendMode = BlendMode.plus
            ..color = fade(color[i], a)
            ..strokeWidth = s;
          c.drawLine(Offset(px, y[i]), Offset(px - vx[i] * 0.03, y[i] - vy[i] * 0.03), _line);
          _line.blendMode = BlendMode.srcOver;
          break;
        case PKind.ember:
          final a = math.sin(t * math.pi);
          _paint
            ..blendMode = BlendMode.plus
            ..color = fade(color[i], a);
          c.drawCircle(Offset(px, y[i]), s, _paint);
          _paint.blendMode = BlendMode.srcOver;
          break;
        case PKind.debris:
          final a = t > 0.7 ? (1 - t) / 0.3 : 1.0;
          _paint
            ..blendMode = BlendMode.srcOver
            ..color = fade(color[i], a);
          c.save();
          c.translate(px, y[i]);
          c.rotate(rot[i]);
          c.drawRect(Rect.fromCenter(center: Offset.zero, width: s, height: s * 0.7), _paint);
          c.restore();
          break;
        case PKind.shard:
          final a = t < 0.2 ? t / 0.2 : (1 - t) / 0.8;
          _paint
            ..blendMode = BlendMode.srcOver
            ..color = fade(color[i], a);
          c.save();
          c.translate(px, y[i]);
          c.rotate(rot[i]);
          _path
            ..reset()
            ..moveTo(0, -s)
            ..lineTo(s * 0.45, 0)
            ..lineTo(0, s * 0.6)
            ..lineTo(-s * 0.45, 0)
            ..close();
          c.drawPath(_path, _paint);
          c.restore();
          break;
      }
    }
  }
}

/// Expanding shockwave ring.
class Ring {
  Ring(this.x, this.y, this.maxR, this.duration, this.color, this.width, {this.flat = 0.35});
  final double x, y, maxR, duration, width, flat;
  final Color color;
  double t = 0;
  bool get done => t >= duration;

  static final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  void update(double dt) => t += dt;

  void render(Canvas c) {
    final k = clampD(t / duration, 0, 1);
    final r = maxR * easeOutCubic(k);
    _paint
      ..color = fade(color, 1 - k)
      ..strokeWidth = width * (1 - k * 0.7)
      ..blendMode = BlendMode.plus;
    c.drawOval(Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r * 2 * (flat <= 0 ? 1 : flat)), _paint);
    _paint.blendMode = BlendMode.srcOver;
  }
}

/// Common emitters.
class Fx {
  Fx(this.p);
  final Particles p;

  static const Color shadowSmoke = Color(0xFF0B0C12);
  static const Color greySmoke = Color(0xFF3A4152);
  static const Color red = Color(0xFFFF3030);
  static const Color steel = Color(0xFFCFE3FF);
  static const Color violet = Color(0xFF8A5CFF);

  void hitSparks(double x, double y, double dir, {int n = 10, Color color = steel}) {
    for (var i = 0; i < n; i++) {
      final a = randRange(-0.9, 0.9) + (dir > 0 ? 0 : math.pi);
      final sp = randRange(250, 650);
      p.spawn(px: x, py: y, pvx: math.cos(a) * sp, pvy: math.sin(a) * sp - 120, plife: randRange(0.15, 0.32), psize: randRange(1.5, 3.0), pgrav: 900, pdrag: 2, pcolor: color, pkind: PKind.spark);
    }
    p.spawn(px: x, py: y, plife: 0.12, psize: 12, pgrow: 70, pcolor: fade(color, 0.45), pkind: PKind.glow);
  }

  void shadowBurst(double x, double y, {int n = 12, double spread = 1, Color color = shadowSmoke}) {
    for (var i = 0; i < n; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final sp = randRange(40, 220) * spread;
      p.spawn(px: x + randRange(-10, 10), py: y + randRange(-10, 10), pvx: math.cos(a) * sp, pvy: math.sin(a) * sp - 40, plife: randRange(0.5, 1.1), psize: randRange(6, 14) * spread, pgrow: 18, pdrag: 2.5, pcolor: color, pkind: PKind.smoke);
    }
  }

  void dust(double x, double y, {int n = 8, double power = 1}) {
    for (var i = 0; i < n; i++) {
      final dir = i.isEven ? 1.0 : -1.0;
      p.spawn(px: x + randRange(-12, 12), py: y - 4, pvx: dir * randRange(40, 200) * power, pvy: randRange(-80, -10) * power, plife: randRange(0.5, 0.9), psize: randRange(6, 12) * power, pgrow: 22 * power, pdrag: 3, pcolor: const Color(0xAA2C3140), pkind: PKind.smoke);
    }
  }

  void disintegrate(Rect r, {int n = 40, Color color = shadowSmoke, Color glow = red}) {
    for (var i = 0; i < n; i++) {
      final px = randRange(r.left, r.right);
      final py = randRange(r.top, r.bottom);
      p.spawn(px: px, py: py, pvx: randRange(-30, 30), pvy: randRange(-140, -40), plife: randRange(0.8, 1.6), psize: randRange(4, 10), pgrow: 6, pdrag: 0.8, pcolor: color, pkind: i % 4 == 0 ? PKind.shard : PKind.smoke);
      if (i % 5 == 0) {
        p.spawn(px: px, py: py, pvx: randRange(-20, 20), pvy: randRange(-120, -50), plife: randRange(0.6, 1.2), psize: randRange(1.5, 3), pcolor: glow, pkind: PKind.ember);
      }
    }
  }

  void energy(double x, double y, {int n = 24, Color color = violet, double speed = 420}) {
    for (var i = 0; i < n; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final sp = randRange(0.4, 1.0) * speed;
      p.spawn(px: x, py: y, pvx: math.cos(a) * sp, pvy: math.sin(a) * sp * 0.6, plife: randRange(0.35, 0.7), psize: randRange(2, 5), pdrag: 2.2, pcolor: color, pkind: PKind.glow);
    }
  }

  void debris(double x, double y, {int n = 10, Color color = const Color(0xFF262A33)}) {
    for (var i = 0; i < n; i++) {
      p.spawn(px: x + randRange(-20, 20), py: y - 6, pvx: randRange(-260, 260), pvy: randRange(-620, -220), plife: randRange(0.8, 1.4), psize: randRange(5, 12), pgrav: 1700, pdrag: 0.4, pcolor: color, pkind: PKind.debris);
    }
  }

  void heal(double x, double y) {
    for (var i = 0; i < 18; i++) {
      p.spawn(px: x + randRange(-26, 26), py: y + randRange(-40, 40), pvx: randRange(-20, 20), pvy: randRange(-160, -60), plife: randRange(0.5, 1.0), psize: randRange(2, 4.5), pcolor: const Color(0xFFFF5A6A), pkind: PKind.glow);
    }
  }
}
