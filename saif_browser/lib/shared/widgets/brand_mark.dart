import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Trex wordmark logo: black "Trex" lettering on an accent tile.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  /// Height of the tile; the width follows the wordmark.
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: 'Trex',
      child: Container(
        height: size,
        padding: EdgeInsets.symmetric(horizontal: size * 0.28),
        decoration: BoxDecoration(
          color: palette.accent,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withValues(alpha: 0.45),
              blurRadius: size * 0.4,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            'Trex',
            style: TextStyle(
              color: palette.onAccent,
              fontSize: size * 0.46,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -size * 0.02,
            ),
          ),
        ),
      ),
    );
  }
}
