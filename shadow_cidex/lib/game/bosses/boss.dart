import 'dart:ui';

import '../../audio.dart';
import '../../core/utils.dart';
import '../battle.dart';

class BossPhase {
  const BossPhase(this.name, this.maxHp, this.color);
  final String name;
  final double maxHp;
  final Color color;
}

/// Shared boss behaviour: phased health, hit handling and helpers.
abstract class Boss implements Hittable {
  Boss(this.b, this.phases) {
    hp = phases.first.maxHp;
  }

  final Battle b;
  final List<BossPhase> phases;
  int phase = 0;
  late double hp;
  double x = 0;
  double y = 0;
  double facing = -1;
  double flash = 0;
  bool introDone = false;
  bool defeated = false;
  bool finished = false;
  bool transforming = false;

  int get scoreValue;
  double get focusX => x;
  String get phaseName => phases[phase].name;
  Color get barColor => phases[phase].color;
  int get phaseCount => phases.length;
  double get barFraction => clampD(hp / phases[phase].maxHp, 0, 1);
  bool get vulnerable => true;
  bool get enraged => barFraction < 0.5;

  @override
  bool get canBeHit => introDone && !defeated && !transforming && vulnerable;

  @override
  void receiveHit(double damage, double dir, double knock, {bool heavy = false}) {
    if (!canBeHit) return;
    hp -= damage;
    flash = 1;
    b.sfx(Sfx.bossHit, x: x, volume: 0.75, gap: 50);
    b.spawnPickup(hurtBox.center.dx, hurtBox.center.dy, 0.025);
    onHit(damage, dir, heavy);
    if (hp <= 0) {
      hp = 0;
      if (phase < phases.length - 1) {
        transforming = true;
        startTransform();
      } else {
        defeated = true;
        b.bossDefeated();
        startDeath();
      }
    }
  }

  void nextPhase() {
    phase++;
    hp = phases[phase].maxHp;
    transforming = false;
  }

  void onHit(double damage, double dir, bool heavy) {}
  void startTransform() {}
  void startDeath();
  void update(double dt);
  void render(Canvas c);

  /// Damages the player if [r] overlaps the player's body.
  bool contact(Rect r, double damage, {double knock = 420, double lift = 300}) {
    final p = b.player;
    if (!p.alive || p.invuln > 0) return false;
    if (r.overlaps(p.box)) {
      p.damage(damage, r.center.dx, knock: knock, lift: lift);
      return true;
    }
    return false;
  }

  /// Rect in world space from local extents relative to [x], honouring [facing].
  Rect sideRect(double back, double front, double top, double bottom) {
    if (facing >= 0) return Rect.fromLTRB(x - back, y + top, x + front, y + bottom);
    return Rect.fromLTRB(x - front, y + top, x + back, y + bottom);
  }

  void faceTarget() => facing = b.player.x >= x ? 1 : -1;

  double get arenaMin => 120;
  double get arenaMax => b.cfg.length - 120;
}
