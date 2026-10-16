import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 56, this.color = GC.amber, this.foreground = GC.onAmber, this.iconAfter = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color color;
  final Color foreground;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          disabledBackgroundColor: GC.surface3,
          disabledForegroundColor: GC.faint,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM)),
          textStyle: GC.body(16, weight: FontWeight.w700, height: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && !iconAfter) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (icon != null && iconAfter) ...[const SizedBox(width: 10), Icon(icon, size: 20)],
          ],
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 52});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: GC.text,
          side: const BorderSide(color: GC.lineStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GC.radiusM)),
          textStyle: GC.body(15, weight: FontWeight.w600, height: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// Round translucent icon button used over photos and the camera.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.size = 46, this.iconColor = GC.text});

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0x8C0F0E0C),
        shape: const CircleBorder(side: BorderSide(color: Color(0x33F3EBDD))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(width: size, height: size, child: Icon(icon, size: 21, color: iconColor)),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.background = GC.amberDeep, this.foreground = GC.amberLight, this.icon});

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: foreground), const SizedBox(width: 5)],
          Text(label.toUpperCase(), style: GC.label(color: foreground, size: 11)),
        ],
      ),
    );
  }
}

class ChoiceChipX extends StatelessWidget {
  const ChoiceChipX({super.key, required this.label, required this.selected, required this.onTap, this.solid = false});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? GC.amberDeep : (solid ? GC.surface : const Color(0xEB201D17)),
      shape: StadiumBorder(side: BorderSide(color: selected ? GC.amber : GC.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          child: Text(
            label,
            style: GC.body(13, color: selected ? GC.amberLight : GC.textSoft, weight: selected ? FontWeight.w700 : FontWeight.w600, height: 1.2),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(text.toUpperCase(), style: GC.label())),
        ?trailing,
      ],
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 9, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF3D9A1), GC.amber]),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: compact ? 11 : 12, color: GC.onAmber),
          const SizedBox(width: 4),
          Text('PLUS', style: GC.label(color: GC.onAmber, size: compact ? 9.5 : 10.5)),
        ],
      ),
    );
  }
}

/// Historical photo with a subtle film treatment.
class ArchivePhoto extends StatelessWidget {
  const ArchivePhoto(this.asset, {super.key, this.fit = BoxFit.cover, this.alignment = Alignment.center});
  final String asset;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A2F1A), Color(0xFF1A1815)],
        ),
      ),
      child: Center(child: Icon(Icons.account_balance_outlined, color: Color(0x80E9B44C), size: 34)),
    );
    if (asset.isEmpty) return fallback;
    if (asset.startsWith('http')) {
      return Image.network(
        asset,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) => progress == null ? child : const ColoredBox(color: GC.surface2),
        errorBuilder: (context, error, stack) => fallback,
      );
    }
    return Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => fallback,
    );
  }
}

/// Fades a photo into the page background.
class BottomFade extends StatelessWidget {
  const BottomFade({super.key, this.color = GC.ground, this.stops = const [0.35, 1.0], this.topShade = true});
  final Color color;
  final List<double> stops;
  final bool topShade;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              topShade ? Colors.black.withValues(alpha: 0.45) : Colors.transparent,
              Colors.transparent,
              color.withValues(alpha: 0.0),
              color,
            ],
            stops: [0.0, 0.18, stops[0], stops[1]],
          ),
        ),
      ),
    );
  }
}

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
}
