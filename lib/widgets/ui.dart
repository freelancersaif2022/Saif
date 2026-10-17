import 'package:flutter/material.dart';

import '../models/element.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Full-screen gradient background with subtle star dust.
class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child, this.tint});
  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: _DustPainter())),
          ),
          if (tint != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(center: const Alignment(0, -0.5), radius: 1.0, colors: [tint!.withValues(alpha: 0.28), Colors.transparent]),
                ),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  const _DustPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    var seed = 12345;
    double rnd() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    for (var i = 0; i < 70; i++) {
      final o = Offset(rnd() * size.width, rnd() * size.height);
      final r = rnd() * 1.4 + 0.3;
      p.color = Colors.white.withValues(alpha: rnd() * 0.22 + 0.04);
      canvas.drawCircle(o, r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shrinks slightly while pressed. Wraps anything tappable.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.95, this.sound = true});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool sound;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: enabled
          ? () {
              if (widget.sound) Sfx.tap();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(scale: _down ? widget.scale : 1, duration: const Duration(milliseconds: 90), curve: Curves.easeOut, child: widget.child),
    );
  }
}

/// Chunky 3D game button.
class GameButton extends StatelessWidget {
  const GameButton({super.key, required this.label, this.onTap, this.icon, this.color = AppColors.primary, this.expand = false, this.small = false, this.trailing, this.loading = false});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final bool expand;
  final bool small;
  final Widget? trailing;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || loading;
    final c = disabled ? const Color(0xFF4A4468) : color;
    final hsl = HSLColor.fromColor(c);
    final light = hsl.withLightness((hsl.lightness + 0.1).clamp(0, 1)).toColor();
    final dark = hsl.withLightness((hsl.lightness - 0.18).clamp(0, 1)).toColor();
    final h = small ? 42.0 : 54.0;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white))
        else ...[
          if (icon != null) ...[Icon(icon, color: Colors.white, size: small ? 18 : 22), const SizedBox(width: 8)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (small ? AppText.h3 : AppText.h2).copyWith(
                color: Colors.white,
                shadows: [Shadow(color: dark.withValues(alpha: 0.8), offset: const Offset(0, 2), blurRadius: 0)],
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ],
    );
    return Pressable(
      onTap: disabled ? null : onTap,
      child: Container(
        height: h,
        padding: EdgeInsets.symmetric(horizontal: small ? 16 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(small ? 14 : 18),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [light, c]),
          boxShadow: [
            BoxShadow(color: dark, offset: const Offset(0, 4)),
            if (!disabled) BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: content,
      ),
    );
  }
}

/// Rounded dark panel.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.borderColor, this.gradient, this.radius = 22});
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Gradient? gradient;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: gradient == null ? AppColors.surface.withValues(alpha: 0.92) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.stroke),
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 6))],
    ),
    child: child,
  );
}

enum Currency { coins, gems, stones, energy }

class CurrencyIcon extends StatelessWidget {
  const CurrencyIcon(this.type, {super.key, this.size = 20});
  final Currency type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      Currency.coins => (Icons.monetization_on_rounded, AppColors.gold),
      Currency.gems => (Icons.diamond_rounded, AppColors.gem),
      Currency.stones => (Icons.auto_awesome_rounded, const Color(0xFFFF7BE5)),
      Currency.energy => (Icons.bolt_rounded, AppColors.energy),
    };
    return Icon(
      icon,
      color: color,
      size: size,
      shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 8)],
    );
  }
}

class CurrencyChip extends StatelessWidget {
  const CurrencyChip({super.key, required this.type, required this.value, this.onTap});
  final Currency type;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyIcon(type, size: 18),
          const SizedBox(width: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(value, key: ValueKey(value), style: AppText.number),
          ),
          if (onTap != null) ...[const SizedBox(width: 4), const Icon(Icons.add_circle_rounded, size: 15, color: AppColors.success)],
        ],
      ),
    ),
  );
}

class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.label, required this.value, required this.max, required this.color, this.icon});
  final String label;
  final int value;
  final int max;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 6)],
        SizedBox(
          width: 34,
          child: Text(
            label,
            style: AppText.small.copyWith(color: AppColors.text, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(6)),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (value / max).clamp(0.02, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 38,
          child: Text('$value', textAlign: TextAlign.right, style: AppText.number),
        ),
      ],
    );
  }
}

class ElementBadge extends StatelessWidget {
  const ElementBadge(this.element, {super.key, this.compact = false});
  final BeastElement element;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: compact ? 3 : 5),
    decoration: BoxDecoration(
      color: element.color.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: element.color.withValues(alpha: 0.6)),
    ),
    child: Text(
      compact ? element.emoji : '${element.emoji} ${element.label}',
      style: AppText.small.copyWith(color: element.color, fontWeight: FontWeight.w900),
    ),
  );
}

class RarityTag extends StatelessWidget {
  const RarityTag(this.rarity, {super.key});
  final Rarity rarity;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [rarity.color, HSLColor.fromColor(rarity.color).withLightness(0.35).toColor()]),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      rarity.label.toUpperCase(),
      style: AppText.small.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 10.5),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(text.toUpperCase(), style: AppText.h3.copyWith(color: AppColors.textDim, letterSpacing: 1.2)),
        ),
        ?trailing,
      ],
    ),
  );
}

String formatDuration(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
