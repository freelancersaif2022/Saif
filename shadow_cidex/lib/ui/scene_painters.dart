import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/images.dart';
import '../core/utils.dart';
import '../render/beasts.dart';
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
  double _lastT = -1;
  final Pose _ePose = Pose();
  final Skeleton _eSkel = Skeleton();

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
  static const HumanoidStyle brute = HumanoidStyle(height: 150, bulk: 1.6, weapon: WeaponType.greatsword, helmet: true, armor: true, hakama: true, cape: true, rimStrength: 0.4, bladeGlow: Color(0xFF801010), veins: Color(0xFFB01808), eyeGlow: 1.3);
  static const HumanoidStyle heavy = HumanoidStyle(height: 150, bulk: 1.4, weapon: WeaponType.axe, horns: true, armor: true, hakama: true, rimStrength: 0.4);
  static const HumanoidStyle swords = HumanoidStyle(height: 150, weapon: WeaponType.katana, hood: true, mask: true, rimStrength: 0.4);

  @override
  void paint(Canvas c, Size size) {
    final t = clock.value;
    final w = size.width;
    final h = size.height;
    final hs = h / 720;
    // Slow cinematic camera drift.
    final camX = math.sin(t * 0.16) * 26 * hs;
    final camY = math.cos(t * 0.11) * 8 * hs;
    final zoom = 1.08 + math.sin(t * 0.09) * 0.03;

    SceneKit.cover(c, GameImages.get(GameImages.lobbyBg), size, zoom: zoom, pan: Offset(camX * 0.4, camY * 0.4));
    SceneKit.lightShafts(c, size, t, intensity: 0.9);
    final fog = GameImages.get(GameImages.fog);
    SceneKit.tiled(c, fog, size, bottom: h * 0.82, height: h * 0.4, offset: t * 14 * hs, opacity: 0.35);

    final ground = h * 0.86;
    c.save();
    c.translate(camX * 0.7, camY * 0.7);

    // Eagle circling high on the left.
    final ex = w * 0.44 + math.sin(t * 0.5) * 60 * hs;
    final ey = h * 0.26 + math.sin(t * 1.1) * 18 * hs;
    c.save();
    c.translate(ex, ey);
    c.scale(math.cos(t * 0.5) >= 0 ? 1 : -1, 1);
    BeastPainter.eagle(c, s: 46 * hs, flap: t * 5.5, alpha: 0.95, time: t);
    c.restore();

    // Monster on the far right.
    c.save();
    c.translate(w * 0.9, ground - 8 * hs);
    c.scale(-0.72 * hs, 0.72 * hs);
    BeastPainter.monster(c, k: 1, walk: 0, alpha: 0.96, time: t, armF: 0.08 + 0.05 * math.sin(t * 0.8));
    c.restore();

    // Elephant on the far left.
    c.save();
    c.translate(w * 0.3, ground - 6 * hs);
    c.scale(0.7 * hs, 0.7 * hs);
    BeastPainter.elephant(c, k: 1, walk: 0, alpha: 0.96, time: t, trunk: 0.1 + 0.1 * math.sin(t * 0.9));
    c.restore();

    // Distance fog between the beasts and the warriors.
    SceneKit.tiled(c, fog, size, bottom: ground + 40 * hs, height: h * 0.32, offset: t * 22 * hs + 300, opacity: 0.32);

    // Rat crouched on the right.
    c.save();
    c.translate(w * 0.8, ground);
    c.scale(-0.58 * hs, 0.58 * hs);
    BeastPainter.rat(c, k: 1, run: 0, alpha: 1, time: t, crouch: 0.3 + 0.1 * math.sin(t * 2));
    c.restore();

    // Shadow warriors flanking the hero.
    _warrior(c, w * 0.43, ground, 1.25 * hs, heavy, t, 1);
    _warrior(c, w * 0.7, ground, 1.45 * hs, brute, t + 1.3, -1);
    _warrior(c, w * 0.49, ground, 1.0 * hs, swords, t + 2.1, 1);
    c.restore();

    // Ground band.
    final gimg = GameImages.get(GameImages.ground);
    if (gimg != null) {
      SceneKit.tiled(c, gimg, size, bottom: h + 40 * hs, height: (h - ground) + 40 * hs, offset: camX, opacity: 1);
    }
    final gp = Paint()
      ..shader = ui.Gradient.linear(Offset(0, ground - 30 * hs), Offset(0, h), [const Color(0x00000000), const Color(0xCC000000)]);
    c.drawRect(Rect.fromLTWH(0, ground - 30 * hs, w, h - ground + 30 * hs), gp);

    // Hero spotlight.
    final hx = w * 0.58 + camX;
    final spot = Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(Offset(hx, ground - 120 * hs), 260 * hs, [const Color(0x33587CB0), const Color(0x00000000)]);
    c.drawCircle(Offset(hx, ground - 120 * hs), 260 * hs, spot);

    // Hero.
    final dt = _lastT < 0 ? 1 / 60 : (t - _lastT).clamp(0.0, 1 / 20).toDouble();
    _lastT = t;
    _rig.pose.idle(t);
    _rig.pose.weapon = 2.2 + math.sin(t * 2.2) * 0.04;
    _rig.compute();
    _rig.updateCloth(dt, 0, 0, 1, t, wind: 0.7 + 0.3 * math.sin(t * 0.6));
    final shadow = Paint()..color = const Color(0xAA000000);
    c.drawOval(Rect.fromCenter(center: Offset(hx, ground), width: 130 * hs, height: 16 * hs), shadow);
    c.save();
    c.translate(hx, ground);
    c.scale(1.75 * hs, 1.75 * hs);
    HumanoidPainter.draw(c, _rig.skel, _rig.pose, hero, time: t, wind: 0.6 + 0.3 * math.sin(t * 0.7), cloth: _rig.cloth);
    c.restore();

    SceneKit.tiled(c, GameImages.get(GameImages.foreground), size, bottom: h + 30 * hs, height: 130 * hs, offset: camX * 2.5 + t * 4, opacity: 0.95);
    SceneKit.tiled(c, fog, size, bottom: h + 20 * hs, height: h * 0.28, offset: t * 40 * hs, opacity: 0.18);
    SceneKit.embers(c, size, t, count: 70);
    SceneKit.vignette(c, size, strength: 0.88);
  }

  void _warrior(Canvas c, double x, double ground, double scale, HumanoidStyle style, double t, double facing) {
    _ePose.idle(t, breath: 1.3);
    _eSkel.compute(_ePose, style);
    c.save();
    c.translate(x, ground);
    c.scale(facing * scale, scale);
    HumanoidPainter.draw(c, _eSkel, _ePose, style, time: t, alpha: 0.97, rimDx: facing);
    c.restore();
  }

  @override
  bool shouldRepaint(LobbyScenePainter old) => old.clock != clock;
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
