import 'dart:ui';

import 'package:flame/game.dart';

import 'battle.dart';
import 'level_data.dart';

/// Flame game hosting one level of combat.
class ShadowGame extends FlameGame {
  ShadowGame({
    required this.level,
    required this.input,
    required this.hud,
    required this.startX,
    required this.baseScore,
    required this.onPlayerDied,
    required this.onLevelComplete,
    this.ultimateEnabled = false,
  });

  final int level;
  final GameInput input;
  final HudState hud;
  final double startX;
  final int baseScore;
  final VoidCallback onPlayerDied;
  final void Function(int score) onLevelComplete;
  final bool ultimateEnabled;

  Battle? battle;

  @override
  Color backgroundColor() => const Color(0xFF040508);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    battle = Battle(
      cfg: levelConfig(level),
      input: input,
      hud: hud,
      startX: startX,
      baseScore: baseScore,
      onPlayerDied: onPlayerDied,
      onLevelComplete: onLevelComplete,
      ultimateEnabled: ultimateEnabled,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final b = battle;
    if (b == null) return;
    // Clamp long frames so physics stays stable after hitches.
    b.update(dt > 1 / 30 ? 1 / 30 : dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    battle?.render(canvas, size.x, size.y);
  }

  @override
  void onRemove() {
    battle?.dispose();
    battle = null;
    super.onRemove();
  }

  @override
  void onDispose() {
    battle?.dispose();
    battle = null;
    super.onDispose();
  }
}
