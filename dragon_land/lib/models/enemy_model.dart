enum EnemyKind { slime, bat, stone, goblin, boss }

/// Tunable stats for an enemy type. Sizes are in world units (720 units tall).
class EnemyDef {
  const EnemyDef({
    required this.kind,
    required this.id,
    required this.name,
    required this.hp,
    required this.damage,
    required this.width,
    required this.height,
    required this.extraSpeed,
    required this.flying,
  });

  final EnemyKind kind;
  final String id;
  final String name;
  final int hp;
  final int damage;
  final double width;
  final double height;

  /// Speed (units/s) the enemy moves left in addition to world scrolling.
  final double extraSpeed;
  final bool flying;

  static const slime = EnemyDef(
    kind: EnemyKind.slime,
    id: 'slime',
    name: 'Slime',
    hp: 1,
    damage: 1,
    width: 86,
    height: 70,
    extraSpeed: 60,
    flying: false,
  );
  static const bat = EnemyDef(
    kind: EnemyKind.bat,
    id: 'bat',
    name: 'Flying Bat',
    hp: 1,
    damage: 1,
    width: 92,
    height: 64,
    extraSpeed: 90,
    flying: true,
  );
  static const stone = EnemyDef(
    kind: EnemyKind.stone,
    id: 'stone',
    name: 'Stone Monster',
    hp: 4,
    damage: 1,
    width: 128,
    height: 130,
    extraSpeed: 20,
    flying: false,
  );
  static const goblin = EnemyDef(
    kind: EnemyKind.goblin,
    id: 'goblin',
    name: 'Goblin Rider',
    hp: 2,
    damage: 1,
    width: 132,
    height: 112,
    extraSpeed: 260,
    flying: false,
  );
  static const boss = EnemyDef(
    kind: EnemyKind.boss,
    id: 'boss',
    name: 'Crystal Golem',
    hp: 30,
    damage: 1,
    width: 250,
    height: 270,
    extraSpeed: 0,
    flying: false,
  );

  static EnemyDef of(EnemyKind k) => switch (k) {
    EnemyKind.slime => slime,
    EnemyKind.bat => bat,
    EnemyKind.stone => stone,
    EnemyKind.goblin => goblin,
    EnemyKind.boss => boss,
  };
}
