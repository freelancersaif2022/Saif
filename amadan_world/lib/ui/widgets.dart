import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../utils/asset_paths.dart';
import 'ui_theme.dart';

/// Bevelled military style button with press feedback and a click sound.
class MilitaryButton extends StatefulWidget {
  const MilitaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.height = 48,
    this.width,
    this.fontSize = 16,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final double height;
  final double? width;
  final double fontSize;
  final IconData? icon;

  @override
  State<MilitaryButton> createState() => _MilitaryButtonState();
}

class _MilitaryButtonState extends State<MilitaryButton> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primary;
    final colors = primary
        ? (_pressed
            ? const [Color(0xFFF2A048), Color(0xFFB0602A)]
            : const [UiColors.accent, UiColors.accentDark])
        : (_pressed
            ? const [Color(0xFF4A5058), Color(0xFF24282C)]
            : const [Color(0xFF363B42), Color(0xFF1A1D21)]);
    final cut = widget.height * 0.28;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: () {
        AudioManager.instance.play(Sfx.uiClick, volume: 0.7, minGapMs: 0);
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Container(
          height: widget.height,
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: widget.height * 0.5),
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cut),
                bottomRight: Radius.circular(cut),
              ),
              side: BorderSide(
                color: primary ? const Color(0xAAFFD6A0) : const Color(0x66E0C8A0),
                width: 1.2,
              ),
            ),
            shadows: const [
              BoxShadow(color: Color(0x88000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: UiColors.text, size: widget.fontSize * 1.2),
                SizedBox(width: widget.fontSize * 0.5),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      color: primary ? const Color(0xFF1A0E06) : UiColors.text,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: widget.fontSize * 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Translucent dark panel with a thin warm edge.
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xCC1B1E22), Color(0xB30C0D0F)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: UiColors.panelEdge, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}

/// Labelled horizontal stat bar.
class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.label, required this.value, required this.fontSize});

  final String label;
  final double value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: fontSize * 0.28),
      child: Row(
        children: [
          SizedBox(
            width: fontSize * 8.4,
            child: Text(label.toUpperCase(), style: UiText.label(fontSize)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  children: [
                    Container(height: fontSize * 0.6, color: const Color(0x33FFFFFF)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      height: fontSize * 0.6,
                      width: c.maxWidth * value.clamp(0.0, 1.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [UiColors.accentSoft, UiColors.accent]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
