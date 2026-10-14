import 'dart:math' as math;
import 'dart:ui' as ui;

class Particles {
  static const int cap = 360;

  final List<double> _x = List<double>.filled(cap, 0.0);
  final List<double> _y = List<double>.filled(cap, 0.0);
  final List<double> _vx = List<double>.filled(cap, 0.0);
  final List<double> _vy = List<double>.filled(cap, 0.0);
  final List<double> _life = List<double>.filled(cap, 0.0);
  final List<double> _max = List<double>.filled(cap, 1.0);
  final List<double> _size = List<double>.filled(cap, 1.0);
  final List<double> _grow = List<double>.filled(cap, 0.0);
  final List<double> _grav = List<double>.filled(cap, 0.0);
  final List<int> _color = List<int>.filled(cap, 0xFFFFFF);
  final List<int> _kind = List<int>.filled(cap, 0);

  int _n = 0;
  final math.Random _r = math.Random();
  final ui.Paint _normal = ui.Paint();
  final ui.Paint _add = ui.Paint()..blendMode = ui.BlendMode.plus;

  double _rnd(double a, double b) => a + _r.nextDouble() * (b - a);

  void _put(int kind, double x, double y, double vx, double vy, double life, double size,
      double grow, double grav, int color) {
    final i = _n;
    _n = (_n + 1) % cap;
    _kind[i] = kind;
    _x[i] = x;
    _y[i] = y;
    _vx[i] = vx;
    _vy[i] = vy;
    _life[i] = life;
    _max[i] = life;
    _size[i] = size;
    _grow[i] = grow;
    _grav[i] = grav;
    _color[i] = color;
  }

  void clear() {
    for (var i = 0; i < cap; i++) {
      _life[i] = 0;
    }
  }

  void spark(double x, double y, {int n = 8, int color = 0xFFD060, double speed = 260}) {
    for (var i = 0; i < n; i++) {
      final a = _r.nextDouble() * math.pi * 2;
      final s = _rnd(speed * 0.3, speed);
      _put(0, x, y, math.cos(a) * s, math.sin(a) * s - speed * 0.2, _rnd(0.25, 0.6), _rnd(1.5, 3.0), 0, 520, color);
    }
  }

  void smoke(double x, double y, {double size = 14, int n = 1, double rise = 40}) {
    for (var i = 0; i < n; i++) {
      _put(1, x + _rnd(-6, 6), y + _rnd(-4, 4), _rnd(-14, 14), -_rnd(rise * 0.6, rise), _rnd(0.9, 1.7), size * _rnd(0.7, 1.2),
          size * 1.4, 0, 0x555566);
    }
  }

  void fire(double x, double y, {double size = 16, int n = 6, double speed = 120}) {
    for (var i = 0; i < n; i++) {
      final a = _r.nextDouble() * math.pi * 2;
      final s = _rnd(10, speed);
      _put(2, x, y, math.cos(a) * s, math.sin(a) * s - 30, _rnd(0.3, 0.6), size * _rnd(0.6, 1.1), -size * 0.6, 0,
          _r.nextBool() ? 0xFF8A1E : 0xFFC94A);
    }
  }

  void ring(double x, double y, {double size = 10, double grow = 220, int color = 0xFFD890}) {
    _put(3, x, y, 0, 0, 0.35, size, grow, 0, color);
  }

  void glow(double x, double y, {double size = 60, int color = 0xFFC060, double life = 0.16}) {
    _put(5, x, y, 0, 0, life, size, 0, 0, color);
  }

  void debris(double x, double y, int color, {int n = 6}) {
    for (var i = 0; i < n; i++) {
      final a = -_r.nextDouble() * math.pi;
      final s = _rnd(80, 260);
      _put(4, x, y, math.cos(a) * s, math.sin(a) * s, _rnd(0.5, 1.0), _rnd(2.0, 4.5), 0, 700, color);
    }
  }

  void explosion(double x, double y, {double scale = 1.0}) {
    glow(x, y, size: 90 * scale, life: 0.22);
    ring(x, y, size: 10 * scale, grow: 320 * scale);
    fire(x, y, size: 26 * scale, n: 9, speed: 190 * scale);
    spark(x, y, n: 12, speed: 380 * scale);
    smoke(x, y, size: 20 * scale, n: 4, rise: 55);
    debris(x, y, 0x3A2C22, n: 6);
  }

  void muzzle(double x, double y, double scale) {
    glow(x, y, size: 80 * scale, life: 0.12);
    fire(x, y - 8 * scale, size: 18 * scale, n: 6, speed: 150 * scale);
    spark(x, y, n: 10, speed: 420 * scale, color: 0xFFE08A);
    smoke(x, y - 6, size: 16 * scale, n: 4, rise: 70);
  }

  void coinSparkle(double x, double y) {
    spark(x, y, n: 5, speed: 150, color: 0xFFE060);
    glow(x, y, size: 26, color: 0xFFD040, life: 0.12);
  }

  void update(double dt) {
    for (var i = 0; i < cap; i++) {
      if (_life[i] <= 0) continue;
      _life[i] -= dt;
      _x[i] += _vx[i] * dt;
      _y[i] += _vy[i] * dt;
      _vy[i] += _grav[i] * dt;
      final k = _kind[i];
      if (k == 1) {
        _vx[i] *= 0.985;
        _size[i] += _grow[i] * dt;
      } else if (k == 2) {
        _size[i] = math.max(1.0, _size[i] + _grow[i] * dt);
      } else if (k == 3) {
        _size[i] += _grow[i] * dt;
      }
    }
  }

  ui.Color _c(int rgb, double a) {
    final al = (a.clamp(0.0, 1.0) * 255).round();
    return ui.Color((al << 24) | (rgb & 0xFFFFFF));
  }

  void render(ui.Canvas c) {
    for (var i = 0; i < cap; i++) {
      final l = _life[i];
      if (l <= 0) continue;
      final t = (l / _max[i]).clamp(0.0, 1.0).toDouble();
      final x = _x[i];
      final y = _y[i];
      switch (_kind[i]) {
        case 0:
          _add
            ..style = ui.PaintingStyle.stroke
            ..strokeCap = ui.StrokeCap.round
            ..strokeWidth = _size[i]
            ..color = _c(_color[i], t);
          c.drawLine(ui.Offset(x, y), ui.Offset(x - _vx[i] * 0.035, y - _vy[i] * 0.035), _add);
          break;
        case 1:
          _normal
            ..style = ui.PaintingStyle.fill
            ..color = _c(_color[i], t * 0.55);
          c.drawCircle(ui.Offset(x, y), _size[i], _normal);
          break;
        case 2:
          _add
            ..style = ui.PaintingStyle.fill
            ..color = _c(_color[i], t * 0.85);
          c.drawCircle(ui.Offset(x, y), _size[i], _add);
          break;
        case 3:
          _add
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1.0 + 3.0 * t
            ..color = _c(_color[i], t);
          c.drawCircle(ui.Offset(x, y), _size[i], _add);
          break;
        case 4:
          _normal
            ..style = ui.PaintingStyle.fill
            ..color = _c(_color[i], math.min(1.0, t * 2));
          c.drawCircle(ui.Offset(x, y), _size[i], _normal);
          break;
        default:
          _add
            ..style = ui.PaintingStyle.fill
            ..color = _c(_color[i], t * 0.5);
          c.drawCircle(ui.Offset(x, y), _size[i] * (1.3 - 0.3 * t), _add);
          break;
      }
    }
  }
}
