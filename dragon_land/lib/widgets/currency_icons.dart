import 'package:flutter/material.dart';

import '../art/prop_art.dart';

class _PropPainter extends CustomPainter {
  _PropPainter(this.kind);
  final int kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 * 0.9;
    switch (kind) {
      case 0:
        PropArt.coin(canvas, 0, r: r);
      case 1:
        PropArt.gem(canvas, 0.25, r: r);
      default:
        PropArt.heart(canvas, 0, r: r * 0.95);
    }
  }

  @override
  bool shouldRepaint(_PropPainter old) => old.kind != kind;
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 24});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _PropPainter(0)),
  );
}

class GemIcon extends StatelessWidget {
  const GemIcon({super.key, this.size = 24});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _PropPainter(1)),
  );
}

class HeartIcon extends StatelessWidget {
  const HeartIcon({super.key, this.size = 24});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _PropPainter(2)),
  );
}
