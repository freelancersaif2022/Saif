import 'dart:math' as math;
import 'dart:ui';

import '../../audio.dart';
import '../../core/utils.dart';
import '../../render/beasts.dart';
import '../../render/humanoid.dart';
import '../fx.dart';
import '../hazards.dart';
import '../battle.dart';
import 'boss.dart';

enum _F {
  intro,
  // Phase 1: abyss monster.
  mIdle,
  mWalk,
  mSlamTell,
  mSlam,
  mCrossTell,
  mOrbs,
  mSweepTell,
  mSweep,
  mRecover,
  // Phase 2: giant rat.
  rIdle,
  rRun,
  rPounceTell,
  rPounce,
  rDashTell,
  rDash,
  rWhipTell,
  rWhip,
  rRecover,
  // Phase 3: shadow king.
  sIdle,
  sApproach,
  sComboTell,
  sCombo,
  sWaveTell,
  sWave,
  sBlades,
  sLeapTell,
  sLeap,
  sVanish,
  sAppear,
  sSigils,
  sRecover,
  transform,
  dying,
}

/// Level 10: the multi-phase final boss.
class FinalBoss extends Boss {
  FinalBoss(Battle b) : super(b, const [
          BossPhase('ABYSS MONSTER', 1700, Color(0xFF2A8BFF)),
          BossPhase('ABYSS RAT', 1250, Color(0xFFFFC21A)),
          BossPhase('THE SHADOW KING', 1900, Color(0xFFFF2020)),
        ]) {
    x = b.cfg.length * 0.68;
    y = 0;
    facing = -1;
  }

  static const HumanoidStyle kingStyle = HumanoidStyle(
    height: 390,
    bulk: 1.32,
    weapon: WeaponType.greatsword,
    helmet: true,
    armor: true,
    hakama: true,
    cape: true,
    eyeGlow: 1.6,
    veins: Color(0xFFFF2020),
    bladeColor: Color(0xFFFFA0A0),
    bladeGlow: Color(0xFFFF1A1A),
    rimStrength: 0.65,
  );

  _F _state = _F.intro;
  double _st = 0;
  double vx = 0;
  double walk = 0;
  double armF = 0;
  double armB = 0;
  double lean = 0;
  double crouch = 0;
  double rise = 1;
  double alpha = 1;
  double formAlpha = 1;
  double _eyeBoost = 0;
  double _next = 1;
  bool _did = false;
  int _count = 0;
  double _fromX = 0;
  double _toX = 0;
  double _hopH = 0;
  double _stepT = 0;
  final Set<Object> _hitOnce = {};
  final Pose pose = Pose();
  final Pose _target = Pose();
  final Skeleton skel = Skeleton();

  @override
  int get scoreValue => 20000;

  @override
  Rect get hurtBox {
    switch (phase) {
      case 0:
        return sideRect(120, 175, -390, 0).translate(0, y);
      case 1:
        return sideRect(160, 240, -195 + crouch * 30, 0).translate(0, y);
      default:
        return Rect.fromLTRB(x - 70, y - 380, x + 70, y);
    }
  }

  @override
  bool get vulnerable => _state != _F.sVanish && formAlpha > 0.5;

  double get _rage => enraged ? 1.25 : 1.0;

  void _set(_F s) {
    _state = s;
    _st = 0;
    _did = false;
  }

  @override
  void update(double dt) {
    _st += dt;
    flash = math.max(0, flash - dt * 5);
    _eyeBoost = math.max(0, _eyeBoost - dt * 2);
    final p = b.player;
    final adx = (p.x - x).abs();

    switch (_state) {
      case _F.intro:
        _updateIntro(dt);
        break;
      case _F.transform:
        _updateTransform(dt);
        break;
      case _F.dying:
        _updateDeath(dt);
        break;
      default:
        if (phase == 0) {
          _monster(dt, adx);
        } else if (phase == 1) {
          _rat(dt, adx);
        } else {
          _king(dt, adx);
        }
    }
    x = clampD(x, arenaMin - 40, arenaMax + 40);
    _animateKing(dt);
    // Ambient smoke.
    if (formAlpha > 0.2 && rng.nextDouble() < 0.5) {
      final hb = hurtBox;
      b.particles.spawn(px: randRange(hb.left, hb.right), py: randRange(hb.top, hb.bottom), pvx: randRange(-20, 20), pvy: -randRange(30, 90), plife: randRange(0.7, 1.3), psize: randRange(8, 18), pgrow: 12, pcolor: const Color(0x770B0C12));
    }
  }

  // ------------------------------------------------------------------ intro

  void _updateIntro(double dt) {
    if (!_did) {
      _did = true;
      b.sfx(Sfx.bossEntrance, volume: 1.0);
    }
    rise = clampD(1 - _st / 2.6, 0, 1);
    b.addShake(dt * 0.5);
    for (var i = 0; i < 3; i++) {
      b.particles.spawn(px: x + randRange(-200, 200), py: -randRange(0, 30), pvx: randRange(-30, 30), pvy: -randRange(60, 220), plife: randRange(0.8, 1.4), psize: randRange(10, 22), pgrow: 14, pcolor: const Color(0xAA0B0C12));
    }
    if (_st > 2.7 && _st - dt <= 2.7) {
      b.sfx(Sfx.bossRoar, volume: 1.0);
      b.addShake(0.7);
      b.ring(x, -200, 360, 0.8, const Color(0xFF2A8BFF), 8, flat: 1);
    }
    if (_st > 3.4) {
      rise = 0;
      introDone = true;
      b.showBanner('ABYSS MONSTER', 'THE FIRST FORM');
      _set(_F.mIdle);
      _next = 0.6;
    }
  }

  // ------------------------------------------------------------------ phase 1

  void _monster(double dt, double adx) {
    final p = b.player;
    switch (_state) {
      case _F.mIdle:
        vx = 0;
        faceTarget();
        armF += (0 - armF) * smoothK(6, dt);
        armB += (0 - armB) * smoothK(6, dt);
        if (_st > _next) {
          final r = rng.nextDouble();
          if (adx < 380) {
            if (r < 0.4) {
              _set(_F.mSlamTell);
            } else if (r < 0.7) {
              _set(_F.mSweepTell);
            } else {
              _set(_F.mCrossTell);
            }
          } else {
            if (r < 0.35) {
              _set(_F.mCrossTell);
            } else if (r < 0.65) {
              _set(_F.mOrbs);
              _count = enraged ? 5 : 3;
            } else {
              _set(_F.mWalk);
              _next = randRange(1.0, 1.8);
            }
          }
        }
        break;
      case _F.mWalk:
        faceTarget();
        vx = facing * 130 * _rage;
        walk += dt * 2.6;
        _heavySteps(dt, 0.55);
        if (_st > _next || adx < 320) {
          _set(_F.mIdle);
          _next = 0.2;
        }
        break;
      case _F.mSlamTell:
        vx = 0;
        faceTarget();
        armF += (1 - armF) * smoothK(7, dt);
        lean += (-0.3 - lean) * smoothK(6, dt);
        _eyeBoost = 1.4;
        if (_st > 0.75 / _rage) {
          b.sfx(Sfx.monsterAttack, x: x, volume: 1.0);
          _set(_F.mSlam);
        }
        break;
      case _F.mSlam:
        armF += (-0.15 - armF) * smoothK(22, dt);
        lean += (0.6 - lean) * smoothK(18, dt);
        if (_st > 0.16 && !_did) {
          _did = true;
          final hx = x + facing * 250;
          b.addShake(0.8);
          b.fx.dust(hx, 0, n: 18, power: 1.6);
          b.fx.debris(hx, 0, n: 12);
          b.ring(hx, -3, 230, 0.5, const Color(0xFF2A8BFF), 8);
          b.sfx(Sfx.shockwave, x: hx, volume: 0.9);
          if ((p.x - hx).abs() < 170 && p.y > -120) p.damage(26, hx, knock: 520, lift: 420);
          b.projectiles.add(GroundWave(b, hx, facing, speed: 600, height: 70, damage: 16, color: const Color(0xFF2A8BFF)));
          if (enraged) b.projectiles.add(GroundWave(b, hx, -facing, speed: 520, height: 70, damage: 16, color: const Color(0xFF2A8BFF)));
        }
        if (_st > 0.5) _set(_F.mRecover);
        break;
      case _F.mCrossTell:
        vx = 0;
        armF += (1 - armF) * smoothK(5, dt);
        armB += (1 - armB) * smoothK(5, dt);
        _eyeBoost = 2;
        if (_st > 0.55 && !_did) {
          _did = true;
          b.sfx(Sfx.bossSpecial, x: x, volume: 1.0);
          b.projectiles.add(CrossSigil(b, clampD(p.x, arenaMin, arenaMax), delay: 0.9 / _rage, damage: 24));
          if (enraged) {
            b.projectiles.add(CrossSigil(b, clampD(p.x + 330, arenaMin, arenaMax), delay: 1.25, damage: 22));
            b.projectiles.add(CrossSigil(b, clampD(p.x - 330, arenaMin, arenaMax), delay: 1.25, damage: 22));
          }
        }
        if (_st > 1.4) _set(_F.mRecover);
        break;
      case _F.mOrbs:
        vx = 0;
        faceTarget();
        final cycle = _st % 0.45;
        armF = cycle < 0.25 ? cycle / 0.25 : 1 - (cycle - 0.25) / 0.2;
        if (cycle - dt < 0.25 && cycle >= 0.25 && _count > 0) {
          _count--;
          final hand = BeastPainter.monsterHand(1, lean, b.time);
          final hx = x + hand.dx * facing;
          final hy = hand.dy;
          final tx = p.x + randRange(-140, 140);
          const t = 1.0;
          final ovx = (tx - hx) / t;
          final ovy = (0 - hy - 0.5 * 1100 * t * t) / t;
          b.projectiles.add(ShadowOrb(b, hx, hy, ovx, ovy, damage: 16));
          b.sfx(Sfx.bossSpecial, x: x, volume: 0.5, gap: 120);
        }
        if (_count <= 0 && _st > 0.6) _set(_F.mRecover);
        break;
      case _F.mSweepTell:
        vx = 0;
        faceTarget();
        armF += (-0.6 - armF) * smoothK(8, dt);
        lean += (-0.2 - lean) * smoothK(6, dt);
        _eyeBoost = 1.2;
        if (_st > 0.55 / _rage) {
          _hitOnce.clear();
          b.sfx(Sfx.bossAttack, x: x, volume: 1.0);
          _set(_F.mSweep);
        }
        break;
      case _F.mSweep:
        armF += (0.55 - armF) * smoothK(20, dt);
        lean += (0.4 - lean) * smoothK(14, dt);
        if (_st < 0.3 && !_hitOnce.contains(p)) {
          if (contact(sideRect(-20, 360, -100, 0), 22, knock: 500, lift: 360)) _hitOnce.add(p);
        }
        if (_st > 0.12 && rng.nextDouble() < 0.8) b.fx.dust(x + facing * randRange(100, 340), 0, n: 2, power: 1.0);
        if (_st > 0.45) _set(_F.mRecover);
        break;
      case _F.mRecover:
        lean += (0 - lean) * smoothK(4, dt);
        armF += (0 - armF) * smoothK(4, dt);
        armB += (0 - armB) * smoothK(4, dt);
        if (_st > 0.7 / _rage) {
          _set(_F.mIdle);
          _next = randRange(0.3, 0.8) / _rage;
        }
        break;
      default:
        break;
    }
    x += vx * dt;
  }

  void _heavySteps(double dt, double interval) {
    _stepT -= dt;
    if (_stepT <= 0) {
      _stepT = interval;
      b.sfx(Sfx.elephantStomp, x: x, volume: 0.4, gap: 120);
      b.addShake(0.15);
    }
  }

  // ------------------------------------------------------------------ phase 2

  void _rat(double dt, double adx) {
    final p = b.player;
    switch (_state) {
      case _F.rIdle:
        vx *= 0.7;
        crouch += (0 - crouch) * smoothK(8, dt);
        faceTarget();
        if (_st > _next) {
          final r = rng.nextDouble();
          if (adx > 500) {
            if (r < 0.45) {
              _set(_F.rDashTell);
            } else if (r < 0.8) {
              _set(_F.rPounceTell);
            } else {
              _set(_F.rRun);
            }
          } else {
            if (r < 0.35) {
              _set(_F.rWhipTell);
            } else if (r < 0.7) {
              _set(_F.rPounceTell);
            } else {
              _set(_F.rDashTell);
            }
          }
        }
        break;
      case _F.rRun:
        faceTarget();
        vx = facing * 420 * _rage;
        walk += dt * 14;
        if (adx < 300 || _st > 1.2) {
          _set(_F.rIdle);
          _next = 0.1;
        }
        break;
      case _F.rPounceTell:
        vx *= 0.6;
        faceTarget();
        crouch += (1 - crouch) * smoothK(10, dt);
        _eyeBoost = 1.4;
        if (_st > 0.36 / _rage) {
          _fromX = x;
          _toX = clampD(p.x + p.vx * 0.25, arenaMin, arenaMax);
          _hopH = 280;
          b.sfx(Sfx.ratScreech, x: x, volume: 0.9);
          _hitOnce.clear();
          _set(_F.rPounce);
        }
        break;
      case _F.rPounce:
        const dur = 0.62;
        final t = clampD(_st / dur, 0, 1);
        crouch = 0;
        x = lerpD(_fromX, _toX, t);
        y = -math.sin(t * math.pi) * _hopH;
        walk += dt * 6;
        if (!_hitOnce.contains(p) && contact(hurtBox.deflate(20), 18, knock: 460, lift: 360)) _hitOnce.add(p);
        if (t >= 1 && !_did) {
          _did = true;
          y = 0;
          b.addShake(0.55);
          b.fx.dust(x, 0, n: 16, power: 1.5);
          b.ring(x, -3, 180, 0.4, const Color(0xFFFFC21A), 6);
          b.sfx(Sfx.stoneImpact, x: x, volume: 0.9);
          if ((p.x - x).abs() < 150 && p.y > -80) p.damage(18, x, knock: 420, lift: 380);
        }
        if (_st > dur + 0.05) {
          y = 0;
          _set(_F.rRecover);
        }
        break;
      case _F.rDashTell:
        vx *= 0.6;
        faceTarget();
        crouch += (0.6 - crouch) * smoothK(10, dt);
        _eyeBoost = 1.6;
        if (_st > 0.32 / _rage) {
          _hitOnce.clear();
          b.sfx(Sfx.ratScreech, x: x, volume: 0.8);
          b.sfx(Sfx.elephantCharge, x: x, volume: 0.5);
          _set(_F.rDash);
        }
        break;
      case _F.rDash:
        crouch = 0.3;
        vx = facing * 1050 * _rage;
        walk += dt * 22;
        if (rng.nextDouble() < 0.8) b.fx.dust(x - facing * 150, 0, n: 2, power: 1.0);
        if (!_hitOnce.contains(p) && contact(hurtBox.deflate(10), 18, knock: 520, lift: 360)) _hitOnce.add(p);
        if (_st > 0.55 || x <= arenaMin || x >= arenaMax) _set(_F.rRecover);
        break;
      case _F.rWhipTell:
        vx *= 0.6;
        faceTarget();
        crouch += (0.5 - crouch) * smoothK(10, dt);
        if (_st > 0.32 / _rage) {
          _hitOnce.clear();
          b.sfx(Sfx.bossAttack, x: x, volume: 0.9);
          _set(_F.rWhip);
        }
        break;
      case _F.rWhip:
        // Spin: flip facing quickly and sweep the tail around.
        if ((_st * 10).floor() % 2 == 0) {
          facing = 1;
        } else {
          facing = -1;
        }
        if (!_hitOnce.contains(p) && contact(Rect.fromLTRB(x - 300, -130, x + 300, 0), 16, knock: 460, lift: 400)) _hitOnce.add(p);
        if (rng.nextDouble() < 0.9) b.fx.dust(x + randRange(-280, 280), 0, n: 1, power: 1);
        if (_st > 0.42) {
          faceTarget();
          _set(_F.rRecover);
        }
        break;
      case _F.rRecover:
        vx *= 0.7;
        crouch += (0 - crouch) * smoothK(6, dt);
        if (_st > 0.42 / _rage) {
          _set(_F.rIdle);
          _next = randRange(0.15, 0.45) / _rage;
        }
        break;
      default:
        break;
    }
    if (_state != _F.rPounce) {
      x += vx * dt;
      y = 0;
      walk += dt * vx.abs() / 60;
    }
  }

  // ------------------------------------------------------------------ phase 3

  void _king(double dt, double adx) {
    final p = b.player;
    switch (_state) {
      case _F.sIdle:
        vx *= 0.8;
        faceTarget();
        if (_st > _next) {
          final r = rng.nextDouble();
          if (adx > 420) {
            if (r < 0.22) {
              _set(_F.sWaveTell);
            } else if (r < 0.44) {
              _set(_F.sBlades);
              _count = enraged ? 5 : 3;
            } else if (r < 0.62) {
              _set(_F.sLeapTell);
            } else if (r < 0.78) {
              _set(_F.sVanish);
            } else if (r < 0.9) {
              _set(_F.sSigils);
            } else {
              _set(_F.sApproach);
            }
          } else {
            if (r < 0.45) {
              _count = rng.nextDouble() < 0.5 ? 2 : 3;
              _set(_F.sComboTell);
            } else if (r < 0.65) {
              _set(_F.sWaveTell);
            } else if (r < 0.82) {
              _set(_F.sLeapTell);
            } else {
              _set(_F.sVanish);
            }
          }
        }
        break;
      case _F.sApproach:
        faceTarget();
        vx = facing * 300 * _rage;
        walk += dt * 6;
        if (adx < 280 || _st > 1.2) {
          _count = 2;
          _set(_F.sComboTell);
        }
        break;
      case _F.sComboTell:
        vx *= 0.8;
        faceTarget();
        _eyeBoost = 1.2;
        if (_st > randRange(0.26, 0.4) / _rage) {
          _hitOnce.clear();
          vx = facing * 420;
          b.sfx(Sfx.bossAttack, x: x, volume: 0.95);
          _set(_F.sCombo);
        }
        break;
      case _F.sCombo:
        vx *= math.max(0, 1 - 6 * dt);
        if (_st > 0.05 && _st < 0.22 && !_hitOnce.contains(p)) {
          if (contact(sideRect(-10, 300, -400, 0), 20, knock: 480, lift: 340)) _hitOnce.add(p);
        }
        if (_st > 0.36) {
          _count--;
          if (_count > 0) {
            _set(_F.sComboTell);
            _st = 0.14;
          } else {
            _set(_F.sRecover);
          }
        }
        break;
      case _F.sWaveTell:
        vx *= 0.7;
        faceTarget();
        _eyeBoost = 1.8;
        if (_st > 0.45 / _rage) {
          _set(_F.sWave);
          b.sfx(Sfx.bossSpecial, x: x, volume: 1.0);
        }
        break;
      case _F.sWave:
        if (_st > 0.1 && !_did) {
          _did = true;
          b.addShake(0.5);
          b.projectiles.add(GroundWave(b, x + facing * 120, facing, speed: 700, height: 95, damage: 20, color: const Color(0xFFFF2A3A)));
          if (enraged) {
            b.projectiles.add(GroundWave(b, x - facing * 120, -facing, speed: 640, height: 95, damage: 20, color: const Color(0xFFFF2A3A)));
          }
          b.fx.energy(x + facing * 140, -40, n: 24, color: const Color(0xFFFF2A3A), speed: 400);
        }
        if (_st > 0.5) _set(_F.sRecover);
        break;
      case _F.sBlades:
        vx *= 0.8;
        faceTarget();
        final cycle = _st % 0.42;
        if (cycle - dt < 0.2 && cycle >= 0.2 && _count > 0) {
          _count--;
          final high = rng.nextBool();
          b.projectiles.add(CrossBlade(b, x + facing * 100, high ? -205 : -42, facing, speed: randRange(520, 640) * _rage, damage: 18));
          b.sfx(Sfx.monsterCross, x: x, volume: 0.6, gap: 120);
        }
        if (_count <= 0 && _st > 0.5) _set(_F.sRecover);
        break;
      case _F.sLeapTell:
        vx *= 0.7;
        faceTarget();
        if (_st > 0.38 / _rage) {
          _fromX = x;
          _toX = clampD(p.x, arenaMin, arenaMax);
          b.sfx(Sfx.jump, x: x, volume: 1.0);
          b.fx.dust(x, 0, n: 14, power: 1.5);
          _set(_F.sLeap);
        }
        break;
      case _F.sLeap:
        const dur = 0.74;
        final t = clampD(_st / dur, 0, 1);
        x = lerpD(_fromX, _toX, t);
        y = -math.sin(t * math.pi) * 360;
        if (t >= 1 && !_did) {
          _did = true;
          y = 0;
          b.addShake(0.85);
          b.sfx(Sfx.shockwave, x: x, volume: 1.0);
          b.sfx(Sfx.elephantStomp, x: x, volume: 0.8);
          b.ring(x, -3, 300, 0.6, const Color(0xFFFF2020), 9);
          b.fx.dust(x, 0, n: 20, power: 1.8);
          b.fx.debris(x, 0, n: 12);
          b.projectiles.add(GroundWave(b, x, 1, speed: 620, height: 80, damage: 18, color: const Color(0xFFFF2A3A)));
          b.projectiles.add(GroundWave(b, x, -1, speed: 620, height: 80, damage: 18, color: const Color(0xFFFF2A3A)));
          if ((p.x - x).abs() < 180 && p.y > -100) p.damage(26, x, knock: 520, lift: 420);
        }
        if (_st > dur + 0.1) {
          y = 0;
          _set(_F.sRecover);
        }
        break;
      case _F.sVanish:
        vx = 0;
        formAlpha = clampD(1 - _st / 0.3, 0, 1);
        if (!_did) {
          _did = true;
          b.fx.shadowBurst(x, -200, n: 24, spread: 1.6);
          b.sfx(Sfx.splashShadowForm, x: x, volume: 0.5, gap: 300);
        }
        if (_st > 0.55) {
          final side = rng.nextBool() ? 1.0 : -1.0;
          x = clampD(p.x + side * 230, arenaMin, arenaMax);
          faceTarget();
          b.fx.shadowBurst(x, -200, n: 24, spread: 1.6);
          _set(_F.sAppear);
        }
        break;
      case _F.sAppear:
        formAlpha = clampD(_st / 0.2, 0, 1);
        faceTarget();
        if (_st > 0.25) {
          _count = 1;
          _set(_F.sComboTell);
          _st = 0.1;
        }
        break;
      case _F.sSigils:
        vx = 0;
        _eyeBoost = 2;
        if (!_did && _st > 0.35) {
          _did = true;
          b.sfx(Sfx.bossSpecial, x: x, volume: 1.0);
          final n = enraged ? 4 : 3;
          for (var i = 0; i < n; i++) {
            final tx = clampD(p.x + (i - (n - 1) / 2) * 280, arenaMin, arenaMax);
            b.projectiles.add(CrossSigil(b, tx, delay: 0.8 + i * 0.22, damage: 22));
          }
        }
        if (_st > 1.2) _set(_F.sRecover);
        break;
      case _F.sRecover:
        vx *= math.max(0, 1 - 8 * dt);
        if (_st > 0.5 / _rage) {
          _set(_F.sIdle);
          _next = randRange(0.15, 0.6) / _rage;
        }
        break;
      default:
        break;
    }
    if (_state != _F.sLeap) {
      x += vx * dt;
      y = 0;
    }
    walk += dt * (2 + vx.abs() / 60);
  }

  void _animateKing(double dt) {
    if (phase != 2 && !(_state == _F.transform && phase == 1)) return;
    var rate = 14.0;
    switch (_state) {
      case _F.sApproach:
        _target.walk(walk, 1, run: true);
        break;
      case _F.sComboTell:
        if (_count.isEven) {
          _target.windUp(clampD(_st / 0.3, 0, 1));
        } else {
          _target.slashUp(0);
        }
        rate = 18;
        break;
      case _F.sCombo:
        final k = clampD(_st / 0.14, 0, 1);
        if (_count.isEven) {
          _target.slashDown(k);
        } else {
          _target.slashUp(k);
        }
        rate = 36;
        break;
      case _F.sWaveTell:
        _target.windUp(clampD(_st / 0.4, 0, 1));
        break;
      case _F.sWave:
        _target.slashDown(clampD(_st / 0.12, 0, 1));
        rate = 34;
        break;
      case _F.sBlades:
        final c = (_st % 0.42) / 0.42;
        _target.sweep(c);
        rate = 22;
        break;
      case _F.sLeapTell:
        _target.windUp(1);
        _target.fThigh = 0.9;
        _target.bShin = -1.2;
        break;
      case _F.sLeap:
        if (_st < 0.55) {
          _target.windUp(1);
        } else {
          _target.smashImpact();
        }
        rate = 22;
        break;
      case _F.sSigils:
        _target.windUp(1);
        _target.weapon = 3.1;
        break;
      case _F.sRecover:
        _target.idle(b.time);
        _target.torso = 0.28;
        rate = 8;
        break;
      case _F.dying:
        if (_st < 0.7) {
          _target.windUp(clampD(_st / 0.6, 0, 1));
        } else if (_st < 1.2) {
          _target.slashDown(clampD((_st - 0.7) / 0.2, 0, 1));
        } else if (_st < 2.2) {
          _target.hurt();
          _target.fThigh = 1.3;
          _target.fShin = -0.4;
        } else {
          _target.collapsed(clampD((_st - 2.2) / 0.6, 0, 1));
          _target.rot = -1.5 * easeInCubic(clampD((_st - 2.2) / 0.8, 0, 1));
        }
        rate = 14;
        break;
      default:
        _target.idle(b.time);
    }
    pose.blend(_target, smoothK(rate, dt));
    skel.compute(pose, kingStyle);
  }

  // ------------------------------------------------------------------ transform

  int _formFrom = 0;

  @override
  void startTransform() {
    _formFrom = phase;
    _set(_F.transform);
    vx = 0;
    y = 0;
    crouch = 0;
    b.projectiles.clear();
    b.letterboxTarget = 1;
    b.sfx(Sfx.bossTransform, volume: 1.0);
    b.sfx(Sfx.bossRoar, volume: 0.9);
    b.showBanner('TRANSFORMATION', _formFrom == 0 ? 'THE ABYSS SHIFTS' : 'THE KING RISES');
    pose.idle(0);
  }

  void _updateTransform(double dt) {
    final t = _st;
    b.addShake(dt * clampD(t / 2.0, 0, 1));
    formAlpha = t < 1.6 ? clampD(1 - (t - 0.4) / 1.2, 0, 1) : clampD((t - 2.0) / 0.9, 0, 1);
    final color = _formFrom == 0 ? const Color(0xFFFFC21A) : const Color(0xFFFF2020);
    if (t < 2.4) {
      for (var i = 0; i < 4; i++) {
        final a = rng.nextDouble() * math.pi * 2;
        final r = randRange(160, 340);
        b.particles.spawn(px: x + math.cos(a) * r, py: -170 + math.sin(a) * r * 0.7, pvx: -math.cos(a) * r * 1.3, pvy: -math.sin(a) * r * 0.9, plife: 0.75, psize: randRange(8, 18), pgrow: -8, pcolor: const Color(0xCC0B0C12));
      }
      if (rng.nextDouble() < 0.5) b.fx.energy(x, -170, n: 3, color: color, speed: 260);
      if ((t * 3).floor() != ((t - dt) * 3).floor()) b.ring(x, -170, 240, 0.5, color, 4, flat: 1);
    }
    if (t >= 1.6 && !_did) {
      _did = true;
      phase = _formFrom + 1;
      hp = phases[phase].maxHp;
    }
    if (t > 2.4 && t - dt <= 2.4) {
      b.flashWhite = 1;
      b.addShake(1);
      b.sfx(phase == 1 ? Sfx.ratScreech : Sfx.bossRoar, volume: 1.0);
      b.fx.energy(x, -170, n: 60, color: color, speed: 720);
      b.ring(x, -4, 440, 0.8, color, 10);
    }
    if (t > 3.1) {
      transforming = false;
      formAlpha = 1;
      b.letterboxTarget = 0;
      if (phase == 1) {
        b.showBanner('ABYSS RAT', 'THE SECOND FORM');
        _set(_F.rIdle);
      } else {
        b.showBanner('THE SHADOW KING', 'THE FINAL FORM');
        _set(_F.sIdle);
      }
      _next = 0.4;
    }
  }

  // ------------------------------------------------------------------ death

  @override
  void startDeath() {
    _set(_F.dying);
    vx = 0;
    y = 0;
    b.projectiles.clear();
    b.slowMotion(2.2, 0.45);
    b.sfx(Sfx.bossSpecial, x: x, volume: 1.0);
    b.letterboxTarget = 1;
  }

  void _updateDeath(double dt) {
    final t = _st;
    if (t > 1.0 && t - dt <= 1.0) {
      // Final dramatic strike.
      b.addShake(0.9);
      b.flashWhite = 0.6;
      b.ring(x + facing * 200, -4, 420, 0.7, const Color(0xFFFF2020), 10);
      b.fx.energy(x + facing * 200, -60, n: 50, color: const Color(0xFFFF2020), speed: 650);
      b.sfx(Sfx.monsterAttack, volume: 1.0);
    }
    if (t > 1.2 && t - dt <= 1.2) {
      b.sfx(Sfx.bossDeath, volume: 1.0);
    }
    if (t > 1.2 && t < 2.6) {
      flash = (t * 12).floor() % 2 == 0 ? 0.8 : 0;
      if (rng.nextDouble() < 0.7) b.fx.shadowBurst(x + randRange(-80, 80), randRange(-360, -40), n: 4, spread: 1.2);
    }
    if (t > 3.0 && t - dt <= 3.0) {
      b.addShake(1);
      b.flashWhite = 1;
      b.ring(x, -100, 600, 1.0, const Color(0xFFFF2020), 14, flat: 1);
      b.ring(x, -4, 700, 1.1, const Color(0xFFB09CFF), 10);
      b.fx.energy(x, -150, n: 140, color: const Color(0xFFFF4040), speed: 900);
      b.fx.energy(x, -150, n: 60, color: const Color(0xFFB09CFF), speed: 600);
      b.sfx(Sfx.bombExplode, volume: 1.0);
    }
    if (t > 3.0) {
      formAlpha = clampD(1 - (t - 3.0) / 2.4, 0, 1);
      if (formAlpha > 0) {
        b.fx.disintegrate(Rect.fromLTRB(x - 230, -140, x + 230, 0), n: 9, glow: const Color(0xFFFF3030));
        for (var i = 0; i < 3; i++) {
          b.particles.spawn(px: x + randRange(-200, 200), py: -randRange(0, 120), pvx: randRange(-20, 20), pvy: -randRange(120, 260), plife: randRange(1.4, 2.4), psize: randRange(2, 4), pcolor: const Color(0xFFFF5050), pkind: PKind.ember);
        }
      }
    }
    if (t > 6.0) finished = true;
  }

  // ------------------------------------------------------------------ render

  static final Paint _sh = Paint();

  @override
  void render(Canvas c) {
    final a = alpha * formAlpha;
    if (_state == _F.intro) {
      // Shadow pool the monster rises from.
      _sh.color = const Color(0xEE000000);
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 520, height: 40), _sh);
    }
    if (a <= 0.01) return;
    _sh.color = fade(const Color(0x88000000), a * clampD(1 + y / 500, 0.3, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: phase == 1 ? 480 : 300, height: 18), _sh);
    c.save();
    c.translate(x, y);
    c.scale(facing, 1);
    final showPhase = _state == _F.transform ? (_st < 1.6 ? _formFrom : _formFrom + 1) : phase;
    switch (showPhase) {
      case 0:
        if (rise > 0) {
          c.clipRect(const Rect.fromLTRB(-600, -900, 600, 4));
          c.translate(0, 420 * rise);
        }
        BeastPainter.monster(c, k: 1.0, walk: walk, alpha: a, flash: flash, eyeGlow: 1 + _eyeBoost, armF: armF, armB: armB, lean: lean, rimDx: facing, time: b.time);
        break;
      case 1:
        BeastPainter.rat(c, k: 1.2, run: walk, alpha: a, flash: flash, eyeGlow: 1 + _eyeBoost, crouch: crouch, rimDx: facing, time: b.time);
        break;
      default:
        if (_state == _F.transform) {
          final s = 0.6 + 0.4 * formAlpha;
          c.scale(s, s);
        }
        if (pose.rot != 0) c.rotate(pose.rot);
        HumanoidPainter.draw(c, skel, pose, kingStyle, time: b.time, alpha: a, flash: flash, rimDx: facing, wind: 0.5, eyeBoost: _eyeBoost);
    }
    c.restore();
  }
}
