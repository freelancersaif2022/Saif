import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../audio.dart';
import 'theme.dart';

/// Provides a continuously increasing time value (seconds) without rebuilding.
mixin SceneClock<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  final ValueNotifier<double> clock = ValueNotifier<double>(0);
  Ticker? _ticker;

  void onClockTick(double t) {}

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      clock.value = t;
      onClockTick(t);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    clock.dispose();
    super.dispose();
  }
}

/// Angled cinematic button with glow, press animation and click sound.
class CinematicButton extends StatefulWidget {
  const CinematicButton({
    super.key,
    required this.label,
    required this.onTap,
    this.sub,
    this.width = 260,
    this.height = 58,
    this.accent = UiColors.accent,
    this.icon,
    this.primary = false,
    this.sound = Sfx.uiClick,
  });

  final String label;
  final String? sub;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Color accent;
  final IconData? icon;
  final bool primary;
  final String? sound;

  @override
  State<CinematicButton> createState() => _CinematicButtonState();
}

class _CinematicButtonState extends State<CinematicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  bool _down = false;

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  void _tap() {
    final s = widget.sound;
    if (s != null) GameAudio.instance.play(s, volume: 0.8);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        _tap();
      },
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: RepaintBoundary(
          child: AnimatedBuilder(
          animation: _glow,
          builder: (context, child) => CustomPaint(
            painter: _ButtonPainter(widget.accent, _glow.value, widget.primary, _down),
            child: child,
          ),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.height * 0.45),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.accent, size: widget.height * 0.42),
                    SizedBox(width: widget.height * 0.22),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(widget.label, style: UiText.heading(widget.height * 0.34)),
                        ),
                        if (widget.sub != null)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(widget.sub!, style: UiText.body(widget.height * 0.24, color: widget.accent)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _ButtonPainter extends CustomPainter {
  _ButtonPainter(this.accent, this.t, this.primary, this.down);
  final Color accent;
  final double t;
  final bool primary;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cut = h * 0.32;
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(w, 0)
      ..lineTo(w - cut, h)
      ..lineTo(0, h)
      ..close();
    final fill = Paint()
      ..shader = LinearGradient(
        colors: [
          accent.withAlpha(primary ? 90 : 50),
          const Color(0xEE0A0D14),
          const Color(0xCC05060A),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = accent.withAlpha((90 + 120 * pulse * (primary ? 1 : 0.6)).round().clamp(0, 255));
    canvas.drawPath(path, border);
    // Soft glow under the border (wide translucent stroke, no blur filter).
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = accent.withAlpha(((primary ? 40 : 18) + (down ? 50 : 0) + 18 * pulse).round().clamp(0, 255));
    canvas.drawPath(path, glow);
    // Moving sheen.
    final sx = -w * 0.3 + (w * 1.6) * t;
    final sheen = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withAlpha(0), Colors.white.withAlpha(primary ? 34 : 18), Colors.white.withAlpha(0)],
      ).createShader(Rect.fromLTWH(sx - 60, 0, 120, h));
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(Rect.fromLTWH(sx - 60, 0, 120, h), sheen);
    canvas.restore();
    // Accent tick on the left edge.
    final tick = Paint()..color = accent;
    canvas.drawPath(
      Path()
        ..moveTo(cut + 2, 3)
        ..lineTo(cut + 10, 3)
        ..lineTo(10 - 2, h - 3)
        ..lineTo(0 + 2, h - 3)
        ..close(),
      tick..color = accent.withAlpha(primary ? 230 : 150),
    );
  }

  @override
  bool shouldRepaint(_ButtonPainter old) => old.t != t || old.down != down || old.accent != accent;
}

/// Small round icon button used in overlays (pause etc).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, this.size = 48, this.color = UiColors.accent});
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xAA05070C),
          border: Border.all(color: color.withAlpha(170), width: 1.5),
          boxShadow: [BoxShadow(color: color.withAlpha(60), blurRadius: 12)],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

/// Dark glass panel used for menus and popups.
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.accent = UiColors.accent, this.padding = const EdgeInsets.all(28)});
  final Widget child;
  final Color accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF00C0F17), Color(0xF005060A)],
        ),
        border: Border.all(color: accent.withAlpha(110), width: 1.4),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: accent.withAlpha(45), blurRadius: 30, spreadRadius: 2),
          const BoxShadow(color: Colors.black87, blurRadius: 40),
        ],
      ),
      child: child,
    );
  }
}

/// Sword icon for the attack button.
class SwordIconPainter extends CustomPainter {
  SwordIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.rotate(-math.pi / 4);
    final blade = Path()
      ..moveTo(-s * 0.05, -s * 0.06)
      ..lineTo(s * 0.05, -s * 0.06)
      ..lineTo(s * 0.04, -s * 0.38)
      ..lineTo(0, -s * 0.46)
      ..lineTo(-s * 0.04, -s * 0.38)
      ..close();
    canvas.drawPath(blade, Paint()..color = color);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -s * 0.02), width: s * 0.3, height: s * 0.06), Radius.circular(s * 0.03)), Paint()..color = color);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-s * 0.035, 0, s * 0.07, s * 0.26), Radius.circular(s * 0.02)), Paint()..color = color.withAlpha(200));
    canvas.drawCircle(Offset(0, s * 0.3), s * 0.045, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SwordIconPainter old) => old.color != color;
}

/// Running figure icon for the sprint button.
class SprintIconPainter extends CustomPainter {
  SprintIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(Offset(s * 0.62, s * 0.16), s * 0.09, Paint()..color = color);
    final body = Path()
      ..moveTo(s * 0.56, s * 0.3)
      ..lineTo(s * 0.44, s * 0.56)
      ..lineTo(s * 0.62, s * 0.7)
      ..lineTo(s * 0.56, s * 0.92)
      ..moveTo(s * 0.44, s * 0.56)
      ..lineTo(s * 0.3, s * 0.74)
      ..lineTo(s * 0.12, s * 0.74)
      ..moveTo(s * 0.52, s * 0.36)
      ..lineTo(s * 0.72, s * 0.48)
      ..lineTo(s * 0.86, s * 0.4)
      ..moveTo(s * 0.52, s * 0.36)
      ..lineTo(s * 0.34, s * 0.4)
      ..lineTo(s * 0.24, s * 0.52);
    canvas.drawPath(body, p);
    final lines = Paint()
      ..color = color.withAlpha(140)
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.0, s * 0.42), Offset(s * 0.14, s * 0.42), lines);
    canvas.drawLine(Offset(s * 0.02, s * 0.56), Offset(s * 0.16, s * 0.56), lines);
  }

  @override
  bool shouldRepaint(SprintIconPainter old) => old.color != color;
}

/// Heart icon row drawn with Material icons.
class HeartsRow extends StatelessWidget {
  const HeartsRow({super.key, required this.hearts, this.total = 3, this.size = 26});
  final int hearts;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final full = i < hearts;
        return Padding(
          padding: EdgeInsets.only(right: size * 0.18),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              Icons.favorite,
              key: ValueKey(full),
              size: size,
              color: full ? const Color(0xFFE8203A) : const Color(0xFF1A1C22),
              shadows: full
                  ? const [Shadow(color: Color(0xAAFF2040), blurRadius: 10)]
                  : const [Shadow(color: Color(0xFF000000), blurRadius: 3)],
            ),
          ),
        );
      }),
    );
  }
}
