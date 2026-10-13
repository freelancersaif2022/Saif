import 'package:flutter/material.dart';

import '../app/app_theme.dart';

/// Rounded gauge with an icon, used for stamina and flight energy.
class MeterBar extends StatelessWidget {
  const MeterBar({
    super.key,
    required this.value,
    required this.color,
    required this.icon,
    this.width = 150,
    this.active = false,
    this.label,
  });

  final double value;
  final Color color;
  final IconData icon;
  final double width;
  final bool active;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return SizedBox(
      width: width,
      height: 24,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0x992A1636),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active ? Colors.white : const Color(0xCC2A1636), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: v,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color.lerp(color, Colors.white, 0.4)!, color],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
