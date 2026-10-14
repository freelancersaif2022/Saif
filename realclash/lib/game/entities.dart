double clampD(double v, double a, double b) => v < a ? a : (v > b ? b : v);

class Soldier {
  double x;
  double z;
  double hp;
  double dmg;
  double speed;
  double phase;
  int type;
  int gateId = -1;
  double cd = 0;
  double fight = 0;
  double hop = 0;
  double aiT = 0;
  bool alive = true;
  Enemy? tgt;

  Soldier({
    required this.x,
    required this.z,
    required this.hp,
    required this.dmg,
    required this.speed,
    required this.phase,
    required this.type,
  });
}

class Enemy {
  double x;
  double z;
  double hp;
  double maxHp;
  double speed;
  double dmg;
  double phase;
  double lat;
  double flank;
  double halfW;
  double halfZ;
  int kind; // 0 grunt, 1 brute, 2 boss
  double tx;
  double aiT = 0;
  double hitFlash = 0;
  double slow = 0;
  bool alive = true;

  Enemy({
    required this.x,
    required this.z,
    required this.hp,
    required this.speed,
    required this.dmg,
    required this.phase,
    required this.lat,
    required this.flank,
    required this.halfW,
    required this.halfZ,
    required this.kind,
  })  : maxHp = hp,
        tx = x;
}

class Gate {
  final int id;
  double x;
  double z;
  double w;
  bool bad;
  int value;
  double flash = 0;
  bool alive = true;

  Gate({required this.id, required this.x, required this.z, required this.w, required this.bad, required this.value});

  String get label => bad ? '/2' : 'x$value';
}

class Obstacle {
  double x;
  double z;
  double hw;
  int kind; // 0 crate, 1 spikes, 2 barrel
  double hp;
  double maxHp;
  double hitFlash = 0;
  bool touched = false;
  bool alive = true;

  Obstacle({required this.x, required this.z, required this.hw, required this.kind, required this.hp}) : maxHp = hp;
}

class Coin {
  double x;
  double z;
  double spin;
  bool alive = true;
  Coin({required this.x, required this.z, required this.spin});
}

class BaseFort {
  double z;
  double hp;
  double maxHp;
  bool arrived = false;
  double spawnT = 1.5;
  double fireT = 4.0;
  double hitFlash = 0;
  BaseFort({required this.z, required this.hp}) : maxHp = hp;
}

class Missile {
  double tx;
  double t;
  double total;
  Missile({required this.tx, required this.t}) : total = t;
}

class Corpse {
  double x;
  double z;
  double y = 0;
  double vy;
  double vx;
  double rot = 0;
  double vr;
  double life;
  double maxLife;
  int style;
  double size;
  Corpse({
    required this.x,
    required this.z,
    required this.vy,
    required this.vx,
    required this.vr,
    required this.life,
    required this.style,
    required this.size,
  }) : maxLife = life;
}
