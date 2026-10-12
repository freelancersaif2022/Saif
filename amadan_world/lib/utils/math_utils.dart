import 'dart:math' as math;

final math.Random rng = math.Random();

const double twoPi = math.pi * 2;

double randRange(double a, double b) => a + rng.nextDouble() * (b - a);

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

double lerpD(double a, double b, double t) => a + (b - a) * t;

double smoothStepD(double e0, double e1, double x) {
  final t = clampD((x - e0) / (e1 - e0), 0, 1);
  return t * t * (3 - 2 * t);
}

/// Moves [current] toward [target] by at most [maxDelta].
double approach(double current, double target, double maxDelta) {
  if (current < target) {
    return math.min(current + maxDelta, target);
  }
  return math.max(current - maxDelta, target);
}

double wrapAngle(double a) {
  var r = a % twoPi;
  if (r > math.pi) r -= twoPi;
  if (r < -math.pi) r += twoPi;
  return r;
}

/// Rotates angle [current] toward [target] by at most [maxStep] radians.
double turnToward(double current, double target, double maxStep) {
  final diff = wrapAngle(target - current);
  if (diff.abs() <= maxStep) return target;
  return current + (diff > 0 ? maxStep : -maxStep);
}

double dist2(double ax, double ay, double bx, double by) {
  final dx = ax - bx;
  final dy = ay - by;
  return dx * dx + dy * dy;
}

/// Exponential smoothing factor that is frame-rate independent.
double damp(double rate, double dt) => 1 - math.exp(-rate * dt);
