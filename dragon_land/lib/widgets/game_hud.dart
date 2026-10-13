import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../game/run_state.dart';
import 'coin_counter.dart';
import 'currency_icons.dart';
import 'flight_energy_bar.dart';
import 'health_bar.dart';
import 'stamina_bar.dart';

/// In-run heads-up display: health, meters, distance, score, run coins,
/// buffs, boss health and announcement banners.
class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.hud, required this.onPause, required this.leftHanded});

  final HudState hud;
  final VoidCallback onPause;
  final bool leftHanded;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: hud,
      builder: (context, _) {
        return Stack(
          children: [
            // health + meters
            Positioned(
              left: 14,
              top: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HealthBar(health: hud.health, maxHealth: hud.maxHealth, damageEvents: hud.damageEvents),
                  const SizedBox(height: 6),
                  StaminaBar(value: hud.stamina01, sprinting: hud.sprinting),
                  const SizedBox(height: 4),
                  FlightEnergyBar(value: hud.energy01, flying: hud.flying),
                  if (hud.shieldActive) ...[
                    const SizedBox(height: 4),
                    _Chip(
                      icon: Icons.shield_rounded,
                      text: hud.shieldHits > 0 ? 'SHIELD x${hud.shieldHits}' : 'SHIELD',
                      color: const Color(0xFF38B6FF),
                    ),
                  ],
                ],
              ),
            ),
            // distance / score / boss
            Positioned(
              left: 0,
              right: 0,
              top: 6,
              child: Column(
                children: [
                  Text('${formatNumber(hud.distance)} m', style: AppText.title(30)),
                  Text('SCORE ${formatNumber(hud.score)}', style: AppText.label(15, weight: FontWeight.w700)),
                  if (hud.bossHealth01 != null) ...[
                    const SizedBox(height: 4),
                    _BossBar(name: hud.bossName ?? '', value: hud.bossHealth01!),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hud.magnetLeft > 0)
                        _Chip(icon: Icons.all_inclusive_rounded, text: 'MAGNET ${hud.magnetLeft.ceil()}s', color: AppColors.red),
                      if (hud.magnetLeft > 0 && hud.doubleCoinsLeft > 0) const SizedBox(width: 6),
                      if (hud.doubleCoinsLeft > 0)
                        _Chip(
                          icon: Icons.exposure_plus_2_rounded,
                          text: 'x2 COINS ${hud.doubleCoinsLeft.ceil()}s',
                          color: AppColors.goldDark,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // run currency + pause
            Positioned(
              right: 12,
              top: 8,
              child: Row(
                children: [
                  _RunCounter(icon: const CoinIcon(size: 26), value: hud.coins),
                  const SizedBox(width: 8),
                  _RunCounter(icon: const GemIcon(size: 24), value: hud.gems),
                  const SizedBox(width: 10),
                  _PauseButton(onPressed: onPause),
                ],
              ),
            ),
            // announcement banner
            if (hud.banner != null)
              Positioned(
                left: 0,
                right: 0,
                top: 120,
                child: IgnorePointer(
                  child: _Banner(key: ValueKey(hud.bannerId), text: hud.banner!),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RunCounter extends StatelessWidget {
  const _RunCounter({required this.icon, required this.value});
  final Widget icon;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(4, 2, 10, 2),
    decoration: BoxDecoration(color: const Color(0xAA2A1636), borderRadius: BorderRadius.circular(18)),
    child: Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(formatNumber(value), style: AppText.title(20)),
      ],
    ),
  );
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Pause',
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.skyDeep,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 3))],
        ),
        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 28),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(text, style: AppText.label(12, weight: FontWeight.w700)),
      ],
    ),
  );
}

class _BossBar extends StatelessWidget {
  const _BossBar({required this.name, required this.value});
  final String name;
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Column(
      children: [
        Text(name, style: AppText.title(16, color: const Color(0xFFFFD6F7))),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xAA2A1636),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 200),
                widthFactor: value.clamp(0.0, 1.0),
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF5CE1), Color(0xFF8A4FE0)])),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      builder: (context, t, child) {
        final inT = (t / 0.15).clamp(0.0, 1.0);
        final outT = ((t - 0.75) / 0.25).clamp(0.0, 1.0);
        return Opacity(
          opacity: (inT * (1 - outT)).clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.6 + 0.4 * Curves.easeOutBack.transform(inT), child: child),
        );
      },
      child: Center(
        child: Text(
          text,
          style: AppText.title(34, color: const Color(0xFFFFE14D)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
