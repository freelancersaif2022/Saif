import 'dart:math' as math;
import 'dart:ui';

final math.Random rng = math.Random();

double randRange(double a, double b) => a + rng.nextDouble() * (b - a);

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

double lerpD(double a, double b, double t) => a + (b - a) * t;

/// Returns [c] with its alpha multiplied by [o] (0..1).
Color fade(Color c, double o) {
  final a = (c.a * clampD(o, 0, 1) * 255).round();
  return c.withAlpha(a.clamp(0, 255));
}

/// Returns [c] with an absolute opacity [o] (0..1).
Color withOpacityOf(Color c, double o) => c.withAlpha((clampD(o, 0, 1) * 255).round());

double easeOutCubic(double t) {
  final x = clampD(t, 0, 1) - 1;
  return x * x * x + 1;
}

double easeInOut(double t) {
  final x = clampD(t, 0, 1);
  return x * x * (3 - 2 * x);
}

double easeInCubic(double t) {
  final x = clampD(t, 0, 1);
  return x * x * x;
}

/// Exponential smoothing factor for frame independent blending.
double smoothK(double rate, double dt) => 1 - math.exp(-rate * dt);

double sign(double v) => v < 0 ? -1 : 1;
