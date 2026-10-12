import 'dart:ui';

/// A pooled bullet. Player and enemy bullets share the pool.
class Bullet {
  bool active = false;
  bool fromPlayer = false;
  double x = 0;
  double y = 0;
  double z = 0;
  double dx = 0;
  double dy = 0;
  double speed = 0;
  double travelled = 0;
  double range = 0;
  double damage = 0;
  double headshotChance = 0;
  int pierce = 0;
  int lastHitId = -1;
  double width = 1;
  Color color = const Color(0xFFFFFFFF);
}

/// A boss grenade arcing toward a marked spot on the ground.
class Grenade {
  bool active = false;
  double sx = 0;
  double sy = 0;
  double tx = 0;
  double ty = 0;
  double t = 0;
  double duration = 1;
  double radius = 150;
  double damage = 30;

  double get progress => (t / duration).clamp(0.0, 1.0);
}

/// Medical kit dropped by defeated enemies.
class Pickup {
  bool active = false;
  double x = 0;
  double y = 0;
  double life = 0;
  double heal = 35;
}

/// Floating score text anchored to a world position.
class ScorePopup {
  bool active = false;
  double x = 0;
  double y = 0;
  double z = 0;
  double life = 0;
  int value = 0;
  bool headshot = false;
}
