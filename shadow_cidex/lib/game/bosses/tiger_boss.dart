import 'dart:math' as math;
import 'dart:ui';

import '../../audio.dart';
import '../../core/utils.dart';
import '../../render/beasts.dart';
import '../battle.dart';
import '../fx.dart';
import '../hazards.dart';
import '../player.dart';
import 'boss.dart';

enum _T {
  intro,
  // Tiger and monster tiger.
  prowl,
  dodge,
  pounceTell,
  pounce,
  clawTell,
  claw,
  dashTell,
  dash,
  roar,
  breath,
  recover,
  // Dragon.
  hover,
  fireTell,
  fire,
  diveTell,
  dive,
  grounded,
  meteors,
  gust,
  rise,
  transform,
  dying,
}

/// Level 20: the Tiger God. Tiger (blue) -> monster tiger (yellow) ->
/// two-headed dragon (red).
class TigerBoss extends Boss {
  TigerBoss(Battle b)
      : super(b, const [
          BossPhase('THE TIGER GOD', 1900, Color(0xFF2A8BFF)),
          BossPhase('MONSTER TIGER', 1800, Color(0xFFFFC21A)),
          BossPhase('TWIN-HEADED DRAGON', 2300, Color(0xFFFF2020)),
        ]) {
    x = b.cfg.length + 300;
    y = 0;
    facing = -1;
  }

  _T _state = _T.intro;
  double _st = 0;
  double vx = 0;
  double vy = 0;
  double run = 0;
  double crouch = 0;
  double mouth = 0;
  double morph = 0;
  double alpha = 1;
  double tigerAlpha = 1;
  double dragonAlpha = 0;
  double flap = 0;
  double tilt = 0;
  double mouthA = 0;
  double mouthB = 0;
  double _eyeBoost = 0;
  double _next = 1;
  bool _did = false;
  int _count = 0;
  int _head = 0;
  double _fromX = 0;
  double _toX = 0;
  double _hopH = 260;
  double _dodgeCd = 0;
  final Set<Object> _hitOnce = {};

  static const double _ds = 92;

  bool get isDragon => phase == 2 && _state != _T.transform || (_state == _T.transform && phase == 2);
  double get _rage => (1 + phase * 0.15) * (enraged ? 1.15 : 1.0);
  double get _k => 1.0 + morph * 0.18;

  @override
  int get scoreValue => 30000;

  @override
  double get focusX => _state == _T.intro ? b.cfg.length * 0.62 : x;

  @override
  Rect get hurtBox {
    if (isDragon) return Rect.fromCenter(center: Offset(x + facing * 30, y - 10), width: 2.7 * _ds, height: 1.2 * _ds);
    final k = _k;
    return sideRect(180 * k, 260 * k, -210 * k + crouch * 40, 0).translate(0, y);
  }

  @override
  bool get vulnerable => _state != _T.dodge;

  void _set(_T s) {
    _state = s;
    _st = 0;
    _did = false;
  }

  @override
  void update(double dt) {
    _st += dt;
    flash = math.max(0, flash - dt * 5);
    _eyeBoost = math.max(0, _eyeBoost - dt * 2);
    _dodgeCd = math.max(0, _dodgeCd - dt);
    mouth = math.max(0, mouth - dt * 2);
    final p = b.player;
    final adx = (p.x - x).abs();
    switch (_state) {
      case _T.intro:
        _intro(dt);
        break;
      case _T.transform:
        _transform(dt);
        break;
      case _T.dying:
        _death(dt);
        break;
      default:
        if (isDragon) {
          _dragon(dt, adx);
        } else {
          _tiger(dt, adx);
        }
    }
    if (!isDragon && _state != _T.pounce && _state != _T.intro && _state != _T.dodge && _state != _T.dying && _state != _T.transform) {
      x = clampD(x + vx * dt, arenaMin - 40, arenaMax + 40);
      y = 0;
    }
    if (rng.nextDouble() < 0.35 && alpha > 0.2) {
      final hb = hurtBox;
      b.particles.spawn(px: randRange(hb.left, hb.right), py: randRange(hb.top, hb.bottom), pvy: -randRange(30, 80), plife: 0.9, psize: randRange(8, 16), pgrow: 10, pcolor: const Color(0x660B0C12));
    }
  }

  // ------------------------------------------------------------------ intro

  void _intro(double dt) {
    if (!_did) {
      _did = true;
      _fromX = x;
      _toX = b.cfg.length * 0.66;
      b.sfx(Sfx.bossEntrance, volume: 1.0);
    }
    final t = clampD(_st / 1.1, 0, 1);
    x = lerpD(_fromX, _toX, t);
    y = -math.sin(t * math.pi) * 300;
    run += dt * 10;
    if (t >= 1 && _st - dt < 1.1) {
      y = 0;
      b.addShake(0.8);
      b.fx.dust(x, 0, n: 20, power: 1.8);
      b.sfx(Sfx.tigerRoar, volume: 1.0);
      mouth = 1;
    }
    if (_st > 1.1) {
      y = 0;
      mouth = math.max(mouth, 0.8);
      b.addShake(dt * 0.6);
    }
    if (_st > 2.8) {
      introDone = true;
      b.showBanner('THE TIGER GOD', 'THE FINAL HUNT');
      _set(_T.prowl);
      _next = 0.8;
    }
  }

  // ------------------------------------------------------------------ tiger

  void _tiger(double dt, double adx) {
    final p = b.player;
    final mt = phase == 1;
    // Clever: leap away from the player's swing.
    if (_dodgeCd <= 0 && (p.state == PState.attack || p.state == PState.smash) && adx < 260 && (_state == _T.prowl || _state == _T.recover) && rng.nextDouble() < (mt ? 0.08 : 0.05)) {
      _fromX = x;
      _toX = clampD(x - (p.x - x).sign * randRange(320, 460), arenaMin, arenaMax);
      _hopH = 200;
      _dodgeCd = 2.2;
      b.sfx(Sfx.tigerClaw, x: x, volume: 0.6);
      _set(_T.dodge);
      return;
    }
    switch (_state) {
      case _T.prowl:
        faceTarget();
        // Circle at a hunting distance, then strike.
        final want = adx > 520 ? 1.0 : (adx < 300 ? -0.6 : 0.0);
        vx += (facing * want * 300 * _rage - vx) * smoothK(5, dt);
        run += dt * (2 + vx.abs() / 60);
        crouch += (0.25 - crouch) * smoothK(4, dt);
        if (_st > _next) _chooseTiger(adx);
        break;
      case _T.dodge:
        const dur = 0.5;
        final t = clampD(_st / dur, 0, 1);
        x = lerpD(_fromX, _toX, t);
        y = -math.sin(t * math.pi) * _hopH;
        run += dt * 8;
        if (t >= 1) {
          y = 0;
          b.fx.dust(x, 0, n: 8, power: 1.0);
          // Counter-pounce straight away.
          _set(rng.nextDouble() < 0.6 ? _T.pounceTell : _T.prowl);
          _next = 0.2;
        }
        break;
      case _T.pounceTell:
        vx *= 0.7;
        faceTarget();
        crouch += (1 - crouch) * smoothK(12, dt);
        _eyeBoost = 1.5;
        if (_st > 0.38 / _rage) {
          _fromX = x;
          _toX = clampD(p.x + p.vx * 0.3, arenaMin, arenaMax);
          _hopH = 260 + randRange(0, 80);
          _hitOnce.clear();
          b.sfx(Sfx.tigerRoar, x: x, volume: 0.6, gap: 800);
          b.sfx(Sfx.tigerClaw, x: x, volume: 0.8);
          mouth = 1;
          _set(_T.pounce);
        }
        break;
      case _T.pounce:
        const dur = 0.6;
        final t = clampD(_st / dur, 0, 1);
        crouch = 0;
        x = lerpD(_fromX, _toX, t);
        y = -math.sin(t * math.pi) * _hopH;
        run += dt * 6;
        if (!_hitOnce.contains(p) && contact(hurtBox.deflate(24), 22, knock: 480, lift: 380)) _hitOnce.add(p);
        if (t >= 1 && !_did) {
          _did = true;
          y = 0;
          b.addShake(0.6);
          b.fx.dust(x, 0, n: 16, power: 1.5);
          b.ring(x, -3, 190, 0.4, phases[phase].color, 6);
          b.sfx(Sfx.stoneImpact, x: x, volume: 0.9);
          if ((p.x - x).abs() < 160 && p.y > -90) p.damage(20, x, knock: 440, lift: 380);
          if (mt) b.projectiles.add(GroundWave(b, x, facing, speed: 560, height: 60, damage: 16, color: const Color(0xFFFFB020)));
        }
        if (_st > dur + 0.05) {
          y = 0;
          _count--;
          if (_count > 0) {
            _set(_T.pounceTell);
            _st = 0.2;
          } else {
            _set(_T.recover);
          }
        }
        break;
      case _T.clawTell:
        vx *= 0.7;
        faceTarget();
        crouch += (0.4 - crouch) * smoothK(10, dt);
        if (_st > 0.3 / _rage) {
          _hitOnce.clear();
          vx = facing * 420;
          mouth = 0.8;
          b.sfx(Sfx.tigerClaw, x: x, volume: 0.9);
          _set(_T.claw);
        }
        break;
      case _T.claw:
        vx *= math.max(0, 1 - 7 * dt);
        if (_st < 0.2 && !_hitOnce.contains(p)) {
          if (contact(sideRect(-40, 330 * _k, -200, 0), 18, knock: 420, lift: 300)) _hitOnce.add(p);
        }
        if (mt && !_did && _st > 0.1) {
          _did = true;
          b.projectiles.add(GroundWave(b, x + facing * 260, facing, speed: 640, height: 55, damage: 14, color: const Color(0xFFFFB020)));
        }
        if (_st > 0.3) {
          _count--;
          if (_count > 0) {
            _set(_T.clawTell);
            _st = 0.15;
          } else {
            _set(_T.recover);
          }
        }
        break;
      case _T.dashTell:
        vx *= 0.6;
        faceTarget();
        crouch += (0.6 - crouch) * smoothK(10, dt);
        _eyeBoost = 1.6;
        if (_st > 0.32 / _rage) {
          _hitOnce.clear();
          b.sfx(Sfx.elephantCharge, x: x, volume: 0.6);
          _set(_T.dash);
        }
        break;
      case _T.dash:
        crouch = 0.2;
        vx = facing * 1100 * _rage;
        run += dt * 20;
        if (rng.nextDouble() < 0.8) b.fx.dust(x - facing * 150, 0, n: 2, power: 1.0);
        if (!_hitOnce.contains(p) && contact(hurtBox.deflate(14), 20, knock: 520, lift: 360)) _hitOnce.add(p);
        if (_st > 0.55 || x <= arenaMin || x >= arenaMax) _set(_T.recover);
        break;
      case _T.roar:
        vx *= 0.6;
        mouth = 1;
        if (_st > 0.3 && !_did) {
          _did = true;
          b.sfx(Sfx.tigerRoar, x: x, volume: 1.0);
          b.addShake(0.7);
          b.ring(x + facing * 200, -150, 320, 0.6, phases[phase].color, 8, flat: 1);
          b.projectiles.add(GroundWave(b, x, 1, speed: 620, height: 70, damage: 16, color: phases[phase].color));
          b.projectiles.add(GroundWave(b, x, -1, speed: 620, height: 70, damage: 16, color: phases[phase].color));
          if ((p.x - x).abs() < 260) p.damage(10, x, knock: 600, lift: 200);
        }
        if (_st > 1.0) _set(_T.recover);
        break;
      case _T.breath:
        vx *= 0.7;
        faceTarget();
        mouth = 1;
        final cycle = _st % 0.1;
        if (_st > 0.35 && _st < 1.25 && cycle - dt < 0 + 0.0001 + 0.05 && cycle >= 0.05) {
          final mx = x + facing * 270 * _k;
          final my = -170.0;
          final aim = math.atan2((p.y - 60) - my, (p.x - mx)) + math.sin(_st * 6) * 0.15;
          b.projectiles.add(Fireball(b, mx, my, math.cos(aim) * 640, math.sin(aim) * 640, damage: 12, radius: 14, color: const Color(0xFFFF8A2A)));
        }
        if (_st > 0.35 && !_did) {
          _did = true;
          b.sfx(Sfx.fireBreath, x: x, volume: 0.9);
        }
        if (_st > 1.5) _set(_T.recover);
        break;
      case _T.recover:
        vx *= math.max(0, 1 - 8 * dt);
        crouch += (0 - crouch) * smoothK(6, dt);
        if (_st > 0.45 / _rage) {
          _set(_T.prowl);
          _next = randRange(0.25, 0.7) / _rage;
        }
        break;
      default:
        break;
    }
  }

  void _chooseTiger(double adx) {
    final mt = phase == 1;
    final r = rng.nextDouble();
    if (adx > 420) {
      if (r < 0.35) {
        _count = mt ? 3 : 1;
        _set(_T.pounceTell);
      } else if (r < 0.6) {
        _set(_T.dashTell);
      } else if (r < 0.78) {
        _set(mt ? _T.breath : _T.roar);
      } else {
        // Feint: fake a pounce then dash.
        _count = 1;
        _set(_T.pounceTell);
        _st = -0.25;
      }
    } else {
      if (r < 0.45) {
        _count = mt ? 3 : 2;
        _set(_T.clawTell);
      } else if (r < 0.65) {
        _set(_T.roar);
      } else if (r < 0.85) {
        _count = 1;
        _set(_T.pounceTell);
      } else {
        _set(_T.dashTell);
      }
    }
  }

  // ------------------------------------------------------------------ dragon

  void _dragon(double dt, double adx) {
    final p = b.player;
    flap += dt * 7;
    mouthA = math.max(0, mouthA - dt * 2);
    mouthB = math.max(0, mouthB - dt * 2);
    switch (_state) {
      case _T.hover:
        final t = b.time;
        final side = p.x < (arenaMin + arenaMax) / 2 ? 1.0 : -1.0;
        final hx = clampD(p.x + side * 380 + math.sin(t * 0.8) * 120, arenaMin + 120, arenaMax - 120);
        final hy = -300 + math.sin(t * 1.6) * 40;
        _steer(hx, hy, 2.6 * _rage, dt);
        facing = p.x >= x ? 1 : -1;
        if (_st > _next) _chooseDragon();
        break;
      case _T.fireTell:
        _steer(x, y - 20, 2, dt);
        facing = p.x >= x ? 1 : -1;
        if (_count == 2) {
          mouthA = 0.6;
          mouthB = 0.6;
        } else if (_head == 0) {
          mouthA = 0.6;
        } else {
          mouthB = 0.6;
        }
        _eyeBoost = 1.5;
        if (_st > 0.45 / _rage) {
          b.sfx(Sfx.fireBreath, x: x, volume: 1.0);
          b.sfx(Sfx.dragonRoar, x: x, volume: 0.5, gap: 1500);
          _set(_T.fire);
        }
        break;
      case _T.fire:
        vx *= 0.9;
        vy *= 0.9;
        x += vx * dt;
        y += vy * dt;
        final cycle = _st % 0.08;
        if (cycle - dt < 0 + 0.04 && cycle >= 0.04 && _st < 1.1) {
          for (var h = 0; h < 2; h++) {
            if (_count != 2 && h != _head) continue;
            final m = BeastPainter.dragonMouth(_ds, b.time, h);
            final mx = x + m.dx * facing;
            final my = y + m.dy;
            final sweep = (_st / 1.1 - 0.5) * 0.9 * (h == 0 ? 1 : -1);
            final aim = math.atan2((p.y - 40) - my, (p.x - mx)) + sweep;
            b.projectiles.add(Fireball(b, mx, my, math.cos(aim) * 700, math.sin(aim) * 700, damage: 14, radius: 16, gravity: 200));
            if (h == 0) {
              mouthA = 1;
            } else {
              mouthB = 1;
            }
          }
        }
        if (_st > 1.4) {
          _set(_T.hover);
          _next = randRange(0.6, 1.2) / _rage;
        }
        break;
      case _T.diveTell:
        _steer(x, -380, 3, dt);
        _eyeBoost = 1.8;
        if (_st > 0.55 / _rage) {
          _toX = clampD(p.x, arenaMin, arenaMax);
          b.sfx(Sfx.eagleDive, x: x, volume: 0.9);
          b.sfx(Sfx.dragonRoar, x: x, volume: 0.7);
          _hitOnce.clear();
          _set(_T.dive);
        }
        break;
      case _T.dive:
        final dx = _toX - x;
        vx = dx.sign * math.min(dx.abs() * 4, 1100);
        vy = 1200;
        x += vx * dt;
        y += vy * dt;
        facing = vx >= 0 ? 1 : -1;
        if (!_hitOnce.contains(p) && contact(hurtBox.deflate(16), 24, knock: 520, lift: 400)) _hitOnce.add(p);
        if (y >= -70) {
          y = -70;
          b.addShake(0.9);
          b.fx.dust(x, 0, n: 24, power: 2);
          b.ring(x, -3, 300, 0.6, const Color(0xFFFF4A1A), 9);
          b.sfx(Sfx.elephantStomp, x: x, volume: 1.0);
          b.projectiles.add(GroundWave(b, x, 1, speed: 640, height: 80, damage: 18, color: const Color(0xFFFF5A1A)));
          b.projectiles.add(GroundWave(b, x, -1, speed: 640, height: 80, damage: 18, color: const Color(0xFFFF5A1A)));
          if ((p.x - x).abs() < 200 && p.y > -120) p.damage(22, x, knock: 520, lift: 420);
          _set(_T.grounded);
        }
        break;
      case _T.grounded:
        vx = 0;
        vy = 0;
        flap -= dt * 5;
        // Tail sweep while grounded.
        if (_st > 0.5 && !_did) {
          _did = true;
          b.sfx(Sfx.bossAttack, x: x, volume: 0.9);
          contact(Rect.fromLTRB(x - 320, -120, x + 320, 0), 16, knock: 460, lift: 360);
        }
        if (_st > 1.5 / _rage) _set(_T.rise);
        break;
      case _T.rise:
        _steer(x, -300, 3, dt);
        if (_st > 0.8) {
          _set(_T.hover);
          _next = randRange(0.5, 1.0);
        }
        break;
      case _T.meteors:
        _steer(x, -360, 2, dt);
        mouthA = 0.8;
        mouthB = 0.8;
        if (_st > 0.4 && !_did) {
          _did = true;
          b.sfx(Sfx.dragonRoar, x: x, volume: 1.0);
          b.addShake(0.5);
          final n = enraged ? 7 : 5;
          for (var i = 0; i < n; i++) {
            final tx = clampD(p.x + (i - n / 2) * 170 + randRange(-40, 40), arenaMin, arenaMax);
            b.projectiles.add(FireMeteor(b, tx, delay: 0.7 + i * 0.16, damage: 20));
          }
        }
        if (_st > 2.2) {
          _set(_T.hover);
          _next = 0.6;
        }
        break;
      case _T.gust:
        _steer(x, y, 2, dt);
        flap += dt * 10;
        if (_st > 0.4 && _st < 1.2) {
          final dir = p.x >= x ? 1.0 : -1.0;
          if (p.alive && p.onGround && (p.x - x).abs() < 900) p.x += dir * 260 * dt;
          if (rng.nextDouble() < 0.6) b.particles.spawn(px: x + dir * randRange(50, 400), py: -randRange(10, 200), pvx: dir * 600, plife: 0.5, psize: randRange(6, 12), pgrow: 10, pcolor: const Color(0x66A0A8C0));
        }
        if (_st > 0.5 && !_did) {
          _did = true;
          b.sfx(Sfx.shockwave, x: x, volume: 0.8);
          final dir = p.x >= x ? 1.0 : -1.0;
          b.projectiles.add(GroundWave(b, x, dir, speed: 700, height: 70, damage: 14, color: const Color(0xFFFF7A3A)));
        }
        if (_st > 1.4) {
          _set(_T.hover);
          _next = 0.5;
        }
        break;
      default:
        break;
    }
    final targetTilt = clampD(math.atan2(vy, vx.abs() + 1) * 0.4, -0.4, 0.7);
    tilt += (targetTilt - tilt) * smoothK(5, dt);
  }

  void _steer(double tx, double ty, double k, double dt) {
    final ax = (tx - x) * k * k - vx * 2 * k;
    final ay = (ty - y) * k * k - vy * 2 * k;
    vx += ax * dt;
    vy += ay * dt;
    x += vx * dt;
    y += vy * dt;
  }

  void _chooseDragon() {
    final r = rng.nextDouble();
    if (r < 0.3) {
      _count = rng.nextDouble() < 0.4 ? 2 : 1;
      _head = rng.nextInt(2);
      _set(_T.fireTell);
    } else if (r < 0.55) {
      _set(_T.diveTell);
    } else if (r < 0.78) {
      _set(_T.meteors);
    } else {
      _set(_T.gust);
    }
  }

  // ------------------------------------------------------------------ transform

  int _from = 0;

  @override
  void startTransform() {
    _from = phase;
    _set(_T.transform);
    vx = 0;
    vy = 0;
    crouch = 0;
    b.projectiles.clear();
    b.letterboxTarget = 1;
    b.sfx(Sfx.bossTransform, volume: 1.0);
    b.sfx(_from == 0 ? Sfx.tigerRoar : Sfx.dragonRoar, volume: 1.0);
    b.showBanner('TRANSFORMATION', _from == 0 ? 'THE BEAST AWAKENS' : 'THE DRAGON RISES');
  }

  void _transform(double dt) {
    final t = _st;
    b.addShake(dt * clampD(t / 2.0, 0, 1));
    y += (0 - y) * smoothK(6, dt);
    mouth = 1;
    final color = _from == 0 ? const Color(0xFFFFC21A) : const Color(0xFFFF2020);
    if (t < 2.6) {
      for (var i = 0; i < 4; i++) {
        final a = rng.nextDouble() * math.pi * 2;
        final r = randRange(180, 360);
        b.particles.spawn(px: x + math.cos(a) * r, py: -160 + math.sin(a) * r * 0.7, pvx: -math.cos(a) * r * 1.3, pvy: -math.sin(a) * r * 0.9, plife: 0.75, psize: randRange(8, 18), pgrow: -8, pcolor: const Color(0xCC0B0C12));
      }
      if (rng.nextDouble() < 0.5) b.fx.energy(x, -160, n: 3, color: color, speed: 260);
      if ((t * 3).floor() != ((t - dt) * 3).floor()) b.ring(x, -160, 260, 0.5, color, 4, flat: 1);
    }
    if (_from == 0) {
      morph = easeInOut(clampD((t - 0.6) / 1.8, 0, 1));
    } else {
      tigerAlpha = clampD(1 - (t - 0.6) / 1.2, 0, 1);
      dragonAlpha = clampD((t - 1.4) / 1.2, 0, 1);
      y = -lerpD(0, 280, easeInOut(clampD((t - 1.2) / 1.6, 0, 1)));
      flap += dt * 6;
    }
    if (t >= 1.6 && !_did) {
      _did = true;
      phase = _from + 1;
      hp = phases[phase].maxHp;
    }
    if (t > 2.6 && t - dt <= 2.6) {
      b.flashWhite = 1;
      b.addShake(1);
      b.sfx(_from == 0 ? Sfx.tigerRoar : Sfx.dragonRoar, volume: 1.0);
      b.fx.energy(x, -180, n: 70, color: color, speed: 760);
      b.ring(x, -4, 480, 0.8, color, 11);
    }
    if (t > 3.3) {
      transforming = false;
      b.letterboxTarget = 0;
      if (phase == 1) {
        morph = 1;
        b.showBanner('MONSTER TIGER', 'FASTER  STRONGER  SMARTER');
        _set(_T.prowl);
      } else {
        tigerAlpha = 0;
        dragonAlpha = 1;
        b.showBanner('TWIN-HEADED DRAGON', 'THE LAST FORM');
        _set(_T.hover);
      }
      _next = 0.5;
    }
  }

  // ------------------------------------------------------------------ death

  @override
  void startDeath() {
    _set(_T.dying);
    vx = 0;
    vy = 0;
    b.projectiles.clear();
    b.slowMotion(2.4, 0.4);
    b.letterboxTarget = 1;
    b.sfx(Sfx.dragonRoar, volume: 1.0);
    mouthA = 1;
    mouthB = 1;
  }

  void _death(double dt) {
    final t = _st;
    flap += dt * (t < 1.2 ? 14 : 3);
    if (t < 1.2) {
      // A final desperate breath of fire into the sky.
      if (rng.nextDouble() < 0.8) {
        final m = BeastPainter.dragonMouth(_ds, b.time, rng.nextInt(2));
        b.particles.spawn(px: x + m.dx * facing, py: y + m.dy, pvx: facing * randRange(100, 300), pvy: -randRange(200, 500), plife: 0.6, psize: randRange(8, 14), pgrow: 14, pcolor: const Color(0xFFFF6A1A), pkind: PKind.glow);
      }
      flash = (t * 12).floor() % 2 == 0 ? 0.6 : 0;
    }
    if (t > 1.2 && t - dt <= 1.2) {
      b.sfx(Sfx.bossDeath, volume: 1.0);
    }
    if (t > 1.2 && t < 2.6) {
      vy += 900 * dt;
      y = math.min(-70, y + vy * dt);
      tilt = math.min(1.0, tilt + dt * 0.8);
      if (rng.nextDouble() < 0.7) b.fx.shadowBurst(x + randRange(-140, 140), y + randRange(-60, 60), n: 3, spread: 1.2);
    }
    if (t > 2.6 && t - dt <= 2.6) {
      b.addShake(1);
      b.flashWhite = 1;
      b.ring(x, y, 650, 1.0, const Color(0xFFFF3A1A), 14, flat: 1);
      b.ring(x, -4, 760, 1.1, const Color(0xFFB09CFF), 10);
      b.fx.energy(x, y, n: 150, color: const Color(0xFFFF5A2A), speed: 950);
      b.fx.energy(x, y, n: 60, color: const Color(0xFFB09CFF), speed: 600);
      b.sfx(Sfx.bombExplode, volume: 1.0);
    }
    if (t > 2.6) {
      // Dissolve upward into the night sky.
      dragonAlpha = clampD(1 - (t - 2.6) / 2.8, 0, 1);
      y -= 40 * dt;
      if (dragonAlpha > 0) {
        b.fx.disintegrate(Rect.fromCenter(center: Offset(x, y), width: 360, height: 160), n: 8, glow: const Color(0xFFFF4A2A));
        for (var i = 0; i < 3; i++) {
          b.particles.spawn(px: x + randRange(-220, 220), py: y + randRange(-80, 80), pvx: randRange(-20, 20), pvy: -randRange(160, 320), plife: randRange(1.4, 2.6), psize: randRange(2, 4), pcolor: const Color(0xFFFF7050), pkind: PKind.ember);
        }
      }
    }
    if (t > 6.4) finished = true;
  }

  // ------------------------------------------------------------------ render

  static final Paint _sh = Paint();

  @override
  void render(Canvas c) {
    final ta = tigerAlpha * alpha;
    final da = dragonAlpha * alpha;
    final hgt = -y;
    _sh.color = fade(const Color(0x88000000), math.max(ta, da) * clampD(1 - hgt / 700, 0.2, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, 0), width: 440 * clampD(1 - hgt / 900, 0.4, 1), height: 18), _sh);
    if (ta > 0.01) {
      c.save();
      c.translate(x, isDragon ? 0 : y);
      c.scale(facing, 1);
      final stripes = phase == 0 ? const Color(0xFF3A8BFF) : const Color(0xFFFFB020);
      BeastPainter.tiger(c, k: _k, run: run, alpha: ta, flash: flash, eyeGlow: 1 + _eyeBoost, crouch: crouch, mouth: mouth, morph: morph, rimDx: facing, time: b.time, stripes: stripes);
      c.restore();
    }
    if (da > 0.01) {
      c.save();
      c.translate(x, y);
      c.scale(facing, 1);
      c.rotate(tilt);
      BeastPainter.dragon(c, s: _ds, flap: flap, alpha: da, flash: flash, eyeGlow: 1 + _eyeBoost, mouthA: mouthA, mouthB: mouthB, rimDx: facing, time: b.time);
      c.restore();
    }
  }
}
