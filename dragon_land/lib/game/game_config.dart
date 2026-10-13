/// Gameplay tuning constants. World units: the play field is always 720
/// units tall; its width follows the screen aspect ratio.
class GameConfig {
  GameConfig._();

  static const double worldHeight = 720;

  /// Y of the ground surface.
  static const double groundY = 600;

  /// Visual scale applied to the dragon art in gameplay.
  static const double dragonScale = 0.78;

  // movement
  static const double gravity = 2900;
  static const double jumpVelocity = 1080;
  static const double coyoteTime = 0.1;
  static const double jumpBuffer = 0.14;
  static const double moveSpeed = 440;
  static const double minPlayerX = 150;

  /// Player x limits and start position as fractions of the visible width.
  /// The lane sits right of the on-screen movement buttons.
  static const double minPlayerXFraction = 0.22;
  static const double startPlayerXFraction = 0.30;
  static const double maxPlayerXFraction = 0.55;

  // world speed
  static const double baseSpeed = 360;
  static const double maxSpeed = 700;

  /// Distance (meters) over which the speed approaches its maximum.
  static const double speedRampMeters = 1800;
  static const double unitsPerMeter = 40;

  // sprint
  static const double sprintMultiplier = 1.45;
  static const double maxStamina = 100;
  static const double staminaDrain = 30;
  static const double staminaRegen = 20;
  static const double staminaRegenDelay = 0.7;
  static const double sprintMinStamina = 15;

  // flight
  static const double flightCruiseY = 330;
  static const double maxFlightEnergy = 100;
  static const double flightDrain = 22;
  static const double flightRegen = 11;
  static const double flightRegenDelay = 1.0;
  static const double flightMinStart = 30;
  static const double flightRiseSpeed = 900;

  // combat
  static const double attackCooldown = 0.42;
  static const int maxHealth = 3;
  static const double invulnerableAfterHit = 1.4;
  static const double reviveInvulnerability = 3.0;

  // abilities
  static const double waterShieldDuration = 4.0;
  static const double natureShieldDuration = 9.0;
  static const int natureShieldHits = 2;
  static const double shadowDashDuration = 0.6;
  static const double shadowDashSpeedMultiplier = 2.6;

  // buffs
  static const double magnetDuration = 8;
  static const double magnetRadius = 260;
  static const double doubleCoinsDuration = 10;

  // boss
  static const double firstBossMeters = 1200;
  static const double bossEveryMeters = 1600;
  static const double bossMaxDuration = 50;
}
