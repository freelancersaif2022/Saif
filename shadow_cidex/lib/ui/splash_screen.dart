import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../audio.dart';
import '../core/images.dart';
import '../core/utils.dart';
import '../render/humanoid.dart';
import '../render/soft_sprite.dart';
import 'lobby_screen.dart';
import 'scene_painters.dart';
import 'theme.dart';
import 'widgets.dart';

/// Cinematic intro: smoke gathers into the shadow warrior, title glitches in.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin, SceneClock {
  static const double duration = 7.0;
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  double _imgP = 0;
  double _audioP = 0;
  bool _loaded = false;
  bool _ready = false;
  bool _left = false;
  final Set<int> _cues = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await GameImages.load(GameImages.splashBg);
    await GameImages.load(GameImages.fog);
    if (mounted) setState(() => _ready = true);
    try {
      await GameAudio.instance.init().timeout(const Duration(seconds: 3));
    } catch (_) {}
    _cue(0, Sfx.splashIntro, 0.9);
    try {
      await Future.wait([
        GameImages.loadAll(onProgress: (p) => _imgP = p),
        GameAudio.instance.preload(onProgress: (p) => _audioP = p),
      ]).timeout(const Duration(seconds: 12));
    } catch (_) {
      // Never block the intro on slow storage or audio devices.
    }
    _loaded = true;
  }

  void _cue(int id, String sfx, double vol) {
    if (_cues.contains(id)) return;
    _cues.add(id);
    GameAudio.instance.play(sfx, volume: vol);
  }

  @override
  void onClockTick(double t) {
    if (!_ready) return;
    if (t > 0.55) _cue(1, Sfx.splashShadowForm, 0.85);
    if (t > 2.9) _cue(2, Sfx.splashReveal, 1.0);
    if (t > 3.55) _cue(3, Sfx.splashTitle, 0.9);
    if (t > 4.6) _cue(4, Sfx.splashLoading, 0.5);
    if (t > 5.6) _cue(5, Sfx.splashLoading, 0.5);
    final real = 0.12 + 0.88 * (_imgP * 0.4 + _audioP * 0.6);
    final timed = clampD((t - 0.4) / (duration - 1.2), 0, 1);
    _progress.value = _loaded ? timed : math.min(timed, real);
    if (t >= duration && _loaded && !_left) {
      _left = true;
      Navigator.of(context).pushReplacement(FadeRoute(page: const LobbyScreen(), ms: 900));
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _ready
          ? CustomPaint(
              painter: _SplashPainter(clock, _progress),
              size: Size.infinite,
            )
          : const SizedBox.expand(),
    );
  }
}

class _Smoke {
  _Smoke(math.Random r)
      : start = 0.25 + r.nextDouble() * 2.2,
        angle = r.nextDouble() * math.pi * 2,
        radius = 0.35 + r.nextDouble() * 0.5,
        spin = 2.5 + r.nextDouble() * 3,
        size = 0.012 + r.nextDouble() * 0.03,
        ember = r.nextDouble() < 0.18,
        height = r.nextDouble();
  final double start;
  final double angle;
  final double radius;
  final double spin;
  final double size;
  final bool ember;
  final double height;
}

class _SplashPainter extends CustomPainter {
  _SplashPainter(this.clock, this.progress) : super(repaint: Listenable.merge([clock, progress]));
  final ValueNotifier<double> clock;
  final ValueNotifier<double> progress;

  static final List<_Smoke> _smoke = List.generate(260, (i) => _Smoke(math.Random(i * 7 + 3)));
  final Pose _pose = Pose();
  final Skeleton _skel = Skeleton();
  final Paint _p = Paint()..isAntiAlias = true;
  TextPainter? _title;
  TextPainter? _loading;
  double _titleFor = 0;

  static const HumanoidStyle _style = HumanoidStyle(
    height: 150,
    hood: true,
    cape: true,
    eye: Color(0xFFFF2A2A),
    eyeGlow: 1.0,
    rim: Color(0xFFB0C4E8),
    rimStrength: 0.75,
    bladeColor: Color(0xFFE0E8F8),
    bladeGlow: Color(0x66FF2020),
  );

  @override
  void paint(Canvas c, Size size) {
    final t = clock.value;
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.58);

    // Camera: slow push-in plus a punch at the reveal.
    final reveal = t - 2.9;
    final punch = reveal > 0 && reveal < 0.6 ? math.sin(reveal / 0.6 * math.pi) * 0.04 : 0.0;
    final shake = reveal > 0 && reveal < 0.5 ? (1 - reveal / 0.5) * 10 : 0.0;
    final zoom = 1.22 - 0.12 * easeOutCubic(t / SplashKit.total) + punch;
    final pan = Offset(-24 + t * 5 + math.sin(t * 40) * shake, math.cos(t * 37) * shake * 0.6);

    _p
      ..shader = null
      ..color = Colors.black;
    c.drawRect(Offset.zero & size, _p);
    final bgA = clampD(t / 1.0, 0, 1) * (0.55 + 0.45 * clampD((t - 2.6) / 0.6, 0, 1));
    SceneKit.cover(c, GameImages.get(GameImages.splashBg), size, zoom: zoom, pan: pan, opacity: bgA);
    SceneKit.lightShafts(c, size, t, intensity: clampD(t / 2, 0, 1) * 1.3);
    final fog = GameImages.get(GameImages.fog);
    SceneKit.tiled(c, fog, size, bottom: h * 0.95, height: h * 0.55, offset: t * 40, opacity: 0.5 * bgA);

    // Gathering smoke vortex.
    final charH = h * 0.5;
    for (final s in _smoke) {
      final k = (t - s.start) / 1.5;
      if (k <= 0) continue;
      double x;
      double y;
      double a;
      if (k < 1) {
        final r = s.radius * w * 0.6 * (1 - easeInCubic(k) * 0.92);
        final ang = s.angle + k * s.spin;
        x = center.dx + math.cos(ang) * r + pan.dx;
        y = center.dy - charH * 0.15 + math.sin(ang) * r * 0.45 - s.height * charH * 0.5 * k + pan.dy;
        a = math.sin(k * math.pi) * 0.75;
      } else {
        // Residual smoke drifting around the figure.
        final d = k - 1;
        final ang = s.angle + s.spin + d * 0.6;
        final r = w * (0.05 + d * 0.05) * (0.5 + s.radius);
        x = center.dx + math.cos(ang) * r + pan.dx;
        y = center.dy - s.height * charH * 0.9 - d * 30 + pan.dy;
        a = clampD(0.35 - d * 0.12, 0, 0.35);
      }
      if (a <= 0.01) continue;
      final rad = s.size * w * (s.ember ? 0.12 : 1.0);
      if (s.ember) {
        _p
          ..blendMode = BlendMode.plus
          ..color = fade(const Color(0xFFFF4A2A), a);
        c.drawCircle(Offset(x, y), rad, _p);
      } else {
        SoftSprite.draw(c, Offset(x, y), rad * 2.2, fade(const Color(0xFF07080C), a));
      }
    }
    _p.blendMode = BlendMode.srcOver;

    // Shadow warrior forming.
    final form = clampD((t - 1.5) / 1.5, 0, 1);
    if (form > 0) {
      _pose.planted(t);
      _skel.compute(_pose, _style);
      final scale = charH / 150;
      final eye = t < 2.9 ? 0.0 : (reveal < 0.4 ? 2.5 * (1 - reveal / 0.4) + 1 : 1.0);
      // Ghost copies while materialising.
      if (form < 1) {
        for (var i = 0; i < 3; i++) {
          c.save();
          c.translate(center.dx + pan.dx + math.sin(t * 13 + i * 2) * 14 * (1 - form), center.dy + charH * 0.5 + pan.dy);
          c.scale(scale, scale);
          HumanoidPainter.draw(c, _skel, _pose, _style, time: t, alpha: form * 0.25, wind: 1.0);
          c.restore();
        }
      }
      c.save();
      c.translate(center.dx + pan.dx, center.dy + charH * 0.5 + pan.dy);
      c.scale(scale, scale);
      HumanoidPainter.draw(c, _skel, _pose, _style, time: t, alpha: easeInOut(form), wind: 0.8 + 0.4 * math.sin(t), eyeBoost: eye - 1);
      c.restore();
    }

    // Reveal shockwave.
    if (reveal > 0 && reveal < 0.9) {
      final k = reveal / 0.9;
      _p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * (1 - k)
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFFFF3A2A), (1 - k) * 0.8);
      c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + charH * 0.5), width: w * 0.9 * easeOutCubic(k), height: h * 0.12 * easeOutCubic(k)), _p);
      _p
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.srcOver;
      if (reveal < 0.15) {
        _p.color = fade(const Color(0xFFFFE0D0), (1 - reveal / 0.15) * 0.35);
        c.drawRect(Offset.zero & size, _p);
      }
    }

    SceneKit.tiled(c, fog, size, bottom: h * 1.05, height: h * 0.3, offset: t * 70 + 400, opacity: 0.25);
    SceneKit.embers(c, size, t, count: 50, color: const Color(0xFFFF4A2A), speed: 1.4);

    // Title.
    _drawTitle(c, size, t);
    // Loading bar.
    _drawLoading(c, size, t);

    SceneKit.vignette(c, size, strength: 0.92);
    // Letterbox.
    _p.color = Colors.black;
    final lb = h * 0.07;
    c.drawRect(Rect.fromLTWH(0, 0, w, lb), _p);
    c.drawRect(Rect.fromLTWH(0, h - lb * 0.6, w, lb * 0.6), _p);
    // Fade from and to black.
    final fadeIn = 1 - clampD(t / 0.6, 0, 1);
    final fadeOut = clampD((t - (SplashKit.total - 0.45)) / 0.45, 0, 1);
    final f = math.max(fadeIn, fadeOut);
    if (f > 0) {
      _p.color = fade(Colors.black, f);
      c.drawRect(Offset.zero & size, _p);
    }
  }

  void _drawTitle(Canvas c, Size size, double t) {
    const start = 3.55;
    if (t < start) return;
    final w = size.width;
    final h = size.height;
    final fs = math.min(w * 0.078, h * 0.15);
    if (_title == null || (_titleFor - fs).abs() > 0.5) {
      _titleFor = fs;
      _title = TextPainter(
        text: TextSpan(text: 'SHADOW CIDEX', style: UiText.title(fs, glow: 0)),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    final tp = _title!;
    final pos = Offset((w - tp.width) / 2, h * 0.13);
    final k = t - start;
    final glitch = k < 0.9 ? (1 - k / 0.9) : (math.sin(t * 3.1) > 0.985 ? 0.25 : 0.0);
    final alpha = clampD(k / 0.35, 0, 1);
    // Glow behind the title.
    _p
      ..shader = ui.Gradient.radial(pos + Offset(tp.width / 2, tp.height / 2), tp.width * 0.6, [fade(const Color(0xFFB01020), 0.35 * alpha), const Color(0x00000000)])
      ..blendMode = BlendMode.srcOver;
    c.drawRect(Rect.fromCenter(center: pos + Offset(tp.width / 2, tp.height / 2), width: tp.width * 1.4, height: tp.height * 3), _p);
    _p.shader = null;

    c.saveLayer(Rect.fromLTWH(0, pos.dy - fs, w, tp.height + fs * 2), Paint()..color = fade(Colors.white, alpha));
    if (glitch > 0.01) {
      final r = math.Random((t * 30).floor());
      // Chromatic split.
      c.save();
      c.translate(-6 * glitch, 0);
      tp.paint(c, pos);
      c.restore();
      c.drawRect(Rect.fromLTWH(0, pos.dy - fs, w, tp.height + fs * 2), Paint()
        ..color = fade(const Color(0xFFFF2030), 0.6 * glitch)
        ..blendMode = BlendMode.srcATop);
      // Sliced horizontal offsets.
      const slices = 7;
      for (var i = 0; i < slices; i++) {
        final sy = pos.dy + tp.height * i / slices;
        final off = (r.nextDouble() - 0.5) * 60 * glitch;
        c.save();
        c.clipRect(Rect.fromLTWH(0, sy, w, tp.height / slices + 1));
        c.translate(off, 0);
        tp.paint(c, pos);
        c.restore();
      }
      c.save();
      c.translate(5 * glitch, 0);
      c.clipRect(Rect.fromLTWH(0, pos.dy + tp.height * r.nextDouble(), w, tp.height * 0.2));
      tp.paint(c, pos);
      c.restore();
    } else {
      tp.paint(c, pos);
    }
    c.restore();
    // Underline accent.
    final lw = tp.width * clampD((k - 0.5) / 0.6, 0, 1);
    _p.color = fade(const Color(0xFFFF2A3A), 0.85 * alpha);
    c.drawRect(Rect.fromCenter(center: Offset(w / 2, pos.dy + tp.height + fs * 0.32), width: lw, height: 2), _p);
  }

  void _drawLoading(Canvas c, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final a = clampD((t - 0.6) / 0.6, 0, 1);
    if (a <= 0) return;
    final bw = w * 0.42;
    final bx = (w - bw) / 2;
    final by = h * 0.86;
    final fs = math.max(11.0, h * 0.026);
    if (_loading == null || (_loading!.text!.style!.fontSize! - fs).abs() > 0.5) {
      _loading = TextPainter(
        text: TextSpan(text: 'LOADING...', style: UiText.body(fs, color: const Color(0xFFC8D4E8))),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    final lp = _loading!;
    final pulse = 0.65 + 0.35 * math.sin(t * 5);
    c.saveLayer(Rect.fromLTWH(bx - 10, by - lp.height - 20, bw + 20, lp.height + 40), Paint()..color = fade(Colors.white, a * pulse));
    lp.paint(c, Offset(bx, by - lp.height - 8));
    c.restore();
    final prog = progress.value;
    _p
      ..shader = null
      ..color = fade(const Color(0xFF10131A), a);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, 5), const Radius.circular(3)), _p);
    final fw = bw * prog;
    if (fw > 1) {
      _p.shader = ui.Gradient.linear(Offset(bx, by), Offset(bx + bw, by), [const Color(0xFF6A0A14), const Color(0xFFFF2A3A), const Color(0xFFFFB0B0)], const [0.0, 0.7, 1.0]);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, fw, 5), const Radius.circular(3)), _p);
      _p.shader = null;
      // Head glow.
      _p
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFFFF5060), 0.55 * a);
      c.drawCircle(Offset(bx + fw, by + 2.5), 9, _p);
      _p.blendMode = BlendMode.srcOver;
      // Sheen.
      final sx = bx + ((t * 0.6) % 1.0) * fw;
      _p.color = fade(Colors.white, 0.35 * a);
      c.drawRect(Rect.fromLTWH(sx, by, 16, 5), _p);
    }
  }

  @override
  bool shouldRepaint(_SplashPainter old) => old.clock != clock;
}

class SplashKit {
  SplashKit._();
  static const double total = 7.0;
}
