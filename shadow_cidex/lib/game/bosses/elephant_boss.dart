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

enum _EL {
  intro,
  idle,
  walk,
  chargeTell,
  charge,
  stunned,
  stompTell,
  stomp,
  headbutt,
  transform,
  wIdle,
  wApproach,
  wSlashTell,
  wSlash,
  wLeapTell,
  wLeap,
  wDashTell,
  wDash,
  wRecover,
  dying,
}

/// Level 8: the Titan Elephant, which transforms into a giant shadow warrior.
class ElephantBoss extends Boss {
  ElephantBoss(Battle b) : super(b, const [
          BossPhase('TITAN ELEPHANT', 1500, Color(0xFFFFC21A)),
          BossPhase('TITAN WARLORD', 1250, Color(0xFFFF2A2A)),
        ]) {
    x = b.cfg.length * 0.66 + 760;
    facing = -1;
  }

  static const double k = 1.05;
  static const HumanoidStyle warriorStyle = HumanoidStyle(
    height: 330,
    bulk: 1.55,
    weapon: WeaponType.axe,
    horns: true,
    armor: true,
    hakama: true,
    cape: true,
    eyeGlow: 1.4,
    veins: Color(0xFFFF4010),
    bladeColor: Color(0xFFB08080),
    bladeGlow: Color(0xFFB01010),
  );

  _EL _state = _EL.intro;
  double _st = 0;
  double vx = 0;
  double vy = 0;
  double walk = 0;
  double rear = 0;
  double trunk = 0;
  double alpha = 1;
  double warriorAlpha = 0;
  double _stepT = 0;
  double _nextDur = 1;
  bool _did = false;
  int _combo = 0;
  double _leapFrom = 0;
  double _leapTo = 0;
  double _eyeBoost = 0;
  final Pose pose = Pose();
  final Pose _target = Pose();
  final Skeleton skel = Skeleton();
  final Set<Object> _hitOnce = {};

  bool get isWarrior => phase == 1 || (_state == _EL.transform && _st > 1.6);

  @override
  int get scoreValue => 10000;

  @override
  double get focusX => _state == _EL.intro ? b.cfg.length * 0.6 : x;

  @override
  Rect get hurtBox {
    if (isWarrior) return Rect.fromLTRB(x - 62, y - 320, x + 62, y);
    return sideRect(190 * k, 245 * k, -265 * k, 0);
  }

  void _set(_EL s) {
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
    final dx = p.x - x;
    final adx = dx.abs();
    final rageMul = enraged ? 1.2 : 1.0;

    switch (_state) {
      case _EL.intro:
        vx = -260;
        x += vx * dt;
        walk += dt * 4.2;
        _footsteps(dt, 0.42, 0.25);
        if (x <= b.cfg.length * 0.66) {
          x = b.cfg.length * 0.66;
          vx = 0;
          if (!_did) {
            _did = true;
            b.sfx(Sfx.elephantTrumpet, volume: 1.0);
            b.sfx(Sfx.bossEntrance, volume: 0.8);
            b.addShake(0.5);
          }
          rear = math.min(1, rear + dt * 2);
          if (_st > 0.1 && rear >= 1) {
            introDone = true;
            b.showBanner('TITAN ELEPHANT', 'THE EARTHSHAKER');
            _set(_EL.idle);
            _nextDur = 0.8;
          }
        }
        break;
      case _EL.idle:
        rear = math.max(0, rear - dt * 3);
        vx = 0;
        faceTarget();
        if (_st > _nextDur) _chooseElephant(adx);
        break;
      case _EL.walk:
        faceTarget();
        vx = facing * 150 * rageMul;
        x += vx * dt;
        walk += dt * 3.0 * rageMul;
        _footsteps(dt, 0.5, 0.18);
        _pushPlayer();
        if (_st > _nextDur || adx < 260) {
          _set(_EL.idle);
          _nextDur = randRange(0.2, 0.5);
        }
        break;
      case _EL.chargeTell:
        faceTarget();
        rear = math.min(0.35, rear + dt * 2);
        walk += dt * 1.5;
        _eyeBoost = 1.5;
        if (!_did) {
          _did = true;
          b.sfx(Sfx.elephantTrumpet, x: x, volume: 0.9);
        }
        if (rng.nextDouble() < 0.5) b.fx.dust(x - facing * 120, 0, n: 2, power: 0.8);
        if (_st > 0.95 / rageMul) {
          rear = 0;
          _hitOnce.clear();
          b.sfx(Sfx.elephantCharge, x: x, volume: 1.0);
          _set(_EL.charge);
        }
        break;
      case _EL.charge:
        vx = facing * 800 * rageMul;
        x += vx * dt;
        walk += dt * 9;
        _footsteps(dt, 0.2, 0.12);
        if (rng.nextDouble() < 0.8) b.fx.dust(x - facing * 150, 0, n: 2, power: 1.2);
        if (!_hitOnce.contains(p)) {
          final body = sideRect(160 * k, 260 * k, -215 * k, 0);
          if (contact(body, 26, knock: 640, lift: 520)) _hitOnce.add(p);
        }
        if (x < arenaMin + 60 || x > arenaMax - 60) {
          x = clampD(x, arenaMin + 60, arenaMax - 60);
          b.addShake(0.75);
          b.fx.debris(x + facing * 220, 0, n: 16);
          b.fx.dust(x + facing * 220, 0, n: 16, power: 1.6);
          b.sfx(Sfx.stoneImpact, x: x, volume: 1.0);
          b.sfx(Sfx.elephantStomp, x: x, volume: 0.8);
          b.ring(x + facing * 230, -120, 160, 0.5, const Color(0xFFFFC21A), 6, flat: 1);
          _set(_EL.stunned);
        }
        break;
      case _EL.stunned:
        vx = 0;
        trunk = math.sin(_st * 6) * 0.3;
        if (rng.nextDouble() < 0.3) {
          b.particles.spawn(px: x + facing * 190 + randRange(-30, 30), py: -300 + randRange(-20, 20), pvy: -30, plife: 0.6, psize: 3, pcolor: const Color(0xFFFFE08A), pkind: PKind.glow);
        }
        if (_st > 1.7) {
          trunk = 0;
          _set(_EL.idle);
          _nextDur = 0.3;
        }
        break;
      case _EL.stompTell:
        faceTarget();
        rear = math.min(1, rear + dt * 2.2 * rageMul);
        trunk = rear * 0.8;
        _eyeBoost = 1.2;
        if (_st > 0.7 / rageMul) _set(_EL.stomp);
        break;
      case _EL.stomp:
        rear = math.max(0, rear - dt * 9);
        trunk = rear * 0.8;
        if (rear <= 0.05 && !_did) {
          _did = true;
          _stompImpact(x + facing * 150, 1.0);
        }
        if (_st > 0.8) {
          _set(_EL.idle);
          _nextDur = randRange(0.5, 1.0) / rageMul;
        }
        break;
      case _EL.headbutt:
        if (_st < 0.3) {
          vx = -facing * 60;
          trunk = -0.3;
        } else if (_st < 0.62) {
          vx = facing * 760;
          trunk = 0.6;
          if (!_did) {
            _did = true;
            b.sfx(Sfx.bossAttack, x: x, volume: 0.9);
          }
          if (!_hitOnce.contains(p)) {
            if (contact(sideRect(-60 * k, 300 * k, -230 * k, 0), 22, knock: 560, lift: 380)) _hitOnce.add(p);
          }
        } else {
          vx *= 0.85;
          trunk *= 0.9;
        }
        x = clampD(x + vx * dt, arenaMin + 40, arenaMax - 40);
        walk += dt * 4;
        if (_st > 1.0) {
          _set(_EL.idle);
          _nextDur = randRange(0.4, 0.9) / rageMul;
        }
        break;
      case _EL.transform:
        _updateTransform(dt);
        break;
      case _EL.wIdle:
      case _EL.wApproach:
      case _EL.wSlashTell:
      case _EL.wSlash:
      case _EL.wLeapTell:
      case _EL.wLeap:
      case _EL.wDashTell:
      case _EL.wDash:
      case _EL.wRecover:
        _updateWarrior(dt, adx);
        break;
      case _EL.dying:
        _updateDeath(dt);
        break;
    }
    x = clampD(x, arenaMin - 300, arenaMax + 500);
    if (!isWarrior && rng.nextDouble() < 0.35 && alpha > 0.1) {
      final hb = hurtBox;
      b.particles.spawn(px: randRange(hb.left, hb.right), py: randRange(hb.top + 40, hb.bottom - 40), pvx: randRange(-15, 15), pvy: -randRange(20, 60), plife: randRange(0.8, 1.4), psize: randRange(8, 16), pgrow: 10, pcolor: const Color(0x660B0C12));
    }
    _animateWarrior(dt);
  }

  void _footsteps(double dt, double interval, double shake) {
    _stepT -= dt;
    if (_stepT <= 0) {
      _stepT = interval;
      b.sfx(Sfx.elephantStomp, x: x, volume: 0.45, gap: 100);
      b.addShake(shake);
      b.fx.dust(x + facing * (rng.nextBool() ? 120 : -100), 0, n: 4, power: 0.9);
    }
  }

  void _pushPlayer() {
    final p = b.player;
    final r = sideRect(170 * k, 220 * k, -220 * k, 0);
    if (p.y > r.top + 30 && p.box.overlaps(r)) {
      p.x = p.x < r.center.dx ? r.left - 22 : r.right + 22;
      p.x = clampD(p.x, 30, b.cfg.length - 30);
    }
  }

  void _chooseElephant(double adx) {
    final r = rng.nextDouble();
    if (adx > 520) {
      if (r < 0.5) {
        _set(_EL.chargeTell);
      } else if (r < 0.75) {
        _set(_EL.stompTell);
      } else {
        _set(_EL.walk);
        _nextDur = randRange(0.8, 1.6);
      }
    } else {
      if (r < 0.4) {
        _hitOnce.clear();
        _set(_EL.headbutt);
      } else if (r < 0.8) {
        _set(_EL.stompTell);
      } else {
        _set(_EL.chargeTell);
      }
    }
  }

  void _stompImpact(double sx, double power) {
    b.sfx(Sfx.elephantStomp, x: sx, volume: 1.0);
    b.sfx(Sfx.shockwave, x: sx, volume: 0.9);
    b.addShake(0.8 * power);
    b.fx.dust(sx, 0, n: 20, power: 1.8);
    b.fx.debris(sx, 0, n: 12);
    b.ring(sx, -3, 280, 0.6, const Color(0xFFFFC21A), 8);
    b.projectiles.add(GroundWave(b, sx, 1, speed: 560 * (enraged ? 1.15 : 1), height: 72, damage: 16, color: const Color(0xFFFFB020)));
    b.projectiles.add(GroundWave(b, sx, -1, speed: 560 * (enraged ? 1.15 : 1), height: 72, damage: 16, color: const Color(0xFFFFB020)));
    final p = b.player;
    if ((p.x - sx).abs() < 180 && p.y > -90) p.damage(22, sx, knock: 480, lift: 420);
  }

  // ------------------------------------------------------------------ transform

  @override
  void startTransform() {
    _set(_EL.transform);
    vx = 0;
    b.sfx(Sfx.bossTransform, volume: 1.0);
    b.sfx(Sfx.elephantTrumpet, x: x, volume: 1.0);
    b.letterboxTarget = 1;
    b.projectiles.clear();
    b.showBanner('TRANSFORMATION', 'THE TITAN AWAKENS');
    pose.idle(0);
  }

  void _updateTransform(double dt) {
    final t = _st;
    if (t < 0.6) {
      rear = math.min(1, rear + dt * 2.5);
    } else {
      rear = math.max(0, rear - dt * 2);
    }
    b.addShake(dt * 0.9 * clampD(t / 2.4, 0, 1));
    alpha = clampD(1 - (t - 0.8) / 1.4, 0, 1);
    warriorAlpha = clampD((t - 1.4) / 1.2, 0, 1);
    final cx = x;
    final cy = -150.0;
    if (t < 2.6) {
      for (var i = 0; i < 3; i++) {
        final a = rng.nextDouble() * math.pi * 2;
        final r = randRange(160, 300);
        b.particles.spawn(px: cx + math.cos(a) * r, py: cy + math.sin(a) * r * 0.7, pvx: -math.cos(a) * r * 1.4, pvy: -math.sin(a) * r, plife: 0.7, psize: randRange(8, 16), pgrow: -8, pcolor: const Color(0xCC0B0C12));
      }
      if (rng.nextDouble() < 0.4) b.fx.energy(cx, cy, n: 3, color: const Color(0xFFFF3A2A), speed: 240);
      if ((t * 3).floor() != ((t - dt) * 3).floor()) {
        b.ring(cx, cy, 220, 0.5, const Color(0xFFFF3A2A), 4, flat: 1);
      }
    }
    if (t >= 2.6 && !_did) {
      _did = true;
      b.flashWhite = 1;
      b.addShake(1);
      b.sfx(Sfx.bossRoar, volume: 1.0);
      b.fx.energy(cx, cy, n: 60, color: const Color(0xFFFF3A2A), speed: 700);
      b.ring(cx, -4, 420, 0.8, const Color(0xFFFF3A2A), 10);
    }
    if (t > 3.3) {
      nextPhase();
      alpha = 0;
      warriorAlpha = 1;
      b.letterboxTarget = 0;
      b.showBanner('TITAN WARLORD', 'FINAL FORM');
      _set(_EL.wIdle);
      _nextDur = 0.6;
    }
  }

  // ------------------------------------------------------------------ warrior

  void _updateWarrior(double dt, double adx) {
    final p = b.player;
    final rage = enraged ? 1.25 : 1.0;
    switch (_state) {
      case _EL.wIdle:
        vx *= 0.8;
        faceTarget();
        if (_st > _nextDur) {
          if (adx > 300) {
            final r = rng.nextDouble();
            if (r < 0.35) {
              _set(_EL.wLeapTell);
            } else if (r < 0.6) {
              _set(_EL.wDashTell);
            } else {
              _set(_EL.wApproach);
            }
          } else {
            final r = rng.nextDouble();
            _combo = r < 0.5 ? 1 : 2;
            if (r < 0.75) {
              _set(_EL.wSlashTell);
            } else {
              _set(_EL.wLeapTell);
            }
          }
        }
        break;
      case _EL.wApproach:
        faceTarget();
        vx = facing * 250 * rage;
        if (adx < 250 || _st > 1.4) {
          _combo = rng.nextDouble() < 0.5 ? 1 : 2;
          _set(_EL.wSlashTell);
        }
        break;
      case _EL.wSlashTell:
        vx *= 0.8;
        faceTarget();
        _eyeBoost = 1;
        if (_st > 0.48 / rage) {
          _hitOnce.clear();
          b.sfx(Sfx.bossAttack, x: x, volume: 0.9);
          vx = facing * 380;
          _set(_EL.wSlash);
        }
        break;
      case _EL.wSlash:
        vx *= math.max(0, 1 - 6 * dt);
        if (_st > 0.06 && _st < 0.24 && !_hitOnce.contains(p)) {
          if (contact(sideRect(-10, 285, -330, 0), 24, knock: 520, lift: 380)) _hitOnce.add(p);
        }
        if (_st > 0.12 && !_did) {
          _did = true;
          b.addShake(0.3);
          b.fx.dust(x + facing * 220, 0, n: 8, power: 1.2);
        }
        if (_st > 0.42) {
          _combo--;
          if (_combo > 0) {
            _set(_EL.wSlashTell);
            _st = 0.2;
          } else {
            _set(_EL.wRecover);
          }
        }
        break;
      case _EL.wLeapTell:
        vx *= 0.7;
        faceTarget();
        if (_st > 0.42 / rage) {
          _leapFrom = x;
          _leapTo = clampD(p.x, arenaMin, arenaMax);
          b.sfx(Sfx.jump, x: x, volume: 1.0);
          b.fx.dust(x, 0, n: 12, power: 1.5);
          _set(_EL.wLeap);
        }
        break;
      case _EL.wLeap:
        const dur = 0.78;
        final t = clampD(_st / dur, 0, 1);
        x = lerpD(_leapFrom, _leapTo, t);
        y = -math.sin(t * math.pi) * 330;
        vx = 0;
        if (t >= 1 && !_did) {
          _did = true;
          y = 0;
          _stompImpact(x, 1.0);
        }
        if (_st > dur + 0.1) _set(_EL.wRecover);
        break;
      case _EL.wDashTell:
        vx *= 0.7;
        faceTarget();
        _eyeBoost = 1.4;
        if (_st > 0.32 / rage) {
          _hitOnce.clear();
          b.sfx(Sfx.bossAttack, x: x, volume: 0.9);
          _set(_EL.wDash);
        }
        break;
      case _EL.wDash:
        vx = facing * 950 * rage;
        if (!_hitOnce.contains(p) && contact(sideRect(40, 200, -320, 0), 20, knock: 520, lift: 300)) _hitOnce.add(p);
        if (rng.nextDouble() < 0.8) b.fx.shadowBurst(x - facing * 40, -150, n: 2);
        if (_st > 0.38) _set(_EL.wRecover);
        break;
      case _EL.wRecover:
        vx *= math.max(0, 1 - 8 * dt);
        if (_st > 0.55 / rage) {
          _set(_EL.wIdle);
          _nextDur = randRange(0.2, 0.6) / rage;
        }
        break;
      default:
        break;
    }
    x = clampD(x + vx * dt, arenaMin, arenaMax);
    if (_state != _EL.wLeap) y = 0;
    walk += dt * (2 + vx.abs() / 50);
  }

  void _animateWarrior(double dt) {
    if (!isWarrior) return;
    var rate = 14.0;
    switch (_state) {
      case _EL.wApproach:
        _target.walk(walk, 1, run: true);
        break;
      case _EL.wSlashTell:
        _target.windUp(clampD(_st / 0.4, 0, 1));
        rate = 16;
        break;
      case _EL.wSlash:
        _target.slashDown(clampD(_st / 0.16, 0, 1));
        rate = 34;
        break;
      case _EL.wLeapTell:
        _target.windUp(clampD(_st / 0.4, 0, 1));
        _target.fThigh = 0.9;
        _target.bThigh = -0.2;
        _target.bShin = -1.2;
        break;
      case _EL.wLeap:
        if (_st < 0.6) {
          _target.windUp(1);
          _target.fThigh = 1.2;
        } else {
          _target.smashImpact();
        }
        rate = 22;
        break;
      case _EL.wDashTell:
        _target.sweep(0);
        break;
      case _EL.wDash:
        _target.sweep(clampD(_st / 0.2, 0, 1));
        rate = 30;
        break;
      case _EL.wRecover:
        _target.idle(b.time);
        _target.torso = 0.3;
        rate = 8;
        break;
      case _EL.dying:
        if (_st < 0.6) {
          _target.windUp(clampD(_st / 0.5, 0, 1));
        } else if (_st < 1.0) {
          _target.slashDown(clampD((_st - 0.6) / 0.25, 0, 1));
        } else {
          _target.collapsed(clampD((_st - 1.0) / 0.8, 0, 1));
          _target.rot = -1.45 * easeInCubic(clampD((_st - 1.0) / 1.0, 0, 1));
        }
        rate = 16;
        break;
      default:
        _target.idle(b.time);
    }
    pose.blend(_target, smoothK(rate, dt));
    skel.compute(pose, warriorStyle);
  }

  // ------------------------------------------------------------------ death

  @override
  void startDeath() {
    _set(_EL.dying);
    vx = 0;
    b.slowMotion(1.6, 0.45);
    b.sfx(Sfx.bossAttack, x: x, volume: 1.0);
    b.flashWhite = 0.5;
  }

  void _updateDeath(double dt) {
    if (_st > 0.85 && !_did) {
      _did = true;
      b.sfx(Sfx.bossDeath, volume: 1.0);
      b.addShake(0.8);
      b.fx.energy(x + facing * 150, -40, n: 30, color: const Color(0xFFFF3A2A), speed: 500);
    }
    if (_st > 1.0 && _st < 1.6) {
      flash = (_st * 12).floor() % 2 == 0 ? 0.7 : 0;
      if (rng.nextDouble() < 0.6) b.fx.shadowBurst(x + randRange(-60, 60), randRange(-300, -40), n: 3);
    }
    if (_st > 2.0 && _st - dt <= 2.0) {
      b.addShake(0.9);
      b.fx.dust(x - facing * 150, 0, n: 24, power: 2);
      b.sfx(Sfx.stoneImpact, volume: 1.0);
    }
    if (_st > 2.2) {
      warriorAlpha = clampD(1 - (_st - 2.4) / 2.2, 0, 1);
      if (warriorAlpha > 0) {
        b.fx.disintegrate(Rect.fromLTRB(x - 200, -110, x + 200, 0), n: 7);
      }
    }
    if (_st > 5.0) finished = true;
  }

  // ------------------------------------------------------------------ render

  static final Paint _sh = Paint();

  @override
  void render(Canvas c) {
    _sh.color = const Color(0x88000000);
    if (alpha > 0.01) {
      c.drawOval(Rect.fromCenter(center: Offset(x + facing * 20, 0), width: 460 * k, height: 18), _sh);
      c.save();
      c.translate(x, y);
      c.scale(facing, 1);
      BeastPainter.elephant(c, k: k, walk: walk, alpha: alpha, flash: flash, eyeGlow: 1 + _eyeBoost, trunk: trunk, rear: rear, rimDx: facing, time: b.time);
      c.restore();
    }
    if (warriorAlpha > 0.01) {
      c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 180, height: 14), _sh);
      c.save();
      c.translate(x, y);
      c.scale(facing, 1);
      if (_state == _EL.transform) {
        final s = 0.6 + 0.4 * warriorAlpha;
        c.scale(s, s);
      }
      if (pose.rot != 0) c.rotate(pose.rot);
      HumanoidPainter.draw(c, skel, pose, warriorStyle, time: b.time, alpha: warriorAlpha, flash: flash, rimDx: facing, wind: 0.4, eyeBoost: _eyeBoost);
      c.restore();
    }
  }
}
