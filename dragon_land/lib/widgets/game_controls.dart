import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../game/input_state.dart';
import '../game/run_state.dart';
import '../models/dragon_model.dart';

/// Thumb-friendly on-screen controls. Every button handles its own pointer,
/// so several can be pressed at once (e.g. hold RIGHT while tapping JUMP).
class GameControls extends StatelessWidget {
  const GameControls({super.key, required this.input, required this.hud, required this.dragon, required this.leftHanded});

  final InputState input;
  final HudState hud;
  final DragonDef dragon;
  final bool leftHanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final u = math.min(box.maxHeight / 360, box.maxWidth / 700).clamp(0.8, 1.6);
        final move = _MoveCluster(input: input, u: u);
        final actions = ListenableBuilder(
          listenable: hud,
          builder: (context, _) => _ActionCluster(input: input, hud: hud, dragon: dragon, u: u, mirrored: leftHanded),
        );
        return Stack(
          children: [
            Positioned(left: leftHanded ? null : 18 * u, right: leftHanded ? 18 * u : null, bottom: 16 * u, child: move),
            Positioned(right: leftHanded ? null : 14 * u, left: leftHanded ? 14 * u : null, bottom: 10 * u, child: actions),
          ],
        );
      },
    );
  }
}

class _MoveCluster extends StatelessWidget {
  const _MoveCluster({required this.input, required this.u});
  final InputState input;
  final double u;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HoldButton(
          size: 78 * u,
          icon: Icons.arrow_back_rounded,
          color: const Color(0xFF5B8DEF),
          onChanged: (v) => input.left = v,
          label: 'LEFT',
        ),
        SizedBox(width: 16 * u),
        HoldButton(
          size: 78 * u,
          icon: Icons.arrow_forward_rounded,
          color: const Color(0xFF5B8DEF),
          onChanged: (v) => input.right = v,
          label: 'RIGHT',
        ),
      ],
    );
  }
}

class _ActionCluster extends StatelessWidget {
  const _ActionCluster({required this.input, required this.hud, required this.dragon, required this.u, required this.mirrored});
  final InputState input;
  final HudState hud;
  final DragonDef dragon;
  final double u;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final w = 300 * u, h = 230 * u;
    double x(double v) => mirrored ? w - v : v;
    Widget place(double cx, double cy, double size, Widget child) =>
        Positioned(left: x(cx) - size / 2, top: cy - size / 2, width: size, height: size, child: child);
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          place(
            w - 62 * u,
            h - 62 * u,
            112 * u,
            TapButton(icon: Icons.keyboard_double_arrow_up_rounded, label: 'JUMP', color: AppColors.grass, onTap: input.pressJump),
          ),
          place(
            w - 175 * u,
            h - 48 * u,
            86 * u,
            TapButton(
              icon: Icons.local_fire_department_rounded,
              label: 'ATTACK',
              color: AppColors.red,
              ready: hud.attackReady01,
              onTap: input.pressAttack,
            ),
          ),
          place(
            w - 62 * u,
            h - 170 * u,
            82 * u,
            TapButton(
              icon: Icons.flight_rounded,
              label: hud.flying ? 'LAND' : 'FLY',
              color: const Color(0xFF38B6FF),
              ready: hud.flying ? 1 : hud.energy01,
              active: hud.flying,
              enabled: hud.flying || hud.energy01 >= 0.3,
              onTap: input.pressFly,
            ),
          ),
          place(
            w - 170 * u,
            h - 150 * u,
            74 * u,
            TapButton(
              icon: Icons.bolt_rounded,
              label: 'SPRINT',
              color: const Color(0xFFFFB020),
              ready: hud.sprinting ? 1 : hud.stamina01,
              active: hud.sprinting,
              enabled: hud.sprinting || hud.stamina01 >= 0.15,
              onTap: input.pressSprint,
            ),
          ),
          place(
            w - 262 * u,
            h - 104 * u,
            76 * u,
            TapButton(
              icon: Icons.auto_awesome_rounded,
              label: 'SPECIAL',
              color: dragon.bodyDark,
              ready: hud.specialReady01,
              onTap: input.pressSpecial,
            ),
          ),
        ],
      ),
    );
  }
}

/// Button held down for continuous input.
class HoldButton extends StatefulWidget {
  const HoldButton({super.key, required this.size, required this.icon, required this.color, required this.onChanged, required this.label});
  final double size;
  final IconData icon;
  final Color color;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> {
  int _pointers = 0;

  void _set(int delta) {
    final was = _pointers > 0;
    _pointers = math.max(0, _pointers + delta);
    final now = _pointers > 0;
    if (was != now) {
      widget.onChanged(now);
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_pointers > 0) widget.onChanged(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: Listener(
        onPointerDown: (_) => _set(1),
        onPointerUp: (_) => _set(-1),
        onPointerCancel: (_) => _set(-1),
        child: _Disc(size: widget.size, color: widget.color, icon: widget.icon, pressed: _pointers > 0),
      ),
    );
  }
}

/// Button that fires on touch-down. Shows a cooldown ring when [ready] < 1.
class TapButton extends StatefulWidget {
  const TapButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.ready = 1,
    this.active = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double ready;
  final bool active;
  final bool enabled;

  @override
  State<TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<TapButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final usable = widget.enabled && widget.ready >= 0.999;
    return Semantics(
      button: true,
      label: widget.label,
      child: Listener(
        onPointerDown: (_) {
          setState(() => _down = true);
          widget.onTap();
        },
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: LayoutBuilder(
          builder: (context, box) {
            final size = box.maxWidth;
            return Stack(
              alignment: Alignment.center,
              children: [
                _Disc(
                  size: size,
                  color: usable || widget.active ? widget.color : Color.lerp(widget.color, const Color(0xFF6E6E80), 0.6)!,
                  icon: widget.icon,
                  pressed: _down,
                  glow: widget.active,
                  label: widget.label,
                ),
                if (widget.ready < 0.999)
                  IgnorePointer(
                    child: SizedBox.square(
                      dimension: size,
                      child: CustomPaint(painter: _CooldownPainter(widget.ready)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.size, required this.color, required this.icon, required this.pressed, this.glow = false, this.label});
  final double size;
  final Color color;
  final IconData icon;
  final bool pressed;
  final bool glow;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 70),
      scale: pressed ? 0.9 : 1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [Color.lerp(color, Colors.white, 0.45)!.withValues(alpha: 0.8), color.withValues(alpha: 0.72)],
          ),
          border: Border.all(color: glow ? Colors.white : const Color(0xCC2A1636), width: glow ? 4 : 3),
          boxShadow: [
            BoxShadow(
              color: glow ? color.withValues(alpha: 0.8) : const Color(0x55000000),
              blurRadius: glow ? 18 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: size * (label == null ? 0.5 : 0.42),
              shadows: const [Shadow(color: Color(0x992A1636), offset: Offset(0, 2))],
            ),
            if (label != null) Text(label!, style: AppText.title(math.max(9, size * 0.14))),
          ],
        ),
      ),
    );
  }
}

class _CooldownPainter extends CustomPainter {
  _CooldownPainter(this.ready);
  final double ready;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 2),
      -math.pi / 2 + ready * math.pi * 2,
      (1 - ready) * math.pi * 2,
      true,
      Paint()..color = const Color(0x882A1636),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 3),
      -math.pi / 2,
      ready * math.pi * 2,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CooldownPainter old) => old.ready != ready;
}
