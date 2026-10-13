import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Saif logo: accent disc with a black "S" monogram.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.45),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Text(
        'S',
        style: TextStyle(
          color: palette.onAccent,
          fontSize: size * 0.56,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
