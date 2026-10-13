import 'dart:math' as math;

import '../game_config.dart';

/// Converts distance travelled into world speed and a 0..1 difficulty level.
class DifficultySystem {
  double meters = 0;

  /// Base world speed (before sprint / dash multipliers).
  double get speed =>
      GameConfig.baseSpeed + (GameConfig.maxSpeed - GameConfig.baseSpeed) * (1 - math.exp(-meters / GameConfig.speedRampMeters));

  /// 0 (start) .. 1 (around 3 km and beyond).
  double get level => (meters / 3000).clamp(0.0, 1.0);

  /// Phase label used for spawn rules.
  bool get early => meters < 400;
  bool get advanced => meters > 1500;
}
