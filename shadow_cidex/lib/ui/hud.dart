import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/battle.dart';
import 'theme.dart';
import 'widgets.dart';

/// Gameplay HUD: hearts, health, score, boss bar, banner and touch controls.
class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.hud, required this.input, required this.onPause});
  final HudState hud;
  final GameInput input;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final h = box.maxHeight;
      final w = box.maxWidth;
      final u = math.min(h / 600, w / 1100).clamp(0.78, 1.3).toDouble();
      final ctrl = math.min(h / 620, w / 1000).clamp(0.72, 1.2).toDouble();
      return SafeArea(
        child: Stack(
          children: [
            // Top-left status.
            Positioned(
              left: 18 * u,
              top: 12 * u,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: hud.hearts,
                      builder: (context, v, _) => HeartsRow(hearts: v, size: 24 * u),
                    ),
                    SizedBox(height: 6 * u),
                    ValueListenableBuilder<bool>(
                      valueListenable: hud.regen,
                      builder: (context, regen, _) => ValueListenableBuilder<double>(
                        valueListenable: hud.health,
                        builder: (context, v, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _HealthBar(value: v, width: 220 * u, height: 12 * u, regen: regen),
                            if (regen) ...[
                              SizedBox(width: 6 * u),
                              Icon(Icons.add_circle_rounded, size: 15 * u, color: const Color(0xFF7FFFD0)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * u),
                    ValueListenableBuilder<int>(
                      valueListenable: hud.score,
                      builder: (context, v, _) => Text('SCORE  ${v.toString().padLeft(6, '0')}', style: UiText.body(15 * u, color: const Color(0xFFD8E2F0))),
                    ),
                    SizedBox(height: 2 * u),
                    ValueListenableBuilder<String>(
                      valueListenable: hud.objective,
                      builder: (context, v, _) => v.isEmpty ? const SizedBox.shrink() : Text(v, style: UiText.body(12.5 * u, color: UiColors.accent)),
                    ),
                  ],
                ),
              ),
            ),
            // Boss bar.
            Positioned(
              top: 14 * u,
              left: w * 0.3,
              right: w * 0.18,
              child: IgnorePointer(
                child: ValueListenableBuilder<BossHud?>(
                  valueListenable: hud.boss,
                  builder: (context, v, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: v == null ? const SizedBox.shrink() : _BossBar(key: ValueKey(v.phase), info: v, u: u),
                  ),
                ),
              ),
            ),
            // Pause.
            Positioned(
              right: 18 * u,
              top: 12 * u,
              child: RoundIconButton(icon: Icons.pause_rounded, size: 46 * u, onTap: onPause),
            ),
            // Banner.
            Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<BannerInfo?>(
                  valueListenable: hud.banner,
                  builder: (context, v, _) => v == null ? const SizedBox.shrink() : _Banner(key: ValueKey(v.id), info: v, u: u),
                ),
              ),
            ),
            // Joystick.
            Positioned(
              left: 30 * ctrl,
              bottom: 26 * ctrl,
              child: VirtualJoystick(size: 190 * ctrl, onChanged: (v) => input.moveX = v),
            ),
            // Action buttons.
            Positioned(
              right: 30 * ctrl,
              bottom: 26 * ctrl,
              child: SizedBox(
                width: 290 * ctrl,
                height: 230 * ctrl,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: ActionButton(
                        size: 112 * ctrl,
                        color: const Color(0xFFFF4A5A),
                        onDown: () => input.attack = true,
                        child: CustomPaint(size: Size.square(58 * ctrl), painter: SwordIconPainter(const Color(0xFFFFE0E4))),
                      ),
                    ),
                    Positioned(
                      right: 124 * ctrl,
                      bottom: 2 * ctrl,
                      child: ActionButton(
                        size: 84 * ctrl,
                        color: UiColors.accent,
                        onDown: () => input.jump = true,
                        child: Icon(Icons.keyboard_double_arrow_up_rounded, size: 42 * ctrl, color: const Color(0xFFE0F4FF)),
                      ),
                    ),
                    Positioned(
                      right: 18 * ctrl,
                      bottom: 124 * ctrl,
                      child: ValueListenableBuilder<double>(
                        valueListenable: hud.power,
                        builder: (context, v, _) => PowerButton(size: 84 * ctrl, charge: v, onDown: () => input.power = true),
                      ),
                    ),
                    Positioned(
                      right: 128 * ctrl,
                      bottom: 108 * ctrl,
                      child: ActionButton(
                        size: 76 * ctrl,
                        color: const Color(0xFF7FFFD0),
                        onDown: () {
                          input.dash = true;
                          input.sprint = true;
                        },
                        onUp: () => input.sprint = false,
                        child: CustomPaint(size: Size.square(40 * ctrl), painter: SprintIconPainter(const Color(0xFFDFFFF4))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HealthBar extends StatelessWidget {
  const _HealthBar({required this.value, required this.width, required this.height, this.regen = false});
  final double value;
  final double width;
  final double height;
  final bool regen;

  @override
  Widget build(BuildContext context) {
    final low = value < 0.3;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xCC05060A),
        border: Border.all(color: regen ? const Color(0xFF7FFFD0) : const Color(0x88A0B4D0), width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 160),
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: regen
                      ? const [Color(0xFF8A0E1E), Color(0xFFFF3A4A), Color(0xFF9AFFD8)]
                      : (low ? const [Color(0xFF7A0A10), Color(0xFFFF2A2A)] : const [Color(0xFF8A0E1E), Color(0xFFFF3A4A), Color(0xFFFF8A8A)]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BossBar extends StatelessWidget {
  const _BossBar({super.key, required this.info, required this.u});
  final BossHud info;
  final double u;

  @override
  Widget build(BuildContext context) {
    final c = info.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(info.name, style: UiText.heading(15 * u, color: Color.lerp(c, Colors.white, 0.45)!)),
              ),
            ),
            if (info.phases > 1) ...[
              SizedBox(width: 10 * u),
              for (var i = 0; i < info.phases; i++)
                Container(
                  width: 8 * u,
                  height: 8 * u,
                  margin: EdgeInsets.only(left: 3 * u),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < info.phase ? const Color(0xFF2A2C34) : (i == info.phase ? c : c.withAlpha(90)),
                  ),
                ),
            ],
          ],
        ),
        SizedBox(height: 5 * u),
        Container(
          height: 13 * u,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xDD05060A),
            border: Border.all(color: c.withAlpha(170), width: 1.2),
            boxShadow: [BoxShadow(color: c.withAlpha(60), blurRadius: 14)],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: info.frac.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 220),
              builder: (context, v, _) => FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color.lerp(c, Colors.black, 0.45)!, c, Color.lerp(c, Colors.white, 0.35)!]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatefulWidget {
  const _Banner({super.key, required this.info, required this.u});
  final BannerInfo info;
  final double u;

  @override
  State<_Banner> createState() => _BannerState();
}

class _BannerState extends State<_Banner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final a = t < 0.15 ? t / 0.15 : (t > 0.75 ? (1 - t) / 0.25 : 1.0);
        final spread = 1.0 + 0.3 * (1 - Curves.easeOutCubic.transform((t / 0.3).clamp(0.0, 1.0)));
        return Opacity(
          opacity: a.clamp(0.0, 1.0),
          child: Align(
            alignment: const Alignment(0, -0.38),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: spread,
                  child: Text(widget.info.title, textAlign: TextAlign.center, style: UiText.title(40 * u, glow: 0.9)),
                ),
                SizedBox(height: 8 * u),
                Container(width: 260 * u * (2 - spread), height: 1.5, color: UiColors.red.withAlpha(200)),
                SizedBox(height: 8 * u),
                Text(widget.info.subtitle, textAlign: TextAlign.center, style: UiText.body(18 * u, color: const Color(0xFFC8D4E8))),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal virtual joystick (left / right movement).
class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({super.key, required this.size, required this.onChanged});
  final double size;
  final ValueChanged<double> onChanged;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knob = Offset.zero;
  int? _pointer;

  void _update(Offset local) {
    final r = widget.size / 2;
    var d = local - Offset(r, r);
    final maxR = r * 0.62;
    if (d.distance > maxR) d = d / d.distance * maxR;
    setState(() => _knob = d);
    var v = d.dx / maxR;
    if (v.abs() < 0.14) v = 0;
    widget.onChanged(v.clamp(-1.0, 1.0));
  }

  void _release() {
    _pointer = null;
    setState(() => _knob = Offset.zero);
    widget.onChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        if (_pointer != null) return;
        _pointer = e.pointer;
        _update(e.localPosition);
      },
      onPointerMove: (e) {
        if (e.pointer == _pointer) _update(e.localPosition);
      },
      onPointerUp: (e) {
        if (e.pointer == _pointer) _release();
      },
      onPointerCancel: (e) {
        if (e.pointer == _pointer) _release();
      },
      child: SizedBox(
        width: s,
        height: s,
        child: CustomPaint(painter: _JoystickPainter(_knob, _pointer != null)),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  _JoystickPainter(this.knob, this.active);
  final Offset knob;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(c, r * 0.92, Paint()..color = const Color(0x5505070C));
    canvas.drawCircle(
      c,
      r * 0.92,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = UiColors.accent.withAlpha(active ? 150 : 80),
    );
    canvas.drawCircle(
      c,
      r * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = UiColors.accent.withAlpha(40),
    );
    final arrow = Paint()..color = UiColors.accent.withAlpha(active ? 170 : 100);
    for (final dir in [-1.0, 1.0]) {
      final ax = c.dx + dir * r * 0.78;
      canvas.drawPath(
        Path()
          ..moveTo(ax + dir * r * 0.1, c.dy)
          ..lineTo(ax - dir * r * 0.04, c.dy - r * 0.11)
          ..lineTo(ax - dir * r * 0.04, c.dy + r * 0.11)
          ..close(),
        arrow,
      );
    }
    final k = c + knob;
    canvas.drawCircle(k, r * 0.36, Paint()..color = UiColors.accent.withAlpha(active ? 60 : 30));
    canvas.drawCircle(
      k,
      r * 0.3,
      Paint()
        ..shader = RadialGradient(colors: [const Color(0xFF2A3446), const Color(0xFF0B0E15)]).createShader(Rect.fromCircle(center: k, radius: r * 0.3)),
    );
    canvas.drawCircle(
      k,
      r * 0.3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = UiColors.accent.withAlpha(active ? 220 : 140),
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter old) => old.knob != knob || old.active != active;
}

/// Round touch button that fires on pointer down (multi-touch friendly).
class ActionButton extends StatefulWidget {
  const ActionButton({super.key, required this.size, required this.color, required this.onDown, required this.child, this.onUp});
  final double size;
  final Color color;
  final VoidCallback onDown;
  final VoidCallback? onUp;
  final Widget child;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final c = widget.color;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        widget.onDown();
        setState(() => _down = true);
      },
      onPointerUp: (_) {
        widget.onUp?.call();
        setState(() => _down = false);
      },
      onPointerCancel: (_) {
        widget.onUp?.call();
        setState(() => _down = false);
      },
      child: AnimatedScale(
        scale: _down ? 0.9 : 1,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [c.withAlpha(_down ? 110 : 60), const Color(0xAA06070C)]),
            border: Border.all(color: c.withAlpha(_down ? 255 : 170), width: 2),
            boxShadow: [BoxShadow(color: c.withAlpha(_down ? 120 : 50), blurRadius: _down ? 22 : 12)],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Power button with a radial cooldown display (reloads every 5 seconds).
class PowerButton extends StatelessWidget {
  const PowerButton({super.key, required this.size, required this.charge, required this.onDown});
  final double size;
  final double charge;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    final ready = charge >= 1;
    const c = Color(0xFFB08CFF);
    return ActionButton(
      size: size,
      color: ready ? c : const Color(0xFF5A6070),
      onDown: onDown,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CooldownPainter(charge, ready),
          child: Center(
            child: Icon(Icons.bolt_rounded, size: size * 0.5, color: ready ? const Color(0xFFF0E6FF) : const Color(0xFF7A8090)),
          ),
        ),
      ),
    );
  }
}

class _CooldownPainter extends CustomPainter {
  _CooldownPainter(this.charge, this.ready);
  final double charge;
  final bool ready;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 5);
    if (!ready) {
      canvas.drawCircle(r.center, r.width / 2, Paint()..color = const Color(0x88000000));
    }
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * charge.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = ready ? const Color(0xFFD0B8FF) : const Color(0xFF8A70D0),
    );
  }

  @override
  bool shouldRepaint(_CooldownPainter old) => old.charge != charge || old.ready != ready;
}
