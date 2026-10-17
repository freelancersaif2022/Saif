import 'dart:math';

import 'package:flutter/painting.dart';

import '../models/element.dart';

/// Visual DNA. Fully derived from (seed, element, stage) so a short
/// challenge code is enough to redraw any monster on any phone.
class Genome {
  Genome._({
    required this.element,
    required this.stage,
    required this.bodyWidth,
    required this.bodyHeight,
    required this.lobes,
    required this.lobeDepth,
    required this.lobePhase,
    required this.eyeCount,
    required this.eyeSize,
    required this.hornType,
    required this.hornLength,
    required this.spikes,
    required this.fangs,
    required this.mouthWidth,
    required this.armSize,
    required this.pattern,
    required this.tailLength,
    required this.skin,
    required this.skinDark,
    required this.belly,
    required this.accent,
    required this.eyeGlow,
    required this.ears,
  });

  final BeastElement element;
  final int stage;
  final double bodyWidth; // 0.8..1.15
  final double bodyHeight; // 0.8..1.15
  final int lobes;
  final double lobeDepth;
  final double lobePhase;
  final int eyeCount; // 1..4
  final double eyeSize;
  final int hornType; // 0 none, 1 curved, 2 straight, 3 antlers
  final double hornLength;
  final int spikes;
  final int fangs;
  final double mouthWidth;
  final double armSize;
  final int pattern; // 0 none, 1 spots, 2 stripes, 3 scales
  final double tailLength;
  final Color skin;
  final Color skinDark;
  final Color belly;
  final Color accent;
  final Color eyeGlow;
  final bool ears;

  static final Map<int, Genome> _cache = {};

  factory Genome.from(int seed, BeastElement element, int stage) {
    final key = seed * 31 + element.index * 7 + stage;
    return _cache.putIfAbsent(key, () => Genome._build(seed, element, stage));
  }

  factory Genome._build(int seed, BeastElement element, int stage) {
    final r = Random(seed);
    double rr(double a, double b) => a + r.nextDouble() * (b - a);

    final hsl = HSLColor.fromColor(element.color);
    final hueShift = rr(-18, 18);
    final skin = hsl.withHue((hsl.hue + hueShift) % 360).withSaturation((hsl.saturation * rr(0.7, 0.95)).clamp(0, 1)).withLightness(rr(0.42, 0.55)).toColor();
    final skinDark = HSLColor.fromColor(skin).withLightness(0.2).toColor();
    final belly = HSLColor.fromColor(skin).withLightness(0.78).withSaturation(0.45).toColor();
    final accentHue = (hsl.hue + 180 + rr(-40, 40)) % 360;
    final accent = HSLColor.fromAHSL(1, accentHue, 0.7, 0.55).toColor();
    final eyeGlow = switch (element) {
      BeastElement.inferno => const Color(0xFFFFD34D),
      BeastElement.shadow => const Color(0xFFFF3D7F),
      BeastElement.frost => const Color(0xFF7DF9FF),
      BeastElement.storm => const Color(0xFF9DFF4D),
      BeastElement.tide => const Color(0xFF4DFFE1),
      BeastElement.terra => const Color(0xFFFF8A3D),
    };

    final hornRoll = r.nextInt(10);
    return Genome._(
      element: element,
      stage: stage,
      bodyWidth: rr(0.85, 1.12),
      bodyHeight: rr(0.82, 1.08),
      lobes: 2 + r.nextInt(5),
      lobeDepth: rr(0.02, 0.07),
      lobePhase: rr(0, pi * 2),
      eyeCount: const [1, 2, 2, 2, 2, 3, 2, 4][r.nextInt(8)],
      eyeSize: rr(0.85, 1.2),
      hornType: stage >= 2 && hornRoll < 3 ? 1 + r.nextInt(3) : (hornRoll < 3 ? 0 : 1 + hornRoll % 3),
      hornLength: rr(0.8, 1.2) * (1 + (stage - 1) * 0.25),
      spikes: (2 + r.nextInt(4)) + (stage - 1) * 2,
      fangs: 2 + r.nextInt(3),
      mouthWidth: rr(0.75, 1.15),
      armSize: rr(0.8, 1.2),
      pattern: r.nextInt(4),
      tailLength: rr(0.7, 1.2),
      skin: skin,
      skinDark: skinDark,
      belly: belly,
      accent: accent,
      eyeGlow: eyeGlow,
      ears: r.nextInt(3) == 0,
    );
  }
}
