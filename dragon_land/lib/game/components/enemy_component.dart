import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../art/enemy_art.dart';
import '../../art/sprite_cache.dart';
import '../../models/enemy_model.dart';
import '../game_config.dart';

/// A regular enemy. (x, y) is the bottom centre of its body.
class Enemy {
  Enemy(this.def, this.x, this.y) : hp = def.hp, baseY = y;

  final EnemyDef def;
  double x;
  double y;
  final double baseY;
  int hp;
  double phase = 0;
  double flash = 0;

  /// >0 while the enemy is off-screen and its warning marker is shown.
  double warn = 0;

  /// Death animation timer (>0 while dying).
  double dying = 0;
  bool get alive => hp > 0;

  /// Reward / defeat bookkeeping already done.
  bool rewarded = false;

  /// Cooldown before this enemy can damage the player again.
  double contactCooldown = 0;
  double hopT = 0;
  bool remove = false;

  EnemyKind get kind => def.kind;

  Rect get hitbox {
    final w = def.width * 0.78, h = def.height * 0.82;
    return Rect.fromLTWH(x - w / 2, y - h, w, h);
  }
}

enum BossAction { entering, idle, throwRocks, slam, summon, leaving, dying }

/// The Crystal Golem mini boss. Holds its own state machine; the game polls
/// [pendingRocks] / [pendingShockwave] / [pendingBats] to spawn attacks.
class Boss {
  Boss({required this.maxHp, required this.index}) : hp = maxHp;

  final int maxHp;
  final int index;
  int hp;
  double x = 2000;
  double y = GameConfig.groundY;
  double phase = 0;
  double flash = 0;
  BossAction action = BossAction.entering;
  double actionT = 0;
  double life = 0;
  bool rewarded = false;
  double contactCooldown = 0;

  // attack requests consumed by the game
  int pendingRocks = 0;
  bool pendingShockwave = false;
  int pendingBats = 0;
  int _attackCycle = 0;

  bool get alive => hp > 0;
  bool get gone => (action == BossAction.leaving && x > _viewWidth + 300) || (action == BossAction.dying && actionT > 1.6);
  double _viewWidth = 1280;

  Rect get hitbox => Rect.fromLTWH(x - 110, y - 250, 220, 250);

  /// Animation 'action' parameter for [EnemyArt].
  double get artAction => switch (action) {
    BossAction.slam => (actionT / 1.1).clamp(0.0, 1.0),
    BossAction.summon => -(math.sin(actionT * math.pi / 1.2)).abs(),
    _ => 0,
  };

  void update(double dt, double viewWidth, {required double difficulty}) {
    _viewWidth = viewWidth;
    phase += dt * 0.6;
    life += dt;
    actionT += dt;
    if (flash > 0) flash -= dt;
    if (contactCooldown > 0) contactCooldown -= dt;
    final homeX = viewWidth - 210;
    switch (action) {
      case BossAction.entering:
        x = math.max(homeX, x - 260 * dt);
        if (x <= homeX + 0.5) _next(BossAction.idle);
      case BossAction.idle:
        x += (homeX - x) * math.min(1, dt * 3);
        final pause = 1.6 - difficulty * 0.6 - index * 0.1;
        if (actionT > math.max(0.8, pause)) {
          _attackCycle++;
          final pick = _attackCycle % 3;
          _next(pick == 0 ? BossAction.slam : (pick == 1 ? BossAction.throwRocks : BossAction.summon));
        }
        if (life > GameConfig.bossMaxDuration) _next(BossAction.leaving);
      case BossAction.throwRocks:
        if (actionT > 0.5 && pendingRocks == 0 && actionT < 0.55) pendingRocks = 2 + (index > 1 ? 1 : 0);
        if (actionT > 1.0) _next(BossAction.idle);
      case BossAction.slam:
        if (actionT >= 0.66 && actionT - dt < 0.66) pendingShockwave = true;
        if (actionT > 1.1) _next(BossAction.idle);
      case BossAction.summon:
        if (actionT >= 0.6 && actionT - dt < 0.6) pendingBats = 1 + (index > 0 ? 1 : 0);
        if (actionT > 1.2) _next(BossAction.idle);
      case BossAction.leaving:
        x += 320 * dt;
      case BossAction.dying:
        y += 90 * dt * actionT;
    }
  }

  void _next(BossAction a) {
    action = a;
    actionT = 0;
  }

  void kill() {
    hp = 0;
    _next(BossAction.dying);
  }
}

/// Renders and moves regular enemies and the boss.
class EnemyLayer extends Component {
  EnemyLayer(this.sprites, {super.priority});

  final SpriteCache sprites;
  final List<Enemy> items = [];
  Boss? boss;
  double viewWidth = 1280;
  final Paint _p = Paint()..isAntiAlias = true;

  void clear() {
    items.clear();
    boss = null;
  }

  void step(double dt, double scroll) {
    for (final e in items) {
      e.phase += dt * (e.kind == EnemyKind.goblin ? 2.2 : 1.4);
      if (e.flash > 0) e.flash -= dt;
      if (e.contactCooldown > 0) e.contactCooldown -= dt;
      if (e.dying > 0) {
        e.dying += dt;
        e.x -= scroll * dt;
        e.y -= (e.kind == EnemyKind.bat ? -200 : 120) * dt;
        if (e.dying > 0.7) e.remove = true;
        continue;
      }
      if (e.warn > 0) {
        e.warn -= dt;
        if (e.warn > 0) continue;
      }
      e.x -= (scroll + e.def.extraSpeed) * dt;
      switch (e.kind) {
        case EnemyKind.slime:
          e.hopT += dt * 2.2;
          e.y = e.baseY - (math.sin(e.hopT * math.pi).abs() * 26);
        case EnemyKind.bat:
          e.y = e.baseY + math.sin(e.phase * 2.4) * 36;
        default:
          break;
      }
      if (e.x < -200) e.remove = true;
    }
    items.removeWhere((e) => e.remove);
  }

  @override
  void render(Canvas canvas) {
    for (final e in items) {
      final sheet = sprites.enemy(e.kind);
      if (e.warn > 0) {
        _warning(canvas, e);
        continue;
      }
      // ground shadow
      if (!e.def.flying && e.dying <= 0) {
        _p.color = const Color(0x33203020);
        canvas.drawOval(Rect.fromCenter(center: Offset(e.x, GameConfig.groundY + 2), width: e.def.width * 0.8, height: 14), _p);
      }
      if (e.dying > 0) {
        canvas.save();
        canvas.translate(e.x, e.y);
        canvas.rotate(e.dying * 3);
        sheet.draw(canvas, e.phase, Offset.zero, flash: true, opacity: (1 - e.dying / 0.7).clamp(0.0, 1.0));
        canvas.restore();
      } else {
        sheet.draw(canvas, e.phase, Offset(e.x, e.y), flash: e.flash > 0);
      }
    }
    final b = boss;
    if (b != null) {
      canvas.save();
      canvas.translate(b.x, b.y);
      if (b.action == BossAction.dying) canvas.rotate(math.min(0.5, b.actionT * 0.4));
      _p.color = const Color(0x44203020);
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 4), width: 240, height: 26), _p);
      if (b.flash > 0) {
        canvas.saveLayer(const Rect.fromLTWH(-200, -330, 400, 340), Paint());
        EnemyArt.paint(canvas, EnemyKind.boss, b.phase, action: b.artAction);
        canvas.drawPaint(
          Paint()
            ..blendMode = BlendMode.srcATop
            ..color = const Color(0xBBFFFFFF),
        );
        canvas.restore();
      } else {
        EnemyArt.paint(canvas, EnemyKind.boss, b.phase, action: b.artAction);
      }
      canvas.restore();
    }
  }

  void _warning(Canvas canvas, Enemy e) {
    final x = viewWidth - 50;
    final y = e.y - e.def.height * 0.5;
    final pulse = 0.75 + 0.25 * math.sin(e.warn * 20);
    _p.color = Color.fromRGBO(255, 70, 70, 0.9 * pulse);
    canvas.drawPath(
      Path()
        ..moveTo(x + 30, y)
        ..lineTo(x - 6, y - 34)
        ..lineTo(x - 6, y + 34)
        ..close(),
      _p,
    );
    _p.color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(x + 1, y - 16, 7, 20), _p);
    canvas.drawCircle(Offset(x + 4.5, y + 11), 4, _p);
  }
}
