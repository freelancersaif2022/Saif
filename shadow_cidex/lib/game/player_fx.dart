import 'dart:math' as math;
import 'dart:ui';

import '../core/utils.dart';
import '../render/soft_sprite.dart';
import 'battle.dart';
import 'fx.dart';

final Paint _paint = Paint()..isAntiAlias = true;
final Paint _stroke = Paint()
  ..isAntiAlias = true
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;
final Path _path = Path();

/// Effects spawned by the player's shadow power.
abstract class PlayerEffect {
  PlayerEffect(this.b, this.x, this.y);
  final Battle b;
  double x;
  double y;
  bool dead = false;
  void update(double dt);
  void render(Canvas c);
}

/// Crescent of shadow energy racing along the ground, cutting enemies.
class ShadowWave extends PlayerEffect {
  ShadowWave(super.b, super.x, super.y, this.dir);
  final double dir;
  double life = 0.8;
  final Set<Object> _hit = {};

  @override
  void update(double dt) {
    life -= dt;
    x += dir * 980 * dt;
    if (life <= 0 || x < -100 || x > b.cfg.length + 100) {
      dead = true;
      return;
    }
    final hb = Rect.fromLTRB(x - 60, y - 190, x + 60, y + 10);
    for (final h in b.hittables().toList()) {
      if (_hit.contains(h)) continue;
      if (h.hurtBox.overlaps(hb)) {
        _hit.add(h);
        h.receiveHit(38, dir, 420, heavy: true);
        final r = h.hurtBox.intersect(hb);
        b.fx.hitSparks(r.center.dx, r.center.dy, dir, n: 10, color: const Color(0xFF9FD0FF));
      }
    }
    for (var i = 0; i < 2; i++) {
      b.particles.spawn(px: x - dir * randRange(0, 50), py: y - randRange(0, 170), pvx: -dir * randRange(60, 160), pvy: -randRange(20, 90), plife: randRange(0.25, 0.5), psize: randRange(2, 4), pcolor: const Color(0xFF7FC0FF), pkind: PKind.glow);
    }
    b.particles.spawn(px: x, py: y - randRange(0, 60), pvx: -dir * 50, pvy: -60, plife: 0.5, psize: randRange(10, 18), pgrow: 20, pcolor: const Color(0xCC06070C));
  }

  @override
  void render(Canvas c) {
    final k = clampD(life / 0.25, 0, 1);
    final h = 190.0;
    c.save();
    c.translate(x, y);
    c.scale(dir, 1);
    _path
      ..reset()
      ..moveTo(-40, 0)
      ..quadraticBezierTo(70, -h * 0.5, -20, -h)
      ..quadraticBezierTo(30, -h * 0.5, -70, 0)
      ..close();
    _paint
      ..blendMode = BlendMode.srcOver
      ..color = fade(const Color(0xFF05060C), 0.85 * k);
    c.drawPath(_path, _paint);
    _stroke
      ..blendMode = BlendMode.plus
      ..strokeWidth = 7
      ..color = fade(const Color(0xFF4F9CFF), 0.6 * k);
    _path
      ..reset()
      ..moveTo(-40, 0)
      ..quadraticBezierTo(70, -h * 0.5, -20, -h);
    c.drawPath(_path, _stroke);
    _stroke
      ..strokeWidth = 2.5
      ..color = fade(const Color(0xFFE0F0FF), 0.9 * k);
    c.drawPath(_path, _stroke);
    _stroke.blendMode = BlendMode.srcOver;
    c.restore();
    SoftSprite.draw(c, Offset(x, y - h * 0.5), 110, fade(const Color(0xFF3F7CFF), 0.25 * k), blend: BlendMode.plus);
  }
}

/// Glowing fissures left in the ground by the power slam.
class GroundCrack extends PlayerEffect {
  GroundCrack(super.b, super.x, super.y) {
    final r = math.Random();
    for (var j = 0; j < 7; j++) {
      final dir = j.isEven ? 1.0 : -1.0;
      final pts = <Offset>[Offset.zero];
      var p = Offset.zero;
      final len = 80 + r.nextDouble() * 200;
      for (var i = 0; i < 6; i++) {
        p = p + Offset(dir * len / 6, (r.nextDouble() - 0.5) * 10 + (j > 3 ? 3 : 0));
        pts.add(p);
      }
      _cracks.add(pts);
    }
  }

  final List<List<Offset>> _cracks = [];
  double t = 0;
  static const double life = 2.6;

  @override
  void update(double dt) {
    t += dt;
    if (t > life) dead = true;
  }

  @override
  void render(Canvas c) {
    final k = 1 - t / life;
    final glow = k * k;
    c.save();
    c.translate(x, y + 2);
    c.scale(1, 0.35);
    for (final pts in _cracks) {
      _path.reset();
      _path.moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        _path.lineTo(pts[i].dx, pts[i].dy);
      }
      _stroke
        ..blendMode = BlendMode.srcOver
        ..strokeWidth = 7
        ..color = fade(const Color(0xFF020204), 0.9 * k);
      c.drawPath(_path, _stroke);
      _stroke
        ..blendMode = BlendMode.plus
        ..strokeWidth = 3
        ..color = fade(const Color(0xFF4F9CFF), glow);
      c.drawPath(_path, _stroke);
    }
    _stroke.blendMode = BlendMode.srcOver;
    c.restore();
    SoftSprite.draw(c, Offset(x, y), 160, fade(const Color(0xFF3F7CFF), 0.3 * glow), blend: BlendMode.plus);
  }
}

/// Shadow blade erupting out of the ground around the impact.
class ShadowSpike extends PlayerEffect {
  ShadowSpike(super.b, super.x, super.y, {this.delay = 0, this.height = 140});
  final double delay;
  final double height;
  double t = 0;

  @override
  void update(double dt) {
    t += dt;
    if (t > delay + 0.7) dead = true;
  }

  @override
  void render(Canvas c) {
    final e = t - delay;
    if (e <= 0) return;
    final grow = e < 0.08 ? e / 0.08 : (e > 0.45 ? clampD(1 - (e - 0.45) / 0.25, 0, 1) : 1.0);
    final h = height * grow;
    _path
      ..reset()
      ..moveTo(x - 14, y)
      ..lineTo(x - 3, y - h)
      ..lineTo(x + 2, y - h * 0.92)
      ..lineTo(x + 14, y)
      ..close();
    _paint
      ..blendMode = BlendMode.srcOver
      ..color = const Color(0xFF04050A);
    c.drawPath(_path, _paint);
    _stroke
      ..blendMode = BlendMode.plus
      ..strokeWidth = 2
      ..color = fade(const Color(0xFF6FB0FF), 0.8 * grow);
    c.drawLine(Offset(x - 3, y - h), Offset(x - 9, y), _stroke);
    _stroke.blendMode = BlendMode.srcOver;
  }
}

/// Bright blade streak left by an ultimate blink-cut.
class UltimateCut extends PlayerEffect {
  UltimateCut(Battle b, this.from, this.to) : super(b, to.dx, to.dy);
  final Offset from;
  final Offset to;
  double t = 0;
  static const double life = 0.55;

  @override
  void update(double dt) {
    t += dt;
    if (t > life) dead = true;
  }

  @override
  void render(Canvas c) {
    final k = 1 - t / life;
    final d = to - from;
    final n = Offset(-d.dy, d.dx) / math.max(d.distance, 0.001);
    final w = 16 * k;
    _path
      ..reset()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo((from.dx + to.dx) / 2 + n.dx * w, (from.dy + to.dy) / 2 + n.dy * w, to.dx, to.dy)
      ..quadraticBezierTo((from.dx + to.dx) / 2 - n.dx * w * 0.3, (from.dy + to.dy) / 2 - n.dy * w * 0.3, from.dx, from.dy)
      ..close();
    _paint
      ..blendMode = BlendMode.plus
      ..color = fade(const Color(0xFF6FB6FF), 0.7 * k);
    c.drawPath(_path, _paint);
    _stroke
      ..blendMode = BlendMode.plus
      ..strokeWidth = 3 * k + 1
      ..color = fade(const Color(0xFFF0F8FF), k);
    c.drawLine(from, to, _stroke);
    _paint.blendMode = BlendMode.srcOver;
    _stroke.blendMode = BlendMode.srcOver;
  }
}

/// Screen-wide cross slash that ends the ultimate.
class UltimateCross extends PlayerEffect {
  UltimateCross(super.b, super.x, super.y);
  double t = 0;
  static const double life = 0.9;

  @override
  void update(double dt) {
    t += dt;
    if (t > life) dead = true;
  }

  @override
  void render(Canvas c) {
    final k = clampD(t / 0.12, 0, 1);
    final fadeK = clampD(1 - (t - 0.3) / 0.6, 0, 1);
    final half = b.viewW * 0.6 * k;
    for (final dir in [const Offset(1, 0.42), const Offset(1, -0.42)]) {
      final d = dir / dir.distance;
      final a = Offset(x, y) - d * half;
      final e = Offset(x, y) + d * half;
      _stroke
        ..blendMode = BlendMode.plus
        ..strokeWidth = 34 * fadeK
        ..color = fade(const Color(0xFF3F7CFF), 0.45 * fadeK);
      c.drawLine(a, e, _stroke);
      _stroke
        ..strokeWidth = 8 * fadeK + 1
        ..color = fade(const Color(0xFFF4FAFF), fadeK);
      c.drawLine(a, e, _stroke);
    }
    _stroke.blendMode = BlendMode.srcOver;
    SoftSprite.draw(c, Offset(x, y), 260 * k, fade(const Color(0xFF6FA8FF), 0.4 * fadeK), blend: BlendMode.plus);
  }
}
