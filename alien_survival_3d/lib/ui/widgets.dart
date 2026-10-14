import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../audio/menu_audio.dart';
import '../progression/game_state.dart';

/// Lime action button as on the reference sheet (black text on #D1FE17), or an
/// outlined dark variant for secondary actions.
class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.icon,
    this.width,
    this.height = 46,
    this.fontSize = 15,
    this.sound = 'ui_click',
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
  final double? width;
  final double height;
  final double fontSize;
  final String sound;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final fg = widget.primary ? Colors.black : (enabled ? AppColors.text : AppColors.textDim);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                MenuAudio.instance.click(widget.sound);
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.95 : 1,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.primary ? (enabled ? AppColors.lime : AppColors.limeDim) : const Color(0xE6101410),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.primary ? AppColors.lime : (enabled ? const Color(0xFF6B7466) : const Color(0xFF333A30)), width: 1.6),
              boxShadow: widget.primary && enabled ? const [BoxShadow(color: Color(0x66D1FE17), blurRadius: 16)] : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: widget.fontSize + 4), const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w900, letterSpacing: 1.4, fontSize: widget.fontSize),
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

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.highlight = false});

  final Widget child;
  final EdgeInsets padding;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? AppColors.lime : AppColors.panelBorder, width: highlight ? 2 : 1),
      ),
      child: child,
    );
  }
}

class CurrencyBar extends StatelessWidget {
  const CurrencyBar({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => Panel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.monetization_on, color: AppColors.gold, size: 20),
          const SizedBox(width: 6),
          Text('${state.save.coins}', style: label.copyWith(fontSize: 16), key: const Key('coins')),
          const SizedBox(width: 16),
          const Icon(Icons.diamond, color: AppColors.gem, size: 20),
          const SizedBox(width: 6),
          Text('${state.save.gems}', style: label.copyWith(fontSize: 16), key: const Key('gems')),
        ]),
      ),
    );
  }
}

/// Full-screen backdrop: the in-engine forest render, darkened.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.child, this.dim = 0.55});

  final Widget child;
  final double dim;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Image.asset('assets/images/menu_bg.jpg', fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.black)),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.black.withValues(alpha: dim * 0.6), Colors.black.withValues(alpha: dim + 0.2)],
          ),
        ),
      ),
      child,
    ]);
  }
}

/// Standard sub-screen layout: back button, title, currency and content.
class SubScreen extends StatelessWidget {
  const SubScreen({super.key, required this.title, required this.child, this.state, this.actions = const []});

  final String title;
  final Widget child;
  final GameState? state;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Backdrop(
        dim: 0.7,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(children: [
              Row(children: [
                NeonButton(label: 'BACK', icon: Icons.arrow_back, height: 38, fontSize: 13, onPressed: () => Navigator.of(context).maybePop()),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: headline.copyWith(fontSize: 24, color: AppColors.lime), overflow: TextOverflow.ellipsis)),
                ...actions,
                if (state != null) CurrencyBar(state: state!),
              ]),
              const SizedBox(height: 10),
              Expanded(child: child),
            ]),
          ),
        ),
      ),
    );
  }
}

class LevelPips extends StatelessWidget {
  const LevelPips({super.key, required this.level, required this.max});

  final int level;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < max; i++)
        Container(
          width: 16,
          height: 8,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(color: i < level ? AppColors.lime : const Color(0xFF2A3226), borderRadius: BorderRadius.circular(2)),
        ),
    ]);
  }
}

class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.name, required this.value, required this.display});

  final String name;

  /// 0..1
  final double value;
  final String display;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 74, child: Text(name, style: dim)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 6, color: AppColors.lime, backgroundColor: const Color(0xFF2A3226)),
          ),
        ),
        SizedBox(width: 56, child: Text(display, textAlign: TextAlign.right, style: label.copyWith(fontSize: 12))),
      ]),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
      backgroundColor: AppColors.lime,
      duration: const Duration(milliseconds: 1600),
      behavior: SnackBarBehavior.floating,
      width: 360,
    ));
}

String purchaseMessage(PurchaseResult r) => switch (r) {
      PurchaseResult.ok => 'Purchased!',
      PurchaseResult.notEnoughCoins => 'Not enough coins',
      PurchaseResult.notEnoughGems => 'Not enough gems',
      PurchaseResult.maxed => 'Already at max level',
      PurchaseResult.alreadyOwned => 'Already owned',
      PurchaseResult.locked => 'Buy this weapon in the shop first',
    };

String formatDuration(int seconds) {
  final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60, s = seconds % 60;
  if (h > 0) return '${h}h ${m}m';
  return '$m:${s.toString().padLeft(2, '0')}';
}
