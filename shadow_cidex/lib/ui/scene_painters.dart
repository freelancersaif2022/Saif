import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/images.dart';
import '../core/utils.dart';
import '../render/soft_sprite.dart';
import '../render/humanoid.dart';

/// Shared drawing helpers for the menu scenes.
class SceneKit {
  SceneKit._();

  static final Paint _img = Paint()..filterQuality = FilterQuality.medium;
  static final Paint _p = Paint()..isAntiAlias = true;

  /// Draws [img] covering [size] with a zoom and pan offset (camera move).
  static void cover(Canvas c, ui.Image? img, Size size, {double zoom = 1, Offset pan = Offset.zero, double opacity = 1}) {
    if (img == null) {
      _p
        ..shader = null
        ..color = const Color(0xFF07080D);
      c.drawRect(Offset.zero & size, _p);
      return;
    }
    final s = math.max(size.width / img.width, size.height / img.height) * zoom;
    final w = img.width * s;
    final h = img.height * s;
    final dst = Rect.fromLTWH((size.width - w) / 2 + pan.dx, (size.height - h) / 2 + pan.dy, w, h);
    _img.color = fade(Colors.white, opacity);
    c.drawImageRect(img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), dst, _img);
    _img.color = Colors.white;
  }

  /// Horizontally tiled scrolling layer (fog, foreground).
  static void tiled(Canvas c, ui.Image? img, Size size, {required double bottom, required double height, required double offset, double opacity = 1}) {
    if (img == null) return;
    final s = height / img.height;
    final tw = img.width * s;
    var x = -(offset % tw);
    if (x > 0) x -= tw;
    _img.color = fade(Colors.white, opacity);
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    for (; x < size.width; x += tw) {
      c.drawImageRect(img, src, Rect.fromLTWH(x, bottom - height, tw + 1, height), _img);
    }
    _img.color = Colors.white;
  }

  static void vignette(Canvas c, Size size, {double strength = 0.85}) {
    _p.shader = ui.Gradient.radial(
      size.center(Offset.zero),
      size.longestSide * 0.62,
      [const Color(0x00000000), fade(const Color(0xFF000000), strength)],
      const [0.5, 1.0],
    );
    c.drawRect(Offset.zero & size, _p);
    _p.shader = null;
  }

  /// Rising embers / ash, computed analytically from time (no state needed).
  static void embers(Canvas c, Size size, double t, {int count = 60, Color color = const Color(0xFFFF6A3A), double speed = 1}) {
    for (var i = 0; i < count; i++) {
      final seed = i * 12.9898;
      final rx = (math.sin(seed) * 43758.5453) % 1.0;
      final rs = (math.sin(seed * 1.7) * 24634.6345) % 1.0;
      final life = 5 + rs.abs() * 6;
      final phase = ((t * speed + rx.abs() * life) % life) / life;
      final x = (rx.abs() * size.width + math.sin(t * 0.7 + i) * 30) % size.width;
      final y = size.height * (1.05 - phase * 1.1);
      final a = math.sin(phase * math.pi) * (0.35 + 0.65 * rs.abs());
      final col = i % 4 == 0 ? color : const Color(0xFFA8B8D0);
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(col, a * 0.8);
      c.drawCircle(Offset(x, y), 1.0 + rs.abs() * 2.2, _p);
    }
    _p.blendMode = BlendMode.srcOver;
  }

  static void lightShafts(Canvas c, Size size, double t, {Color color = const Color(0xFF9AB0D0), double intensity = 1}) {
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.2 + i * 0.22) + math.sin(t * 0.3 + i) * 30;
      final w = size.width * (0.06 + 0.03 * math.sin(i * 1.3));
      final a = (0.05 + 0.03 * math.sin(t * 0.8 + i * 2)) * intensity;
      final path = Path()
        ..moveTo(x - w * 0.3, 0)
        ..lineTo(x + w * 0.3, 0)
        ..lineTo(x + w * 2.2, size.height)
        ..lineTo(x - w * 0.4, size.height)
        ..close();
      _p
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.linear(Offset(x, 0), Offset(x, size.height), [fade(color, a), fade(color, 0)]);
      c.drawPath(path, _p);
    }
    _p
      ..shader = null
      ..blendMode = BlendMode.srcOver;
  }
}

/// Animated lobby: shadow world, bosses behind, hero in the centre.
class LobbyScenePainter extends CustomPainter {
  LobbyScenePainter(this.clock) : super(repaint: clock);
  final ValueNotifier<double> clock;

  final HumanoidRig _rig = HumanoidRig(hero);
  final Pose _target = Pose();
  double _lastT = -1;
  double _rootX = 0;
  double _rootY = 0;
  double _sheath = 1;
  double _dummyHit = 0;
  double _dummyLean = 0;
  double _impact = 0;
  int _lastMove = -1;
  bool _struck = false;
  final List<Offset> _trailBase = [];
  final List<Offset> _trailTip = [];
  final List<_Ghost> _ghosts = [];
  double _ghostT = 0;

  static const HumanoidStyle hero = HumanoidStyle(
    height: 150,
    headband: true,
    bandColor: Color(0xFF9A1424),
    eye: Color(0xFF8FE6FF),
    eyeGlow: 1.1,
    rim: Color(0xFF9AB8E0),
    rimStrength: 0.85,
    bladeColor: Color(0xFFD8E8FF),
    bladeGlow: Color(0xFF5FB8FF),
    hakama: true,
    topknot: true,
    mask: true,
    scarf: true,
    saya: true,
  );
  static const HumanoidStyle _ghostStyle = HumanoidStyle(height: 150, rimStrength: 0, eyeGlow: 0, body: Color(0xFF1A3A6C));

  /// Training drills performed one after another (durations in seconds).
  static const List<double> _moves = [2.4, 1.1, 2.0, 1.4, 1.6, 1.3, 1.6, 1.8, 2.0];
  static final double _cycle = _moves.fold(0.0, (a, b) => a + b);

  @override
  void paint(Canvas c, Size size) {
    final t = clock.value;
    final w = size.width;
    final h = size.height;
    final hs = h / 720;
    // Slow cinematic camera drift.
    final camX = math.sin(t * 0.16) * 20 * hs;
    final camY = math.cos(t * 0.11) * 6 * hs;
    final zoom = 1.08 + math.sin(t * 0.09) * 0.03;

    SceneKit.cover(c, GameImages.get(GameImages.lobbyBg), size, zoom: zoom, pan: Offset(camX * 0.4, camY * 0.4));
    SceneKit.lightShafts(c, size, t, intensity: 0.9);
    final fog = GameImages.get(GameImages.fog);
    SceneKit.tiled(c, fog, size, bottom: h * 0.82, height: h * 0.4, offset: t * 14 * hs, opacity: 0.35);
    final ground = h * 0.86;
    SceneKit.tiled(c, fog, size, bottom: ground + 40 * hs, height: h * 0.32, offset: t * 22 * hs + 300, opacity: 0.32);

    // Ground band.
    final gimg = GameImages.get(GameImages.ground);
    if (gimg != null) {
      SceneKit.tiled(c, gimg, size, bottom: h + 40 * hs, height: (h - ground) + 40 * hs, offset: camX, opacity: 1);
    }
    final gp = Paint()
      ..shader = ui.Gradient.linear(Offset(0, ground - 30 * hs), Offset(0, h), [const Color(0x00000000), const Color(0xCC000000)]);
    c.drawRect(Rect.fromLTWH(0, ground - 30 * hs, w, h - ground + 30 * hs), gp);

    final dt = _lastT < 0 ? 1 / 60 : (t - _lastT).clamp(0.0, 1 / 20).toDouble();
    _lastT = t;
    _animate(t, dt);

    final sc = 1.75 * hs;
    final hx = w * 0.56 + camX;
    final dummyX = hx + 205 * sc;

    // Spotlight on the training ground.
    final spot = Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(Offset(hx + 80 * sc, ground - 120 * hs), 320 * hs, [const Color(0x33587CB0), const Color(0x00000000)]);
    c.drawCircle(Offset(hx + 80 * sc, ground - 120 * hs), 320 * hs, spot);

    _drawDummy(c, dummyX, ground, sc, t);

    // Hero shadow.
    final air = (-_rootY / 160).clamp(0.0, 1.0);
    final shadow = Paint()..color = fade(const Color(0xAA000000), 1 - air * 0.6);
    c.drawOval(Rect.fromCenter(center: Offset(hx + _rootX * sc, ground), width: 130 * hs * (1 - air * 0.4), height: 16 * hs), shadow);

    // Dash afterimages.
    for (final g in _ghosts) {
      g.skel.compute(g.pose, _ghostStyle);
      c.save();
      c.translate(hx + g.x * sc, ground + g.y * sc);
      c.scale(sc, sc);
      HumanoidPainter.draw(c, g.skel, g.pose, _ghostStyle, alpha: g.life / 0.3 * 0.35);
      c.restore();
    }

    // Blade trail (stored in model space, mapped to the screen here).
    if (_trailBase.length >= 2) {
      final bases = [for (final p in _trailBase) Offset(hx + p.dx * sc, ground + p.dy * sc)];
      final tips = [for (final p in _trailTip) Offset(hx + p.dx * sc, ground + p.dy * sc)];
      HumanoidPainter.drawTrail(c, bases, tips, const Color(0xFFBFD8FF));
    }

    c.save();
    c.translate(hx + _rootX * sc, ground + _rootY * sc);
    c.scale(sc, sc);
    if (_rig.pose.rot != 0) c.rotate(_rig.pose.rot);
    HumanoidPainter.draw(c, _rig.skel, _rig.pose, hero, time: t, wind: 0.6 + 0.3 * math.sin(t * 0.7), sheathed: _sheath, cloth: _rig.cloth, eyeBoost: _impact * 1.4);
    c.restore();

    // Ground impact glow.
    if (_impact > 0.01) {
      SoftSprite.draw(c, Offset(hx + _rootX * sc + 40 * sc, ground), 160 * hs * (1.4 - _impact * 0.4), fade(const Color(0xFF3F7CFF), 0.45 * _impact), blend: BlendMode.plus);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * hs * _impact
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFF8FC8FF), 0.8 * _impact);
      final r = (1 - _impact) * 260 * hs + 30 * hs;
      c.drawOval(Rect.fromCenter(center: Offset(hx + _rootX * sc + 40 * sc, ground), width: r * 2, height: r * 0.4), ring);
    }

    SceneKit.tiled(c, GameImages.get(GameImages.foreground), size, bottom: h + 30 * hs, height: 130 * hs, offset: camX * 2.5 + t * 4, opacity: 0.95);
    SceneKit.tiled(c, fog, size, bottom: h + 20 * hs, height: h * 0.28, offset: t * 40 * hs, opacity: 0.18);
    SceneKit.embers(c, size, t, count: 70);
    SceneKit.vignette(c, size, strength: 0.88);
  }

  /// Runs the training sequence and blends the rig toward the current drill.
  void _animate(double t, double dt) {
    var local = t % _cycle;
    var move = 0;
    while (move < _moves.length - 1 && local >= _moves[move]) {
      local -= _moves[move];
      move++;
    }
    if (move != _lastMove) {
      _lastMove = move;
      _struck = false;
    }
    final k = (local / _moves[move]).clamp(0.0, 1.0);
    var rate = 18.0;
    var trail = false;
    var sheathTarget = 0.0;
    var rx = 0.0;
    var ry = 0.0;
    final p = _target;
    switch (move) {
      case 0: // Focus: sheathed meditation stance.
        p.sheathedIdle(t);
        sheathTarget = 1;
        rate = 8;
        break;
      case 1: // Iaido quick-draw cut.
        if (k < 0.25) {
          p.sheathedIdle(t);
          p.torso = 0.25;
          p.fUpper = -0.2;
          p.fFore = 1.4;
          sheathTarget = 1;
        } else {
          p.quickDraw(((k - 0.25) / 0.4).clamp(0.0, 1.0));
          trail = k < 0.7;
          rx = 30 * easeOutCubic(((k - 0.25) / 0.3).clamp(0.0, 1.0));
          _strike(k > 0.4, 0.7);
        }
        rate = 30;
        break;
      case 2: // Four-cut combo.
        final seg = (k * 4).floor().clamp(0, 3);
        final sk = (k * 4 - seg).clamp(0.0, 1.0);
        if (sk < 0.3) {
          p.windUp(sk / 0.3);
        } else {
          final e = (sk - 0.3) / 0.7;
          switch (seg) {
            case 0:
              p.slashDown(e);
              break;
            case 1:
              p.slashUp(e);
              break;
            case 2:
              p.sweep(e);
              break;
            default:
              p.thrust(e);
          }
          trail = e < 0.7;
          if (e > 0.25 && e < 0.35) _strike(true, seg == 3 ? 1.0 : 0.6, again: true);
        }
        rx = 30 + seg * 12.0;
        rate = 32;
        break;
      case 3: // Low sweeping cut.
        if (k < 0.35) {
          p.windUp(k / 0.35);
          p.torso = 0.4;
        } else {
          p.sweep(((k - 0.35) / 0.4).clamp(0.0, 1.0));
          p.torso = 0.45;
          p.fThigh = 0.9;
          p.bThigh = -0.8;
          trail = k < 0.8;
          _strike(k > 0.5, 0.8);
        }
        rx = 60;
        ry = 10 * math.sin(k * math.pi);
        rate = 28;
        break;
      case 4: // Jumping downward strike.
        final jk = (k / 0.85).clamp(0.0, 1.0);
        ry = -math.sin(jk * math.pi) * 150;
        rx = 60 + 40 * jk;
        if (jk < 0.45) {
          p.jump();
          p.weapon = -0.6;
        } else if (jk < 1) {
          p.slashDown(((jk - 0.45) / 0.45).clamp(0.0, 1.0));
          p.fThigh = 0.8;
          trail = true;
          _strike(jk > 0.7, 1.0);
        } else {
          p.smashImpact();
        }
        rate = 26;
        break;
      case 5: // Whirlwind spin.
        p.spinSlash(k);
        rx = 100 - 20 * k;
        ry = -math.sin(k * math.pi) * 40;
        trail = true;
        if (k > 0.5) _strike(true, 0.8);
        rate = 40;
        break;
      case 6: // Shadow dash back and forth.
        if (k < 0.3) {
          p.dash();
          rx = 80 - 260 * easeOutCubic(k / 0.3);
        } else if (k < 0.45) {
          p.planted(t);
          rx = -180;
        } else if (k < 0.75) {
          p.dash();
          p.weapon = 1.4;
          rx = -180 + 260 * easeOutCubic((k - 0.45) / 0.3);
          trail = true;
          _strike(k > 0.62, 1.0);
        } else {
          p.planted(t);
          rx = 80;
        }
        rate = 30;
        break;
      case 7: // Rising power smash.
        if (k < 0.4) {
          p.windUp(k / 0.4);
          p.torso = -0.1;
          ry = -math.sin(k / 0.4 * math.pi * 0.5) * 120;
        } else if (k < 0.55) {
          p.slashDown((k - 0.4) / 0.15);
          ry = -120 * (1 - (k - 0.4) / 0.15);
          trail = true;
        } else {
          p.smashImpact();
          p.weapon = 0.2;
          if (!_struck) {
            _struck = true;
            _impact = 1;
            _dummyHit = 1.2;
          }
        }
        rx = 70;
        rate = 34;
        break;
      default: // Sheathe the blade and return to stance.
        if (k < 0.45) {
          p.planted(t);
          p.weapon = lerpD(2.0, -1.2, easeInOut(k / 0.45));
        } else {
          p.sheathedIdle(t);
          sheathTarget = 1;
        }
        rx = lerpD(70, 0, easeInOut(k));
        rate = 12;
    }
    if (move != 4 && move != 7 && move != 5) ry = ry.clamp(-200.0, 20.0);
    _rootX += (rx - _rootX) * smoothK(move == 6 ? 30 : 10, dt);
    _rootY += (ry - _rootY) * smoothK(26, dt);
    _sheath += (sheathTarget - _sheath) * smoothK(sheathTarget > _sheath ? 9 : 40, dt);
    _rig.pose.blend(p, smoothK(rate, dt));
    _rig.compute();
    _rig.updateCloth(dt, _rootX, _rootY, 1, t, wind: 0.7 + 0.3 * math.sin(t * 0.6));

    // Blade trail in model space.
    if (trail && _sheath < 0.5) {
      final s = _rig.skel;
      final rot = _rig.pose.rot;
      Offset m(Offset q) {
        if (rot == 0) return Offset(_rootX + q.dx, _rootY + q.dy);
        final cs = math.cos(rot), sn = math.sin(rot);
        return Offset(_rootX + q.dx * cs - q.dy * sn, _rootY + q.dx * sn + q.dy * cs);
      }

      _trailBase.add(m(s.fHand + s.wDir * 10));
      _trailTip.add(m(s.wTip));
      if (_trailBase.length > 10) {
        _trailBase.removeAt(0);
        _trailTip.removeAt(0);
      }
    } else if (_trailBase.isNotEmpty) {
      _trailBase.removeAt(0);
      _trailTip.removeAt(0);
    }

    // Afterimages while dashing.
    _ghostT -= dt;
    if (move == 6 && (k < 0.3 || (k > 0.45 && k < 0.75)) && _ghostT <= 0) {
      _ghostT = 0.04;
      final g = _ghosts.length > 8 ? _ghosts.removeAt(0) : _Ghost();
      g.pose.copyFrom(_rig.pose);
      g.x = _rootX;
      g.y = _rootY;
      g.life = 0.3;
      _ghosts.add(g);
    }
    for (final g in _ghosts) {
      g.life -= dt;
    }
    _ghosts.removeWhere((g) => g.life <= 0);

    _dummyHit = math.max(0, _dummyHit - dt * 3);
    _impact = math.max(0, _impact - dt * 1.6);
    _dummyLean += (_dummyHit * 0.25 - _dummyLean) * smoothK(14, dt);
  }

  void _strike(bool when, double power, {bool again = false}) {
    if (!when) return;
    if (_struck && !again) return;
    if (again && _dummyHit > 0.5) return;
    _struck = true;
    _dummyHit = math.max(_dummyHit, power);
  }

  /// Straw-wrapped wooden training post that rocks when struck.
  void _drawDummy(Canvas c, double x, double ground, double sc, double t) {
    final wob = math.sin(t * 22) * _dummyHit * 0.06 + _dummyLean;
    c.save();
    c.translate(x, ground);
    c.scale(sc, sc);
    c.rotate(wob);
    final wood = Paint()..color = const Color(0xFF14161E);
    final rim = Paint()
      ..color = fade(const Color(0xFF9AB8E0), 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final post = RRect.fromRectAndRadius(const Rect.fromLTRB(-9, -170, 9, 0), const Radius.circular(4));
    c.drawRRect(post, wood);
    c.drawLine(const Offset(-8, -168), const Offset(-8, -4), rim);
    // Straw wrapping.
    final straw = Paint()..color = const Color(0xFF1E2028);
    final band = Paint()
      ..color = const Color(0xFF3A3C48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final body = RRect.fromRectAndRadius(const Rect.fromLTRB(-17, -150, 17, -70), const Radius.circular(10));
    c.drawRRect(body, straw);
    for (var i = 0; i < 6; i++) {
      final y = -144.0 + i * 13;
      c.drawLine(Offset(-16, y), Offset(16, y + 3), band);
    }
    c.drawLine(const Offset(-16, -146), const Offset(-16, -74), rim);
    // Cross arm.
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(-34, -128, 34, -120), const Radius.circular(3)), wood);
    // Hit glow.
    if (_dummyHit > 0.05) {
      SoftSprite.draw(c, const Offset(-14, -110), 50, fade(const Color(0xFF8FC8FF), 0.5 * _dummyHit.clamp(0.0, 1.0)), blend: BlendMode.plus);
    }
    c.restore();
    // Base stones.
    final stone = Paint()..color = const Color(0xFF0C0D12);
    c.drawOval(Rect.fromCenter(center: Offset(x, ground), width: 70 * sc, height: 12 * sc), stone);
  }

  @override
  bool shouldRepaint(LobbyScenePainter old) => old.clock != clock;
}

class _Ghost {
  final Pose pose = Pose();
  final Skeleton skel = Skeleton();
  double x = 0;
  double y = 0;
  double life = 0;
}

/// Darkened animated backdrop used by level select / settings / victory.
class BackdropPainter extends CustomPainter {
  BackdropPainter(this.clock, {this.tint = const Color(0xFF000000), this.emberColor = const Color(0xFFFF6A3A)}) : super(repaint: clock);
  final ValueNotifier<double> clock;
  final Color tint;
  final Color emberColor;

  @override
  void paint(Canvas c, Size size) {
    final t = clock.value;
    SceneKit.cover(c, GameImages.get(GameImages.lobbyBg), size, zoom: 1.12 + math.sin(t * 0.1) * 0.03, pan: Offset(math.sin(t * 0.13) * 20, 0));
    final p = Paint()..color = const Color(0x99000000);
    c.drawRect(Offset.zero & size, p);
    if (tint.a > 0) {
      p.color = fade(tint, 0.25);
      c.drawRect(Offset.zero & size, p);
    }
    SceneKit.tiled(c, GameImages.get(GameImages.fog), size, bottom: size.height * 1.02, height: size.height * 0.5, offset: t * 18, opacity: 0.3);
    SceneKit.embers(c, size, t, count: 50, color: emberColor);
    SceneKit.vignette(c, size, strength: 0.9);
  }

  @override
  bool shouldRepaint(BackdropPainter old) => old.clock != clock || old.tint != tint;
}
