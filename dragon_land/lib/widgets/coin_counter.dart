import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import 'currency_icons.dart';

String formatNumber(int v) {
  final s = v.abs().toString();
  final b = StringBuffer(v < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// Pill showing a currency amount that animates when it changes.
class CurrencyPill extends StatelessWidget {
  const CurrencyPill({super.key, required this.amount, this.gem = false, this.onAdd, this.height = 40});

  final int amount;
  final bool gem;
  final VoidCallback? onAdd;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        color: const Color(0xCC2A1636),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          gem ? GemIcon(size: height - 8) : CoinIcon(size: height - 8),
          const SizedBox(width: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: amount.toDouble(), end: amount.toDouble()),
            duration: const Duration(milliseconds: 500),
            builder: (context, v, _) => Text(formatNumber(v.round()), style: AppText.title(height * 0.48)),
          ),
          const SizedBox(width: 6),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: height - 10,
                height: height - 10,
                decoration: BoxDecoration(
                  color: AppColors.grass,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.add, color: Colors.white, size: height * 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
