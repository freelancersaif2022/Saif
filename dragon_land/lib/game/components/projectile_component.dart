import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/dragon_model.dart';

enum ProjectileKind {
  fire,
  water,
  shadow,
  leaf,
  solar,

  /// Ember's special: a tall rolling wall of fire.
  fireWave,

  /// Boss: arcing rock.
  rock,

  /// Boss: shockwave travelling along the ground.
  shockwave,
}

class Projectile {
  ProjectileKind kind = ProjectileKind.fire;
  double x = 0, y = 0, vx = 0, vy = 0;
  double life = 1, age = 0;
  int damage = 1;

  /// How many more targets it can pass through after the first hit.
  int pierce = 0;
  bool hostile = false;
  bool active = false;
  double gravity = 0;

  /// Targets already damaged (prevents multi-hits by piercing projectiles).
  final List<Object> hits = [];

  double get radius => switch (kind) {
    ProjectileKind.fire => 26,
    ProjectileKind.water => 24,
    ProjectileKind.shadow => 30,
    ProjectileKind.leaf => 22,
    ProjectileKind.solar => 28,
    ProjectileKind.fireWave => 120,
    ProjectileKind.rock => 24,
    ProjectileKind.shockwave => 30,
  };

  Rect get hitbox => switch (kind) {
    ProjectileKind.fireWave => Rect.fromLTWH(x - 60, y - 300, 120, 300),
    ProjectileKind.shockwave => Rect.fromLTWH(x - 34, y - 46, 68, 46),
    ProjectileKind.shadow => Rect.fromLTWH(x - 22, y - 46, 44, 92),
    _ => Rect.fromCircle(center: Offset(x, y), radius: radius * 0.85),
  };

  static ProjectileKind forElement(DragonElement e) => switch (e) {
    DragonElement.fire => ProjectileKind.fire,
    DragonElement.water => ProjectileKind.water,
    DragonElement.shadow => ProjectileKind.shadow,
    DragonElement.nature => ProjectileKind.leaf,
    DragonElement.solar => ProjectileKind.solar,
  };
}

/// Pooled projectiles for both the player and enemies.
class ProjectileLayer extends Component {
  ProjectileLayer({super.priority});

  final List<Projectile> items = [];
  final List<Projectile> _pool = [];
  final Paint _p = Paint()..isAntiAlias = true;
  final Paint _s = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  double viewWidth = 1280;

  Projectile spawn(
    ProjectileKind kind,
    double x,
    double y,
    double vx,
    double vy, {
    int damage = 1,
    double life = 1.4,
    int pierce = 0,
    bool hostile = false,
    double gravity = 0,
  }) {
    final p = _pool.isNotEmpty ? _pool.removeLast() : Projectile();
    p
      ..kind = kind
      ..x = x
      ..y = y
      ..vx = vx
      ..vy = vy
      ..damage = damage
      ..life = life
      ..age = 0
      ..pierce = pierce
      ..hostile = hostile
      ..gravity = gravity
      ..active = true;
    p.hits.clear();
    items.add(p);
    return p;
  }

  void kill(Projectile p) => p.active = false;

  void clear() {
    for (final p in items) {
      p.active = false;
    }
    _pool.addAll(items);
    items.clear();
  }

  void clearHostile() {
    for (final p in items) {
      if (p.hostile) p.active = false;
    }
  }

  void step(double dt, double scroll) {
    for (final p in items) {
      p.age += dt;
      p.vy += p.gravity * dt;
      p.x += p.vx * dt - (p.hostile ? scroll * dt : 0);
      p.y += p.vy * dt;
      if (p.age > p.life || p.x > viewWidth + 200 || p.x < -200 || p.y > 760) p.active = false;
    }
    for (var i = items.length - 1; i >= 0; i--) {
      if (!items[i].active) _pool.add(items.removeAt(i));
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in items) {
      switch (p.kind) {
        case ProjectileKind.fire:
          _orb(canvas, p, const Color(0xFFFFF3A0), const Color(0xFFFF8A1F), const Color(0x00FF3D00));
        case ProjectileKind.water:
          _orb(canvas, p, const Color(0xFFE8FDFF), const Color(0xFF38B6FF), const Color(0x002060FF));
          _s
            ..color = const Color(0xCCFFFFFF)
            ..strokeWidth = 3;
          canvas.drawArc(Rect.fromCircle(center: Offset(p.x, p.y), radius: p.radius * 0.6), -2.4, 1.2, false, _s);
        case ProjectileKind.shadow:
          _crescent(canvas, p);
        case ProjectileKind.leaf:
          _leaf(canvas, p);
        case ProjectileKind.solar:
          _orb(canvas, p, const Color(0xFFFFFFFF), const Color(0xFFFFD23F), const Color(0x00FF9F1C));
          _rays(canvas, p);
        case ProjectileKind.fireWave:
          _fireWave(canvas, p);
        case ProjectileKind.rock:
          _rock(canvas, p);
        case ProjectileKind.shockwave:
          _shock(canvas, p);
      }
    }
  }

  void _orb(Canvas c, Projectile p, Color core, Color mid, Color edge) {
    final r = p.radius;
    // trail
    _p.shader = Gradient.linear(Offset(p.x - r * 3, p.y), Offset(p.x, p.y), [edge, mid.withValues(alpha: 0.6)]);
    c.drawPath(
      Path()
        ..moveTo(p.x, p.y - r * 0.7)
        ..lineTo(p.x - r * 3, p.y)
        ..lineTo(p.x, p.y + r * 0.7)
        ..close(),
      _p,
    );
    _p.shader = Gradient.radial(Offset(p.x, p.y), r * 1.4, [core, mid, edge], const [0.0, 0.45, 1.0]);
    c.drawCircle(Offset(p.x, p.y), r * 1.4, _p);
    _p.shader = null;
  }

  void _rays(Canvas c, Projectile p) {
    _s
      ..color = const Color(0xAAFFF6B0)
      ..strokeWidth = 3;
    for (var i = 0; i < 8; i++) {
      final a = p.age * 6 + i * math.pi / 4;
      c.drawLine(
        Offset(p.x + math.cos(a) * p.radius * 0.9, p.y + math.sin(a) * p.radius * 0.9),
        Offset(p.x + math.cos(a) * p.radius * 1.6, p.y + math.sin(a) * p.radius * 1.6),
        _s,
      );
    }
  }

  void _crescent(Canvas c, Projectile p) {
    final r = p.radius * 1.3;
    _p.shader = Gradient.radial(Offset(p.x, p.y), r * 1.4, [const Color(0xAAE47BFF), const Color(0x004E2A96)]);
    c.drawCircle(Offset(p.x, p.y), r * 1.4, _p);
    _p.shader = null;
    _p.color = const Color(0xFF8A4FE0);
    final path = Path()
      ..moveTo(p.x - r * 0.2, p.y - r * 1.4)
      ..quadraticBezierTo(p.x + r * 1.3, p.y, p.x - r * 0.2, p.y + r * 1.4)
      ..quadraticBezierTo(p.x + r * 0.5, p.y, p.x - r * 0.2, p.y - r * 1.4)
      ..close();
    c.drawPath(path, _p);
    _s
      ..color = const Color(0xFFF2D2FF)
      ..strokeWidth = 2.5;
    c.drawPath(path, _s);
  }

  void _leaf(Canvas c, Projectile p) {
    c.save();
    c.translate(p.x, p.y);
    c.rotate(p.age * 14);
    for (var i = 0; i < 3; i++) {
      c.rotate(math.pi * 2 / 3);
      _p.color = i == 0 ? const Color(0xFF7FE06A) : const Color(0xFF4CCB55);
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(12, -12, 26, 0)
          ..quadraticBezierTo(12, 12, 0, 0)
          ..close(),
        _p,
      );
    }
    _p.color = const Color(0xFFFFE27A);
    c.drawCircle(Offset.zero, 5, _p);
    c.restore();
  }

  void _fireWave(Canvas c, Projectile p) {
    final rect = p.hitbox.inflate(10);
    _p.shader = Gradient.linear(
      rect.centerLeft,
      rect.centerRight,
      const [Color(0x00FF3D00), Color(0xCCFF6A1F), Color(0xFFFFE066), Color(0x00FFE066)],
      const [0.0, 0.45, 0.8, 1.0],
    );
    final path = Path()..moveTo(rect.left, rect.bottom);
    for (var i = 0; i <= 10; i++) {
      final y = rect.bottom - rect.height * i / 10;
      final x = rect.right - 20 + math.sin(p.age * 20 + i) * 18;
      path.lineTo(x, y);
    }
    path
      ..lineTo(rect.left, rect.top + 40)
      ..close();
    c.drawPath(path, _p);
    _p.shader = null;
  }

  void _rock(Canvas c, Projectile p) {
    c.save();
    c.translate(p.x, p.y);
    c.rotate(p.age * 5);
    _p.color = const Color(0xFF8E8AA2);
    final path = Path()
      ..moveTo(-22, -6)
      ..lineTo(-10, -22)
      ..lineTo(14, -18)
      ..lineTo(24, 2)
      ..lineTo(10, 20)
      ..lineTo(-16, 16)
      ..close();
    c.drawPath(path, _p);
    _p.color = const Color(0xFF5CF2E6);
    c.drawCircle(const Offset(4, -2), 6, _p);
    _s
      ..color = const Color(0xFF2A1636)
      ..strokeWidth = 3;
    c.drawPath(path, _s);
    c.restore();
  }

  void _shock(Canvas c, Projectile p) {
    final r = p.hitbox;
    _p.shader = Gradient.linear(r.bottomCenter, r.topCenter, const [Color(0xFFC792FF), Color(0x005CF2E6)]);
    c.drawPath(
      Path()
        ..moveTo(r.left - 20, r.bottom)
        ..quadraticBezierTo(r.center.dx, r.top - 20, r.right + 20, r.bottom)
        ..close(),
      _p,
    );
    _p.shader = null;
    _p.color = const Color(0xFF5CF2E6);
    for (var i = 0; i < 3; i++) {
      c.drawPath(
        Path()
          ..moveTo(r.left + 10 + i * 18, r.bottom)
          ..lineTo(r.left + 18 + i * 18, r.bottom - 26 - (i % 2) * 12)
          ..lineTo(r.left + 26 + i * 18, r.bottom)
          ..close(),
        _p,
      );
    }
  }
}
