import 'dart:math';

import '../models/element.dart';
import '../models/monster.dart';

enum MoveKind { claw, special, roar, guard }

class Move {
  const Move(this.kind, this.name, this.power, this.accuracy, this.cooldown, this.description);
  final MoveKind kind;
  final String name;
  final int power;
  final double accuracy;
  final int cooldown;
  final String description;

  static List<Move> forElement(BeastElement e) => [
    const Move(MoveKind.claw, 'Claw Swipe', 38, 1.0, 0, 'Reliable strike'),
    Move(MoveKind.special, e.specialMove, 72, 0.85, 2, '${e.label} power • 85% hit'),
    const Move(MoveKind.roar, 'Battle Roar', 0, 1.0, 3, 'ATK +30% for 3 turns'),
    const Move(MoveKind.guard, 'Guard', 0, 1.0, 1, 'Block 60% • heal 10%'),
  ];
}

class Fighter {
  Fighter(this.monster) : hp = monster.maxHp, moves = Move.forElement(monster.element);

  final Monster monster;
  final List<Move> moves;
  int hp;
  int buffTurns = 0;
  bool guarding = false;
  final Map<MoveKind, int> cooldowns = {};

  int get maxHp => monster.maxHp;
  double get hpRatio => hp / maxHp;
  bool get fainted => hp <= 0;
  bool isReady(Move m) => (cooldowns[m.kind] ?? 0) <= 0;
  int cooldownOf(Move m) => cooldowns[m.kind] ?? 0;
  double get atkMult => buffTurns > 0 ? 1.3 : 1.0;
}

enum EventType { attack, miss, roar, guard, faint }

class BattleEvent {
  BattleEvent({required this.type, required this.byPlayer, required this.move, this.damage = 0, this.heal = 0, this.crit = false, this.effectiveness = 1.0});
  final EventType type;
  final bool byPlayer;
  final Move move;
  final int damage;
  final int heal;
  final bool crit;
  final double effectiveness;

  String get text {
    final who = byPlayer ? 'Your beast' : 'Enemy';
    return switch (type) {
      EventType.attack =>
        '$who used ${move.name}!${crit ? ' Critical hit!' : ''}${effectiveness > 1
            ? ' Super effective!'
            : effectiveness < 1
            ? ' Not very effective…'
            : ''}',
      EventType.miss => '$who used ${move.name}… but missed!',
      EventType.roar => '$who let out a Battle Roar! ATK up!',
      EventType.guard => '$who is guarding${heal > 0 ? ' (+$heal HP)' : ''}.',
      EventType.faint => byPlayer ? 'Enemy fainted!' : 'Your beast fainted!',
    };
  }
}

class BattleEngine {
  BattleEngine(Monster player, Monster enemy, {Random? random}) : player = Fighter(player), enemy = Fighter(enemy), _r = random ?? Random();

  final Fighter player;
  final Fighter enemy;
  final Random _r;
  int turn = 0;
  bool revived = false;

  bool get over => player.fainted || enemy.fainted;
  bool get playerWon => enemy.fainted && !player.fainted;

  Move chooseAiMove() {
    final e = enemy;
    final ready = e.moves.where(e.isReady).toList();
    Move pick(MoveKind k) => e.moves.firstWhere((m) => m.kind == k);
    bool can(MoveKind k) => ready.any((m) => m.kind == k);

    if (e.hpRatio < 0.35 && can(MoveKind.guard) && _r.nextDouble() < 0.4) return pick(MoveKind.guard);
    if (can(MoveKind.roar) && e.buffTurns == 0 && turn < 4 && _r.nextDouble() < 0.3) return pick(MoveKind.roar);
    if (can(MoveKind.special) && _r.nextDouble() < 0.75) return pick(MoveKind.special);
    return pick(MoveKind.claw);
  }

  /// Plays one full round. Returns the ordered events for the UI to animate.
  List<BattleEvent> playRound(Move playerMove) {
    turn++;
    final aiMove = chooseAiMove();
    final playerFirst = player.monster.spd == enemy.monster.spd ? _r.nextBool() : player.monster.spd > enemy.monster.spd;

    // Guards activate before any attack this round.
    player.guarding = playerMove.kind == MoveKind.guard;
    enemy.guarding = aiMove.kind == MoveKind.guard;

    final order = playerFirst ? [(player, enemy, playerMove, true), (enemy, player, aiMove, false)] : [(enemy, player, aiMove, false), (player, enemy, playerMove, true)];

    final events = <BattleEvent>[];
    for (final (atk, def, move, isPlayer) in order) {
      if (atk.fainted || def.fainted) break;
      events.add(_act(atk, def, move, isPlayer));
      if (def.fainted) {
        events.add(BattleEvent(type: EventType.faint, byPlayer: isPlayer, move: move));
        break;
      }
    }

    for (final f in [player, enemy]) {
      f.cooldowns.updateAll((_, v) => max(0, v - 1));
      if (f.buffTurns > 0) f.buffTurns--;
    }
    player.cooldowns[playerMove.kind] = playerMove.cooldown;
    enemy.cooldowns[aiMove.kind] = aiMove.cooldown;
    // A Roar's buff should last 3 of the owner's attacks, not tick down on the same round.
    if (playerMove.kind == MoveKind.roar) player.buffTurns = 3;
    if (aiMove.kind == MoveKind.roar) enemy.buffTurns = 3;
    return events;
  }

  BattleEvent _act(Fighter a, Fighter d, Move m, bool isPlayer) {
    switch (m.kind) {
      case MoveKind.roar:
        return BattleEvent(type: EventType.roar, byPlayer: isPlayer, move: m);
      case MoveKind.guard:
        final heal = min((a.maxHp * 0.10).round(), a.maxHp - a.hp);
        a.hp += heal;
        return BattleEvent(type: EventType.guard, byPlayer: isPlayer, move: m, heal: heal);
      case MoveKind.claw:
      case MoveKind.special:
        if (_r.nextDouble() > m.accuracy) {
          return BattleEvent(type: EventType.miss, byPlayer: isPlayer, move: m);
        }
        final eff = m.kind == MoveKind.special ? a.monster.element.against(d.monster.element) : 1.0;
        final crit = _r.nextDouble() < 0.07;
        final levelFactor = 0.6 + a.monster.level * 0.04;
        var dmg = (a.monster.atk * a.atkMult * m.power / (d.monster.def + 25)) * levelFactor * eff;
        dmg *= 0.9 + _r.nextDouble() * 0.2;
        if (crit) dmg *= 1.6;
        if (d.guarding) dmg *= 0.4;
        final dealt = max(1, dmg.round() + 2);
        d.hp = max(0, d.hp - dealt);
        return BattleEvent(type: EventType.attack, byPlayer: isPlayer, move: m, damage: dealt, crit: crit, effectiveness: eff);
    }
  }

  void revivePlayer() {
    revived = true;
    player.hp = (player.maxHp * 0.5).round();
    player.cooldowns.clear();
  }
}
