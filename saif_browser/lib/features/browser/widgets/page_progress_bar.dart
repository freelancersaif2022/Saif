import 'package:flutter/material.dart';

/// Thin loading bar driven by real WebView progress events. It animates
/// between reported values and fades out when loading finishes.
class PageProgressBar extends StatelessWidget {
  const PageProgressBar({super.key, required this.progress, required this.visible, required this.color});

  final double progress;
  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: Duration(milliseconds: visible ? 80 : 350),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: visible ? progress.clamp(0.0, 1.0) : 1.0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, value, _) => Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 0.5)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
