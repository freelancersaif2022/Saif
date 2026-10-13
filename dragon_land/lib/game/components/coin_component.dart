import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../art/sprite_cache.dart';

enum PickupKind { coin, coinCluster, gem, heart, magnet, chest, gate }

/// Collectable item (pooled). (x, y) is the centre, except chests (bottom centre).
class Pickup {
  PickupKind kind = PickupKind.coin;
  double x = 0, y = 0;
  double phase = 0;
  int value = 1;
  bool collected = false;
  bool active = false;

  /// Being pulled toward the dragon by a magnet.
  bool attracted = false;

  /// Chest opening / gate used animation timer.
  double anim = 0;

  double get radius => switch (kind) {
    PickupKind.coin => 24,
    PickupKind.coinCluster => 34,
    PickupKind.gem => 26,
    PickupKind.heart || PickupKind.magnet => 28,
    PickupKind.chest => 44,
    PickupKind.gate => 60,
  };

  Rect get hitbox =>
      kind == PickupKind.chest ? Rect.fromLTWH(x - 42, y - 56, 84, 56) : Rect.fromCircle(center: Offset(x, y), radius: radius);
}

/// Coins, gems, power-ups, chests and magic gates. Pickups are pooled.
class PickupLayer extends Component {
  PickupLayer(this.sprites, {super.priority});

  final SpriteCache sprites;
  final List<Pickup> items = [];
  final List<Pickup> _pool = [];

  Pickup spawn(PickupKind kind, double x, double y, {int value = 1}) {
    final p = _pool.isNotEmpty ? _pool.removeLast() : Pickup();
    p
      ..kind = kind
      ..x = x
      ..y = y
      ..value = value
      ..phase = (x * 0.0013) % 1.0
      ..collected = false
      ..attracted = false
      ..anim = 0
      ..active = true;
    items.add(p);
    return p;
  }

  void clear() {
    _pool.addAll(items);
    items.clear();
  }

  void scroll(double dx, double dt) {
    for (final p in items) {
      if (!p.attracted) p.x -= dx;
      p.phase += dt * (p.kind == PickupKind.coin || p.kind == PickupKind.coinCluster ? 1.1 : 0.6);
      if (p.anim > 0) p.anim += dt;
    }
    for (var i = items.length - 1; i >= 0; i--) {
      final p = items[i];
      final expired = p.x < -140 || (p.collected && (p.kind != PickupKind.chest && p.kind != PickupKind.gate || p.anim > 1.2));
      if (expired) {
        p.active = false;
        items.removeAt(i);
        _pool.add(p);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in items) {
      final pos = Offset(p.x, p.y);
      switch (p.kind) {
        case PickupKind.coin:
          if (!p.collected) sprites['coin'].draw(canvas, p.phase, pos);
        case PickupKind.coinCluster:
          if (!p.collected) {
            for (var i = 0; i < 3; i++) {
              final a = p.phase * 2 + i * 2.1;
              sprites['coin'].draw(canvas, p.phase + i * 0.2, pos + Offset(math.cos(a) * 14, math.sin(a) * 8), scale: 0.9);
            }
          }
        case PickupKind.gem:
          if (!p.collected) sprites['gem'].draw(canvas, p.phase, pos + Offset(0, math.sin(p.phase * 6) * 6));
        case PickupKind.heart:
          if (!p.collected) sprites['heart'].draw(canvas, p.phase, pos + Offset(0, math.sin(p.phase * 6) * 6));
        case PickupKind.magnet:
          if (!p.collected) sprites['magnet'].draw(canvas, p.phase, pos + Offset(0, math.sin(p.phase * 6) * 6));
        case PickupKind.chest:
          if (p.collected) {
            sprites['chest_open'].draw(canvas, 0, pos, opacity: (1.2 - p.anim).clamp(0.0, 1.0));
          } else {
            sprites['chest'].draw(canvas, p.phase, pos);
          }
        case PickupKind.gate:
          sprites['gate'].draw(canvas, p.phase, pos, opacity: p.collected ? (1 - p.anim).clamp(0.0, 1.0) : 1, scale: 1 + p.anim * 0.4);
      }
    }
  }
}
