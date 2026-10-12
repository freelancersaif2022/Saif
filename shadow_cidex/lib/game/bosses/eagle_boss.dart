import 'dart:math' as math;
import 'dart:ui';

import '../../audio.dart';
import '../../core/utils.dart';
import '../../render/beasts.dart';
import '../hazards.dart';
import '../battle.dart';
import 'boss.dart';

enum _ES { intro, hover, diveTell, dive, grounded, rise, swoopSetup, swoop, bombRun, dying }

/// Level 4: the giant Shadow Eagle.
class EagleBoss extends Boss {
  EagleBoss(Battle b) : super(b, const [BossPhase('SHADOW EAGLE', 1100, Color(0xFFFF3B2F))]) {
    x = b.cfg.length + 400;
    y = -470;
    facing = -1;
    _st = 0;
  }

  static const double s = 74;
  _ES _state = _ES.intro;
  double _st = 0;
  double vx = 0;
  double vy = 0;
  double flap = 0;
  double _flapSpeed = 8;
  double _hoverDur = 2;
  double _bombT = 1;
  double _tx = 0;
  double _ty = 0;
  double _swoopDir = 1;
  int _bombsLeft = 0;
  double tilt = 0;
  double talons = 0;
  double alpha = 1;
  double _eyeBoost = 0;
  double _flapSound = 0;
  bool _impacted = false;

  @override
  int get scoreValue => 6000;

  @override
  double get focusX => _state == _ES.intro ? b.cfg.length * 0.6 : x;

  @override
  Rect get hurtBox => Rect.fromCenter(center: Offset(x + facing * 0.25 * s, y - 0.1 * s), width: 2.7 * s, height: 1.35 * s);

  double get _speedMul => enraged ? 1.22 : 1.0;

  void _set(_ES st) {
    _state = st;
    _st = 0;
  }

  @override
  void update(double dt) {
    _st += dt;
    flash = math.max(0, flash - dt * 5);
    _eyeBoost = math.max(0, _eyeBoost - dt * 2);
    flap += dt * _flapSpeed;
    final p = b.player;
    switch (_state) {
      case _ES.intro:
        if (_st < dt * 1.5) {
          b.sfx(Sfx.bossEntrance, volume: 0.9);
          b.sfx(Sfx.eagleScreech, volume: 0.9);
        }
        _flapSpeed = 7;
        final tx = b.cfg.length * 0.62;
        x += (tx - x) * smoothK(1.4, dt);
        y += (-360 - y) * smoothK(1.2, dt);
        if (_st > 2.8) {
          introDone = true;
          b.showBanner('SHADOW EAGLE', 'GUARDIAN OF THE STORM');
          b.sfx(Sfx.eagleScreech, volume: 1.0);
          _hoverDur = 1.5;
          _set(_ES.hover);
        }
        break;
      case _ES.hover:
        _flapSpeed = 8;
        final t = b.time;
        final hx = clampD(p.x + math.sin(t * 0.9) * 320, arenaMin + 80, arenaMax - 80);
        final hy = -360 + math.sin(t * 1.7) * 45;
        _steer(hx, hy, 3.0 * _speedMul, dt);
        facing = p.x >= x ? 1 : -1;
        _bombT -= dt;
        if (_bombT <= 0 && (x - p.x).abs() < 300) {
          _dropBomb();
          _bombT = randRange(1.0, 1.8) / _speedMul;
        }
        if (_st > _hoverDur) _chooseAttack();
        break;
      case _ES.diveTell:
        _flapSpeed = 12;
        vx *= 0.9;
        vy = -60;
        y += vy * dt;
        facing = p.x >= x ? 1 : -1;
        _eyeBoost = 1.5;
        if (_st > 0.65 / _speedMul) {
          _tx = p.x + p.vx * 0.15;
          _ty = -70;
          final d = Offset(_tx - x, _ty - y);
          final len = d.distance;
          vx = d.dx / len * 1150 * _speedMul;
          vy = d.dy / len * 1150 * _speedMul;
          b.sfx(Sfx.eagleDive, x: x, volume: 0.9);
          _impacted = false;
          _set(_ES.dive);
        }
        break;
      case _ES.dive:
        _flapSpeed = 2;
        talons = math.min(1, talons + dt * 4);
        x += vx * dt;
        y += vy * dt;
        facing = vx >= 0 ? 1 : -1;
        contact(hurtBox.deflate(10), 20, knock: 460, lift: 340);
        if (y >= -70 || _st > 1.4) {
          y = -70;
          if (!_impacted) {
            _impacted = true;
            b.addShake(0.45);
            b.fx.dust(x, 0, n: 16, power: 1.5);
            b.ring(x, -3, 160, 0.45, const Color(0xFFFF6A3A), 5);
            b.sfx(Sfx.stoneImpact, x: x, volume: 0.8);
            if ((p.x - x).abs() < 130 && p.y > -120) p.damage(14, x, knock: 380, lift: 300);
          }
          vx = 0;
          vy = 0;
          _set(_ES.grounded);
        }
        break;
      case _ES.grounded:
        _flapSpeed = 3;
        talons = math.max(0, talons - dt * 2);
        if (_st > randRange(1.15, 1.25) + (enraged ? -0.2 : 0.1)) {
          b.sfx(Sfx.eagleFly, x: x, volume: 0.8);
          _set(_ES.rise);
        }
        break;
      case _ES.rise:
        _flapSpeed = 11;
        _steer(x + facing * 60, -380, 3.5, dt);
        if (_st > 0.9) {
          _hoverDur = randRange(1.4, 2.8) / _speedMul;
          _set(_ES.hover);
        }
        break;
      case _ES.swoopSetup:
        _flapSpeed = 10;
        final sx = _swoopDir > 0 ? arenaMin - 60 : arenaMax + 60;
        _steer(sx, -105, 3.2 * _speedMul, dt);
        facing = _swoopDir;
        if ((x - sx).abs() < 60 || _st > 2.2) {
          b.sfx(Sfx.eagleDive, x: x, volume: 0.9);
          b.sfx(Sfx.eagleScreech, x: x, volume: 0.7);
          vx = _swoopDir * 960 * _speedMul;
          _set(_ES.swoop);
        }
        break;
      case _ES.swoop:
        _flapSpeed = 13;
        x += vx * dt;
        y += (-100 + math.sin(_st * 5) * 18 - y) * smoothK(6, dt);
        facing = _swoopDir;
        contact(hurtBox.deflate(8), 18, knock: 440, lift: 300);
        if ((_swoopDir > 0 && x > arenaMax + 80) || (_swoopDir < 0 && x < arenaMin - 80)) {
          _set(_ES.rise);
        }
        break;
      case _ES.bombRun:
        _flapSpeed = 9;
        final tx = _swoopDir > 0 ? arenaMax - 60 : arenaMin + 60;
        _steer(tx, -430, 2.2 * _speedMul, dt);
        facing = _swoopDir;
        _bombT -= dt;
        if (_bombT <= 0 && _bombsLeft > 0) {
          _bombsLeft--;
          _dropBomb();
          _bombT = 0.38 / _speedMul;
        }
        if ((x - tx).abs() < 80 || _st > 3.5) {
          _hoverDur = randRange(1.2, 2.2);
          _set(_ES.hover);
        }
        break;
      case _ES.dying:
        _updateDeath(dt);
        break;
    }
    // Wing flap sound.
    if (_state != _ES.dying && _state != _ES.dive) {
      _flapSound -= dt;
      if (_flapSound <= 0) {
        _flapSound = 1.6;
        b.sfx(Sfx.eagleFly, x: x, volume: 0.45, gap: 500);
      }
    }
    final targetTilt = clampD(math.atan2(vy, vx.abs() + 1) * 0.6, -0.5, 0.9);
    tilt += (targetTilt - tilt) * smoothK(6, dt);
    if (_state != _ES.dying && rng.nextDouble() < 0.5) {
      b.particles.spawn(px: x - facing * s * 1.2 + randRange(-20, 20), py: y + randRange(-20, 20), pvx: -vx * 0.1, pvy: randRange(-30, 10), plife: randRange(0.5, 1.0), psize: randRange(6, 12), pgrow: 12, pcolor: const Color(0x990B0C12));
    }
  }

  void _steer(double tx, double ty, double k, double dt) {
    final ax = (tx - x) * k * k - vx * 2 * k;
    final ay = (ty - y) * k * k - vy * 2 * k;
    vx += ax * dt;
    vy += ay * dt;
    x += vx * dt;
    y += vy * dt;
  }

  void _chooseAttack() {
    final r = rng.nextDouble();
    if (r < 0.45) {
      b.sfx(Sfx.eagleScreech, x: x, volume: 0.8);
      _set(_ES.diveTell);
    } else if (r < 0.78) {
      _swoopDir = b.player.x > (arenaMin + arenaMax) / 2 ? 1 : -1;
      _set(_ES.swoopSetup);
    } else {
      _swoopDir = x < (arenaMin + arenaMax) / 2 ? 1 : -1;
      _bombsLeft = enraged ? 6 : 4;
      _bombT = 0.3;
      _set(_ES.bombRun);
    }
  }

  void _dropBomb() {
    b.sfx(Sfx.eagleBomb, x: x, volume: 0.7);
    final p = b.player;
    final lead = clampD((p.x - x) * 0.9, -260, 260);
    b.projectiles.add(ShadowBomb(b, x, y + 0.4 * s, vx * 0.35 + lead, -80));
    if (enraged && rng.nextDouble() < 0.5) {
      b.projectiles.add(ShadowBomb(b, x, y + 0.4 * s, vx * 0.35 + lead + randRange(-200, 200), -160));
    }
  }

  @override
  void onHit(double damage, double dir, bool heavy) {
    b.fx.shadowBurst(hurtBox.center.dx, hurtBox.center.dy, n: 6);
    if (_state == _ES.hover && heavy) {
      vy -= 120;
    }
  }

  // ------------------------------------------------------------------ death

  double _deathVy = 0;
  bool _landed = false;
  double _spin = 0;

  @override
  void startDeath() {
    _set(_ES.dying);
    _deathVy = -120;
    _landed = false;
    b.sfx(Sfx.bossDeath, volume: 1.0);
    b.sfx(Sfx.eagleScreech, volume: 0.9);
    b.slowMotion(1.4, 0.4);
    b.addShake(0.6);
    b.flashWhite = 0.6;
  }

  void _updateDeath(double dt) {
    if (_st < 0.8) {
      // Damaged: struggling in the air.
      _flapSpeed = 18;
      flash = (_st * 10).floor() % 2 == 0 ? 0.8 : 0;
      if (rng.nextDouble() < 0.6) b.fx.shadowBurst(x + randRange(-60, 60), y + randRange(-30, 30), n: 3);
      return;
    }
    if (!_landed) {
      _flapSpeed = 4;
      _deathVy += 1100 * dt;
      y += _deathVy * dt;
      x += facing * 120 * dt;
      _spin += dt * 2.2;
      tilt = math.min(1.2, _spin);
      if (rng.nextDouble() < 0.8) {
        b.particles.spawn(px: x, py: y, pvx: randRange(-40, 40), pvy: -randRange(20, 80), plife: 1.0, psize: randRange(8, 16), pgrow: 16, pcolor: const Color(0xAA0B0C12));
      }
      if (y >= -40) {
        y = -40;
        _landed = true;
        _st = 2.0;
        b.addShake(0.9);
        b.fx.dust(x, 0, n: 24, power: 2);
        b.fx.debris(x, 0, n: 14);
        b.ring(x, -3, 260, 0.6, const Color(0xFFFF4A2A), 7);
        b.sfx(Sfx.stoneImpact, x: x, volume: 1.0);
      }
      return;
    }
    _flapSpeed = 0.5;
    alpha = clampD(1 - (_st - 2.6) / 2.0, 0, 1);
    if (_st > 2.4 && alpha > 0) {
      b.fx.disintegrate(Rect.fromCenter(center: Offset(x, y - 20), width: 3 * s, height: 1.4 * s), n: 6, glow: const Color(0xFFFF3B2F));
    }
    if (_st > 5.0) {
      finished = true;
    }
  }

  // ------------------------------------------------------------------ render

  static final Paint _sh = Paint();

  @override
  void render(Canvas c) {
    if (alpha <= 0.01) return;
    final hgt = -y;
    _sh.color = fade(const Color(0x88000000), alpha * clampD(1 - hgt / 700, 0.15, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: s * 3 * clampD(1 - hgt / 900, 0.4, 1), height: 14), _sh);
    c.save();
    c.translate(x, y);
    c.scale(facing, 1);
    c.rotate(tilt);
    final f = _state == _ES.dive ? -0.3 : math.sin(flap);
    BeastPainter.eagle(c, s: s, flap: _state == _ES.dive ? f : flap, alpha: alpha, flash: flash, eyeGlow: 1 + _eyeBoost, talons: talons, rimDx: facing, time: b.time);
    c.restore();
  }
}
