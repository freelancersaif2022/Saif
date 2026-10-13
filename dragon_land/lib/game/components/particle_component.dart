import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle, TextDirection, Shadow, FontWeight;

enum ParticleShape { circle, spark, star, leaf, ring, smoke }

class Particle {
  double x = 0, y = 0, vx = 0, vy = 0;
  double life = 0, maxLife = 1;
  double size = 6;
  double gravity = 0;
  double drag = 0;
  double spin = 0, angle = 0;
  Color color = const Color(0xFFFFFFFF);
  ParticleShape shape = ParticleShape.circle;
  bool additive = false;
  bool scrolls = true;
}

class FloatingText {
  double x = 0, y = 0, life = 0, maxLife = 1;
  TextPainter? painter;
}

/// Pooled particle system + floating reward text. Particles and text are
/// plain objects drawn by this single component, so bursts never allocate
/// components and memory stays bounded.
class ParticleLayer extends Component {
  ParticleLayer({required this.maxParticles, super.priority});

  final int maxParticles;
  final List<Particle> _active = [];
  final List<Particle> _pool = [];
  final List<FloatingText> _texts = [];
  final List<FloatingText> _textPool = [];
  final Map<String, TextPainter> _textCache = {};
  final math.Random _rng = math.Random();

  /// Scroll speed applied to world-anchored particles (set by the game).
  double scrollSpeed = 0;

  /// Global multiplier on spawn counts (graphics quality).
  double density = 1;

  final Paint _paint = Paint()..isAntiAlias = true;
  final Paint _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  int get count => _active.length;

  Particle? _obtain() {
    if (_active.length >= maxParticles) return null;
    final p = _pool.isNotEmpty ? _pool.removeLast() : Particle();
    _active.add(p);
    return p;
  }

  void clear() {
    _pool.addAll(_active);
    _active.clear();
    _textPool.addAll(_texts);
    _texts.clear();
  }

  double _r(double a, double b) => a + _rng.nextDouble() * (b - a);

  /// Radial burst.
  void burst(
    double x,
    double y, {
    required int count,
    required List<Color> colors,
    double speedMin = 80,
    double speedMax = 320,
    double sizeMin = 3,
    double sizeMax = 8,
    double life = 0.6,
    double gravity = 400,
    ParticleShape shape = ParticleShape.circle,
    bool additive = false,
    double angleMin = 0,
    double angleMax = math.pi * 2,
    bool scrolls = true,
    double drag = 1.5,
  }) {
    final n = (count * density).round().clamp(1, 200);
    for (var i = 0; i < n; i++) {
      final p = _obtain();
      if (p == null) return;
      final a = _r(angleMin, angleMax);
      final s = _r(speedMin, speedMax);
      p
        ..x = x
        ..y = y
        ..vx = math.cos(a) * s
        ..vy = math.sin(a) * s
        ..life = _r(life * 0.6, life)
        ..size = _r(sizeMin, sizeMax)
        ..gravity = gravity
        ..drag = drag
        ..spin = _r(-6, 6)
        ..angle = _r(0, math.pi * 2)
        ..color = colors[_rng.nextInt(colors.length)]
        ..shape = shape
        ..additive = additive
        ..scrolls = scrolls;
      p.maxLife = p.life;
    }
  }

  void ring(double x, double y, Color color, {double size = 60, double life = 0.4}) {
    final p = _obtain();
    if (p == null) return;
    p
      ..x = x
      ..y = y
      ..vx = 0
      ..vy = 0
      ..life = life
      ..maxLife = life
      ..size = size
      ..gravity = 0
      ..drag = 0
      ..color = color
      ..shape = ParticleShape.ring
      ..additive = true
      ..scrolls = true;
  }

  void text(double x, double y, String s, {Color color = const Color(0xFFFFE14D), double size = 30}) {
    final key = '$s|${color.toARGB32()}|$size';
    final tp = _textCache.putIfAbsent(key, () {
      if (_textCache.length > 64) _textCache.clear();
      return TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: size,
            color: color,
            fontWeight: FontWeight.w700,
            shadows: const [Shadow(color: Color(0xCC3A1A00), offset: Offset(2, 3), blurRadius: 0)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
    final ft = _textPool.isNotEmpty ? _textPool.removeLast() : FloatingText();
    ft
      ..x = x
      ..y = y
      ..life = 0.9
      ..maxLife = 0.9
      ..painter = tp;
    _texts.add(ft);
    if (_texts.length > 24) _textPool.add(_texts.removeAt(0));
  }

  @override
  void update(double dt) {
    for (var i = _active.length - 1; i >= 0; i--) {
      final p = _active[i];
      p.life -= dt;
      if (p.life <= 0) {
        _active.removeAt(i);
        _pool.add(p);
        continue;
      }
      final k = math.max(0.0, 1 - p.drag * dt);
      p.vx *= k;
      p.vy = p.vy * k + p.gravity * dt;
      p.x += p.vx * dt - (p.scrolls ? scrollSpeed * dt : 0);
      p.y += p.vy * dt;
      p.angle += p.spin * dt;
    }
    for (var i = _texts.length - 1; i >= 0; i--) {
      final t = _texts[i];
      t.life -= dt;
      t.y -= 70 * dt;
      if (t.life <= 0) {
        _texts.removeAt(i);
        _textPool.add(t);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _active) {
      final t = (p.life / p.maxLife).clamp(0.0, 1.0);
      _paint.blendMode = p.additive ? BlendMode.plus : BlendMode.srcOver;
      switch (p.shape) {
        case ParticleShape.circle:
          _paint.color = p.color.withValues(alpha: p.color.a * t);
          canvas.drawCircle(Offset(p.x, p.y), p.size * (0.4 + 0.6 * t), _paint);
        case ParticleShape.smoke:
          _paint.color = p.color.withValues(alpha: p.color.a * t * 0.6);
          canvas.drawCircle(Offset(p.x, p.y), p.size * (2 - t), _paint);
        case ParticleShape.spark:
          _stroke
            ..color = p.color.withValues(alpha: t)
            ..strokeWidth = p.size * 0.5
            ..blendMode = _paint.blendMode;
          canvas.drawLine(Offset(p.x, p.y), Offset(p.x - p.vx * 0.04, p.y - p.vy * 0.04), _stroke);
        case ParticleShape.star:
          _paint.color = p.color.withValues(alpha: t);
          _drawStar(canvas, p.x, p.y, p.size * (0.5 + 0.5 * t), p.angle);
        case ParticleShape.leaf:
          _paint.color = p.color.withValues(alpha: t);
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.angle);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: p.size * 2, height: p.size), _paint);
          canvas.restore();
        case ParticleShape.ring:
          _stroke
            ..color = p.color.withValues(alpha: t)
            ..strokeWidth = 6 * t + 1
            ..blendMode = BlendMode.plus;
          canvas.drawCircle(Offset(p.x, p.y), p.size * (1.4 - t), _stroke);
      }
    }
    _paint.blendMode = BlendMode.srcOver;
    _stroke.blendMode = BlendMode.srcOver;
    for (final t in _texts) {
      final tp = t.painter;
      if (tp == null) continue;
      final a = (t.life / t.maxLife).clamp(0.0, 1.0);
      final s = 0.8 + 0.4 * math.min(1.0, (t.maxLife - t.life) * 8);
      canvas.save();
      canvas.translate(t.x, t.y);
      canvas.scale(s);
      if (a < 1) {
        canvas.saveLayer(
          Rect.fromLTWH(-tp.width / 2 - 4, -tp.height / 2 - 4, tp.width + 8, tp.height + 8),
          Paint()..color = Color.fromRGBO(0, 0, 0, a),
        );
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      } else {
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      }
      canvas.restore();
    }
  }

  final Path _starPath = Path();

  void _drawStar(Canvas c, double x, double y, double r, double ang) {
    _starPath.reset();
    for (var i = 0; i < 8; i++) {
      final a = ang + i * math.pi / 4;
      final rr = i.isEven ? r : r * 0.4;
      final px = x + math.cos(a) * rr, py = y + math.sin(a) * rr;
      if (i == 0) {
        _starPath.moveTo(px, py);
      } else {
        _starPath.lineTo(px, py);
      }
    }
    _starPath.close();
    c.drawPath(_starPath, _paint);
  }
}
