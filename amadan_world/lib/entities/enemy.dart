import 'dart:ui';

import '../weapons/weapon_data.dart';
import 'soldier_rig.dart';

enum EnemyKind { rifleman, rusher, heavy, marksman, boss }

/// Balancing and appearance data for one enemy type.
class EnemySpec {
  const EnemySpec({
    required this.kind,
    required this.hp,
    required this.speed,
    required this.damage,
    required this.fireInterval,
    required this.burst,
    required this.burstGap,
    required this.range,
    required this.preferredDistance,
    required this.spread,
    required this.bulletSpeed,
    required this.points,
    required this.scale,
    required this.look,
    required this.weapon,
    required this.tracer,
  });

  final EnemyKind kind;
  final double hp;
  final double speed;
  final double damage;
  final double fireInterval;
  final int burst;
  final double burstGap;
  final double range;
  final double preferredDistance;
  final double spread;
  final double bulletSpeed;
  final int points;
  final double scale;
  final RigLook look;
  final WeaponModel weapon;
  final Color tracer;
}

/// A pooled enemy soldier. Instances are recycled by the enemy director.
class Enemy {
  Enemy(this.id);

  final int id;
  final RigPose pose = RigPose();

  bool active = false;
  bool alive = false;
  late EnemySpec spec;

  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double hp = 1;
  double maxHp = 1;
  double damageMul = 1;
  double speedMul = 1;
  double radius = 17;

  double hitFlash = 0;
  double barTimer = 0;
  double deathTimer = 0;
  double spawnFade = 0;
  double fireTimer = 0;
  int burstLeft = 0;
  double burstTimer = 0;
  double losTimer = 0;
  bool hasLos = false;
  bool engaging = false;
  double strafeDir = 1;
  double strafeTimer = 0;
  int avoidSign = 0;
  double avoidTimer = 0;
  double stepAcc = 0;
  bool killedByHeadshot = false;

  // Boss state.
  int bossState = 0;
  double bossTimer = 0;
  double bossCooldown = 0;
  double chargeX = 0;
  double chargeY = 0;
  int summonStage = 0;
  bool critical = false;
  bool chargeHit = false;

  bool get isBoss => spec.kind == EnemyKind.boss;

  void activate(EnemySpec s, double px, double py, double hpMul, double dmgMul) {
    spec = s;
    active = true;
    alive = true;
    x = px;
    y = py;
    vx = 0;
    vy = 0;
    maxHp = s.hp * hpMul;
    hp = maxHp;
    damageMul = dmgMul;
    speedMul = 1;
    radius = 17 * s.scale;
    hitFlash = 0;
    barTimer = 0;
    deathTimer = 0;
    spawnFade = 0;
    fireTimer = 1.0 + s.fireInterval * 0.6;
    burstLeft = 0;
    burstTimer = 0;
    losTimer = 0;
    hasLos = false;
    engaging = false;
    strafeDir = (id.isEven) ? 1 : -1;
    strafeTimer = 1.5;
    avoidSign = 0;
    avoidTimer = 0;
    stepAcc = 0;
    killedByHeadshot = false;
    bossState = 0;
    bossTimer = 0;
    bossCooldown = 2.5;
    summonStage = 0;
    critical = false;
    chargeHit = false;
    pose.reset();
  }
}
