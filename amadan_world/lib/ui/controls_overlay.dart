import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/amadan_game.dart';
import '../game/hud_layout.dart';
import '../utils/asset_paths.dart';

/// Multi-touch controls: a floating joystick on the left, combat buttons on
/// the right and a small pause button next to the mini-map.
class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({super.key, required this.game});

  final AmadanGame game;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HudLayout(Size(constraints.maxWidth, constraints.maxHeight), padding);
        return Stack(
          children: [
            Positioned.fromRect(
              rect: layout.joystickZone,
              child: _Joystick(game: game, layout: layout),
            ),
            _circle(
              center: layout.fireCenter,
              radius: layout.fireRadius,
              child: _HoldButton(
                icon: AssetPaths.iconFire,
                color: const Color(0xFFC23A22),
                onChanged: (down) => game.input.fire = down,
              ),
            ),
            _circle(
              center: layout.aimCenter,
              radius: layout.aimRadius,
              child: ValueListenableBuilder<bool>(
                valueListenable: game.aimingNotifier,
                builder: (context, aiming, _) => _HoldButton(
                  icon: AssetPaths.iconAim,
                  color: const Color(0xFF3A6E8E),
                  active: aiming,
                  onChanged: (down) {
                    if (down) game.input.requestAimToggle();
                  },
                ),
              ),
            ),
            _circle(
              center: layout.reloadCenter,
              radius: layout.reloadRadius,
              child: _HoldButton(
                icon: AssetPaths.iconReload,
                color: const Color(0xFF8A6A2A),
                onChanged: (down) {
                  if (down) game.input.requestReload();
                },
              ),
            ),
            _circle(
              center: layout.sprintCenter,
              radius: layout.sprintRadius,
              child: _HoldButton(
                icon: AssetPaths.iconSprint,
                color: const Color(0xFF3E7A46),
                onChanged: (down) => game.input.sprint = down,
              ),
            ),
            Positioned.fromRect(
              rect: layout.pauseButton,
              child: _PauseButton(onTap: game.pauseGame),
            ),
          ],
        );
      },
    );
  }

  Widget _circle({required Offset center, required double radius, required Widget child}) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      width: radius * 2,
      height: radius * 2,
      child: child,
    );
  }
}

class _HoldButton extends StatefulWidget {
  const _HoldButton({
    required this.icon,
    required this.color,
    required this.onChanged,
    this.active = false,
  });

  final String icon;
  final Color color;
  final ValueChanged<bool> onChanged;
  final bool active;

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  final Set<int> _pointers = <int>{};

  bool get _pressed => _pointers.isNotEmpty;

  void _down(PointerDownEvent e) {
    final was = _pressed;
    _pointers.add(e.pointer);
    if (!was) {
      widget.onChanged(true);
      setState(() {});
    }
  }

  void _up(int pointer) {
    if (!_pointers.remove(pointer)) return;
    if (!_pressed) {
      widget.onChanged(false);
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_pressed) {
      _pointers.clear();
      widget.onChanged(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _pressed;
    final lit = pressed || widget.active;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerUp: (e) => _up(e.pointer),
      onPointerCancel: (e) => _up(e.pointer),
      child: AnimatedScale(
        scale: pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withAlpha(lit ? 235 : 150),
                Color.lerp(widget.color, Colors.black, 0.55)!.withAlpha(lit ? 230 : 140),
              ],
              stops: const [0.15, 1.0],
            ),
            border: Border.all(
              color: lit ? const Color(0xEEFFE2B0) : const Color(0x88FFFFFF),
              width: lit ? 2.4 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: lit ? widget.color.withAlpha(150) : const Color(0x66000000),
                blurRadius: lit ? 16 : 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 0.5,
              child: Image.asset(
                widget.icon,
                fit: BoxFit.contain,
                color: lit ? Colors.white : const Color(0xDDF0E6D2),
                colorBlendMode: BlendMode.modulate,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatefulWidget {
  const _PauseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _down ? const Color(0xCC2A2E33) : const Color(0x991A1C1F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x77E0C8A0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(AssetPaths.iconPause, fit: BoxFit.contain, color: const Color(0xFFF0E6D2)),
          ),
        ),
      ),
    );
  }
}

/// Floating virtual joystick: the base appears under the thumb.
class _Joystick extends StatefulWidget {
  const _Joystick({required this.game, required this.layout});

  final AmadanGame game;
  final HudLayout layout;

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickModel extends ChangeNotifier {
  Offset? base;
  Offset knob = Offset.zero;

  void update(Offset? b, Offset k) {
    base = b;
    knob = k;
    notifyListeners();
  }
}

class _JoystickState extends State<_Joystick> {
  final _JoystickModel _model = _JoystickModel();
  int? _pointer;

  Offset get _rest => widget.layout.joystickRest - widget.layout.joystickZone.topLeft;

  @override
  void dispose() {
    widget.game.input.setMove(0, 0);
    _model.dispose();
    super.dispose();
  }

  void _start(PointerDownEvent e) {
    if (_pointer != null) return;
    _pointer = e.pointer;
    final r = widget.layout.joystickRadius;
    final zone = widget.layout.joystickZone;
    final local = e.localPosition;
    final base = Offset(
      local.dx.clamp(r, math.max(r, zone.width - r)),
      local.dy.clamp(r, math.max(r, zone.height - r)),
    );
    _model.update(base, Offset.zero);
    _apply(local);
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    _apply(e.localPosition);
  }

  void _apply(Offset local) {
    final base = _model.base;
    if (base == null) return;
    final r = widget.layout.joystickRadius;
    var d = local - base;
    final len = d.distance;
    if (len > r) d = d * (r / len);
    _model.update(base, d);
    var x = d.dx / r;
    var y = d.dy / r;
    final m = math.sqrt(x * x + y * y);
    if (m < 0.12) {
      x = 0;
      y = 0;
    }
    widget.game.input.setMove(x, y);
  }

  void _end(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    _model.update(null, Offset.zero);
    widget.game.input.setMove(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _start,
      onPointerMove: _move,
      onPointerUp: (e) => _end(e.pointer),
      onPointerCancel: (e) => _end(e.pointer),
      child: CustomPaint(
        painter: _JoystickPainter(_model, _rest, widget.layout.joystickRadius),
        size: Size.infinite,
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  _JoystickPainter(this.model, this.rest, this.radius) : super(repaint: model);

  final _JoystickModel model;
  final Offset rest;
  final double radius;

  static final Paint _base = Paint();
  static final Paint _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _knob = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final active = model.base != null;
    final c = model.base ?? rest;
    _base.color = active ? const Color(0x44000000) : const Color(0x26000000);
    canvas.drawCircle(c, radius, _base);
    _ring.color = active ? const Color(0x99F0E6D2) : const Color(0x44F0E6D2);
    canvas.drawCircle(c, radius, _ring);
    _ring.color = active ? const Color(0x44F0E6D2) : const Color(0x22F0E6D2);
    canvas.drawCircle(c, radius * 0.55, _ring);
    final k = c + model.knob;
    final kr = radius * 0.42;
    _knob.shader = RadialGradient(
      colors: active
          ? const [Color(0xFFF2E2C4), Color(0xFF9A8A70)]
          : const [Color(0x88F2E2C4), Color(0x449A8A70)],
    ).createShader(Rect.fromCircle(center: k, radius: kr));
    canvas.drawCircle(k, kr, _knob);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) =>
      oldDelegate.rest != rest || oldDelegate.radius != radius || oldDelegate.model != model;
}
