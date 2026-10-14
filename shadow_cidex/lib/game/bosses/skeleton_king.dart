import 'dart:math' as math;
import 'dart:ui';

import '../../audio.dart';
import '../../core/utils.dart';
import '../../render/humanoid.dart';
import '../battle.dart';
import '../enemy.dart';
import '../hazards.dart';
import '../level_data.dart';
import 'boss.dart';

enum _SK { intro, idle, approach, slashTell, slash, throwBones, spikes, leapTell, leap, summon, recover, transform, dying }

/// Level 14: the giant Bone King. Grows larger and summons skeletons in its
/// second (red) life.
class SkeletonKingBoss extends Boss {
  SkeletonKingBoss(Battle b)
      : super(b, const [
          BossPhase('THE BONE KING', 1700, Color(0xFFFFC21A)),
          BossPhase('THE BONE KING  UNBOUND', 1800, Color(0xFFFF2020)),
        ]) {
    x = b.cfg.length * 0.66;
    facing = -1;
    rig.pose.idle(0);
  }

  static const HumanoidStyle style1 = HumanoidStyle(
    height: 320,
    bulk: 1.35,
    skeleton: true,
    crown: true,
    cape: true,
    armor: true,
    weapon: WeaponType.greatsword,
    body: Color(0xFF141418),
    backTint: Color(0xFF24242C),
    rim: Color(0xFFD8C8A8),
    rimStrength: 0.68,
    eyeGlow: 1.6,
    bladeColor: Color(0xFFFFC0A0),
    bladeGlow: Color(0xFFFF4010),
  );

  static const HumanoidStyle style2 = HumanoidStyle(
    height: 320,
    bulk: 1.45,
    skeleton: true,
    crown: true,
    horns: true,
    cape: true,
    armor: true,
    weapon: WeaponType.greatsword,
    body: Color(0xFF16100F),
    backTint: Color(0xFF2A1A18),
    rim: Color(0xFFFF9A7A),
    rimStrength: 0.7,
    eyeGlow: 2.0,
    bladeColor: Color(0xFFFFA080),
    bladeGlow: Color(0xFFFF1A0A),
    veins: Color(0xFFFF2010),
  );

  final HumanoidRig rig = HumanoidRig(style1);
  _SK _state = _SK.intro;
  double _st = 0;
  double vx = 0;
  double walk = 0;
  double rise = 1;
  double alpha = 1;
  double grow = 0;
  double _next = 1;
  bool _did = false;
  int _combo = 0;
  int _count = 0;
  double _fromX = 0;
  double _toX = 0;
  double _eyeBoost = 0;
  double _summonCd = 6;
  final Set<Object> _hitOnce = {};

  HumanoidStyle get style => grow > 0.5 ? style2 : style1;
  double get height => lerpD(320, 420, grow);
  double get _rage => (phase == 1 ? 1.25 : 1.0) * (enraged ? 1.15 : 1.0);

  @override
  int get scoreValue => 14000;

  @override
  double get focusX => _state == _SK.intro ? x : x;

  @override
  Rect get hurtBox => Rect.fromLTRB(x - 70 - grow * 20, y - height * 0.95, x + 70 + grow * 20, y);

  void _set(_SK s) {
    _state = s;
    _st = 0;
    _did = false;
  }

  @override
  void update(double dt) {
    _st += dt;
    flash = math.max(0, flash - dt * 5);
    _eyeBoost = math.max(0, _eyeBoost - dt * 2);
    _summonCd -= dt;
    final p = b.player;
    final adx = (p.x - x).abs();
    switch (_state) {
      case _SK.intro:
        if (!_did) {
          _did = true;
          b.sfx(Sfx.bossEntrance, volume: 1.0);
          b.sfx(Sfx.skeletonRattle, volume: 1.0);
        }
        rise = clampD(1 - _st / 2.4, 0, 1);
        b.addShake(dt * 0.6);
        if (rng.nextDouble() < 0.8) b.fx.debris(x + randRange(-120, 120), 0, n: 1, color: const Color(0xFF3A342C));
        if (_st > 2.5 && _st - dt <= 2.5) {
          b.sfx(Sfx.bossRoar, volume: 1.0);
          b.ring(x, -200, 340, 0.8, const Color(0xFFFFC21A), 8, flat: 1);
        }
        if (_st > 3.1) {
          rise = 0;
          introDone = true;
          b.showBanner('THE BONE KING', 'LORD OF THE GRAVEYARD');
          _set(_SK.idle);
          _next = 0.5;
        }
        break;
      case _SK.idle:
        vx *= 0.8;
        faceTarget();
        if (_st > _next) _choose(adx);
        break;
      case _SK.approach:
        faceTarget();
        vx = facing * 210 * _rage;
        walk += dt * 5;
        if (adx < 300 || _st > 1.5) {
          _combo = rng.nextDouble() < 0.5 ? 2 : 3;
          _set(_SK.slashTell);
        }
        break;
      case _SK.slashTell:
        vx *= 0.8;
        faceTarget();
        _eyeBoost = 1.2;
        if (_st > 0.42 / _rage) {
          _hitOnce.clear();
          vx = facing * 380;
          b.sfx(Sfx.swordSwingHeavy, x: x, volume: 1.0);
          _set(_SK.slash);
        }
        break;
      case _SK.slash:
        vx *= math.max(0, 1 - 6 * dt);
        if (_st > 0.05 && _st < 0.22 && !_hitOnce.contains(p)) {
          if (contact(sideRect(-10, 290 + grow * 80, -height, 0), 24, knock: 500, lift: 360)) _hitOnce.add(p);
        }
        if (_st > 0.12 && !_did) {
          _did = true;
          b.addShake(0.3);
          b.fx.dust(x + facing * 240, 0, n: 8, power: 1.2);
        }
        if (_st > 0.38) {
          _combo--;
          if (_combo > 0) {
            _set(_SK.slashTell);
            _st = 0.18;
          } else {
            _set(_SK.recover);
          }
        }
        break;
      case _SK.throwBones:
        vx *= 0.8;
        faceTarget();
        final cycle = _st % 0.4;
        if (cycle - dt < 0.2 && cycle >= 0.2 && _count > 0) {
          _count--;
          final high = rng.nextBool();
          b.projectiles.add(CrossBlade(b, x + facing * 100, high ? -205 : -45, facing, speed: randRange(520, 640) * _rage, damage: 18));
          b.sfx(Sfx.swordSwing2, x: x, volume: 0.7, gap: 100);
        }
        if (_count <= 0 && _st > 0.5) _set(_SK.recover);
        break;
      case _SK.spikes:
        vx = 0;
        _eyeBoost = 1.6;
        if (_st > 0.5 && !_did) {
          _did = true;
          b.sfx(Sfx.bossSpecial, x: x, volume: 1.0);
          b.addShake(0.5);
          b.projectiles.add(BoneSpikeRow(b, x + facing * 120, facing, count: 10, damage: 20));
          if (phase == 1) b.projectiles.add(BoneSpikeRow(b, x - facing * 120, -facing, count: 7, damage: 20));
        }
        if (_st > 1.2) _set(_SK.recover);
        break;
      case _SK.leapTell:
        vx *= 0.7;
        faceTarget();
        if (_st > 0.4 / _rage) {
          _fromX = x;
          _toX = clampD(p.x, arenaMin, arenaMax);
          b.sfx(Sfx.jump, x: x, volume: 1.0);
          b.fx.dust(x, 0, n: 14, power: 1.6);
          _set(_SK.leap);
        }
        break;
      case _SK.leap:
        const dur = 0.8;
        final t = clampD(_st / dur, 0, 1);
        x = lerpD(_fromX, _toX, t);
        y = -math.sin(t * math.pi) * 340;
        if (t >= 1 && !_did) {
          _did = true;
          y = 0;
          b.addShake(0.9);
          b.sfx(Sfx.shockwave, x: x, volume: 1.0);
          b.sfx(Sfx.boneBreak, x: x, volume: 0.8);
          b.ring(x, -3, 320, 0.6, const Color(0xFFFF4010), 9);
          b.fx.dust(x, 0, n: 20, power: 1.8);
          b.fx.debris(x, 0, n: 12, color: const Color(0xFF3A342C));
          b.projectiles.add(GroundWave(b, x, 1, speed: 600, height: 80, damage: 18, color: const Color(0xFFFF5A2A)));
          b.projectiles.add(GroundWave(b, x, -1, speed: 600, height: 80, damage: 18, color: const Color(0xFFFF5A2A)));
          if ((p.x - x).abs() < 180 && p.y > -100) p.damage(26, x, knock: 520, lift: 420);
        }
        if (_st > dur + 0.1) {
          y = 0;
          _set(_SK.recover);
        }
        break;
      case _SK.summon:
        vx = 0;
        _eyeBoost = 2;
        if (_st > 0.6 && !_did) {
          _did = true;
          _summonCd = 9;
          b.sfx(Sfx.bossRoar, x: x, volume: 0.9);
          b.sfx(Sfx.skeletonRattle, volume: 1.0);
          b.ring(x, -3, 300, 0.6, const Color(0xFFFF2020), 6);
          final n = enraged ? 3 : 2;
          for (var i = 0; i < n; i++) {
            final sx = clampD(p.x + (i.isEven ? 1 : -1) * randRange(220, 420), arenaMin, arenaMax);
            final kind = i == 2 ? EnemyKind.archer : EnemyKind.skeleton;
            b.enemies.add(Enemy(b, kind, sx, SpawnSide.ground));
          }
        }
        if (_st > 1.3) _set(_SK.recover);
        break;
      case _SK.recover:
        vx *= math.max(0, 1 - 8 * dt);
        if (_st > 0.55 / _rage) {
          _set(_SK.idle);
          _next = randRange(0.2, 0.6) / _rage;
        }
        break;
      case _SK.transform:
        _updateTransform(dt);
        break;
      case _SK.dying:
        _updateDeath(dt);
        break;
    }
    if (_state != _SK.leap) {
      x = clampD(x + vx * dt, arenaMin, arenaMax);
      if (_state != _SK.intro) y = 0;
    }
    walk += dt * (1 + vx.abs() / 80);
    _animate(dt);
    if (rng.nextDouble() < 0.4 && alpha > 0.2) {
      final hb = hurtBox;
      b.particles.spawn(px: randRange(hb.left, hb.right), py: randRange(hb.top, hb.bottom), pvy: -randRange(30, 80), plife: 1.0, psize: randRange(8, 16), pgrow: 10, pcolor: const Color(0x660B0C12));
    }
  }

  void _choose(double adx) {
    final r = rng.nextDouble();
    final aliveMinions = b.enemies.where((e) => !e.isDead).length;
    if (phase == 1 && _summonCd <= 0 && aliveMinions < 3) {
      _set(_SK.summon);
      return;
    }
    if (adx > 420) {
      if (r < 0.28) {
        _set(_SK.spikes);
      } else if (r < 0.52) {
        _count = phase == 1 ? 4 : 3;
        _set(_SK.throwBones);
      } else if (r < 0.75) {
        _set(_SK.leapTell);
      } else {
        _set(_SK.approach);
      }
    } else {
      if (r < 0.5) {
        _combo = rng.nextDouble() < 0.5 ? 2 : 3;
        _set(_SK.slashTell);
      } else if (r < 0.7) {
        _set(_SK.spikes);
      } else {
        _set(_SK.leapTell);
      }
    }
  }

  void _animate(double dt) {
    final t = rig.target;
    var rate = 14.0;
    switch (_state) {
      case _SK.approach:
        t.walk(walk, 1, run: true);
        break;
      case _SK.slashTell:
        if (_combo.isEven) {
          t.windUp(clampD(_st / 0.4, 0, 1));
        } else {
          t.sweep(0);
        }
        rate = 18;
        break;
      case _SK.slash:
        if (_combo.isEven) {
          t.slashDown(clampD(_st / 0.16, 0, 1));
        } else {
          t.sweep(clampD(_st / 0.16, 0, 1));
        }
        rate = 34;
        break;
      case _SK.throwBones:
        t.sweep((_st % 0.4) / 0.4);
        rate = 22;
        break;
      case _SK.spikes:
      case _SK.summon:
        t.windUp(1);
        t.weapon = 3.1;
        if (_st > 0.5) t.smashImpact();
        rate = 18;
        break;
      case _SK.leapTell:
        t.windUp(1);
        t.fThigh = 0.9;
        t.bShin = -1.2;
        break;
      case _SK.leap:
        if (_st < 0.6) {
          t.windUp(1);
        } else {
          t.smashImpact();
        }
        rate = 22;
        break;
      case _SK.recover:
        t.idle(b.time);
        t.torso = 0.3;
        rate = 8;
        break;
      case _SK.dying:
        if (_st < 0.7) {
          t.windUp(clampD(_st / 0.6, 0, 1));
        } else if (_st < 1.1) {
          t.slashDown(clampD((_st - 0.7) / 0.2, 0, 1));
        } else {
          t.collapsed(clampD((_st - 1.1) / 0.7, 0, 1));
          t.rot = -1.5 * easeInCubic(clampD((_st - 1.1) / 0.9, 0, 1));
        }
        rate = 14;
        break;
      default:
        t.idle(b.time);
    }
    rig.pose.blend(t, smoothK(rate, dt));
    rig.skel.compute(rig.pose, style1);
  }

  // ------------------------------------------------------------------ transform

  @override
  void startTransform() {
    _set(_SK.transform);
    vx = 0;
    y = 0;
    b.projectiles.clear();
    b.letterboxTarget = 1;
    b.sfx(Sfx.bossTransform, volume: 1.0);
    b.sfx(Sfx.skeletonRattle, volume: 1.0);
    b.showBanner('TRANSFORMATION', 'THE KING GROWS');
  }

  void _updateTransform(double dt) {
    final t = _st;
    b.addShake(dt * clampD(t / 2.0, 0, 1));
    grow = easeInOut(clampD((t - 0.6) / 1.8, 0, 1));
    if (t < 2.4) {
      for (var i = 0; i < 3; i++) {
        final a = rng.nextDouble() * math.pi * 2;
        final r = randRange(160, 320);
        b.particles.spawn(px: x + math.cos(a) * r, py: -200 + math.sin(a) * r * 0.7, pvx: -math.cos(a) * r * 1.3, pvy: -math.sin(a) * r * 0.9, plife: 0.7, psize: randRange(8, 16), pgrow: -8, pcolor: const Color(0xCC0B0C12));
      }
      if (rng.nextDouble() < 0.5) b.fx.debris(x + randRange(-80, 80), -randRange(0, 200), n: 1, color: const Color(0xFF3A342C));
      if ((t * 3).floor() != ((t - dt) * 3).floor()) b.ring(x, -200, 260, 0.5, const Color(0xFFFF2020), 4, flat: 1);
    }
    if (t >= 1.5 && !_did) {
      _did = true;
      phase = 1;
      hp = phases[1].maxHp;
    }
    if (t > 2.4 && t - dt <= 2.4) {
      b.flashWhite = 1;
      b.addShake(1);
      b.sfx(Sfx.bossRoar, volume: 1.0);
      b.fx.energy(x, -220, n: 60, color: const Color(0xFFFF3020), speed: 720);
      b.ring(x, -4, 460, 0.8, const Color(0xFFFF2020), 10);
    }
    if (t > 3.0) {
      grow = 1;
      transforming = false;
      b.letterboxTarget = 0;
      b.showBanner('THE BONE KING', 'UNBOUND');
      _summonCd = 1.5;
      _set(_SK.idle);
      _next = 0.4;
    }
  }

  // ------------------------------------------------------------------ death

  @override
  void startDeath() {
    _set(_SK.dying);
    vx = 0;
    y = 0;
    b.projectiles.clear();
    for (final e in b.enemies) {
      if (e.canBeHit) e.receiveHit(9999, e.x >= x ? 1 : -1, 200, heavy: true);
    }
    b.slowMotion(1.8, 0.45);
    b.sfx(Sfx.swordSwingHeavy, x: x, volume: 1.0);
    b.letterboxTarget = 1;
  }

  void _updateDeath(double dt) {
    final t = _st;
    if (t > 1.0 && t - dt <= 1.0) {
      b.sfx(Sfx.bossDeath, volume: 1.0);
      b.sfx(Sfx.boneBreak, volume: 1.0);
      b.addShake(0.9);
      b.fx.energy(x + facing * 160, -60, n: 40, color: const Color(0xFFFF3020), speed: 600);
    }
    if (t > 1.1 && t < 2.3) {
      flash = (t * 12).floor() % 2 == 0 ? 0.7 : 0;
      if (rng.nextDouble() < 0.7) b.fx.debris(x + randRange(-90, 90), -randRange(40, 300), n: 2, color: const Color(0xFF3A342C));
    }
    if (t > 2.0 && t - dt <= 2.0) {
      b.addShake(1);
      b.fx.dust(x - facing * 150, 0, n: 26, power: 2.2);
      b.sfx(Sfx.stoneImpact, volume: 1.0);
    }
    if (t > 2.4) {
      alpha = clampD(1 - (t - 2.4) / 2.2, 0, 1);
      if (alpha > 0) b.fx.disintegrate(Rect.fromLTRB(x - 260, -150, x + 260, 0), n: 8, glow: const Color(0xFFFF3020));
    }
    if (t > 5.2) finished = true;
  }

  // ------------------------------------------------------------------ render

  static final Paint _sh = Paint();

  @override
  void render(Canvas c) {
    if (_state == _SK.intro) {
      _sh.color = const Color(0xEE000000);
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 420, height: 34), _sh);
    }
    if (alpha <= 0.01) return;
    _sh.color = fade(const Color(0x88000000), alpha * clampD(1 + y / 500, 0.3, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 240 + grow * 60, height: 18), _sh);
    c.save();
    c.translate(x, y);
    c.scale(facing, 1);
    if (rise > 0) {
      c.clipRect(const Rect.fromLTRB(-700, -900, 700, 4));
      c.translate(0, 420 * rise);
    }
    final sc = 1 + grow * 0.3125;
    c.scale(sc, sc);
    if (rig.pose.rot != 0) c.rotate(rig.pose.rot);
    HumanoidPainter.draw(c, rig.skel, rig.pose, grow > 0.5 ? style2 : style1,
        time: b.time, alpha: alpha, flash: flash, rimDx: facing, wind: 0.5, eyeBoost: _eyeBoost);
    c.restore();
  }
}
