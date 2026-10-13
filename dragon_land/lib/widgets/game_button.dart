import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../services/audio_service.dart';

/// Glossy cartoon button with press animation, tap sound and double-tap
/// protection (ignores taps within [cooldown] of the previous one).
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.orange,
    this.colorDark,
    this.width,
    this.height = 56,
    this.fontSize = 22,
    this.cooldown = const Duration(milliseconds: 450),
    this.leading,
    this.pulse = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final Color color;
  final Color? colorDark;
  final double? width;
  final double height;
  final double fontSize;
  final Duration cooldown;
  final bool pulse;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with SingleTickerProviderStateMixin {
  bool _down = false;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(GameButton old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_pulse.isAnimating) _pulse.repeat(reverse: true);
    if (!widget.pulse && _pulse.isAnimating) _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    final now = DateTime.now();
    if (now.difference(_last) < widget.cooldown) return;
    _last = now;
    try {
      AppScope.of(context).audio.play(Sfx.button);
    } catch (_) {}
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final base = enabled ? widget.color : const Color(0xFF9E9EAE);
    final dark = enabled ? (widget.colorDark ?? Color.lerp(base, Colors.black, 0.35)!) : const Color(0xFF6E6E80);
    final light = Color.lerp(base, Colors.white, 0.35)!;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final s = widget.pulse ? 1 + _pulse.value * 0.05 : 1.0;
        return Transform.scale(scale: s * (_down ? 0.94 : 1.0), child: child);
      },
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                _tap();
              }
            : null,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: dark,
            borderRadius: BorderRadius.circular(widget.height * 0.36),
            border: Border.all(color: AppColors.ink, width: 2.5),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 4))],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height * 0.34),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [light, base]),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  right: 10,
                  top: 4,
                  height: widget.height * 0.28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(widget.height),
                    ),
                  ),
                ),
                if (widget.label.isEmpty && widget.icon != null)
                  Center(
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: widget.height * 0.55,
                      shadows: const [Shadow(color: Color(0x882A1636), offset: Offset(0, 2))],
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: Colors.white,
                                size: widget.fontSize * 1.15,
                                shadows: const [Shadow(color: Color(0x882A1636), offset: Offset(0, 2))],
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(widget.label, style: AppText.title(widget.fontSize)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round icon button used in top bars.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.skyDeep,
    this.size = 46,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GameButton(label: '', icon: icon, onPressed: onPressed, color: color, width: size, height: size, fontSize: size * 0.42),
        if (badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(badge!, style: AppText.label(11, weight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}
