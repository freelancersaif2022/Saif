import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../art/sprite_cache.dart';

enum ObstacleKind { thorns, boulder, crystal, barrier, pod }

/// A static hazard. Ground obstacles use (x, y) = bottom centre; floating
/// pods use the centre.
class Obstacle {
  Obstacle(this.kind, this.x, this.y) : hp = _hpFor(kind), maxHp = _hpFor(kind);

  final ObstacleKind kind;
  double x;
  double y;
  int hp;
  final int maxHp;
  double phase = 0;
  double flash = 0;
  bool destroyed = false;

  /// Already damaged the player once (prevents repeated damage while overlapping).
  bool hitPlayer = false;
  double bob = 0;

  static int _hpFor(ObstacleKind k) => switch (k) {
    ObstacleKind.thorns => 999,
    ObstacleKind.boulder => 2,
    ObstacleKind.crystal => 1,
    ObstacleKind.barrier => 3,
    ObstacleKind.pod => 1,
  };

  bool get destructible => kind != ObstacleKind.thorns;
  int get damage => 1;

  Rect get hitbox => switch (kind) {
    ObstacleKind.thorns => Rect.fromLTWH(x - 40, y - 44, 80, 44),
    ObstacleKind.boulder => Rect.fromLTWH(x - 40, y - 70, 80, 70),
    ObstacleKind.crystal => Rect.fromLTWH(x - 34, y - 76, 68, 76),
    ObstacleKind.barrier => Rect.fromLTWH(x - 30, y - 236, 60, 236),
    ObstacleKind.pod => Rect.fromLTWH(x - 32, y + bob - 32, 64, 64),
  };

  double get right => x + 70;
}

class ObstacleLayer extends Component {
  ObstacleLayer(this.sprites, {super.priority});

  final SpriteCache sprites;
  final List<Obstacle> items = [];

  void scroll(double dx, double dt) {
    for (final o in items) {
      o.x -= dx;
      o.phase += dt * 0.8;
      if (o.flash > 0) o.flash -= dt;
      if (o.kind == ObstacleKind.pod) o.bob = math.sin(o.phase * 4) * 14;
    }
    items.removeWhere((o) => o.destroyed || o.right < -100);
  }

  @override
  void render(Canvas canvas) {
    for (final o in items) {
      final flash = o.flash > 0;
      switch (o.kind) {
        case ObstacleKind.thorns:
          sprites['thorns'].draw(canvas, o.phase, Offset(o.x, o.y), flash: flash);
        case ObstacleKind.boulder:
          sprites[o.hp < o.maxHp ? 'boulder_cracked' : 'boulder'].draw(canvas, 0, Offset(o.x, o.y), flash: flash);
        case ObstacleKind.crystal:
          sprites['crystal'].draw(canvas, o.phase, Offset(o.x, o.y), flash: flash);
        case ObstacleKind.barrier:
          sprites['barrier'].draw(canvas, o.phase, Offset(o.x, o.y), flash: flash, opacity: 0.55 + 0.45 * o.hp / o.maxHp);
        case ObstacleKind.pod:
          sprites['pod'].draw(canvas, o.phase, Offset(o.x, o.y + o.bob), flash: flash);
      }
    }
  }
}
