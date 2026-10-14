import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/audio_manager.dart';
import '../graphics/particles.dart';
import '../graphics/scene.dart';
import 'game_screen.dart';
import 'widgets.dart';

double _smooth(double x) {
  final t = x < 0 ? 0.0 : (x > 1 ? 1.0 : x);
  return t * t * (3 - 2 * t);
}

class _SItem {
  final double z;
  final double x;
  final int style;
  final int frame;
  _SItem(this.z, this.x, this.style, this.frame);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const double total = 6.5;
  static const List<double> _shots = <double>[1.1, 2.0, 2.9, 3.7, 4.5, 5.2];

  late final AnimationController _c;
  final SceneRenderer _scene = SceneRenderer();
  final Particles _fx = Particles();
  final math.Random _r = math.Random();

  double _last = 0;
  double _recoil = 0;
  double _flash = 0;
  double _shake = 0;
  double _white = 0;
  int _shotIdx = 0;
  int _explIdx = 0;
  bool _voice = false;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: (total * 1000).round()));
    _c.addListener(_tick);
    _c.addStatusListener((AnimationStatus s) {
      if (s == AnimationStatus.completed) _go();
    });
    AudioManager.I.playMusic('music_splash');
    AudioManager.I.sfx('footstep', volume: 0.8);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go() {
    if (_gone || !mounted) return;
    _gone = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (BuildContext c, Animation<double> a, Animation<double> b) => const GameScreen(),
        transitionsBuilder: (BuildContext c, Animation<double> a, Animation<double> b, Widget child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  void _tick() {
    final cam = _scene.cam;
    final now = _c.value * total;
    var dt = now - _last;
    if (dt < 0) dt = 0;
    _last = now;
    _fx.update(dt);
    _recoil = math.max(0.0, _recoil - dt * 5.5);
    _flash = math.max(0.0, _flash - dt);
    _white = math.max(0.0, _white - dt * 3);
    _shake = math.max(0.0, _shake - dt * 40);
    if (cam.w <= 0) return;

    while (_shotIdx < _shots.length && now >= _shots[_shotIdx]) {
      _shotIdx++;
      _recoil = 1.0;
      _flash = 0.12;
      _shake = 9;
      _white = 0.25;
      final s = cam.w * 0.0026;
      final mx = cam.sx(0, 0);
      final my = cam.sy(0) - (56 + 108 + 8) * s;
      _fx.muzzle(mx, my, 1.4);
      AudioManager.I.sfx('shoot');
    }
    while (_explIdx < _shots.length && now >= _shots[_explIdx] + 0.45) {
      _explIdx++;
      final x = _r.nextDouble() * 1.4 - 0.7;
      _fx.explosion(cam.sx(x, 30), cam.sy(30) - cam.w * 0.05, scale: 1.0 + _r.nextDouble() * 0.6);
      AudioManager.I.sfx('explosion', volume: 0.7);
      _shake = math.max(_shake, 6);
    }
    if (!_voice && now > 2.3) {
      _voice = true;
      AudioManager.I.sfx('voice_battle');
    }
    final e = _smooth((now - 0.8) / 3.2);
    if (e > 0.85 && _r.nextDouble() < 0.5) {
      final x = _r.nextDouble() * 1.6 - 0.8;
      _fx.spark(cam.sx(x, 28), cam.sy(28) - cam.w * 0.06, n: 4, speed: 220);
      if (_r.nextDouble() < 0.2) _fx.smoke(cam.sx(x, 28), cam.sy(28) - cam.w * 0.03, size: 12, n: 1, rise: 50);
    }
  }

  void _paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w < 10 || h < 10) return;
    _scene.layout(w, h);
    final cam = _scene.cam;
    final t = _c.value * total;
    final e = _smooth((t - 0.8) / 3.2);

    canvas.save();
    final zoom = 1.0 + 0.10 * _c.value;
    canvas.translate(w / 2, h * 0.8);
    canvas.scale(zoom);
    canvas.translate(-w / 2, -h * 0.8);
    if (_shake > 0.2) {
      canvas.translate((_r.nextDouble() - 0.5) * _shake, (_r.nextDouble() - 0.5) * _shake);
    }

    _scene.drawBackdrop(canvas);
    _scene.drawGround(canvas, t * 4.0);

    final items = <_SItem>[];
    for (var i = 0; i < 14; i++) {
      final x = ((i % 7) - 3) * 0.2 + math.sin(i * 1.7) * 0.05;
      final z = 1.5 + (i ~/ 7) * 2.2 + 22 * e;
      items.add(_SItem(z, x, i % 4, ((t * 9 + i).floor()) % 6));
    }
    for (var j = 0; j < 14; j++) {
      final x = ((j % 7) - 3) * 0.19 + math.sin(j * 2.3) * 0.06;
      final z = 82 - 52 * e + (j ~/ 7) * 2.4;
      items.add(_SItem(z, x, j % 5 == 0 ? 5 : 4, ((t * 9 + j * 2).floor()) % 6));
    }
    items.sort((a, b) => b.z.compareTo(a.z));
    for (final it in items) {
      final sc = cam.scale(it.z);
      final dh = cam.w * (it.style == 5 ? 0.235 : 0.19) * sc;
      _scene.drawSprite(canvas, it.style, it.frame, cam.sx(it.x, it.z), cam.sy(it.z), dh);
    }
    _scene.drawFog(canvas);

    // crew around cannon
    for (final side in <double>[-1.0, 1.0]) {
      final sc = cam.scale(0.6);
      final dh = cam.w * 0.19 * sc;
      final hop = math.sin(t * 7 + side).abs() * 0.12;
      _scene.drawSprite(canvas, side < 0 ? 1 : 2, ((t * 6).floor() + (side > 0 ? 3 : 0)) % 6, cam.sx(side * 0.3, 0.6),
          cam.sy(0.6) - hop * dh, dh);
    }
    _scene.drawCannon(canvas, cam.sx(0, 0), cam.sy(0), 0, _recoil, _flash);
    _fx.render(canvas);
    canvas.restore();

    _scene.drawVignette(canvas);
    if (_white > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Color.fromARGB((_white * 120).round().clamp(0, 255).toInt(), 255, 230, 190));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            final t = _c.value * total;
            final p = _smooth((t - 0.3) / 0.9);
            final pulse = 1.0 + 0.025 * math.sin(t * 3.2);
            final scale = (1.0 + 0.35 * (1 - p)) * pulse;
            final fade = _smooth((t - (total - 0.6)) / 0.5);
            final bar = (t / total).clamp(0.0, 1.0).toDouble();
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CustomPaint(painter: _SplashPainter(this, _c)),
                SafeArea(
                  child: Align(
                    alignment: const Alignment(0, -0.72),
                    child: Opacity(
                      opacity: p,
                      child: Transform.scale(scale: scale, child: const RealClashLogo(size: 84)),
                    ),
                  ),
                ),
                Positioned(
                  left: 48,
                  right: 48,
                  bottom: 40,
                  height: 8,
                  child: Opacity(
                    opacity: p,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x66000000),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0x99FFFFFF), width: 1),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: bar,
                          heightFactor: 1.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(colors: <Color>[Color(0xFF3FA9FF), Color(0xFFFFC94A)]),
                              boxShadow: const <BoxShadow>[BoxShadow(color: Color(0xAAFFA726), blurRadius: 8)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(child: Opacity(opacity: fade, child: const ColoredBox(color: Colors.black))),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final _SplashScreenState s;
  _SplashPainter(this.s, Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) => s._paint(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
