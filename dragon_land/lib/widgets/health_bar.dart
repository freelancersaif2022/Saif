import 'package:flutter/material.dart';

import 'currency_icons.dart';

/// Row of hearts; lost hearts are shown faded. Shakes when damage happens.
class HealthBar extends StatelessWidget {
  const HealthBar({super.key, required this.health, required this.maxHealth, required this.damageEvents, this.size = 34});

  final int health;
  final int maxHealth;
  final int damageEvents;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(damageEvents),
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 400),
      builder: (context, v, child) => Transform.translate(offset: Offset(((v * 30).round() % 2 == 0 ? 1 : -1) * 5 * v, 0), child: child),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < maxHealth; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: i < health ? 1 : 0.25,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: i < health ? 1 : 0.8,
                  child: HeartIcon(size: size),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
