import 'dart:math' as math;

import '../weapons/weapon_data.dart';
import '../weapons/weapon_state.dart';
import 'enemy.dart';
import 'soldier_rig.dart';

/// The player's soldier.
class Player {
  Player(WeaponSpec spec) : weapon = WeaponState(spec);

  static const double radius = 17;
  static const double maxHp = 100;

  final WeaponState weapon;
  final RigPose pose = RigPose();

  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double hp = maxHp;
  double displayHp = maxHp;
  double stamina = 1;
  double staminaDelay = 0;
  bool alive = true;
  bool aiming = false;
  bool sprinting = false;
  Enemy? target;
  double aimAngle = -math.pi / 2;
  double hitFlash = 0;
  double sinceDamage = 99;
  double sinceFire = 99;
  double deathTimer = 0;
  double stepAcc = 0;
  double retargetTimer = 0;

  void reset(double sx, double sy) {
    x = sx;
    y = sy;
    vx = 0;
    vy = 0;
    hp = maxHp;
    displayHp = maxHp;
    stamina = 1;
    staminaDelay = 0;
    alive = true;
    aiming = false;
    sprinting = false;
    target = null;
    aimAngle = -math.pi / 2;
    hitFlash = 0;
    sinceDamage = 99;
    sinceFire = 99;
    deathTimer = 0;
    stepAcc = 0;
    retargetTimer = 0;
    weapon.reset();
    pose.reset();
  }
}
